import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaufhansel_client/generated/l10n.dart';
import 'package:kaufhansel_client/main.dart';
import 'package:kaufhansel_client/model.dart';
import 'package:kaufhansel_client/rest_client.dart';
import 'package:kaufhansel_client/utils/semantic_versioning.dart';

import 'rest_client_stub.dart';
import 'settings_store_stub.dart';
import 'utils.dart';

/// Checks whether we are on the login page
void checkIsLoginPage(AppLocalizations localizations) {
  expect(find.text(localizations.appTitle), findsOneWidget);
  expect(find.widgetWithText(TextFormField, localizations.emailHint), findsOneWidget);
  expect(find.widgetWithText(TextFormField, localizations.passwordHint), findsOneWidget);
  expect(find.widgetWithText(ElevatedButton, localizations.buttonLogin), findsOneWidget);
}

Future<void> checkIsUnAuthenticatedDialogAndDismiss(WidgetTester tester, AppLocalizations localizations) async {
  expect(find.text(localizations.exceptionUnAuthenticated), findsOneWidget);
  final dismissDialogBtn = find.widgetWithText(OutlinedButton, localizations.willLoginAgain);
  expect(dismissDialogBtn, findsOneWidget);
  await tester.tap(dismissDialogBtn);
  await tester.pumpAndSettle();
}

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
      fieldLabelOrHint: localizations.createOrSearchHint,
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
      fieldLabelOrHint: localizations.createOrSearchHint,
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

  testWidgets('Remove current category from item', (WidgetTester tester) async {
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

  testWidgets("Uncheck all items", (WidgetTester tester) async {
    final store = SettingsStoreStub();
    // Store a user info obj so that we start in a logged in state
    store.saveUserInfo(ShoppingListUserInfo("1", "test", "test@test.de", "1234"));

    final item0 = ShoppingListItem("1", "A", true, "aCategory");
    final item1 = ShoppingListItem("2", "B", false, "aCategory");
    final item2 = ShoppingListItem("3", "C", true, null);
    List<ShoppingListItem> backendItems = [item0, item1, item2];

    final version = Version(1, 0, 0);
    final client = RestClientStub(
      onGetBackendInfo: () => BackendInfo(version, null),
      onGetShoppingLists: () {
        final adminPermissions = ShoppingListPermissions(ShoppingListRole.ADMIN, true, true, true);
        return [ShoppingListInfo("1", "TestList", adminPermissions, [])];
      },
      onFetchShoppingList: (id) => backendItems,
      onUncheckItems: (shoppingListId, ofCategory) {
        expect(shoppingListId, equals("1"));
        expect(ofCategory, isNull);
      },
    );

    await tester.pumpWidget(await makeBasicTestableWidget(
        ShoppingListApp(
          client: client,
          settingsStore: store,
          currentVersion: () async => version,
        ),
        locale: testLocale));
    await tester.pumpAndSettle();

    // open drawer
    final drawerIcon = find.widgetWithIcon(IconButton, Icons.menu);
    expect(drawerIcon, findsOneWidget);
    await tester.tap(drawerIcon);
    await tester.pumpAndSettle();

    // check that we see the menu item
    final manageCategoriesMenuItem = find.widgetWithText(ListTile, localizations.manageCategories);
    expect(manageCategoriesMenuItem, findsOneWidget);

    // open the manage categories dialog
    await tester.tap(manageCategoriesMenuItem);
    await tester.pumpAndSettle();

    // check that the dialog is open
    expect(find.text(localizations.manageCategoriesTitle), findsOneWidget);

    // select CATEGORY_ALL
    final dropdownButton = find.widgetWithText(GestureDetector, localizations.manageCategoriesWhich);
    // await tester.ensureVisible(dropdownButton);
    await tester.tap(dropdownButton);
    await tester.pumpAndSettle();

    final menuItemCategoryAll = find.descendant(of: dropdownButton, matching: find.text(CATEGORY_ALL));
    // await tester.ensureVisible(dropdownButton);
    await tester.tap(menuItemCategoryAll, warnIfMissed: false);
    await tester.pumpAndSettle();

    // select uncheck items
    final uncheckItemsOption = find.text(localizations.manageCategoriesUncheckAll);
    await tester.tap(uncheckItemsOption);
    await tester.pumpAndSettle();
  });

  testWidgets("Uncheck items of category", (WidgetTester tester) async {
    // TODO
    final store = SettingsStoreStub();
    // Store a user info obj so that we start in a logged in state
    store.saveUserInfo(ShoppingListUserInfo("1", "test", "test@test.de", "1234"));

    final item0 = ShoppingListItem("1", "A", true, "Test category");
    final item1 = ShoppingListItem("2", "B", false, "Test category");
    final item2 = ShoppingListItem("3", "C", true, null);
    List<ShoppingListItem> backendItems = [item0, item1, item2];

    final version = Version(1, 0, 0);
    final client = RestClientStub(
      onGetBackendInfo: () => BackendInfo(version, null),
      onGetShoppingLists: () {
        final adminPermissions = ShoppingListPermissions(ShoppingListRole.ADMIN, true, true, true);
        return [ShoppingListInfo("1", "TestList", adminPermissions, [])];
      },
      onFetchShoppingList: (id) => backendItems,
      onUncheckItems: (shoppingListId, ofCategory) {
        expect(shoppingListId, equals("1"));
        expect(ofCategory, equals("Test category"));
      },
    );

    await tester.pumpWidget(await makeBasicTestableWidget(
        ShoppingListApp(client: client, settingsStore: store, currentVersion: () async => version),
        locale: testLocale));
    await tester.pumpAndSettle();

    // open drawer
    final drawerIcon = find.widgetWithIcon(IconButton, Icons.menu);
    expect(drawerIcon, findsOneWidget);
    await tester.tap(drawerIcon);
    await tester.pumpAndSettle();

    // check that we see the menu item
    final manageCategoriesMenuItem = find.widgetWithText(ListTile, localizations.manageCategories);
    expect(manageCategoriesMenuItem, findsOneWidget);

    // open the manage categories dialog
    await tester.tap(manageCategoriesMenuItem);
    await tester.pumpAndSettle();

    // check that the dialog is open
    expect(find.text(localizations.manageCategoriesTitle), findsOneWidget);

    // select category "Test category"
    final dropdownButton = find.widgetWithText(GestureDetector, localizations.manageCategoriesWhich);
    // await tester.ensureVisible(dropdownButton);
    await tester.tap(dropdownButton);
    await tester.pumpAndSettle();

    final menuItemCategory = find.byKey(ValueKey<String>("menuitem-Test_category"));
    expect(menuItemCategory, findsOneWidget);
    // await tester.ensureVisible(menuItemCategory);
    await tester.tap(menuItemCategory, warnIfMissed: false);
    await tester.
    await tester.pumpAndSettle();

    // select uncheck items
    final uncheckItemsOption = find.byKey(ValueKey<String>("option-uncheck"));
    //find.text(localizations.manageCategoriesUncheckCategory("Test category"));
    expect(uncheckItemsOption, findsOneWidget);
    await tester.tap(uncheckItemsOption);
    await tester.pumpAndSettle();
  });

  testWidgets("Remove all categories", (WidgetTester tester) async {
    final store = SettingsStoreStub();
    // Store a user info obj so that we start in a logged in state
    store.saveUserInfo(ShoppingListUserInfo("1", "test", "test@test.de", "1234"));

    final item0 = ShoppingListItem("1", "A", true, "Category1");
    final item1 = ShoppingListItem("2", "B", false, "Category2");
    final item2 = ShoppingListItem("3", "C", true, null);
    List<ShoppingListItem> backendItems = [item0, item1, item2];

    final version = Version(1, 0, 0);
    final client = RestClientStub(
      onGetBackendInfo: () => BackendInfo(version, null),
      onGetShoppingLists: () {
        final adminPermissions = ShoppingListPermissions(ShoppingListRole.ADMIN, true, true, true);
        return [ShoppingListInfo("1", "TestList", adminPermissions, [])];
      },
      onFetchShoppingList: (id) => backendItems,
      onRemoveCategory: (shoppingListId, category) {
        expect(shoppingListId, equals("1"));
        expect(category, isNull);
      },
    );

    await tester.pumpWidget(await makeBasicTestableWidget(
        ShoppingListApp(
          client: client,
          settingsStore: store,
          currentVersion: () async => version,
        ),
        locale: testLocale));
    await tester.pumpAndSettle();

    // open drawer
    final drawerIcon = find.widgetWithIcon(IconButton, Icons.menu);
    expect(drawerIcon, findsOneWidget);
    await tester.tap(drawerIcon);
    await tester.pumpAndSettle();

    // check that we see the menu item
    final manageCategoriesMenuItem = find.widgetWithText(ListTile, localizations.manageCategories);
    expect(manageCategoriesMenuItem, findsOneWidget);

    // open the manage categories dialog
    await tester.tap(manageCategoriesMenuItem);
    await tester.pumpAndSettle();

    // check that the dialog is open
    expect(find.text(localizations.manageCategoriesTitle), findsOneWidget);

    // select CATEGORY_ALL
    final dropdownButton = find.widgetWithText(GestureDetector, localizations.manageCategoriesWhich);
    // await tester.ensureVisible(dropdownButton);
    await tester.tap(dropdownButton);
    await tester.pumpAndSettle();

    final menuItemCategoryAll = find.descendant(of: dropdownButton, matching: find.text(CATEGORY_ALL));
    // await tester.ensureVisible(dropdownButton);
    await tester.tap(menuItemCategoryAll, warnIfMissed: false);
    await tester.pumpAndSettle();

    // select uncheck items
    final uncheckItemsOption = find.text(localizations.manageCategoriesRemoveCategories);
    await tester.tap(uncheckItemsOption);
    await tester.pumpAndSettle();
  });

  testWidgets("Remove category", (WidgetTester tester) async {
    fail("unimplemented");
  });

  testWidgets("Rename category", (WidgetTester tester) async {
    fail("unimplemented");
  });

  testWidgets('Logout when fetching shopping list infos if unauthenticated', (WidgetTester tester) async {
    final store = SettingsStoreStub();

    // Store a user info obj so that we start in a logged in state
    store.saveUserInfo(ShoppingListUserInfo("1", "test", "test@test.de", "1234"));

    final version = Version(1, 0, 0);
    final client = RestClientStub(
      onGetBackendInfo: () => BackendInfo(version, null),
      onGetShoppingLists: () => throw HttpResponseException.unAuthenticated(),
    );

    await tester.pumpWidget(await makeBasicTestableWidget(
        ShoppingListApp(
          client: client,
          settingsStore: store,
          currentVersion: () async => version,
        ),
        locale: testLocale));
    await tester.pumpAndSettle();

    await checkIsUnAuthenticatedDialogAndDismiss(tester, localizations);
    checkIsLoginPage(localizations);
  });

  testWidgets('Logout when fetching shopping list if unauthenticated', (WidgetTester tester) async {
    final store = SettingsStoreStub();

    // Store a user info obj so that we start in a logged in state
    store.saveUserInfo(ShoppingListUserInfo("1", "test", "test@test.de", "1234"));

    final version = Version(1, 0, 0);
    final client = RestClientStub(
      onGetBackendInfo: () => BackendInfo(version, null),
      onGetShoppingLists: () {
        final adminPermissions = ShoppingListPermissions(ShoppingListRole.ADMIN, true, true, true);
        return [ShoppingListInfo("1", "TestList", adminPermissions, [])];
      },
      onFetchShoppingList: (id) => throw HttpResponseException.unAuthenticated(),
    );

    await tester.pumpWidget(await makeBasicTestableWidget(
        ShoppingListApp(
          client: client,
          settingsStore: store,
          currentVersion: () async => version,
        ),
        locale: testLocale));
    await tester.pumpAndSettle();

    await checkIsUnAuthenticatedDialogAndDismiss(tester, localizations);
    checkIsLoginPage(localizations);
  });

  testWidgets('Logout when setting category if unauthenticated', (WidgetTester tester) async {
    final store = SettingsStoreStub();

    // Store a user info obj so that we start in a logged in state
    store.saveUserInfo(ShoppingListUserInfo("1", "test", "test@test.de", "1234"));

    final item = ShoppingListItem("1", "A", false, null);

    final version = Version(1, 0, 0);
    final client = RestClientStub(
        onGetBackendInfo: () => BackendInfo(version, null),
        onGetShoppingLists: () {
          final adminPermissions = ShoppingListPermissions(ShoppingListRole.ADMIN, true, true, true);
          return [ShoppingListInfo("1", "TestList", adminPermissions, [])];
        },
        onFetchShoppingList: (id) => [item],
        onUpdateShoppingListItem: (id, item) => throw HttpResponseException.unAuthenticated());

    await tester.pumpWidget(await makeBasicTestableWidget(
        ShoppingListApp(
          client: client,
          settingsStore: store,
          currentVersion: () async => version,
        ),
        locale: testLocale));
    await tester.pumpAndSettle();

    // Find list tile of new item
    final itemTile = find.widgetWithText(CheckboxListTile, item.name);
    expect(itemTile, findsOneWidget);

    // Find edit icon in tile of the item
    final itemEditBtn = find.descendant(of: itemTile, matching: find.byIcon(Icons.edit));
    expect(itemEditBtn, findsOneWidget);

    // Tap edit icon to open item edit dialog
    await tester.tap(itemEditBtn);
    await tester.pumpAndSettle();

    // Enter name of new category
    await enterText(
      tester,
      widgetType: TextField,
      fieldLabelOrHint: localizations.categoryCreateNew,
      text: "FooBar",
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    await checkIsUnAuthenticatedDialogAndDismiss(tester, localizations);
    checkIsLoginPage(localizations);
  });

  testWidgets('Logout when renaming item if unauthenticated', (WidgetTester tester) async {
    final store = SettingsStoreStub();

    // Store a user info obj so that we start in a logged in state
    store.saveUserInfo(ShoppingListUserInfo("1", "test", "test@test.de", "1234"));

    final item = ShoppingListItem("1", "A", false, null);

    final version = Version(1, 0, 0);
    final client = RestClientStub(
        onGetBackendInfo: () => BackendInfo(version, null),
        onGetShoppingLists: () {
          final adminPermissions = ShoppingListPermissions(ShoppingListRole.ADMIN, true, true, true);
          return [ShoppingListInfo("1", "TestList", adminPermissions, [])];
        },
        onFetchShoppingList: (id) => [item],
        onUpdateShoppingListItem: (id, item) => throw HttpResponseException.unAuthenticated());

    await tester.pumpWidget(await makeBasicTestableWidget(
        ShoppingListApp(
          client: client,
          settingsStore: store,
          currentVersion: () async => version,
        ),
        locale: testLocale));
    await tester.pumpAndSettle();

    // Find list tile of new item
    final itemTile = find.widgetWithText(CheckboxListTile, item.name);
    expect(itemTile, findsOneWidget);

    // Find edit icon in tile of the item
    final itemEditBtn = find.descendant(of: itemTile, matching: find.byIcon(Icons.edit));
    expect(itemEditBtn, findsOneWidget);

    // Tap edit icon to open item edit dialog
    await tester.tap(itemEditBtn);
    await tester.pumpAndSettle();

    // Find and tap more options button
    final moreBtn = find.widgetWithIcon(IconButton, Icons.more_vert);
    expect(moreBtn, findsOneWidget);
    await tester.tap(moreBtn);
    await tester.pumpAndSettle();

    // Find and tap rename option
    final renameMenuItem = find.text(localizations.itemRename);
    expect(renameMenuItem, findsOneWidget);
    await tester.tap(renameMenuItem);
    await tester.pumpAndSettle();

    // Enter new item name
    await enterText(
      tester,
      widgetType: TextField,
      fieldLabelOrHint: item.name,
      text: "FooBar",
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    await checkIsUnAuthenticatedDialogAndDismiss(tester, localizations);
    checkIsLoginPage(localizations);
  });

  testWidgets('Logout when removing item if unauthenticated', (WidgetTester tester) async {
    final store = SettingsStoreStub();

    // Store a user info obj so that we start in a logged in state
    store.saveUserInfo(ShoppingListUserInfo("1", "test", "test@test.de", "1234"));

    final item = ShoppingListItem("1", "A", false, null);

    final version = Version(1, 0, 0);
    final client = RestClientStub(
        onGetBackendInfo: () => BackendInfo(version, null),
        onGetShoppingLists: () {
          final adminPermissions = ShoppingListPermissions(ShoppingListRole.ADMIN, true, true, true);
          return [ShoppingListInfo("1", "TestList", adminPermissions, [])];
        },
        onFetchShoppingList: (id) => [item],
        onDeleteShoppingListItem: (id, item) => throw HttpResponseException.unAuthenticated());

    await tester.pumpWidget(await makeBasicTestableWidget(
        ShoppingListApp(
          client: client,
          settingsStore: store,
          currentVersion: () async => version,
        ),
        locale: testLocale));
    await tester.pumpAndSettle();

    // Find list tile of new item
    final itemTile = find.widgetWithText(CheckboxListTile, item.name);
    expect(itemTile, findsOneWidget);

    // Find edit icon in tile of the item
    final itemEditBtn = find.descendant(of: itemTile, matching: find.byIcon(Icons.edit));
    expect(itemEditBtn, findsOneWidget);

    // Tap edit icon to open item edit dialog
    await tester.tap(itemEditBtn);
    await tester.pumpAndSettle();

    // Find and tap more options button
    final moreBtn = find.widgetWithIcon(IconButton, Icons.more_vert);
    expect(moreBtn, findsOneWidget);
    await tester.tap(moreBtn);
    await tester.pumpAndSettle();

    // Find and tap rename option
    final removeMenuItem = find.text(localizations.itemRemove);
    expect(removeMenuItem, findsOneWidget);
    await tester.tap(removeMenuItem);
    await tester.pumpAndSettle();

    await checkIsUnAuthenticatedDialogAndDismiss(tester, localizations);
    checkIsLoginPage(localizations);
  });

  testWidgets('Logout when adding new item if unauthenticated', (WidgetTester tester) async {
    final store = SettingsStoreStub();

    // Store a user info obj so that we start in a logged in state
    store.saveUserInfo(ShoppingListUserInfo("1", "test", "test@test.de", "1234"));

    final version = Version(1, 0, 0);
    final client = RestClientStub(
        onGetBackendInfo: () => BackendInfo(version, null),
        onGetShoppingLists: () {
          final adminPermissions = ShoppingListPermissions(ShoppingListRole.ADMIN, true, true, true);
          return [ShoppingListInfo("1", "TestList", adminPermissions, [])];
        },
        onFetchShoppingList: (id) => [],
        onCreateShoppingListItem: (id, name, category) => throw HttpResponseException.unAuthenticated());

    await tester.pumpWidget(await makeBasicTestableWidget(
        ShoppingListApp(
          client: client,
          settingsStore: store,
          currentVersion: () async => version,
        ),
        locale: testLocale));
    await tester.pumpAndSettle();

    // Enter name of new category
    await enterText(
      tester,
      widgetType: TextField,
      fieldLabelOrHint: localizations.createOrSearchHint,
      text: "FooBar",
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    await checkIsUnAuthenticatedDialogAndDismiss(tester, localizations);
    checkIsLoginPage(localizations);
  });
}
