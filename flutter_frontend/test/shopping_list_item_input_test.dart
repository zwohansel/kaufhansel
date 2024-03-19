import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaufhansel_client/generated/l10n.dart';
import 'package:kaufhansel_client/model.dart';
import 'package:kaufhansel_client/shopping_list_item_input.dart';
import 'package:kaufhansel_client/synced_shoppinglist.dart';
import 'package:kaufhansel_client/widgets/async_operation_icon_button.dart';
import 'package:provider/provider.dart';

import 'rest_client_stub.dart';
import 'scroll_controller_stub.dart';
import 'utils.dart';

void main() {
  const testLocale = Locale("de");
  late AppLocalizations localizations;
  ScrollController scrollController;
  late ShoppingListItemInput itemInput;

  setUp(() async {
    localizations = await AppLocalizations.load(testLocale);
    scrollController = new ScrollControllerStub();

    itemInput = new ShoppingListItemInput(shoppingListScrollController: scrollController, onChange: (_) {});
  });

  testWidgets("showClearButtonIfTextFieldIsNotEmpty", (WidgetTester tester) async {
    await tester.pumpWidget(await makeTestableWidget(Material(child: itemInput), locale: testLocale));
    await tester.pumpAndSettle();

    await enterText(tester, widgetType: TextField, fieldLabelOrHint: localizations.createOrSearchHint, text: "foo");
    await tester.pumpAndSettle();
    expect(find.widgetWithIcon(TextField, Icons.clear), findsOneWidget);

    final clearButton = find.widgetWithIcon(IconButton, Icons.clear);
    await tester.tap(clearButton);
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextField, "foo"), findsNothing);
  });

  testWidgets("addNewItemIfTextIsValid", (WidgetTester tester) async {
    final shoppingList = new ShoppingList(new ShoppingListInfo("_id", "_name", ShoppingListPermissions(ShoppingListRole.READ_ONLY, false, false, false), []), []);
    final client = RestClientStub(onCreateShoppingListItem: (String shoppingListId, String name, String? category) {
      expect(shoppingListId, equals("_id"));
      expect(name, equals("New Item"));
      expect(category, isNull);
      return ShoppingListItem("0", "New Item", false, "");
    });

    await tester.pumpWidget(await makeTestableWidget(
        Material(
          child: ChangeNotifierProvider<SyncedShoppingList>.value(
            value: SyncedShoppingList(client, shoppingList),
            builder: (context, child) => itemInput,
          ),
        ),
        locale: testLocale));
    await tester.pumpAndSettle();

    await enterText(tester,
        widgetType: TextField, fieldLabelOrHint: localizations.createOrSearchHint, text: "New Item");
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithIcon(AsyncOperationIconButton, Icons.add));
    await tester.pump(); // pump one frame to start the scroll down animation
    await tester.pump(Duration(seconds: 1)); // the animation should be over after less than one second

    expect(find.widgetWithText(TextField, "New Item"), findsNothing);
    expect(shoppingList.items.length, 1);
  });
}
