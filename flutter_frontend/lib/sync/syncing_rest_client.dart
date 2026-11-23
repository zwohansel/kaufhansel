import 'dart:async';
import 'dart:math';
import 'dart:developer' as developer;

import 'package:flutter/widgets.dart';

import 'package:kaufhansel_client/model.dart';
import 'package:kaufhansel_client/rest_client.dart';
import 'package:kaufhansel_client/settings/settings_store.dart';
import 'package:kaufhansel_client/sync/connection_status.dart';
import 'package:kaufhansel_client/sync/sync_status.dart';

/// A [RestClient] that keeps working while the device has no connection to the
/// server, and syncs with the server once the connection is back.
///
/// Reads are served from a local copy of the list and changes are applied to
/// that copy instead of being sent to the server.
///
/// Stores:
///   * the *baseline*: the list as the server last returned it,
///   * the *local* copy: the list as the user sees it right now,
///   * and, while a synchronisation is running, the ids the server assigned to
///     items that were created offline.
///
/// Once the server can be reached again only those local changes are pushed that
/// do not conflict with a change somebody else made in the meantime:
/// a property is only written if the server still holds the value it had when
/// the connection was lost.
class SyncingRestClient implements RestClient {
  static const _temporaryIdPrefix = "tmp-";

  /// Ids of items that only exist locally.
  static bool isTemporaryId(String? id) => id != null && id.startsWith(_temporaryIdPrefix);

  final RestClient _delegate;
  final SettingsStore _store;
  final SyncStatus _status;
  final AppLifecycleListener _lifecycleListener;

  /// The list that is currently cached
  String? _currentListId;

  final Map<String, Future<List<ShoppingListItem>>> _runningSynchronisations = {};

  SyncingRestClient(RestClient delegate, this._store, {WidgetsBinding? binding})
      : _delegate = delegate,
        _status = SyncStatus(delegate.connection),
        // The device may well have regained its connection while the app was in
        // the background, where no request could notice it.
        _lifecycleListener = AppLifecycleListener(binding: binding, onResume: delegate.connection.probe);

  /// What the user interface needs to show about the synchronisation.
  SyncStatus get status => _status;

  ConnectionStatus get _connection => _delegate.connection;

  bool get _online => _connection.online;

  /// True if the list holds local changes that have not reached the server yet.
  Future<bool> isDiverged(String listId) async => await pendingChangeCount(listId) > 0;

  /// How many items of the list have been added, changed or removed without the
  /// server knowing about it. Shown to the user while there is no connection.
  ///
  /// Ordering changes are ignored.
  Future<int> pendingChangeCount(String listId) async {
    final baseline = await _store.getBaselineItems(listId);
    final local = await _store.getLocalItems(listId);
    if (baseline == null || local == null) {
      return 0;
    }
    final baselineById = _byId(baseline);
    final localById = _byId(local);

    var changes = 0;
    localById.forEach((id, item) {
      final baselineItem = baselineById[id];
      if (baselineItem == null || baselineItem != item) {
        changes++;
      }
    });
    for (final id in baselineById.keys) {
      if (!localById.containsKey(id)) {
        changes++;
      }
    }
    return changes;
  }

  /// True if the change must not be sent to the server: either because there is
  /// no connection, or because the list still holds changes the server has not
  /// been told about yet. It then lands in the local copy only, which leaves it
  /// behind the baseline and therefore counted as a change the next
  /// synchronisation has to push.
  ///
  /// Holding a change back although the server could be reached looks needless,
  /// but until the list has been synchronised the server's picture of it is out
  /// of date, and sending the change against that picture breaks:
  ///   * An item that was created offline only exists here, so a change to it
  ///     would address it by its temporary id, which the server has never
  ///     issued.
  ///   * The update endpoint writes the whole item, so a change sent now would
  ///     overwrite whatever somebody else did in the meantime instead of going
  ///     through the property by property merge a synchronisation does.
  ///
  /// Being online is not enough to rule that out: a synchronisation can fail
  /// halfway through, or be aborted by an expired session, which leaves the list
  /// diverged with a connection at hand.
  Future<bool> _keepLocally(String listId) async => !_online || await isDiverged(listId);

  Map<String, ShoppingListItem> _byId(List<ShoppingListItem> items) {
    return {
      for (final item in items)
        if (item.id != null) item.id!: item
    };
  }

  // --------------------------------------------------------------- reading

