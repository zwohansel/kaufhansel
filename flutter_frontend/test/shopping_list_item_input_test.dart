import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaufhansel_client/generated/l10n.dart';
import 'package:kaufhansel_client/model.dart';
import 'package:kaufhansel_client/shopping_list_item_input.dart';
import 'package:kaufhansel_client/widgets/async_operation_icon_button.dart';
import 'package:provider/provider.dart';

import 'rest_client_stub.dart';
import 'scroll_controller_stub.dart';
import 'utils.dart';

void main() {
  const testLocale = Locale("de");
  AppLocalizations localizations;
  RestClientStub client;
  ScrollController scrollController;
  ShoppingListItemInput itemInput;

  setUp(() async {
    localizations = await AppLocalizations.load(testLocale);
    client = new RestClientStub();
    scrollController = new ScrollControllerStub();

    itemInput = new ShoppingListItemInput(shoppingListScrollController: scrollController, onChange: (_) {});
  });

  testWidgets("showClearButtonIfTextFieldIsNotEmpty", (WidgetTester tester) async {
    await tester
        .pumpWidget(await makeTestableWidget(Material(child: itemInput), restClient: client, locale: testLocale));
    await tester.pumpAndSettle();

    await enterText(tester, widgetType: TextField, fieldLabelOrHint: localizations.shoppingListNeededHint, text: "foo");
    await tester.pumpAndSettle();
    expect(find.widgetWithIcon(TextField, Icons.clear), findsOneWidget);

    final clearButton = find.widgetWithIcon(IconButton, Icons.clear);
    await tester.tap(clearButton);
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextField, "foo"), findsNothing);
  });

  testWidgets("addNewItemIfTextIsValid", (WidgetTester tester) async {
    final shoppingList = new ShoppingList(new ShoppingListInfo("_id", "_name", null, []), []);
    client.mockCreateShoppingListItem(new ShoppingListItem("0", "New Item", false, ""));

    await tester.pumpWidget(await makeTestableWidget(
        Material(
          child: ChangeNotifierProvider<ShoppingList>.value(
            value: shoppingList,
            builder: (context, child) => itemInput,
          ),
        ),
        restClient: client,
        locale: testLocale));
    await tester.pumpAndSettle();

    await enterText(tester,
        widgetType: TextField, fieldLabelOrHint: localizations.shoppingListNeededHint, text: "New Item");
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithIcon(AsyncOperationIconButton, Icons.add));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextField, "New Item"), findsNothing);
    expect(shoppingList.items.length, 1);
  });
}
