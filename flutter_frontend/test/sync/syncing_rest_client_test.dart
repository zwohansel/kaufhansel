import 'package:flutter_test/flutter_test.dart';
import 'package:kaufhansel_client/model.dart';
import 'package:kaufhansel_client/rest_client.dart';
import 'package:kaufhansel_client/settings/settings_store.dart';
import 'package:kaufhansel_client/sync/syncing_rest_client.dart';

import '../fake_backend.dart';
import '../rest_client_stub.dart';
import '../settings_store_stub.dart';

const listId = "7";

/// Wires a [FakeBackend] to a [RestClientStub] and puts an [SyncingRestClient]
/// in front of it, so that a test can flip the connection and inspect both the
/// resulting server state and the requests that were actually sent.
class Fixture {
  final FakeBackend backend = FakeBackend();
  final List<ShoppingListInfo> infos = [];
  late final RestClientStub stub;
  late final SettingsStore store;
  late final SyncingRestClient client;

  Fixture() {
    backend.setItems(listId, []);
    infos.add(makeInfo(listId));
    stub = RestClientStub(
      onGetShoppingLists: () => List.of(infos),
      onFetchShoppingList: (id) => backend.fetch(id),
      onCreateShoppingListItem: (id, name, category) => backend.create(id, name, category),
      onUpdateShoppingListItem: (id, item) => backend.update(id, item),
      onDeleteShoppingListItem: (id, item) => backend.delete(id, item),
      onMoveShoppingListItem: (id, item, index) => backend.move(id, item, index),
      onUncheckItems: (id, category) => backend.uncheckItems(id, category),
      onRenameCategory: (id, from, to) => backend.renameCategory(id, from, to),
      onRemoveCategory: (id, category) => backend.removeCategory(id, category),
      onRemoveAllItems: (id) => backend.clear(id),
    );
    store = SettingsStoreStub();
    client = SyncingRestClient(stub, store);
  }

  /// Simulates losing the connection. The stub also puts its connection status
  /// into the state a real failed request would have left it in, so that no
  /// request is attempted at all.
  void goOffline() => stub.offline = true;

  void goOnline() => stub.offline = false;

  /// Puts the local copy into the given state.
  ///
  /// The reconciliation tests care about that state, not about which calls
  /// produced it; the "changing while offline" group covers that the client's
  /// own methods produce it.
  Future<void> applyLocally(List<ShoppingListItem> items) => store.saveLocalItems(listId, items);

  Future<List<ShoppingListItem>> localCopy() async => (await store.getLocalItems(listId))!;

  List<String> get calls => stub.callLog;
}

ShoppingListInfo makeInfo(String id) => ShoppingListInfo(
    id, "Liste $id", ShoppingListPermissions(ShoppingListRole.ADMIN, true, true, true), []);

ShoppingListItem? itemNamed(List<ShoppingListItem> items, String name) =>
    items.where((item) => item.name == name).firstOrNull;