  @override
  Future<List<ShoppingListInfo>> getShoppingLists() async {
    if (!_online) {
      return _cachedShoppingListInfos();
    }
    try {
      final infos = await _delegate.getShoppingLists();
      await _store.saveCachedShoppingListInfos(infos);
      final ids = infos.map((info) => info.id).toList();
      await _store.removeSnapshotsExcept(ids);
      if (_currentListId != null && !ids.contains(_currentListId)) {
        _currentListId = null;
        _status.setPendingChanges(0);
      }
      return infos;
    } on NoConnectionException {
      return _cachedShoppingListInfos();
    }
  }

  Future<List<ShoppingListInfo>> _cachedShoppingListInfos() async {
    final cached = await _store.getCachedShoppingListInfos();
    if (cached == null) {
      // Never been online with this account: there is nothing we could show.
      throw NoConnectionException("no shopping lists have been cached yet");
    }
    return cached;
  }

  @override
  Future<List<ShoppingListItem>> fetchShoppingList(String shoppingListId) async {
    // Reading a list is what makes it the one the app is showing, and therefore
    // the one [status] reports about.
    _currentListId = shoppingListId;
    if (!_online) {
      return _localItems(shoppingListId);
    }
    try {
      return await synchronize(shoppingListId);
    } on NoConnectionException {
      return _localItems(shoppingListId);
    }
  }

  Future<List<ShoppingListItem>> _localItems(String listId) async {
    final local = await _store.getLocalItems(listId);
    if (local == null) {
      throw NoConnectionException("list $listId has not been cached yet");
    }
    await _publishPendingChanges(listId);
    return local;
  }

  // --------------------------------------------------------- synchronising

  /// Pushes the local changes of the list to the server and returns the
  /// resulting list. Concurrent calls for the same list share one run.
  Future<List<ShoppingListItem>> synchronize(String listId) {
    final running = _runningSynchronisations[listId];
    if (running != null) {
      return running;
    }
    final run = _synchronize(listId);
    _runningSynchronisations[listId] = run;
    return run.whenComplete(() => _runningSynchronisations.remove(listId));
  }

  Future<List<ShoppingListItem>> _synchronize(String listId) async {
    final baseline = await _store.getBaselineItems(listId);
    final local = await _store.getLocalItems(listId);

    if (baseline == null || local == null || await pendingChangeCount(listId) == 0) {
      return _fetchAndStore(listId);
    }

    final server = await _delegate.fetchShoppingList(listId);
    final serverById = _byId(server);
    final baselineById = _byId(baseline);
    final localById = _byId(local);

    await _createLocallyAddedItems(listId, local);
    await _deleteLocallyRemovedItems(listId, baseline, localById, serverById);
    await _pushChangedProperties(listId, local, baselineById, serverById);

    // Only drop the aliases once the refresh below succeeded. They are what
    // keeps an interrupted run from creating the same item a second time, so
    // they have to outlive every step that can still fail.
    final items = await _fetchAndStore(listId);
    await _store.removeItemIdAliases(listId);
    return items;
  }

  Future<void> _createLocallyAddedItems(String listId, List<ShoppingListItem> local) async {
    final aliases = await _store.getItemIdAliases(listId);

    for (final item in local) {
      final temporaryId = item.id;
      if (!isTemporaryId(temporaryId)) {
        continue;
      }

      // A previous run may have been interrupted after the item was created but
      // before the local copy was refreshed. Without the stored alias the item
      // would be created a second time.
      var serverId = aliases[temporaryId];
      if (serverId == null) {
        try {
          serverId = (await _delegate.createShoppingListItem(listId, item.name, item.category)).id;
        } on HttpResponseException catch (e) {
          if (e.isUnauthenticated()) {
            rethrow;
          }
          developer.log("The server rejected an item that was created offline.", error: e);
          continue;
        }
        if (serverId == null) {
          continue;
        }
        aliases[temporaryId!] = serverId;
        await _store.saveItemIdAliases(listId, aliases);
      }

      if (item.checked) {
        // Items cannot be created in the checked state.
        final checkedItem = ShoppingListItem(serverId, item.name, true, item.category);
        await _push(() => _delegate.updateShoppingListItem(listId, checkedItem));
      }
    }
  }

  Future<void> _deleteLocallyRemovedItems(String listId, List<ShoppingListItem> baseline,
      Map<String, ShoppingListItem> localById, Map<String, ShoppingListItem> serverById) async {
    for (final baselineItem in baseline) {
      final id = baselineItem.id;
      if (id == null || localById.containsKey(id)) {
        continue;
      }
      final serverItem = serverById[id];
      if (serverItem == null) {
        // Already gone on the server as well.
        continue;
      }
      if (serverItem != baselineItem) {
        // Somebody else changed the item after we lost the connection. Deleting
        // it now would throw their change away, so the item stays.
        continue;
      }
      await _push(() => _delegate.deleteShoppingListItem(listId, serverItem));
    }
  }

