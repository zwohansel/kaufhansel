import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaufhansel_client/generated/l10n.dart';
import 'package:kaufhansel_client/rest_client.dart';
import 'package:kaufhansel_client/shopping_list_item_input.dart';

import 'rest_client_stub.dart';
import 'utils.dart';

void main() {
  const testLocale = Locale("de");
  AppLocalizations localizations;
  RestClient client;
  ScrollController scrollController;

  setUp(() async {
    localizations = await AppLocalizations.load(testLocale);
    client = new RestClientStub();
    scrollController = new ScrollController();
  });

  testWidgets("showClearButtonIfTextFieldIsNotEmpty", (WidgetTester tester) async {
    final ShoppingListItemInput itemInput = new ShoppingListItemInput(
      shoppingListScrollController: scrollController,
      onChange: (x) {},
    );

    await tester
        .pumpWidget(await makeTestableWidget(Material(child: itemInput), restClient: client, locale: testLocale));
    await tester.pumpAndSettle();

    final textField = find.widgetWithText(TextField, localizations.shoppingListNeededHint);
    expect(textField, findsOneWidget);

    await tester.enterText(textField, "foo");
    await tester.pumpAndSettle();
    expect(find.widgetWithIcon(TextField, Icons.clear), findsOneWidget);

    final clearButton = find.widgetWithIcon(IconButton, Icons.clear);
    await tester.tap(clearButton);
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextField, "foo"), findsNothing);
  });
}
