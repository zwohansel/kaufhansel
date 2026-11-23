import 'package:animated_list_plus/animated_list_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaufhansel_client/generated/l10n.dart';
import 'package:kaufhansel_client/main.dart';
import 'package:kaufhansel_client/model.dart';
import 'package:kaufhansel_client/sync/syncing_rest_client.dart';
import 'package:kaufhansel_client/utils/semantic_versioning.dart';

import 'fake_backend.dart';
import 'rest_client_stub.dart';
import 'settings_store_stub.dart';
import 'utils.dart';

const listId = "1";

/// Drives the whole app against a [FakeBackend] whose reachability the test can
/// switch on and off.
class OfflineAppFixture {
  final FakeBackend backend = FakeBackend();
  final SettingsStoreStub store;
  late final RestClientStub stub;

  OfflineAppFixture({SettingsStoreStub? store, Version? version})
      : store = store ?? SettingsStoreStub() {
    stub = RestClientStub(
      onGetBackendInfo: () => BackendInfo(version ?? Version(1, 0, 0), null),
      onGetShoppingLists: () => [
        ShoppingListInfo(listId, "TestList", ShoppingListPermissions(ShoppingListRole.ADMIN, true, true, true), [])
      ],
      onFetchShoppingList: (id) => backend.fetch(id),
      onCreateShoppingListItem: (id, name, category) => backend.create(id, name, category),
      onUpdateShoppingListItem: (id, item) => backend.update(id, item),
      onDeleteShoppingListItem: (id, item) => backend.delete(id, item),
      onMoveShoppingListItem: (id, item, index) => backend.move(id, item, index),
      onUncheckItems: (id, category) => backend.uncheckItems(id, category),
      onRemoveAllItems: (id) => backend.clear(id),
    );
  }

  Future<Widget> app({Version? version}) async {
    // A stored user info puts the app into the logged in state.
    store.saveUserInfo(ShoppingListUserInfo("1", "test", "test@test.de", "1234", tokenExpiresAt));
    return makeBasicTestableWidget(
      // A fresh client per call, so that calling this twice is the restart it
      // pretends to be.
      ShoppingListApp(
        client: SyncingRestClient(stub, store),
        settingsStore: store,
        currentVersion: () async => version ?? Version(1, 0, 0),
      ),
      locale: const Locale("de"),
    );
  }

  void goOffline() => stub.offline = true;

  void goOnline() => stub.offline = false;

  List<String> get calls => stub.callLog;
}

/// Lets the debounced write of the local copy run and then settles the tree.
Future<void> settle(WidgetTester tester) async {
  await tester.pumpAndSettle();
  await tester.pump(const Duration(seconds: 2));
  await tester.pumpAndSettle();
}

/// The reorderable list is generic over the item type, so it cannot be found by
/// `find.byType`.
final reorderableLists = find.byWidgetPredicate(
    (widget) => widget is ImplicitlyAnimatedReorderableList,
    skipOffstage: false);

Future<void> openItemEditDialog(WidgetTester tester, String itemName) async {
  final itemTile = find.widgetWithText(ListTile, itemName);
  expect(itemTile, findsOneWidget);
  final editButton = find.descendant(of: itemTile, matching: find.byIcon(Icons.edit));
  expect(editButton, findsOneWidget);
  await tester.tap(editButton);
  await tester.pumpAndSettle();
}

Future<void> tapItemMenuEntry(WidgetTester tester, String entry) async {
  final moreButton = find.widgetWithIcon(IconButton, Icons.more_vert);
  expect(moreButton, findsOneWidget);
  await tester.tap(moreButton);
  await tester.pumpAndSettle();
  final menuEntry = find.text(entry);
  expect(menuEntry, findsOneWidget);
  await tester.tap(menuEntry);
  await tester.pumpAndSettle();
}