  Future<void> _pushChangedProperties(String listId, List<ShoppingListItem> local,
      Map<String, ShoppingListItem> baselineById, Map<String, ShoppingListItem> serverById) async {
    for (final localItem in local) {
      final id = localItem.id;
      if (id == null || isTemporaryId(id)) {
        continue;
      }
      final baselineItem = baselineById[id];
      final serverItem = serverById[id];
      if (baselineItem == null || serverItem == null) {
        // Unknown to us, or deleted by somebody else: the server wins.
        continue;
      }

      // Start from the server state and overlay only those properties that were
      // changed locally and are untouched on the server. The update endpoint
      // writes the whole item, so everything we do not overlay has to be the
      // value the server currently holds.
      final merged = serverItem.copy();
      var changed = false;
      if (localItem.name != baselineItem.name && serverItem.name == baselineItem.name) {
        merged.name = localItem.name;
        changed = true;
      }
      if (localItem.checked != baselineItem.checked && serverItem.checked == baselineItem.checked) {
        merged.checked = localItem.checked;
        changed = true;
      }
      if (localItem.category != baselineItem.category && serverItem.category == baselineItem.category) {
        merged.category = localItem.category;
        changed = true;
      }

      if (changed) {
        await _push(() => _delegate.updateShoppingListItem(listId, merged));
      }
    }
  }

  /// Sends one request of a synchronisation run.
  ///
  /// A rejected request is skipped: the server state wins and the refresh at the
  /// end of the run shows the user what actually happened. A single bad change
  /// must never keep the rest of the list from being synchronised.
  ///
  /// An expired session is the exception. It makes the app log out, which wipes
  /// the local copy, so the run is aborted before the snapshots are touched and
  /// the changes survive if the user logs in again.
  Future<void> _push(Future<void> Function() request) async {
    try {
      await request();
    } on HttpResponseException catch (e) {
      if (e.isUnauthenticated()) {
        rethrow;
      }
      developer.log("The server rejected a change that was made offline.", error: e);
    }
  }

  Future<List<ShoppingListItem>> _fetchAndStore(String listId) async {
    final items = await _delegate.fetchShoppingList(listId);
    await _store.saveBaselineItems(listId, items);
    await _store.saveLocalItems(listId, items);
    if (listId == _currentListId) {
      _status.setPendingChanges(0);
    }
    return items;
  }

  // ------------------------------------------------------- the local copy

  /// Applies a change the server has accepted to both snapshots.
  ///
  /// The local copy has to move with the server, or the next read without a
  /// connection would serve a state the user has already changed. The baseline
  /// has to move with it, or the change would look like a local one and be
  /// pushed again on the next synchronisation.
  Future<void> _applyToSnapshots(String listId, void Function(List<ShoppingListItem> items) change) async {
    final baseline = await _store.getBaselineItems(listId);
    if (baseline != null) {
      change(baseline);
      await _store.saveBaselineItems(listId, baseline);
    }
    await _applyToLocalCopy(listId, change);
  }

  /// Applies a change that was not sent to the server to the local copy, so
  /// that it keeps showing what the user sees.
  ///
  /// Every change the app can make arrives here as the call that would have
  /// gone to the server, and those calls carry everything needed to reproduce
  /// the change, so the local copy never has to be read back out of the model.
  Future<void> _applyToLocalCopy(String listId, void Function(List<ShoppingListItem> items) change) async {
    final local = await _store.getLocalItems(listId);
    if (local == null) {
      // The list has never been read, so there is no local copy to change.
      return;
    }
    change(local);
    await _store.saveLocalItems(listId, local);
    await _publishPendingChanges(listId);
  }

  /// Keeps a change from racing a synchronisation of the same list.
  ///
  /// A run ends by replacing the local copy with the state the server reports,
  /// which would silently drop a change that was applied to the local copy
  /// while the run was pushing the other ones. Waiting also means the change is
  /// made against the state the run established: usually the list is no longer
  /// diverged afterwards, so the change simply goes to the server.
  Future<void> _awaitRunningSynchronisation(String listId) async {
    try {
      await _runningSynchronisations[listId];
    } on Object catch (e) {
      // Whoever started the run reports its failure; the change must not fail
      // because of it. If the connection is still gone the change is kept
      // locally as usual.
      developer.log("A change waited for a synchronisation that failed.", error: e);
    }
  }

