import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaufhansel_client/generated/l10n.dart';
import 'package:kaufhansel_client/model.dart';
import 'package:kaufhansel_client/rest_client.dart';
import 'package:kaufhansel_client/shopping_list_item_edit_dialog.dart';

import 'rest_client_stub.dart';
import 'utils.dart';

void main() {
  const testLocale = Locale("de");
  AppLocalizations localizations;
  RestClientStub client;

  setUp(() async {
    localizations = await AppLocalizations.load(testLocale);
    client = new RestClientStub();
  });

  testWidgets('showDialog', (WidgetTester tester) async {
    final dialog = createDialog(client, item(), []);

    await tester.pumpWidget(await makeTestableWidget(dialog, restClient: client, locale: testLocale));
    await tester.pumpAndSettle();

    checkAlwaysPresent(localizations);
  });

  testWidgets('showDialogWithCategoriesAndChooseCategory', (WidgetTester tester) async {
    final dialog = createDialog(client, item(), ["Category1", "Category2"]);

    await tester.pumpWidget(await makeTestableWidget(dialog, restClient: client, locale: testLocale));
    await tester.pumpAndSettle();

    checkAlwaysPresent(localizations);
    //TODO: check for color
    expect(find.widgetWithText(OutlinedButton, "Category1"), findsOneWidget);

    final categoryButton = find.widgetWithText(OutlinedButton, "Category2");
    expect(categoryButton, findsOneWidget);

    await tester.tap(categoryButton);
    await tester.pumpAndSettle();

    expect(client.updatedShoppingListItem.category, "Category2");
  });

  testWidgets('addNewCategory', (WidgetTester tester) async {
    final dialog = createDialog(client, item(), []);

    await tester.pumpWidget(await makeTestableWidget(dialog, restClient: client, locale: testLocale));
    await tester.pumpAndSettle();

    await enterText(tester,
        widgetType: TextField, fieldLabelOrHint: localizations.categoryCreateNew, text: "New category");
    await tester.pumpAndSettle();
    final submitButton = find.widgetWithIcon(IconButton, Icons.check);
    expect(submitButton, findsOneWidget);
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    expect(client.updatedShoppingListItem.category, "New category");
  });

  testWidgets('editItemName', (WidgetTester tester) async {
    final dialog = createDialog(client, item(), []);

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

    await enterText(tester, widgetType: TextField, fieldLabelOrHint: "Item name", text: "New item name");
    await tester.testTextInput.receiveAction(TextInputAction.done);

    expect(client.updatedShoppingListItem.name, "New item name");
  });

  testWidgets('deleteItem', (WidgetTester tester) async {
    ShoppingListItem deletedItem;
    final dialog = createDialog(client, item(), [], onDeleteItem: (item) async {
      deletedItem = item;
    });

    await tester.pumpWidget(await makeTestableWidget(dialog, restClient: client, locale: testLocale));
    await tester.pumpAndSettle();

    final moreButton = find.widgetWithIcon(IconButton, Icons.more_vert);
    expect(moreButton, findsOneWidget);
    await tester.tap(moreButton);
    await tester.pumpAndSettle();

    final removeMenuEntry = find.text(localizations.itemRemove);
    expect(removeMenuEntry, findsOneWidget);
    await tester.tap(removeMenuEntry);
    await tester.pumpAndSettle();

    expect(deletedItem.id, "id0");
  });
}

void checkAlwaysPresent(AppLocalizations localizations) {
  expect(find.widgetWithText(MoreOptionsEditableTextLabel, "Item name"), findsOneWidget);
  expect(find.text(localizations.categoryChooseOne), findsOneWidget);
  expect(find.widgetWithText(OutlinedButton, localizations.categoryNone), findsOneWidget);
  expect(find.widgetWithText(TextField, localizations.categoryCreateNew), findsOneWidget);
}

ShoppingListItem item({String category = ""}) {
  return ShoppingListItem("id0", "Item name", false, "");
}

Widget createDialog(RestClient client, ShoppingListItem item, List<String> categories,
    {Future<void> Function(ShoppingListItem) onDeleteItem}) {
  return EditShoppingListItemDialog(
      item: item, shoppingListId: null, client: client, categories: categories, onDeleteItem: onDeleteItem);
}