void main() {
  // SyncingRestClient observes the app lifecycle, which needs a binding.
  TestWidgetsFlutterBinding.ensureInitialized();

  group("reading while offline", () {
    test("serves the items from the local copy", () async {
      final fixture = Fixture();
      fixture.backend.setItems(listId, [ShoppingListItem("1", "Milch", false, "Kühlregal")]);
      await fixture.client.fetchShoppingList(listId);

      fixture.goOffline();
      final items = await fixture.client.fetchShoppingList(listId);

      expect(items.map((item) => item.name), ["Milch"]);
    });

    test("serves the shopping list infos from the cache", () async {
      final fixture = Fixture();
      await fixture.client.getShoppingLists();

      fixture.goOffline();
      final infos = await fixture.client.getShoppingLists();

      expect(infos.map((info) => info.id), [listId]);
    });

    test("fails if the list has never been fetched", () async {
      final fixture = Fixture();
      fixture.goOffline();

      expect(() => fixture.client.fetchShoppingList(listId), throwsA(isA<NoConnectionException>()));
      expect(() => fixture.client.getShoppingLists(), throwsA(isA<NoConnectionException>()));
    });

    test("forgets the snapshots of lists the user lost access to", () async {
      final fixture = Fixture();
      fixture.backend.setItems(listId, [ShoppingListItem("1", "Milch", false, null)]);
      await fixture.client.fetchShoppingList(listId);
      expect(await fixture.store.getBaselineItems(listId), isNotNull);

      // The list is no longer shared with this user.
      fixture.infos.clear();
      await fixture.client.getShoppingLists();

      expect(await fixture.store.getBaselineItems(listId), isNull);
      expect(await fixture.store.getLocalItems(listId), isNull);
    });
  });

  group("changing while offline", () {
    test("creates items with a non numeric temporary id", () async {
      final fixture = Fixture();
      await fixture.client.fetchShoppingList(listId);
      fixture.goOffline();

      final created = await fixture.client.createShoppingListItem(listId, "Milch", "Kühlregal");

      expect(SyncingRestClient.isTemporaryId(created.id), isTrue);
      expect(int.tryParse(created.id!), isNull, reason: "the server declares item ids as long");
      expect(created.name, "Milch");
      expect(created.category, "Kühlregal");
      expect(fixture.calls, isNot(contains(startsWith("createItem"))));
    });

    test("hands out a different temporary id every time", () async {
      final fixture = Fixture();
      await fixture.client.fetchShoppingList(listId);
      fixture.goOffline();

      final first = await fixture.client.createShoppingListItem(listId, "Milch", null);
      final second = await fixture.client.createShoppingListItem(listId, "Brot", null);

      expect(first.id, isNot(second.id));
    });

    test("reports success for changes without sending them", () async {
      final fixture = Fixture();
      fixture.backend.setItems(listId, [ShoppingListItem("1", "Milch", false, null)]);
      final items = await fixture.client.fetchShoppingList(listId);
      fixture.goOffline();
      fixture.calls.clear();

      await fixture.client.updateShoppingListItem(listId, items.first);
      await fixture.client.deleteShoppingListItem(listId, items.first);
      await fixture.client.uncheckItems(listId);
      await fixture.client.renameCategory(listId, "Obst", "Gemüse");
      await fixture.client.removeCategory(listId);
      await fixture.client.removeAllItems(listId);

      expect(fixture.calls, isEmpty);
      expect(fixture.backend.fetch(listId).first.name, "Milch", reason: "the server must be untouched");
    });

    test("applies every change to the local copy", () async {
      final fixture = Fixture();
      fixture.backend.setItems(listId, [
        ShoppingListItem("1", "Apfel", false, "Obst"),
        ShoppingListItem("2", "Birne", true, "Obst"),
        ShoppingListItem("3", "Milch", false, "Kühlregal"),
      ]);
      final items = await fixture.client.fetchShoppingList(listId);
      fixture.goOffline();
      fixture.calls.clear();

      // check
      final milch = itemNamed(items, "Milch")!;
      milch.checked = true;
      await fixture.client.updateShoppingListItem(listId, milch);
      expect(itemNamed(await fixture.localCopy(), "Milch")!.checked, isTrue);

      // rename and recategorise
      final apfel = itemNamed(items, "Apfel")!..name = "Granatapfel";
      apfel.category = "Exotisch";
      await fixture.client.updateShoppingListItem(listId, apfel);
      final renamed = itemNamed(await fixture.localCopy(), "Granatapfel")!;
      expect(renamed.category, "Exotisch");

      // add
      final created = await fixture.client.createShoppingListItem(listId, "Käse", "Kühlregal");
      expect(itemNamed(await fixture.localCopy(), "Käse")?.id, created.id);

      // uncheck a category
      await fixture.client.uncheckItems(listId, ofCategory: "Kühlregal");
      final afterUncheck = await fixture.localCopy();
      expect(itemNamed(afterUncheck, "Milch")!.checked, isFalse);
      expect(itemNamed(afterUncheck, "Birne")!.checked, isTrue, reason: "other category");

      // rename a category
      await fixture.client.renameCategory(listId, "Obst", "Gemüse");
      expect(itemNamed(await fixture.localCopy(), "Birne")!.category, "Gemüse");

      // remove a category
      await fixture.client.removeCategory(listId, category: "Gemüse");
      expect(itemNamed(await fixture.localCopy(), "Birne")!.category, isNull);

      // delete
      await fixture.client.deleteShoppingListItem(listId, milch);
      expect(itemNamed(await fixture.localCopy(), "Milch"), isNull);

      // remove every category
      await fixture.client.removeCategory(listId);
      expect((await fixture.localCopy()).where((item) => item.category != null), isEmpty);

      // clear
      await fixture.client.removeAllItems(listId);
      expect(await fixture.localCopy(), isEmpty);

      expect(fixture.calls, isEmpty, reason: "nothing may have been sent");
    });

    test("the local copy survives without waiting for anything", () async {
      final fixture = Fixture();
      fixture.backend.setItems(listId, [ShoppingListItem("1", "Milch", false, null)]);
      final items = await fixture.client.fetchShoppingList(listId);
      fixture.goOffline();

      items.single.checked = true;
      await fixture.client.updateShoppingListItem(listId, items.single);

      // No debounce to wait out: the change is in the store right away.
      expect((await fixture.localCopy()).single.checked, isTrue);
      expect(fixture.client.status.numPendingChanges, 1);
    });

    test("refuses to move items", () async {
      final fixture = Fixture();
      fixture.backend.setItems(listId, [ShoppingListItem("1", "Milch", false, null)]);
      final items = await fixture.client.fetchShoppingList(listId);
      fixture.goOffline();

      expect(() => fixture.client.moveShoppingListItem(listId, items.first, 0),
          throwsA(isA<NoConnectionException>()));
    });

    test("keeps a change that races a connection loss", () async {
      final fixture = Fixture();
      fixture.backend.setItems(listId, [ShoppingListItem("1", "Milch", false, null)]);
      final items = await fixture.client.fetchShoppingList(listId);

      // The connection dies without the app noticing yet, so the request is
      // attempted and fails.
      fixture.stub.loseConnectionUnnoticed();
      items.first.name = "Vollmilch";
      await fixture.client.updateShoppingListItem(listId, items.first);

      expect(fixture.stub.connection.online, isFalse);
      expect(await fixture.client.isDiverged(listId), isTrue);
    });
  });

  group("changing while online", () {
    test("keeps the local copy up to date so that it is never stale", () async {
      final fixture = Fixture();
      fixture.backend.setItems(listId, [ShoppingListItem("1", "Milch", false, "Kühlregal")]);
      final items = await fixture.client.fetchShoppingList(listId);

      items.first.name = "Vollmilch";
      await fixture.client.updateShoppingListItem(listId, items.first);

      // Reading without a connection must not undo what the user just did.
      fixture.goOffline();
      final offline = await fixture.client.fetchShoppingList(listId);

      expect(offline.map((item) => item.name), ["Vollmilch"]);
      // The server knows about the change, so there is nothing to push.
      expect(await fixture.client.pendingChangeCount(listId), 0);
    });

    test("puts a created item into the local copy", () async {
      final fixture = Fixture();
      await fixture.client.fetchShoppingList(listId);

      await fixture.client.createShoppingListItem(listId, "Milch", "Kühlregal");

      fixture.goOffline();
      final offline = await fixture.client.fetchShoppingList(listId);

      expect(offline.map((item) => item.name), ["Milch"]);
      expect(await fixture.client.pendingChangeCount(listId), 0);
    });

    test("puts a removed item out of the local copy", () async {
      final fixture = Fixture();
      fixture.backend.setItems(
          listId, [ShoppingListItem("1", "Milch", false, null), ShoppingListItem("2", "Brot", false, null)]);
      final items = await fixture.client.fetchShoppingList(listId);

      await fixture.client.deleteShoppingListItem(listId, items.first);

      fixture.goOffline();
      final offline = await fixture.client.fetchShoppingList(listId);

      expect(offline.map((item) => item.name), ["Brot"]);
      expect(await fixture.client.pendingChangeCount(listId), 0);
    });

    test("keeps the local copy in the order the server now holds", () async {
      final fixture = Fixture();
      fixture.backend.setItems(
          listId, [ShoppingListItem("1", "Milch", false, null), ShoppingListItem("2", "Brot", false, null)]);
      final items = await fixture.client.fetchShoppingList(listId);

      await fixture.client.moveShoppingListItem(listId, items.last, 0);

      fixture.goOffline();
      final offline = await fixture.client.fetchShoppingList(listId);

      expect(offline.map((item) => item.name), fixture.backend.fetch(listId).map((item) => item.name));
      expect(offline.map((item) => item.name), ["Brot", "Milch"]);
    });

    test("keeps a change local while earlier changes are still waiting", () async {
      final fixture = Fixture();
      await fixture.client.fetchShoppingList(listId);

      // An item that only exists locally: its id is not one the server knows.
      fixture.goOffline();
      final created = await fixture.client.createShoppingListItem(listId, "Milch", null);
      fixture.goOnline();
      fixture.calls.clear();

      // The connection is back but nothing has been synchronised yet, so this
      // must not be sent: it would address the item by its temporary id.
      await fixture.client.updateShoppingListItem(listId, ShoppingListItem(created.id, "Vollmilch", false, null));

      expect(fixture.calls, isEmpty);
      expect(itemNamed(await fixture.localCopy(), "Vollmilch")!.id, created.id);
    });
  });

  group("synchronising", () {
    test("pushes a locally created item and never sends a temporary id", () async {
      final fixture = Fixture();
      await fixture.client.fetchShoppingList(listId);
      fixture.goOffline();

      final created = await fixture.client.createShoppingListItem(listId, "Milch", "Kühlregal");
      await fixture.applyLocally([created]);

      fixture.goOnline();
      final synced = await fixture.client.fetchShoppingList(listId);

      expect(synced.map((item) => item.name), ["Milch"]);
      expect(synced.first.category, "Kühlregal");
      expect(int.tryParse(synced.first.id!), isNotNull, reason: "the server assigns the id");
      expect(fixture.calls.where((call) => call.contains("tmp-")), isEmpty);
    });

    test("pushes a locally created item that was checked right away", () async {
      final fixture = Fixture();
      await fixture.client.fetchShoppingList(listId);
      fixture.goOffline();

      final created = await fixture.client.createShoppingListItem(listId, "Milch", null);
      created.checked = true;
      await fixture.applyLocally([created]);

      fixture.goOnline();
      final synced = await fixture.client.fetchShoppingList(listId);

      expect(synced.single.checked, isTrue);
    });

    test("pushes a property that only changed locally", () async {
      final fixture = Fixture();
      fixture.backend.setItems(listId, [ShoppingListItem("1", "Milch", false, "Kühlregal")]);
      final items = await fixture.client.fetchShoppingList(listId);
      fixture.goOffline();

      items.single.name = "Vollmilch";
      items.single.checked = true;
      await fixture.applyLocally(items);

      fixture.goOnline();
      final synced = await fixture.client.fetchShoppingList(listId);

      expect(synced.single.name, "Vollmilch");
      expect(synced.single.checked, isTrue);
      expect(synced.single.category, "Kühlregal");
    });

    test("keeps the remote value if the same property changed on both sides", () async {
      final fixture = Fixture();
      fixture.backend.setItems(listId, [ShoppingListItem("1", "Milch", false, null)]);
      final items = await fixture.client.fetchShoppingList(listId);
      fixture.goOffline();

      items.single.name = "Vollmilch";
      await fixture.applyLocally(items);

      // Somebody else renames the same item in the meantime.
      fixture.backend.update(listId, ShoppingListItem("1", "Buttermilch", false, null));

      fixture.goOnline();
      final synced = await fixture.client.fetchShoppingList(listId);

      expect(synced.single.name, "Buttermilch");
    });

    test("pushes a property the other side did not touch", () async {
      final fixture = Fixture();
      fixture.backend.setItems(listId, [ShoppingListItem("1", "Milch", false, null)]);
      final items = await fixture.client.fetchShoppingList(listId);
      fixture.goOffline();

      items.single.checked = true;
      await fixture.applyLocally(items);

      // The other side changes a different property of the same item.
      fixture.backend.update(listId, ShoppingListItem("1", "Milch", false, "Kühlregal"));

      fixture.goOnline();
      final synced = await fixture.client.fetchShoppingList(listId);

      expect(synced.single.checked, isTrue, reason: "our change must survive");
      expect(synced.single.category, "Kühlregal", reason: "their change must survive");
    });

    test("deletes an item that nobody else touched", () async {
      final fixture = Fixture();
      fixture.backend
          .setItems(listId, [ShoppingListItem("1", "Milch", false, null), ShoppingListItem("2", "Brot", false, null)]);
      final items = await fixture.client.fetchShoppingList(listId);
      fixture.goOffline();

      await fixture.applyLocally(items.where((item) => item.name != "Milch").toList());

      fixture.goOnline();
      final synced = await fixture.client.fetchShoppingList(listId);

      expect(synced.map((item) => item.name), ["Brot"]);
    });

    test("keeps an item that somebody else changed instead of deleting it", () async {
      final fixture = Fixture();
      fixture.backend.setItems(listId, [ShoppingListItem("1", "Milch", false, null)]);
      await fixture.client.fetchShoppingList(listId);
      fixture.goOffline();

      await fixture.applyLocally([]);
      fixture.backend.update(listId, ShoppingListItem("1", "Milch", true, null));

      fixture.goOnline();
      final synced = await fixture.client.fetchShoppingList(listId);

      expect(synced.map((item) => item.name), ["Milch"]);
      expect(synced.single.checked, isTrue);
    });

    test("skips a local change to an item somebody else deleted", () async {
      final fixture = Fixture();
      fixture.backend.setItems(listId, [ShoppingListItem("1", "Milch", false, null)]);
      final items = await fixture.client.fetchShoppingList(listId);
      fixture.goOffline();

      items.single.checked = true;
      await fixture.applyLocally(items);
      fixture.backend.delete(listId, ShoppingListItem("1", "Milch", false, null));

      fixture.goOnline();
      final synced = await fixture.client.fetchShoppingList(listId);

      expect(synced, isEmpty);
    });

    test("turns an offline category rename into per item updates", () async {
      final fixture = Fixture();
      fixture.backend.setItems(listId,
          [ShoppingListItem("1", "Apfel", false, "Obst"), ShoppingListItem("2", "Milch", false, "Kühlregal")]);
      final items = await fixture.client.fetchShoppingList(listId);
      fixture.goOffline();

      await fixture.client.renameCategory(listId, "Obst", "Gemüse");
      itemNamed(items, "Apfel")!.category = "Gemüse";
      await fixture.applyLocally(items);

      fixture.goOnline();
      final synced = await fixture.client.fetchShoppingList(listId);

      expect(itemNamed(synced, "Apfel")!.category, "Gemüse");
      expect(itemNamed(synced, "Milch")!.category, "Kühlregal");
      expect(fixture.calls, isNot(contains(startsWith("renameCategory"))));
    });

    test("does not send anything if there is nothing to synchronise", () async {
      final fixture = Fixture();
      fixture.backend.setItems(listId, [ShoppingListItem("1", "Milch", false, null)]);
      await fixture.client.fetchShoppingList(listId);
      fixture.calls.clear();

      await fixture.client.fetchShoppingList(listId);

      expect(fixture.calls, ["fetchList:$listId"]);
    });

    test("ignores a different order of the items", () async {
      final fixture = Fixture();
      fixture.backend
          .setItems(listId, [ShoppingListItem("1", "Milch", false, null), ShoppingListItem("2", "Brot", false, null)]);
      final items = await fixture.client.fetchShoppingList(listId);

      // This is what an online reorder leaves behind: the local copy is in a
      // different order than the baseline.
      await fixture.applyLocally(items.reversed.toList());

      expect(await fixture.client.isDiverged(listId), isFalse);
    });

    test("a change made while the list synchronises is not lost", () async {
      final fixture = Fixture();
      fixture.backend.setItems(listId, [
        ShoppingListItem("1", "Milch", false, "Kühlregal"),
        ShoppingListItem("2", "Brot", false, "Backwaren"),
      ]);
      await fixture.client.fetchShoppingList(listId);

      // Something for the synchronisation to push.
      fixture.goOffline();
      await fixture.client.updateShoppingListItem(listId, ShoppingListItem("1", "Milch", true, "Kühlregal"));
      fixture.goOnline();

      // Not awaited: the change is made while the run is still pushing, which
      // is what happens when the user taps a checkbox as the connection
      // returns. The run ends by replacing the local copy with the server
      // state, so a change that only went into the local copy would be lost.
      final synchronising = fixture.client.fetchShoppingList(listId);
      final changing = fixture.client.updateShoppingListItem(listId, ShoppingListItem("2", "Brot", true, "Backwaren"));
      await Future.wait([synchronising, changing]);

      expect(itemNamed(fixture.backend.fetch(listId), "Brot")!.checked, isTrue);
      expect(itemNamed(fixture.backend.fetch(listId), "Milch")!.checked, isTrue);
      // The change was waved through to the server instead of being kept
      // locally, so there is nothing left to synchronise.
      expect(await fixture.client.pendingChangeCount(listId), 0);
      expect(fixture.calls.last, "updateItem:$listId:2");
    });
  });

  group("interrupted synchronisation", () {
    test("does not create the same item twice", () async {
      final fixture = Fixture();
      await fixture.client.fetchShoppingList(listId);
      fixture.goOffline();

      final created = await fixture.client.createShoppingListItem(listId, "Milch", null);
      await fixture.applyLocally([created]);

      // The item reaches the server but the app dies before the local copy is
      // refreshed. Simulated by letting the closing fetch of the run fail: at
      // that point the item has been created and the alias has been stored.
      var fetches = 0;
      final interrupted = RestClientStub(
        onFetchShoppingList: (id) {
          if (++fetches > 1) {
            throw HttpResponseException(500, message: "the app died here");
          }
          return fixture.backend.fetch(id);
        },
        onCreateShoppingListItem: (id, name, category) => fixture.backend.create(id, name, category),
      );
      await expectLater(
          SyncingRestClient(interrupted, fixture.store).fetchShoppingList(listId),
          throwsA(isA<HttpResponseException>()));
      expect(fixture.backend.fetch(listId).where((item) => item.name == "Milch"), hasLength(1));

      // The next attempt must notice that the item is already on the server.
      fixture.goOnline();
      final synced = await fixture.client.fetchShoppingList(listId);

      expect(synced.where((item) => item.name == "Milch"), hasLength(1));
    });

    test("keeps the snapshots when the session expired", () async {
      final fixture = Fixture();
      fixture.backend.setItems(listId, [ShoppingListItem("1", "Milch", false, null)]);
      final items = await fixture.client.fetchShoppingList(listId);
      fixture.goOffline();

      items.single.name = "Vollmilch";
      await fixture.applyLocally(items);

      fixture.goOnline();
      final failing = RestClientStub(
        onFetchShoppingList: (id) => fixture.backend.fetch(id),
        onUpdateShoppingListItem: (id, item) => throw HttpResponseException.unAuthenticated(),
      );
      final client = SyncingRestClient(failing, fixture.store);

      await expectLater(client.fetchShoppingList(listId), throwsA(isA<HttpResponseException>()));

      final local = await fixture.store.getLocalItems(listId);
      expect(local!.single.name, "Vollmilch", reason: "the unsynchronised change must survive");
    });

    test("drops a change the server rejects and keeps going", () async {
      final fixture = Fixture();
      fixture.backend
          .setItems(listId, [ShoppingListItem("1", "Milch", false, null), ShoppingListItem("2", "Brot", false, null)]);
      final items = await fixture.client.fetchShoppingList(listId);
      fixture.goOffline();

      itemNamed(items, "Milch")!.checked = true;
      itemNamed(items, "Brot")!.checked = true;
      await fixture.applyLocally(items);

      fixture.goOnline();
      final rejectingStub = RestClientStub(
        onFetchShoppingList: (id) => fixture.backend.fetch(id),
        onUpdateShoppingListItem: (id, item) {
          if (item.name == "Milch") {
            throw HttpResponseException(403, message: "nope");
          }
          fixture.backend.update(id, item);
        },
      );
      final client = SyncingRestClient(rejectingStub, fixture.store);

      final synced = await client.fetchShoppingList(listId);

      expect(itemNamed(synced, "Milch")!.checked, isFalse, reason: "rejected");
      expect(itemNamed(synced, "Brot")!.checked, isTrue, reason: "must still be synchronised");
    });
  });

  group("pending changes", () {
    test("counts added, changed and removed items", () async {
      final fixture = Fixture();
      fixture.backend
          .setItems(listId, [ShoppingListItem("1", "Milch", false, null), ShoppingListItem("2", "Brot", false, null)]);
      final items = await fixture.client.fetchShoppingList(listId);
      expect(await fixture.client.pendingChangeCount(listId), 0);

      fixture.goOffline();
      itemNamed(items, "Milch")!.checked = true;
      items.removeWhere((item) => item.name == "Brot");
      final created = await fixture.client.createShoppingListItem(listId, "Käse", null);
      items.add(created);
      await fixture.applyLocally(items);

      expect(await fixture.client.pendingChangeCount(listId), 3);
    });

    test("is zero again after synchronising", () async {
      final fixture = Fixture();
      fixture.backend.setItems(listId, [ShoppingListItem("1", "Milch", false, null)]);
      final items = await fixture.client.fetchShoppingList(listId);
      fixture.goOffline();
      items.single.checked = true;
      await fixture.applyLocally(items);

      fixture.goOnline();
      await fixture.client.fetchShoppingList(listId);

      expect(await fixture.client.pendingChangeCount(listId), 0);
      expect(await fixture.client.isDiverged(listId), isFalse);
    });
  });
}
