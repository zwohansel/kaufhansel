import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaufhansel_client/generated/l10n.dart';
import 'package:kaufhansel_client/main.dart';
import 'package:kaufhansel_client/model.dart';
import 'package:kaufhansel_client/utils/semantic_versioning.dart';

import 'rest_client_stub.dart';
import 'settings_store_stub.dart';
import 'utils.dart';

void main() {
  const testLocale = Locale("de");
  AppLocalizations localizations;

  setUp(() async {
    localizations = await AppLocalizations.load(testLocale);
  });

  testWidgets('Add item to existing category', (WidgetTester tester) async {
    final store = SettingsStoreStub();
    // Store a user info obj so that we start in a logged in state
    store.saveUserInfo(ShoppingListUserInfo("1", "test", "test@test.de", "1234"));

    final categoryOfNewItem = "CategoryB";
    final nameOfNewItem = "C";

    final item0 = ShoppingListItem("1", "A", false, "CategoryA");
    final item1 = ShoppingListItem("2", "B", false, categoryOfNewItem);
    List<ShoppingListItem> backendItems = [item0, item1];

    final version = Version(1, 0, 0);
    final client = RestClientStub(
        onGetBackendInfo: () => BackendInfo(version, null),
        onGetShoppingLists: () {
          final adminPermissions = ShoppingListPermissions(ShoppingListRole.ADMIN, true, true, true);
          return [ShoppingListInfo("1", "TestList", adminPermissions, [])];
        },
        onFetchShoppingList: (id) => backendItems,
        onCreateShoppingListItem: (String shoppingListId, String name, String category) {
          expect(shoppingListId, equals("1"));
          expect(name, equals(nameOfNewItem));
          expect(category, equals(categoryOfNewItem));
          return ShoppingListItem("3", name, false, category);
        });

    await tester.pumpWidget(await makeBasicTestableWidget(
        ShoppingListApp(
          client: client,
          settingsStore: store,
          currentVersion: () async => version,
        ),
        locale: testLocale));
    await tester.pumpAndSettle();

    // Switch to tab of CategoryB
    final tab = find.widgetWithText(Tab, categoryOfNewItem);
    expect(tab, findsOneWidget);
    await tester.tap(tab);
    await tester.pumpAndSettle();

    // Check that we only see items of CategoryB
    expect(find.widgetWithText(CheckboxListTile, item0.name), findsNothing);
    expect(find.widgetWithText(CheckboxListTile, item1.name), findsOneWidget);

    // Add a new item
    await enterText(
      tester,
      widgetType: TextField,
      fieldLabelOrHint: localizations.shoppingListNeededHint,
      text: nameOfNewItem,
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(find.widgetWithText(CheckboxListTile, item0.name), findsNothing);
    expect(find.widgetWithText(CheckboxListTile, item1.name), findsOneWidget);
    expect(find.widgetWithText(CheckboxListTile, nameOfNewItem), findsOneWidget);

    // Switch to tab of all categories
    final allTab = find.widgetWithText(Tab, CATEGORY_ALL);
    expect(allTab, findsOneWidget);
    await tester.tap(allTab);
    await tester.pumpAndSettle();

    expect(find.widgetWithText(CheckboxListTile, item0.name), findsOneWidget);
    expect(find.widgetWithText(CheckboxListTile, item1.name), findsOneWidget);
    expect(find.widgetWithText(CheckboxListTile, nameOfNewItem), findsOneWidget);
  });

  testWidgets('Add item to new category', (WidgetTester tester) async {
    final store = SettingsStoreStub();
    // Store a user info obj so that we start in a logged in state
    store.saveUserInfo(ShoppingListUserInfo("1", "test", "test@test.de", "1234"));

    final categoryOfNewItem = "CategoryB";
    final nameOfNewItem = "B";
    final idOfNewItem = "2";

    final item0 = ShoppingListItem("1", "A", false, "CategoryA");
    List<ShoppingListItem> backendItems = [item0];

    final version = Version(1, 0, 0);
    final client = RestClientStub(
        onGetBackendInfo: () => BackendInfo(version, null),
        onGetShoppingLists: () {
          final adminPermissions = ShoppingListPermissions(ShoppingListRole.ADMIN, true, true, true);
          return [ShoppingListInfo("1", "TestList", adminPermissions, [])];
        },
        onFetchShoppingList: (id) => backendItems,
        onCreateShoppingListItem: (String shoppingListId, String name, String category) {
          expect(shoppingListId, equals("1"));
          expect(name, equals(nameOfNewItem));
          expect(category, isNull);
          return ShoppingListItem(idOfNewItem, name, false, category);
        },
        onUpdateShoppingListItem: (String shoppingListId, ShoppingListItem item) {
          expect(shoppingListId, equals("1"));
          expect(item, isNotNull);
          expect(item.id, equals(idOfNewItem));
          expect(item.name, equals(nameOfNewItem));
          expect(item.category, equals(categoryOfNewItem));
          expect(item.checked, isFalse);
        });

    await tester.pumpWidget(await makeBasicTestableWidget(
        ShoppingListApp(
          client: client,
          settingsStore: store,
          currentVersion: () async => version,
        ),
        locale: testLocale));
    await tester.pumpAndSettle();

    // Check that we only see the initial item
    expect(find.widgetWithText(CheckboxListTile, item0.name), findsOneWidget);
    expect(find.widgetWithText(CheckboxListTile, categoryOfNewItem), findsNothing);

    // Add a new item
    await enterText(
      tester,
      widgetType: TextField,
      fieldLabelOrHint: localizations.shoppingListNeededHint,
      text: nameOfNewItem,
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    // Find list tile of new item
    final newItem = find.widgetWithText(CheckboxListTile, nameOfNewItem);
    expect(newItem, findsOneWidget);

    // Find edit icon in tile of the item
    final newItemEdit = find.descendant(of: newItem, matching: find.byIcon(Icons.edit));
    expect(newItemEdit, findsOneWidget);

    // Tap edit icon to open item edit dialog
    await tester.tap(newItemEdit);
    await tester.pumpAndSettle();

    // Enter name of new category
    await enterText(
      tester,
      widgetType: TextField,
      fieldLabelOrHint: localizations.categoryCreateNew,
      text: categoryOfNewItem,
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    // Switch to tab of new category
    final tab = find.widgetWithText(Tab, categoryOfNewItem);
    expect(tab, findsOneWidget);
    await tester.tap(tab);
    await tester.pumpAndSettle();

    expect(find.widgetWithText(CheckboxListTile, nameOfNewItem), findsOneWidget);
    expect(find.widgetWithText(CheckboxListTile, item0.name), findsNothing);
  });

  testWidgets('Remove current category', (WidgetTester tester) async {
    final store = SettingsStoreStub();
    // Store a user info obj so that we start in a logged in state
    store.saveUserInfo(ShoppingListUserInfo("1", "test", "test@test.de", "1234"));

    final categoryToRemove = "CategoryB";

    final item0 = ShoppingListItem("1", "A", false, "CategoryA");
    final item1 = ShoppingListItem("2", "B", false, categoryToRemove);
    List<ShoppingListItem> backendItems = [item0, item1];

    final version = Version(1, 0, 0);
    final client = RestClientStub(
        onGetBackendInfo: () => BackendInfo(version, null),
        onGetShoppingLists: () {
          final adminPermissions = ShoppingListPermissions(ShoppingListRole.ADMIN, true, true, true);
          return [ShoppingListInfo("1", "TestList", adminPermissions, [])];
        },
        onFetchShoppingList: (id) => backendItems,
        onUpdateShoppingListItem: (String shoppingListId, ShoppingListItem item) {
          expect(shoppingListId, equals("1"));
          expect(item, isNotNull);
          expect(item.id, equals(item1.id));
          expect(item.name, equals(item1.name));
          expect(item.category, isNull);
          expect(item.checked, isFalse);
        });

    await tester.pumpWidget(await makeBasicTestableWidget(
        ShoppingListApp(
          client: client,
          settingsStore: store,
          currentVersion: () async => version,
        ),
        locale: testLocale));
    await tester.pumpAndSettle();

    // Switch to tab of CategoryB
    final tab = find.widgetWithText(Tab, categoryToRemove);
    expect(tab, findsOneWidget);
    await tester.tap(tab);
    await tester.pumpAndSettle();

    // Check that we only see item1
    expect(find.widgetWithText(CheckboxListTile, item0.name), findsNothing);
    expect(find.widgetWithText(CheckboxListTile, item1.name), findsOneWidget);

    // Find list tile of item1
    final item1Tile = find.widgetWithText(CheckboxListTile, item1.name);
    expect(item1Tile, findsOneWidget);

    // Find edit icon in tile of item1
    final newItemEdit = find.descendant(of: item1Tile, matching: find.byIcon(Icons.edit));
    expect(newItemEdit, findsOneWidget);

    // Tap edit icon to open item edit dialog
    await tester.tap(newItemEdit);
    await tester.pumpAndSettle();

    // Find the button to remove the category and tap it
    final noCategoryBtn = find.widgetWithText(OutlinedButton, localizations.categoryNone);
    expect(noCategoryBtn, findsOneWidget);
    await tester.tap(noCategoryBtn);
    await tester.pumpAndSettle();

    // The app should switch to the tab of the other category
    expect(find.widgetWithText(CheckboxListTile, item0.name), findsOneWidget);
    expect(find.widgetWithText(CheckboxListTile, item1.name), findsNothing);

    // Switch to tab of all categories
    final allTab = find.widgetWithText(Tab, CATEGORY_ALL);
    expect(allTab, findsOneWidget);
    await tester.tap(allTab);
    await tester.pumpAndSettle();

    expect(find.widgetWithText(CheckboxListTile, item0.name), findsOneWidget);
    expect(find.widgetWithText(CheckboxListTile, item1.name), findsOneWidget);
  });

  testWidgets('Refresh list using swipe to refresh', (WidgetTester tester) async {
    final store = SettingsStoreStub();
    // Store a user info obj so that we start in a logged in state
    store.saveUserInfo(ShoppingListUserInfo("1", "test", "test@test.de", "1234"));

    final item0 = ShoppingListItem("1", "A", false, null);
    final item1 = ShoppingListItem("2", "B", false, null);
    List<ShoppingListItem> backendItems = [item0];

    final version = Version(1, 0, 0);
    final client = RestClientStub(
      onGetBackendInfo: () => BackendInfo(version, null),
      onGetShoppingLists: () {
        final adminPermissions = ShoppingListPermissions(ShoppingListRole.ADMIN, true, true, true);
        return [ShoppingListInfo("1", "TestList", adminPermissions, [])];
      },
      onFetchShoppingList: (id) => backendItems,
    );

    await tester.pumpWidget(await makeBasicTestableWidget(
        ShoppingListApp(
          client: client,
          settingsStore: store,
          currentVersion: () async => version,
        ),
        locale: testLocale));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(CheckboxListTile, item0.name), findsOneWidget);
    expect(find.widgetWithText(CheckboxListTile, item1.name), findsNothing);

    // add item1 to the backend and trigger a refresh by pulling down the list
    backendItems.add(item1);

    await tester.fling(find.widgetWithText(CheckboxListTile, item0.name), Offset(0, 300), 1000);
    await tester.pumpAndSettle();

    expect(find.widgetWithText(CheckboxListTile, item0.name), findsOneWidget);
    expect(find.widgetWithText(CheckboxListTile, item1.name), findsOneWidget);
  });
}
