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

final Type dropdownButtonType = DropdownButton<String>(
  onChanged: (_) {},
  items: const <DropdownMenuItem<String>>[],
).runtimeType;

void main() {
  const testLocale = Locale("de");
  AppLocalizations localizations;

  final Version version = Version(1, 0, 0);

  setUp(() async {
    localizations = await AppLocalizations.load(testLocale);
  });

  Future<Widget> makeTestableShoppingListApp(RestClient restClient) {
    final store = SettingsStoreStub();
    // Store a user info obj so that we start in a logged in state
    store.saveUserInfo(ShoppingListUserInfo("1", "test", "test@test.de", "1234"));

    return makeBasicTestableWidget(
        ShoppingListApp(
          client: restClient,
          settingsStore: store,
          currentVersion: () async => version,
        ),
        locale: testLocale);
  }

  testWidgets('Add item to existing category', (WidgetTester tester) async {
    final categoryOfNewItem = "CategoryB";
    final nameOfNewItem = "C";

    final item0 = ShoppingListItem("1", "A", false, "CategoryA");
    final item1 = ShoppingListItem("2", "B", false, categoryOfNewItem);
    List<ShoppingListItem> backendItems = [item0, item1];

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

    await tester.pumpWidget(await makeTestableShoppingListApp(client));
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
    final categoryOfNewItem = "CategoryB";
    final nameOfNewItem = "B";
    final idOfNewItem = "2";

    final item0 = ShoppingListItem("1", "A", false, "CategoryA");
    List<ShoppingListItem> backendItems = [item0];

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

    await tester.pumpWidget(await makeTestableShoppingListApp(client));
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
    final categoryToRemove = "CategoryB";

    final item0 = ShoppingListItem("1", "A", false, "CategoryA");
    final item1 = ShoppingListItem("2", "B", false, categoryToRemove);
    List<ShoppingListItem> backendItems = [item0, item1];

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

    await tester.pumpWidget(await makeTestableShoppingListApp(client));
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
    final item0 = ShoppingListItem("1", "A", false, null);
    final item1 = ShoppingListItem("2", "B", false, null);
    List<ShoppingListItem> backendItems = [item0];

    final client = RestClientStub(
      onGetBackendInfo: () => BackendInfo(version, null),
      onGetShoppingLists: () {
        final adminPermissions = ShoppingListPermissions(ShoppingListRole.ADMIN, true, true, true);
        return [ShoppingListInfo("1", "TestList", adminPermissions, [])];
      },
      onFetchShoppingList: (id) => backendItems,
    );

    await tester.pumpWidget(await makeTestableShoppingListApp(client));
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
    final item0 = ShoppingListItem("1", "A", true, "aCategory");
    final item1 = ShoppingListItem("2", "B", false, "aCategory");
    final item2 = ShoppingListItem("3", "C", true, null);
    List<ShoppingListItem> backendItems = [item0, item1, item2];

    bool uncheckedAllItems = false;

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
        uncheckedAllItems = ofCategory == null;
      },
    );

    await tester.pumpWidget(await makeTestableShoppingListApp(client));
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
    final dropdownButton = find.widgetWithText(dropdownButtonType, localizations.manageCategoriesWhich);
    await tester.tap(dropdownButton);
    await tester.pumpAndSettle();

    final menuItemCategoryAll = find.text(CATEGORY_ALL);
    // The DropDownButton creates two widgets with for each menu item.
    // The widget that is found last is always the one that is clickable.
    // See: https://github.com/flutter/flutter/blob/master/packages/flutter/test/material/dropdown_test.dart
    expect(menuItemCategoryAll, findsWidgets);
    await tester.tap(menuItemCategoryAll.last);
    await tester.pumpAndSettle();

    // select uncheck items
    final uncheckItemsOption = find.text(localizations.manageCategoriesUncheckAll);
    await tester.tap(uncheckItemsOption);
    await tester.pumpAndSettle();

    expect(uncheckedAllItems, isTrue,
        reason: "This is probably because the onUncheckItems callback of the RestClient was not called.");
  });

  testWidgets("Uncheck items of category", (WidgetTester tester) async {
    final categoryToUncheck = "Test category";
    final item0 = ShoppingListItem("1", "A", true, categoryToUncheck);
    final item1 = ShoppingListItem("2", "B", false, categoryToUncheck);
    final item2 = ShoppingListItem("3", "C", true, null);
    List<ShoppingListItem> backendItems = [item0, item1, item2];

    String uncheckedCategory;

    final client = RestClientStub(
      onGetBackendInfo: () => BackendInfo(version, null),
      onGetShoppingLists: () {
        final adminPermissions = ShoppingListPermissions(ShoppingListRole.ADMIN, true, true, true);
        return [ShoppingListInfo("1", "TestList", adminPermissions, [])];
      },
      onFetchShoppingList: (id) => backendItems,
      onUncheckItems: (shoppingListId, ofCategory) {
        expect(shoppingListId, equals("1"));
        uncheckedCategory = ofCategory;
      },
    );

    await tester.pumpWidget(await makeTestableShoppingListApp(client));
    await tester.pumpAndSettle();

    // check that item0 is checked
    final item0Tile = find.widgetWithText(CheckboxListTile, item0.name);
    expect(item0Tile, findsOneWidget);
    {
      final item0TileWidget = item0Tile.evaluate().first.widget;
      expect(item0TileWidget, isInstanceOf<CheckboxListTile>());
      expect((item0TileWidget as CheckboxListTile).value, isTrue);
    }

    // check that item1 is unchecked
    final item1Tile = find.widgetWithText(CheckboxListTile, item1.name);
    expect(item1Tile, findsOneWidget);
    {
      final item1TileWidget = item1Tile.evaluate().first.widget;
      expect(item1TileWidget, isInstanceOf<CheckboxListTile>());
      expect((item1TileWidget as CheckboxListTile).value, isFalse);
    }

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

    final dropdownButton = find.widgetWithText(dropdownButtonType, localizations.manageCategoriesWhich);
    await tester.tap(dropdownButton);
    await tester.pumpAndSettle();

    final menuItemCategory = find.text(categoryToUncheck);
    expect(menuItemCategory, findsWidgets);
    await tester.tap(menuItemCategory.last);
    await tester.pumpAndSettle();

    // select uncheck items
    final uncheckItemsOption = find.text(localizations.manageCategoriesUncheckCategory(categoryToUncheck));
    expect(uncheckItemsOption, findsOneWidget);
    await tester.tap(uncheckItemsOption);
    await tester.pumpAndSettle();

    // the drawer should still be open... close it by tapping on the barrier
    await tester.tapAt(const Offset(0, 0));
    await tester.pumpAndSettle();

    // check that both items of the category are now unchecked and not obscured by a modal dialog or the drawer
    {
      expect(item0Tile.hitTestable(), findsOneWidget);
      final item0TileWidget = item0Tile.evaluate().first.widget;
      expect(item0TileWidget, isInstanceOf<CheckboxListTile>());
      expect((item0TileWidget as CheckboxListTile).value, isFalse);
    }
    {
      expect(item1Tile.hitTestable(), findsOneWidget);
      final item1TileWidget = item1Tile.evaluate().first.widget;
      expect(item1TileWidget, isInstanceOf<CheckboxListTile>());
      expect((item1TileWidget as CheckboxListTile).value, isFalse);
    }

    expect(uncheckedCategory, isNotNull,
        reason: "This is probably because the onUncheckItems callback of the RestClient was not called.");
    expect(uncheckedCategory, equals(categoryToUncheck));
  });

  testWidgets("Remove category", (WidgetTester tester) async {
    final categoryToRemove = "Test category";
    final item0 = ShoppingListItem("1", "A", true, categoryToRemove);
    final item1 = ShoppingListItem("2", "B", false, categoryToRemove);
    final item2 = ShoppingListItem("3", "C", true, null);
    List<ShoppingListItem> backendItems = [item0, item1, item2];

    String removedCategory;

    final client = RestClientStub(
      onGetBackendInfo: () => BackendInfo(version, null),
      onGetShoppingLists: () {
        final adminPermissions = ShoppingListPermissions(ShoppingListRole.ADMIN, true, true, true);
        return [ShoppingListInfo("1", "TestList", adminPermissions, [])];
      },
      onFetchShoppingList: (id) => backendItems,
      onRemoveCategory: (shoppingListId, category) {
        expect(shoppingListId, equals("1"));
        removedCategory = category;
      },
    );

    await tester.pumpWidget(await makeTestableShoppingListApp(client));
    await tester.pumpAndSettle();

    // Check that we find two items with the category
    expect(find.widgetWithText(CheckboxListTile, categoryToRemove), findsNWidgets(2));

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

    final dropdownButton = find.widgetWithText(dropdownButtonType, localizations.manageCategoriesWhich);
    await tester.tap(dropdownButton);
    await tester.pumpAndSettle();

    final menuItemCategory = find.text(categoryToRemove);
    expect(menuItemCategory, findsWidgets);
    await tester.tap(menuItemCategory.last);
    await tester.pumpAndSettle();

    // select remove category
    final removeCategoryOption = find.text(localizations.manageCategoriesRemoveCategory(categoryToRemove));
    expect(removeCategoryOption, findsOneWidget);
    await tester.tap(removeCategoryOption);
    await tester.pumpAndSettle();

    // the drawer should still be open... close it by tapping on the barrier
    await tester.tapAt(const Offset(0, 0));
    await tester.pumpAndSettle();

    // check that we no longer find an item with that category...
    expect(find.widgetWithText(CheckboxListTile, categoryToRemove), findsNothing);

    // ...but there should still be 3 items (not obscured by a dialog or the drawer)
    expect(find.byType(CheckboxListTile).hitTestable(), findsNWidgets(3));

    expect(removedCategory, isNotNull,
        reason: "This is probably because the onRemoveCategory callback of the RestClient was not called.");
    expect(removedCategory, equals(categoryToRemove));
  });

  testWidgets("Rename category", (WidgetTester tester) async {
    final categoryToRename = "Test category";
    final newCategoryName = "Renamed test category";
    final item0 = ShoppingListItem("1", "A", true, categoryToRename);
    final item1 = ShoppingListItem("2", "B", false, categoryToRename);
    final item2 = ShoppingListItem("3", "C", true, null);
    List<ShoppingListItem> backendItems = [item0, item1, item2];

    String renamedCategory;
    String newNameOfRenamedCategory;

    final client = RestClientStub(
      onGetBackendInfo: () => BackendInfo(version, null),
      onGetShoppingLists: () {
        final adminPermissions = ShoppingListPermissions(ShoppingListRole.ADMIN, true, true, true);
        return [ShoppingListInfo("1", "TestList", adminPermissions, [])];
      },
      onFetchShoppingList: (id) => backendItems,
      onRenameCategory: (shoppingListId, oldCategoryName, newCategoryName) {
        expect(shoppingListId, equals("1"));
        renamedCategory = oldCategoryName;
        newNameOfRenamedCategory = newCategoryName;
      },
    );

    await tester.pumpWidget(await makeTestableShoppingListApp(client));
    await tester.pumpAndSettle();

    // check that we find two items with the category
    expect(find.widgetWithText(CheckboxListTile, categoryToRename), findsNWidgets(2));

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

    final dropdownButton = find.widgetWithText(dropdownButtonType, localizations.manageCategoriesWhich);
    await tester.tap(dropdownButton);
    await tester.pumpAndSettle();

    final menuItemCategory = find.text(categoryToRename);
    expect(menuItemCategory, findsWidgets);
    await tester.tap(menuItemCategory.last);
    await tester.pumpAndSettle();

    // select rename category
    final renameCategoryOption = find.text(localizations.manageCategoriesRenameCategory(categoryToRename));
    expect(renameCategoryOption, findsOneWidget);
    await tester.tap(renameCategoryOption);
    // Once the rename option has been pressed a progress animation is shown in the background
    // until the rename operation has been completed. Therefore we use pump instead of pumpAndSettle.
    await tester.pump();

    // enter the new category name
    final newCategoryNameInput = find.widgetWithText(TextField, categoryToRename);
    expect(newCategoryNameInput, findsOneWidget);
    await tester.enterText(newCategoryNameInput, newCategoryName);
    await tester.pump();

    // press confirm button
    final confirmButton = find.widgetWithText(ElevatedButton, localizations.ok);
    expect(confirmButton, findsOneWidget);
    await tester.tap(confirmButton);
    await tester.pumpAndSettle();

    // the drawer should still be open... close it by tapping on the barrier
    await tester.tapAt(const Offset(0, 0));
    await tester.pumpAndSettle();

    // check that we no longer find an item with the old category name...
    expect(find.widgetWithText(CheckboxListTile, categoryToRename), findsNothing);
    // ...but two with the new category name (not obscured by a dialog or the drawer)
    expect(find.widgetWithText(CheckboxListTile, newCategoryName).hitTestable(), findsNWidgets(2));

    expect(renamedCategory, isNotNull,
        reason: "This is probably because the onRenameCategory callback of the RestClient was not called.");
    expect(renamedCategory, equals(categoryToRename));
    expect(newNameOfRenamedCategory, equals(newCategoryName));
  });

  testWidgets("Remove all categories", (WidgetTester tester) async {
    final item0 = ShoppingListItem("1", "A", true, "Category1");
    final item1 = ShoppingListItem("2", "B", false, "Category2");
    final item2 = ShoppingListItem("3", "C", true, null);
    List<ShoppingListItem> backendItems = [item0, item1, item2];

    bool removedAllCategories = false;

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
        removedAllCategories = category == null;
      },
    );

    await tester.pumpWidget(await makeTestableShoppingListApp(client));
    await tester.pumpAndSettle();

    // check that we find an item for each category
    expect(find.widgetWithText(CheckboxListTile, item0.category), findsOneWidget);
    expect(find.widgetWithText(CheckboxListTile, item1.category), findsOneWidget);

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
    final dropdownButton = find.widgetWithText(dropdownButtonType, localizations.manageCategoriesWhich);
    await tester.tap(dropdownButton);
    await tester.pumpAndSettle();

    final menuItemCategoryAll = find.text(CATEGORY_ALL);
    expect(menuItemCategoryAll, findsWidgets);
    await tester.tap(menuItemCategoryAll.last);
    await tester.pumpAndSettle();

    // select uncheck items
    final uncheckItemsOption = find.text(localizations.manageCategoriesRemoveCategories);
    await tester.tap(uncheckItemsOption);
    await tester.pumpAndSettle();

    // the drawer should still be open... close it by tapping on the barrier
    await tester.tapAt(const Offset(0, 0));
    await tester.pumpAndSettle();

    // check that we no longer find the categories
    expect(find.widgetWithText(CheckboxListTile, item0.category), findsNothing);
    expect(find.widgetWithText(CheckboxListTile, item1.category), findsNothing);

    // but we still find the items (not obscured by a dialog or the drawer)
    expect(find.widgetWithText(CheckboxListTile, item0.name).hitTestable(), findsOneWidget);
    expect(find.widgetWithText(CheckboxListTile, item1.name).hitTestable(), findsOneWidget);
    expect(find.widgetWithText(CheckboxListTile, item2.name).hitTestable(), findsOneWidget);

    expect(removedAllCategories, isTrue,
        reason: "This is probably because the onRemoveCategory callback of the RestClient was not called.");
  });

  testWidgets("Open category manager dialog with long press on category tab", (WidgetTester tester) async {
    final categoryToOpenDialog = "Test category";
    final item0 = ShoppingListItem("1", "A", true, categoryToOpenDialog);
    final item1 = ShoppingListItem("2", "B", false, categoryToOpenDialog);
    final item2 = ShoppingListItem("3", "C", true, null);
    List<ShoppingListItem> backendItems = [item0, item1, item2];

    final client = RestClientStub(
      onGetBackendInfo: () => BackendInfo(version, null),
      onGetShoppingLists: () {
        final adminPermissions = ShoppingListPermissions(ShoppingListRole.ADMIN, true, true, true);
        return [ShoppingListInfo("1", "TestList", adminPermissions, [])];
      },
      onFetchShoppingList: (id) => backendItems,
    );

    await tester.pumpWidget(await makeTestableShoppingListApp(client));
    await tester.pumpAndSettle();

    // Check that we find a tab for the category
    final categoryTab = find.widgetWithText(Tab, categoryToOpenDialog);
    expect(categoryTab, findsOneWidget);
    await tester.longPress(categoryTab);
    await tester.pumpAndSettle();

    // check that the dialog is open
    expect(find.text(localizations.manageCategoriesTitle), findsOneWidget);

    // check that the category is preselected
    final dropDownButton = find.widgetWithText(dropdownButtonType, categoryToOpenDialog);
    expect(dropDownButton, findsOneWidget);
    final dropDownButtonWidget = dropDownButton.evaluate().first.widget as DropdownButton<String>;
    expect(dropDownButtonWidget.value, equals(categoryToOpenDialog));
  });

  testWidgets('Logout when fetching shopping list infos if unauthenticated', (WidgetTester tester) async {
    final client = RestClientStub(
      onGetBackendInfo: () => BackendInfo(version, null),
      onGetShoppingLists: () => throw HttpResponseException.unAuthenticated(),
    );

    await tester.pumpWidget(await makeTestableShoppingListApp(client));
    await tester.pumpAndSettle();

    await checkIsUnAuthenticatedDialogAndDismiss(tester, localizations);
    checkIsLoginPage(localizations);
  });

  testWidgets('Logout when fetching shopping list if unauthenticated', (WidgetTester tester) async {
    final client = RestClientStub(
      onGetBackendInfo: () => BackendInfo(version, null),
      onGetShoppingLists: () {
        final adminPermissions = ShoppingListPermissions(ShoppingListRole.ADMIN, true, true, true);
        return [ShoppingListInfo("1", "TestList", adminPermissions, [])];
      },
      onFetchShoppingList: (id) => throw HttpResponseException.unAuthenticated(),
    );

    await tester.pumpWidget(await makeTestableShoppingListApp(client));
    await tester.pumpAndSettle();

    await checkIsUnAuthenticatedDialogAndDismiss(tester, localizations);
    checkIsLoginPage(localizations);
  });

  testWidgets('Logout when setting category if unauthenticated', (WidgetTester tester) async {
    final item = ShoppingListItem("1", "A", false, null);

    final client = RestClientStub(
        onGetBackendInfo: () => BackendInfo(version, null),
        onGetShoppingLists: () {
          final adminPermissions = ShoppingListPermissions(ShoppingListRole.ADMIN, true, true, true);
          return [ShoppingListInfo("1", "TestList", adminPermissions, [])];
        },
        onFetchShoppingList: (id) => [item],
        onUpdateShoppingListItem: (id, item) => throw HttpResponseException.unAuthenticated());

    await tester.pumpWidget(await makeTestableShoppingListApp(client));
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
    final item = ShoppingListItem("1", "A", false, null);

    final client = RestClientStub(
        onGetBackendInfo: () => BackendInfo(version, null),
        onGetShoppingLists: () {
          final adminPermissions = ShoppingListPermissions(ShoppingListRole.ADMIN, true, true, true);
          return [ShoppingListInfo("1", "TestList", adminPermissions, [])];
        },
        onFetchShoppingList: (id) => [item],
        onUpdateShoppingListItem: (id, item) => throw HttpResponseException.unAuthenticated());

    await tester.pumpWidget(await makeTestableShoppingListApp(client));
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
    final item = ShoppingListItem("1", "A", false, null);

    final client = RestClientStub(
        onGetBackendInfo: () => BackendInfo(version, null),
        onGetShoppingLists: () {
          final adminPermissions = ShoppingListPermissions(ShoppingListRole.ADMIN, true, true, true);
          return [ShoppingListInfo("1", "TestList", adminPermissions, [])];
        },
        onFetchShoppingList: (id) => [item],
        onDeleteShoppingListItem: (id, item) => throw HttpResponseException.unAuthenticated());

    await tester.pumpWidget(await makeTestableShoppingListApp(client));
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
    final client = RestClientStub(
        onGetBackendInfo: () => BackendInfo(version, null),
        onGetShoppingLists: () {
          final adminPermissions = ShoppingListPermissions(ShoppingListRole.ADMIN, true, true, true);
          return [ShoppingListInfo("1", "TestList", adminPermissions, [])];
        },
        onFetchShoppingList: (id) => [],
        onCreateShoppingListItem: (id, name, category) => throw HttpResponseException.unAuthenticated());

    await tester.pumpWidget(await makeTestableShoppingListApp(client));
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

  testWidgets('Rename shopping list', (WidgetTester tester) async {
    final adminPermissions = ShoppingListPermissions(ShoppingListRole.ADMIN, true, true, true);
    final listId = "1";
    final oldListName = "TestList";
    final newListName = "NewListName";

    String renamedListName;
    final client = RestClientStub(
      onGetBackendInfo: () => BackendInfo(version, null),
      onGetShoppingLists: () => [ShoppingListInfo(listId, oldListName, adminPermissions, [])],
      onFetchShoppingList: (id) => [],
      onRenameShoppingList: (shoppingListId, newName) {
        expect(shoppingListId, equals(listId));
        renamedListName = newName;
      },
    );

    await tester.pumpWidget(await makeTestableShoppingListApp(client));
    await tester.pumpAndSettle();

    // open drawer
    final drawerIcon = find.widgetWithIcon(IconButton, Icons.menu);
    expect(drawerIcon, findsOneWidget);
    await tester.tap(drawerIcon);
    await tester.pumpAndSettle();

    // open list settings
    final listSettingsMenuItem = find.widgetWithText(ListTile, localizations.listSettings);
    expect(listSettingsMenuItem, findsOneWidget);
    await tester.tap(listSettingsMenuItem);
    await tester.pumpAndSettle();

    // check that we see the list name
    expect(find.text(oldListName), findsOneWidget);

    // find and tap the rename button
    final renameListBtn = find.widgetWithIcon(IconButton, Icons.drive_file_rename_outline);
    expect(renameListBtn, findsOneWidget);
    await tester.tap(renameListBtn);
    await tester.pumpAndSettle();

    // find the input field for the list name and enter the new name
    final renameField = find.widgetWithText(TextField, oldListName);
    expect(renameField, findsOneWidget);
    await tester.enterText(renameField, newListName);

    // find and press the confirm button
    final confirmRenameListBtn = find.widgetWithIcon(IconButton, Icons.check);
    expect(confirmRenameListBtn, findsOneWidget);
    await tester.tap(confirmRenameListBtn);
    await tester.pumpAndSettle();

    // check that we find the new name
    expect(find.text(newListName), findsOneWidget);

    // ...but no longer the old name
    expect(find.text(oldListName), findsNothing);

    // leave the list settings
    final backBtn = find.widgetWithIcon(IconButton, Icons.arrow_back);
    expect(backBtn, findsOneWidget);
    await tester.tap(backBtn);
    await tester.pumpAndSettle();

    // check that we find the new name (visible in drawer and appbar)
    expect(find.text(newListName), findsWidgets);

    // ...but no longer the old name
    expect(find.text(oldListName), findsNothing);

    // check that the rename was sent to the backend
    expect(renamedListName, isNotNull,
        reason: "This is probably because the onRenameShoppingList callback of the RestClient was not called.");
    expect(renamedListName, equals(newListName));
  });

  testWidgets('Remove all items from shopping list', (WidgetTester tester) async {
    final adminPermissions = ShoppingListPermissions(ShoppingListRole.ADMIN, true, true, true);
    final listId = "1";
    final listName = "RemoveAllItemsTestList";

    final item0 = ShoppingListItem("0", "item0", false, null);
    final item1 = ShoppingListItem("1", "item1", false, null);

    bool allItemsRemoved = false;
    final client = RestClientStub(
      onGetBackendInfo: () => BackendInfo(version, null),
      onGetShoppingLists: () => [ShoppingListInfo(listId, listName, adminPermissions, [])],
      onFetchShoppingList: (id) => allItemsRemoved ? [] : [item0, item1],
      onRemoveAllItems: (shoppingListId) {
        expect(shoppingListId, equals(listId));
        allItemsRemoved = true;
      },
    );

    await tester.pumpWidget(await makeTestableShoppingListApp(client));
    await tester.pumpAndSettle();

    // check that both items are visible
    expect(find.widgetWithText(CheckboxListTile, item0.name), findsOneWidget);
    expect(find.widgetWithText(CheckboxListTile, item1.name), findsOneWidget);

    // open drawer
    final drawerIcon = find.widgetWithIcon(IconButton, Icons.menu);
    expect(drawerIcon, findsOneWidget);
    await tester.tap(drawerIcon);
    await tester.pumpAndSettle();

    // open list settings
    final listSettingsMenuItem = find.widgetWithText(ListTile, localizations.listSettings);
    expect(listSettingsMenuItem, findsOneWidget);
    await tester.tap(listSettingsMenuItem);
    await tester.pumpAndSettle();

    // find and tap the remove-all-items button
    final removeItemsBtn = find.widgetWithText(OutlinedButton, localizations.listSettingsClearList);
    expect(removeItemsBtn, findsOneWidget);
    await tester.tap(removeItemsBtn);

    // Once the remove-all-items button has been pressed a progress animation is shown in the background
    // until the remove operation has been completed. Therefore we use pump instead of pumpAndSettle.
    await tester.pump();

    // check that a confirmation message is visible
    expect(find.text(localizations.listSettingsClearListConfirmationText(listName)), findsOneWidget);

    // press the confirm button
    final confirmBtn = find.widgetWithText(ElevatedButton, localizations.ok);
    expect(confirmBtn, findsOneWidget);
    await tester.tap(confirmBtn);
    await tester.pumpAndSettle();

    // leave the list settings
    final backBtn = find.widgetWithIcon(IconButton, Icons.arrow_back);
    expect(backBtn, findsOneWidget);
    await tester.tap(backBtn);
    await tester.pumpAndSettle();

    // close the drawer
    await tester.tapAt(const Offset(0, 0));
    await tester.pumpAndSettle();

    // no items should be visible
    expect(find.byType(CheckboxListTile), findsNothing);

    // check that the remove endpoint was called
    expect(allItemsRemoved, isTrue,
        reason: "This is probably because the onRemoveAllItems callback of the RestClient was not called.");
  });

  testWidgets('Add user to shopping list', (WidgetTester tester) async {
    final adminPermissions = ShoppingListPermissions(ShoppingListRole.ADMIN, true, true, true);
    final listId = "1";

    final otherUser = ShoppingListUserReference("0", "Other User", "other@user.test", ShoppingListRole.READ_WRITE);
    bool otherUserAdded = false;
    final client = RestClientStub(
      onGetBackendInfo: () => BackendInfo(version, null),
      onGetShoppingLists: () => [
        ShoppingListInfo(listId, "Test List", adminPermissions, otherUserAdded ? [otherUser] : [])
      ],
      onFetchShoppingList: (id) => [],
      onAddUserToShoppingList: (shoppingListId, userEmailAddress) {
        expect(shoppingListId, listId);
        expect(userEmailAddress, otherUser.userEmailAddress);
        otherUserAdded = true;
        return otherUser;
      },
    );

    await tester.pumpWidget(await makeTestableShoppingListApp(client));
    await tester.pumpAndSettle();

    // open drawer
    final drawerIcon = find.widgetWithIcon(IconButton, Icons.menu);
    expect(drawerIcon, findsOneWidget);
    await tester.tap(drawerIcon);
    await tester.pumpAndSettle();

    // open list settings
    final listSettingsMenuItem = find.widgetWithText(ListTile, localizations.listSettings);
    expect(listSettingsMenuItem, findsOneWidget);
    await tester.tap(listSettingsMenuItem);
    await tester.pumpAndSettle();

    // find the input field for adding another user to the list by entering his email address
    final otherUserEmailField = find.widgetWithText(TextField, localizations.listSettingsAddUserToListEmailAddressHint);
    expect(otherUserEmailField, findsOneWidget);
    await tester.enterText(otherUserEmailField, otherUser.userEmailAddress);

    // press the add button
    final addBtn = find.widgetWithIcon(IconButton, Icons.add);
    expect(addBtn, findsOneWidget);
    await tester.tap(addBtn);
    await tester.pumpAndSettle();

    // find the list tile of the added user
    final otherUserInfoTile = find.widgetWithText(ListTile, otherUser.userName);
    expect(otherUserInfoTile, findsOneWidget);
    // ...the tile should show the email address
    expect(find.descendant(of: otherUserInfoTile, matching: find.text(otherUser.userEmailAddress)), findsOneWidget);
    // ...and the permission icon
    expect(find.descendant(of: otherUserInfoTile, matching: find.byIcon(otherUser.userRole.toIcon())), findsOneWidget);

    // check that the add user to list endpoint was called
    expect(otherUserAdded, isTrue,
        reason: "This is probably because the onAddUserToShoppingList callback of the RestClient was not called.");
  });
}
