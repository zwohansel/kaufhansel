import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaufhansel_client/generated/l10n.dart';
import 'package:kaufhansel_client/model.dart';
import 'package:kaufhansel_client/rest_client.dart';
import 'package:kaufhansel_client/shopping_list_item_edit_dialog.dart';
import 'package:kaufhansel_client/synced_shoppinglist.dart';

import 'rest_client_stub.dart';
import 'utils.dart';

void main() {
  const testLocale = Locale("de");
  late AppLocalizations localizations;

  setUp(() async {
    localizations = await AppLocalizations.load(testLocale);
  });

  final listId = "1234";

  SyncedShoppingList createSyncedListForItem(ShoppingListItem item, RestClient client) {
    final permission = ShoppingListPermissions(ShoppingListRole.ADMIN, true, true, true);
    final listInfo = ShoppingListInfo(listId, "test", permission, []);
    final list = ShoppingList(listInfo, [item]);
    return SyncedShoppingList(client, list);
  }

  Widget createDialog(SyncedShoppingListItem item, {List<String>? categories}) {
    return EditShoppingListItemDialog(item: item, categories: categories ?? []);
  }

  testWidgets('showDialog', (WidgetTester tester) async {
    final client = RestClientStub();

    final item = ShoppingListItem("0", "name", false, null);
    final list = createSyncedListForItem(item, client);
    final dialog = createDialog(list.items.first);

    await tester.pumpWidget(await makeTestableWidget(dialog, restClient: client, locale: testLocale));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(MoreOptionsEditableTextLabel, item.name), findsOneWidget);
    expect(find.text(localizations.categoryChooseOne), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, localizations.categoryNone), findsOneWidget);
    expect(find.widgetWithText(TextField, localizations.categoryCreateNew), findsOneWidget);
  });

  testWidgets('showDialogWithCategoriesAndChooseCategory', (WidgetTester tester) async {
    ShoppingListItem? updatedShoppingListItem;
    final client = RestClientStub(onUpdateShoppingListItem: (String shoppingListId, ShoppingListItem item) {
      expect(shoppingListId, equals(listId));
      updatedShoppingListItem = item;
    });

    final item = ShoppingListItem("0", "Item name", false, null);
    final list = createSyncedListForItem(item, client);
    final dialog = createDialog(list.items.first, categories: ["Category1", "Category2"]);

    await tester.pumpWidget(await makeTestableWidget(dialog, restClient: client, locale: testLocale));
    await tester.pumpAndSettle();

    final categoryOneBtn = find.widgetWithText(OutlinedButton, "Category1");
    expect(categoryOneBtn, findsOneWidget);

    final categoryTwoBtn = find.widgetWithText(OutlinedButton, "Category2");
    expect(categoryTwoBtn, findsOneWidget);

    await tester.tap(categoryTwoBtn);
    await tester.pumpAndSettle();

    expect(updatedShoppingListItem, isNotNull);
    expect(updatedShoppingListItem?.category, "Category2");
    expect(item.category, equals("Category2"));
  });

  testWidgets('addNewCategory', (WidgetTester tester) async {
    final newCategoryName = "New category";
    ShoppingListItem? updatedShoppingListItem;
    final client = RestClientStub(onUpdateShoppingListItem: (String shoppingListId, ShoppingListItem item) {
      expect(shoppingListId, equals(listId));
      updatedShoppingListItem = item;
    });
    final item = ShoppingListItem("0", "name", false, null);
    final list = createSyncedListForItem(item, client);
    final dialog = createDialog(list.items.first);

    await tester.pumpWidget(await makeTestableWidget(dialog, restClient: client, locale: testLocale));
    await tester.pumpAndSettle();

    await enterText(tester,
        widgetType: TextField, fieldLabelOrHint: localizations.categoryCreateNew, text: newCategoryName);
    await tester.pumpAndSettle();
    final submitButton = find.widgetWithIcon(IconButton, Icons.check);
    expect(submitButton, findsOneWidget);
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    expect(updatedShoppingListItem, isNotNull);
    expect(updatedShoppingListItem?.category, newCategoryName);
    expect(item.category, equals(newCategoryName));
  });

  testWidgets('editItemName', (WidgetTester tester) async {
    final newItemName = "New item name";
    ShoppingListItem? updatedShoppingListItem;
    final client = RestClientStub(onUpdateShoppingListItem: (String shoppingListId, ShoppingListItem item) {
      expect(shoppingListId, equals(listId));
      updatedShoppingListItem = item;
    });

    final item = ShoppingListItem("0", "Item name", false, null);
    final list = createSyncedListForItem(item, client);
    final dialog = createDialog(list.items.first);

    await tester.pumpWidget(await makeTestableWidget(dialog, restClient: client, locale: testLocale));
    await tester.pumpAndSettle();

    final moreButton = find.widgetWithIcon(IconButton, Icons.more_vert);
    expect(moreButton, findsOneWidget);
    await tester.tap(moreButton);
    await tester.pumpAndSettle();

    final renameMenuEntry = find.text(localizations.itemRename);
    expect(renameMenuEntry, findsOneWidget);
    await tester.tap(renameMenuEntry);
    await tester.pumpAndSettle();

    await enterText(tester, widgetType: TextField, fieldLabelOrHint: item.name, text: newItemName);
    await tester.testTextInput.receiveAction(TextInputAction.done);

    expect(updatedShoppingListItem, isNotNull);
    expect(updatedShoppingListItem?.name, equals(newItemName));
    expect(item.name, equals(newItemName));
  });

  testWidgets('deleteItem', (WidgetTester tester) async {
    ShoppingListItem? removedItem;
    final client = RestClientStub(onDeleteShoppingListItem: (shoppingListId, item) {
      expect(shoppingListId, equals(listId));
      removedItem = item;
    });
    final item = ShoppingListItem(listId, "Test", false, null);
    final list = createSyncedListForItem(item, client);
    final dialog = createDialog(list.items.first);

    await tester.pumpWidget(await makeTestableWidget(dialog, locale: testLocale));
    await tester.pumpAndSettle();

    final moreButton = find.widgetWithIcon(IconButton, Icons.more_vert);
    expect(moreButton, findsOneWidget);
    await tester.tap(moreButton);
    await tester.pumpAndSettle();

    final removeMenuEntry = find.text(localizations.itemRemove);
    expect(removeMenuEntry, findsOneWidget);
    await tester.tap(removeMenuEntry);
    await tester.pumpAndSettle();

    expect(list.items, isEmpty);
    expect(removedItem, equals(item));
  });
}