void main() {
  late AppLocalizations localizations;

  setUp(() async {
    localizations = await AppLocalizations.load(const Locale("de"));
  });

  testWidgets("The list stays loaded when it is refreshed without a connection", (tester) async {
    final fixture = OfflineAppFixture();
    fixture.backend.setItems(listId, [ShoppingListItem("1", "Milch", false, null)]);

    await tester.pumpWidget(await fixture.app());
    await settle(tester);
    expect(find.widgetWithText(ListTile, "Milch"), findsOneWidget);

    fixture.goOffline();
    await tester.fling(find.widgetWithText(ListTile, "Milch"), const Offset(0, 300), 1000);
    await settle(tester);

    expect(find.widgetWithText(ListTile, "Milch"), findsOneWidget);
    expect(find.text(localizations.shoppingListError), findsNothing);
    expect(find.text(localizations.shoppingListNotPresent("TestList")), findsNothing);
  });

  testWidgets("The list is still there after a restart without a connection", (tester) async {
    final fixture = OfflineAppFixture();
    fixture.backend.setItems(listId, [ShoppingListItem("1", "Milch", false, null)]);

    await tester.pumpWidget(await fixture.app());
    await settle(tester);
    expect(find.widgetWithText(ListTile, "Milch"), findsOneWidget);

    // Restart with the same storage but without a connection.
    final restarted = OfflineAppFixture(store: fixture.store);
    restarted.goOffline();
    await tester.pumpWidget(await restarted.app());
    await settle(tester);

    expect(find.widgetWithText(ListTile, "Milch"), findsOneWidget);
    expect(find.text(localizations.shoppingListError), findsNothing);
  });

  testWidgets("Items can be added, renamed, checked and removed without a connection", (tester) async {
    final fixture = OfflineAppFixture();
    fixture.backend.setItems(
        listId, [ShoppingListItem("1", "Milch", false, null), ShoppingListItem("2", "Brot", false, null)]);

    await tester.pumpWidget(await fixture.app());
    await settle(tester);

    fixture.goOffline();
    await tester.pumpAndSettle();
    fixture.calls.clear();

    // Add
    await enterText(tester,
        widgetType: TextField, fieldLabelOrHint: localizations.createOrSearchHint, text: "Käse");
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await settle(tester);
    expect(find.widgetWithText(ListTile, "Käse"), findsOneWidget);

    // Rename
    await openItemEditDialog(tester, "Milch");
    await tapItemMenuEntry(tester, localizations.itemRename);
    await enterText(tester, widgetType: TextField, fieldLabelOrHint: "Milch", text: "Vollmilch");
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await settle(tester);

    // Remove
    await tapItemMenuEntry(tester, localizations.itemRemove);
    await settle(tester);

    expect(find.widgetWithText(ListTile, "Vollmilch"), findsNothing, reason: "removed");
    expect(find.widgetWithText(ListTile, "Brot"), findsOneWidget);
    expect(find.widgetWithText(ListTile, "Käse"), findsOneWidget);

    // Nothing may have been sent and no error may have been shown.
    expect(fixture.calls, isEmpty);
    expect(find.text(localizations.exceptionNoInternet), findsNothing);
    expect(find.text(localizations.exceptionUnknown("")), findsNothing);
  });

  testWidgets("The changes are sent once the connection is back", (tester) async {
    final fixture = OfflineAppFixture();
    fixture.backend.setItems(
        listId, [ShoppingListItem("1", "Milch", false, null), ShoppingListItem("2", "Brot", false, null)]);

    await tester.pumpWidget(await fixture.app());
    await settle(tester);

    fixture.goOffline();
    await tester.pumpAndSettle();

    await enterText(tester,
        widgetType: TextField, fieldLabelOrHint: localizations.createOrSearchHint, text: "Käse");
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await settle(tester);

    await openItemEditDialog(tester, "Milch");
    await tapItemMenuEntry(tester, localizations.itemRemove);
    await settle(tester);

    fixture.calls.clear();
    fixture.goOnline();
    await settle(tester);

    final serverItems = fixture.backend.fetch(listId).map((item) => item.name).toList();
    expect(serverItems, containsAll(["Brot", "Käse"]));
    expect(serverItems, isNot(contains("Milch")));
    expect(fixture.calls.where((call) => call.contains("tmp-")), isEmpty,
        reason: "a temporary id must never reach the server");

    expect(find.widgetWithText(ListTile, "Käse"), findsOneWidget);
    expect(find.widgetWithText(ListTile, "Milch"), findsNothing);
  });

  testWidgets("Without a connection and without a cache the error view is shown", (tester) async {
    final fixture = OfflineAppFixture();
    fixture.goOffline();

    await tester.pumpWidget(await fixture.app());
    // The login page shows a progress bar while the app initialises, so the
    // tree never settles until that is done. Pumping single frames instead.
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    // Starting without a connection means the update check cannot reach the
    // server either and asks whether it should try again.
    final dontCare = find.widgetWithText(OutlinedButton, localizations.dontCare);
    expect(dontCare, findsOneWidget);
    await tester.tap(dontCare);
    await settle(tester);

    expect(find.text(localizations.shoppingListError), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, localizations.tryAgain), findsOneWidget);
  });

  testWidgets("Items cannot be dragged without a connection", (tester) async {
    final fixture = OfflineAppFixture();
    fixture.backend.setItems(
        listId, [ShoppingListItem("1", "Milch", false, null), ShoppingListItem("2", "Brot", false, null)]);

    await tester.pumpWidget(await fixture.app());
    await settle(tester);

    // Edit mode offers reordering while the server can be reached...
    await tester.tap(find.widgetWithIcon(IconButton, Icons.mode_outlined));
    await settle(tester);
    expect(reorderableLists, findsWidgets);
    expect(find.byIcon(Icons.drag_handle), findsWidgets);

    // ...but not without a connection.
    fixture.goOffline();
    await settle(tester);
    expect(reorderableLists, findsNothing);
    expect(find.byIcon(Icons.drag_handle), findsNothing);

    // The items are still all there and in the order of the list.
    expect(find.widgetWithText(ListTile, "Milch"), findsOneWidget);
    expect(find.widgetWithText(ListTile, "Brot"), findsOneWidget);
  });

  testWidgets("The offline indicator explains the situation and disappears again", (tester) async {
    final fixture = OfflineAppFixture();
    fixture.backend.setItems(listId, [ShoppingListItem("1", "Milch", false, null)]);

    await tester.pumpWidget(await fixture.app());
    await settle(tester);
    expect(find.widgetWithIcon(IconButton, Icons.cloud_off), findsNothing);

    fixture.goOffline();
    await tester.pumpAndSettle();
    final indicator = find.widgetWithIcon(IconButton, Icons.cloud_off);
    expect(indicator, findsOneWidget);

    // One unsynchronised change.
    await enterText(tester,
        widgetType: TextField, fieldLabelOrHint: localizations.createOrSearchHint, text: "Käse");
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await settle(tester);

    await tester.tap(indicator);
    await tester.pumpAndSettle();
    expect(find.text(localizations.offlineMessage), findsOneWidget);
    expect(find.text(localizations.offlinePendingChanges(1)), findsOneWidget);

    await tester.tap(find.widgetWithText(OutlinedButton, localizations.offlineThanks));
    await tester.pumpAndSettle();
    expect(find.text(localizations.offlineMessage), findsNothing);

    fixture.goOnline();
    await settle(tester);
    expect(find.widgetWithIcon(IconButton, Icons.cloud_off), findsNothing);
  });
}