  Future<void> _publishPendingChanges(String listId) async {
    if (listId == _currentListId) {
      _status.setPendingChanges(await pendingChangeCount(listId));
    }
  }

  void dispose() {
    _lifecycleListener.dispose();
    _status.dispose();
  }

  // -------------------------------------------------------------- changing

  @override
  Future<ShoppingListItem> createShoppingListItem(String shoppingListId, String name, String? category) async {
    await _awaitRunningSynchronisation(shoppingListId);
    if (await _keepLocally(shoppingListId)) {
      return _createLocalItem(shoppingListId, name, category);
    }
    try {
      final created = await _delegate.createShoppingListItem(shoppingListId, name, category);
      // A copy per snapshot, so that neither of them holds the object the model
      // gets.
      await _applyToSnapshots(shoppingListId, (items) => items.add(created.copy()));
      return created;
    } on NoConnectionException {
      return _createLocalItem(shoppingListId, name, category);
    }
  }

  Future<ShoppingListItem> _createLocalItem(String listId, String name, String? category) async {
    final sequenceNumber = await _store.getAndIncrementOfflineSequenceNumber();
    final item = ShoppingListItem("$_temporaryIdPrefix$sequenceNumber", name, false, category);
    // A copy, so that the local copy never holds the object the model gets.
    await _applyToLocalCopy(listId, (items) => items.add(item.copy()));
    return item;
  }

  @override
  Future<void> updateShoppingListItem(String shoppingListId, ShoppingListItem item) async {
    // The update endpoint writes the whole item, so the given one is the state
    // the item is supposed to have.
    final name = item.name;
    final checked = item.checked;
    final category = item.category;
    return _change(shoppingListId, () => _delegate.updateShoppingListItem(shoppingListId, item), (items) {
      for (final stored in items.where((stored) => stored.id == item.id)) {
        stored.name = name;
        stored.checked = checked;
        stored.category = category;
      }
    });
  }

  @override
  Future<void> deleteShoppingListItem(String shoppingListId, ShoppingListItem item) async {
    return _change(shoppingListId, () => _delegate.deleteShoppingListItem(shoppingListId, item),
        (items) => items.removeWhere((stored) => stored.id == item.id));
  }

  @override
  Future<void> uncheckItems(String shoppingListId, {String? ofCategory}) async {
    return _change(shoppingListId, () => _delegate.uncheckItems(shoppingListId, ofCategory: ofCategory),
        (items) => _matching(items, ofCategory).forEach((item) => item.checked = false));
  }

  @override
  Future<void> removeCategory(String shoppingListId, {String? category}) async {
    return _change(shoppingListId, () => _delegate.removeCategory(shoppingListId, category: category),
        (items) => _matching(items, category).forEach((item) => item.category = null));
  }

  /// The items of the given category, or all of them if no category is given:
  /// that is what the server does for a missing category as well.
  Iterable<ShoppingListItem> _matching(List<ShoppingListItem> items, String? category) {
    return items.where((item) => category == null || item.category == category);
  }

  @override
  Future<void> renameCategory(String shoppingListId, String oldCategoryName, String newCategoryName) async {
    return _change(
        shoppingListId,
        () => _delegate.renameCategory(shoppingListId, oldCategoryName, newCategoryName),
        (items) => items
            .where((item) => item.category == oldCategoryName)
            .forEach((item) => item.category = newCategoryName));
  }

  @override
  Future<void> removeAllItems(String shoppingListId) async {
    return _change(
        shoppingListId, () => _delegate.removeAllItems(shoppingListId), (items) => items.clear());
  }

  /// Applies the change to the local copy and, if the server can be told about
  /// it right now, sends it and moves the baseline along. Reports success either
  /// way: the caller then applies the change to the in-memory model, which is
  /// what the user sees.
  ///
  /// A change the server *rejects* is not applied to either snapshot: the
  /// request throws before anything is written, so a rejected change can never
  /// stay behind and be pushed again later.
  Future<void> _change(String listId, Future<void> Function() request,
      void Function(List<ShoppingListItem> items) applyChange) async {
    await _awaitRunningSynchronisation(listId);
    if (!await _keepLocally(listId)) {
      try {
        await request();
        // The server has it, so the baseline moves with the local copy and
        // there is nothing left to push.
        return await _applyToSnapshots(listId, applyChange);
      } on NoConnectionException {
        // The connection was lost between the check above and the request, so
        // the change is kept locally after all.
      }
    }
    // Only the local copy knows about the change: it stays behind the baseline
    // and is pushed by the next synchronisation.
    return _applyToLocalCopy(listId, applyChange);
  }

