import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kaufhansel_client/model.dart';
import 'package:localstorage/localstorage.dart';

const _userInfoStorageKey = "userInfo";
const _infoMessageConfirmedStorageKey = "infoMessageConfirmed";
const _lastActiveShoppingListKey = "lastActiveShoppingListId";
const _refreshTokenStorageKey = "refreshToken";

/// Prefixes of the keys under which the offline snapshots of the shopping lists
/// are kept (see `lib/sync/offline_rest_client.dart`).
const _offlineListInfosKey = "offline.listInfos";
const _offlineBaselinePrefix = "offline.baseline.";
const _offlineLocalPrefix = "offline.local.";
const _offlineAliasesPrefix = "offline.aliases.";
const _offlineSeqKey = "offline.seq";

class SettingsStore {
  /// Stores values that must not be readable by anyone but this app
  /// (Android Keystore, iOS/macOS Keychain, libsecret on Linux).
  final _secureStorage = const FlutterSecureStorage();

  Future<void> removeAll() async {
    localStorage.clear();
    await _secureStorage.deleteAll();
  }

  /// The refresh token is required to obtain a new authentication token
  /// once the current one has expired.
  Future<void> saveRefreshToken(String refreshToken) async {
    await _secureStorage.write(key: _refreshTokenStorageKey, value: refreshToken);
  }

  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _refreshTokenStorageKey);
  }

  Future<void> removeRefreshToken() async {
    await _secureStorage.delete(key: _refreshTokenStorageKey);
  }

  Future<ShoppingListUserInfo?> getUserInfo() async {
    final userInfoJson = localStorage.getItem(_userInfoStorageKey);
    if (userInfoJson == null) {
      return null;
    }
    return ShoppingListUserInfo.fromJson(jsonDecode(userInfoJson));
  }

  Future<void> saveUserInfo(ShoppingListUserInfo info) async {
    localStorage.setItem(_userInfoStorageKey, jsonEncode(info));
  }

  Future<void> removeUserInfo() async {
    localStorage.removeItem(_userInfoStorageKey);
  }

  Future<void> confirmInfoMessage(int messageNumber) async {
    localStorage.setItem(_infoMessageConfirmedStorageKey, messageNumber.toString());
  }

  Future<bool> isInfoMessageConfirmed(int messageNumber) async {
    final confirmedMessageNumberStr = localStorage.getItem(_infoMessageConfirmedStorageKey);
    if (confirmedMessageNumberStr == null) {
      return false;
    }
    final confirmedMessageNumber = int.tryParse(confirmedMessageNumberStr);
    if (confirmedMessageNumber == null) {
      return false;
    }
    return confirmedMessageNumber >= messageNumber;
  }

  Future<void> saveActiveShoppingList(ShoppingListInfo shoppingListInfo) async {
    localStorage.setItem(_lastActiveShoppingListKey, jsonEncode(shoppingListInfo));
  }

  Future<void> removeActiveShoppingList() async {
    localStorage.removeItem(_lastActiveShoppingListKey);
  }

  Future<ShoppingListInfo?> getActiveShoppingList() async {
    final lastActiveShoppingList = localStorage.getItem(_lastActiveShoppingListKey);
    if (lastActiveShoppingList == null) {
      return null;
    }
    return ShoppingListInfo.fromJson(jsonDecode(lastActiveShoppingList));
  }

  /// The shopping lists the server returned the last time it could be reached.
  /// Required to show the list overview while there is no connection.
  Future<List<ShoppingListInfo>?> getCachedShoppingListInfos() async {
    final json = localStorage.getItem(_offlineListInfosKey);
    if (json == null) {
      return null;
    }
    final List<dynamic> infos = jsonDecode(json);
    return infos.map((info) => ShoppingListInfo.fromJson(info)).toList();
  }

  Future<void> saveCachedShoppingListInfos(List<ShoppingListInfo> infos) async {
    localStorage.setItem(_offlineListInfosKey, jsonEncode(infos));
  }

  /// The items of the list as the server last returned them. Used as the common
  /// ancestor when local changes are reconciled with the server.
  Future<List<ShoppingListItem>?> getBaselineItems(String listId) async {
    return _getItems(_offlineBaselinePrefix + listId);
  }

  Future<void> saveBaselineItems(String listId, List<ShoppingListItem> items) async {
    localStorage.setItem(_offlineBaselinePrefix + listId, jsonEncode(items));
  }

  /// The items of the list as they are shown to the user right now, including
  /// changes that have not been sent to the server yet.
  Future<List<ShoppingListItem>?> getLocalItems(String listId) async {
    return _getItems(_offlineLocalPrefix + listId);
  }

  Future<void> saveLocalItems(String listId, List<ShoppingListItem> items) async {
    localStorage.setItem(_offlineLocalPrefix + listId, jsonEncode(items));
  }

  Future<List<ShoppingListItem>?> _getItems(String key) async {
    final json = localStorage.getItem(key);
    if (json == null) {
      return null;
    }
    final List<dynamic> items = jsonDecode(json);
    return items.map((item) => ShoppingListItem.fromJson(item)).toList();
  }

  /// Maps the temporary ids of items that were created while there was no
  /// connection to the ids the server assigned them. Written while a
  /// reconciliation is running so that an interrupted reconciliation does not
  /// create the same item twice.
  Future<Map<String, String>> getItemIdAliases(String listId) async {
    final json = localStorage.getItem(_offlineAliasesPrefix + listId);
    if (json == null) {
      return {};
    }
    final Map<String, dynamic> aliases = jsonDecode(json);
    return aliases.map((tempId, realId) => MapEntry(tempId, realId as String));
  }

  Future<void> saveItemIdAliases(String listId, Map<String, String> aliases) async {
    localStorage.setItem(_offlineAliasesPrefix + listId, jsonEncode(aliases));
  }

  Future<void> removeItemIdAliases(String listId) async {
    localStorage.removeItem(_offlineAliasesPrefix + listId);
  }

  /// Counter from which the temporary ids of locally created items are derived.
  /// Persisted so that the ids stay unique across restarts.
  Future<int> getAndIncrementOfflineSequenceNumber() async {
    final current = int.tryParse(localStorage.getItem(_offlineSeqKey) ?? "") ?? 0;
    localStorage.setItem(_offlineSeqKey, (current + 1).toString());
    return current;
  }

  /// Drops the snapshots of all lists the user no longer has access to.
  Future<void> removeSnapshotsExcept(Iterable<String> listIds) async {
    final keep = listIds.toSet();
    const prefixes = [_offlineBaselinePrefix, _offlineLocalPrefix, _offlineAliasesPrefix];
    final keys = [for (var i = 0; i < localStorage.length; i++) localStorage.key(i)].whereType<String>();
    for (final key in keys.toList()) {
      for (final prefix in prefixes) {
        if (key.startsWith(prefix) && !keep.contains(key.substring(prefix.length))) {
          localStorage.removeItem(key);
        }
      }
    }
  }

  Future<void> removeSnapshots(String listId) async {
    localStorage.removeItem(_offlineBaselinePrefix + listId);
    localStorage.removeItem(_offlineLocalPrefix + listId);
    localStorage.removeItem(_offlineAliasesPrefix + listId);
  }
}