  @override
  Future<void> moveShoppingListItem(String shoppingListId, ShoppingListItem item, int targetIndex) async {
    if (await _keepLocally(shoppingListId)) {
      // Moving is the one change that is not kept locally. The position of an
      // item is not part of the item API, so after the fact there is no way to
      // tell an item the user moved from one the server moved, and guessing
      // would scramble a list that other people use as well.
      throw NoConnectionException("items cannot be moved while there are unsynchronised changes");
    }
    await _delegate.moveShoppingListItem(shoppingListId, item, targetIndex);
    // The order is not part of what is compared against the baseline, but the
    // local copy is read back as the list the user sees, so it has to be in the
    // order the server now holds.
    await _applyToSnapshots(shoppingListId, (items) => _move(items, item.id, targetIndex));
  }

  void _move(List<ShoppingListItem> items, String? id, int targetIndex) {
    final current = items.indexWhere((stored) => stored.id == id);
    if (current < 0) {
      return;
    }
    final moved = items.removeAt(current);
    items.insert(min(targetIndex, items.length), moved);
  }

  @override
  Future<void> deleteShoppingList(String shoppingListId) async {
    await _delegate.deleteShoppingList(shoppingListId);
    await _store.removeSnapshots(shoppingListId);
    if (shoppingListId == _currentListId) {
      _currentListId = null;
      _status.setPendingChanges(0);
    }
  }

  // ------------------------------------------------- plain delegation only

  @override
  set onUnauthenticated(VoidCallback onUnauthenticated) => _delegate.onUnauthenticated = onUnauthenticated;

  @override
  set onTokenExpired(TokenRefresh onTokenExpired) => _delegate.onTokenExpired = onTokenExpired;

  @override
  ConnectionStatus get connection => _delegate.connection;

  @override
  void setAuthenticationToken(String token, DateTime expiresAt) =>
      _delegate.setAuthenticationToken(token, expiresAt);

  @override
  void logOut() {
    _currentListId = null;
    _status.setPendingChanges(0);
    _delegate.logOut();
  }

  @override
  Future<LoginResult?> login(String userEmail, String password) => _delegate.login(userEmail, password);

  @override
  Future<ShoppingListUserInfo?> refreshAuthenticationToken(String refreshToken) =>
      _delegate.refreshAuthenticationToken(refreshToken);

  @override
  Future<void> revokeRefreshToken(String refreshToken) => _delegate.revokeRefreshToken(refreshToken);

  @override
  Future<ShoppingListInfo> createShoppingList(String shoppingListName) =>
      _delegate.createShoppingList(shoppingListName);

  @override
  Future<ShoppingListUserReference?> addUserToShoppingList(String shoppingListId, String userEmailAddress) =>
      _delegate.addUserToShoppingList(shoppingListId, userEmailAddress);

  @override
  Future<void> removeUserFromShoppingList(String shoppingListId, String userId) =>
      _delegate.removeUserFromShoppingList(shoppingListId, userId);

  @override
  Future<ShoppingListUserReference> changeShoppingListPermissions(
          String shoppingListId, String affectedUserId, ShoppingListRole newRole) =>
      _delegate.changeShoppingListPermissions(shoppingListId, affectedUserId, newRole);

  @override
  Future<void> changeShoppingListName(String shoppingListId, String newName) =>
      _delegate.changeShoppingListName(shoppingListId, newName);

  @override
  Future<RegistrationResult> register(String userName, String password, String? inviteCode,
          {String? emailAddress}) =>
      _delegate.register(userName, password, inviteCode, emailAddress: emailAddress);

  @override
  Future<void> sendInvite(String emailAddress, {String? shoppingListId}) =>
      _delegate.sendInvite(emailAddress, shoppingListId: shoppingListId);

  @override
  Future<BackendInfo> getBackendInfo() => _delegate.getBackendInfo();

  @override
  Future<void> requestPasswordReset(String emailAddress) => _delegate.requestPasswordReset(emailAddress);

  @override
  Future<void> resetPassword(String emailAddress, String resetCode, String password) =>
      _delegate.resetPassword(emailAddress, resetCode, password);

  @override
  Future<void> deleteAccount(String userId) => _delegate.deleteAccount(userId);
}
