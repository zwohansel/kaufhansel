import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaufhansel_client/generated/l10n.dart';
import 'package:kaufhansel_client/list_settings/danger_card.dart';
import 'package:kaufhansel_client/model.dart';

import 'utils.dart';

void main() {
  const testLocale = Locale("de");
  late AppLocalizations localizations;

  setUp(() async {
    localizations = await AppLocalizations.load(testLocale);
  });

  testWidgets('DeleteIfSelfIsAdminAndOtherAdminsPresent', (WidgetTester tester) async {
    final info = ShoppingListInfo(
      "1234",
      "TestList",
      ShoppingListPermissions(ShoppingListRole.ADMIN, true, true, true),
      [ShoppingListUserReference("007", "Bond", "james.bond@mi6.uk", ShoppingListRole.ADMIN)],
    );
    bool deleted = false;
    bool loading = false;
    final card = DangerCard(
      false,
      (value) => loading = value,
      shoppingListInfo: info,
      deleteShoppingList: () async => deleted = true,
    );

    await tester.pumpWidget(await makeTestableWidget(card));
    await tester.pumpAndSettle();

    final deleteBtn = find.widgetWithText(OutlinedButton, localizations.listSettingsLeaveList);
    expect(deleteBtn, findsOneWidget);
    await tester.tap(deleteBtn);
    await tester.pumpAndSettle();

    expect(loading, isTrue);
    expect(find.text(localizations.listSettingsLeaveListConfirmationText(info.name)), findsOneWidget);

    final confirmBtn = find.widgetWithText(ElevatedButton, localizations.ok);
    expect(confirmBtn, findsOneWidget);
    await tester.tap(confirmBtn);
    await tester.pumpAndSettle();

    expect(loading, isFalse);
    expect(deleted, isTrue);
  });

  testWidgets('DeleteIfSelfIsOnlyAdmin', (WidgetTester tester) async {
    final info = ShoppingListInfo(
      "1234",
      "TestList",
      ShoppingListPermissions(ShoppingListRole.ADMIN, true, true, true),
      [],
    );
    bool deleted = false;
    bool loading = false;
    final card = DangerCard(
      false,
      (value) => loading = value,
      shoppingListInfo: info,
      deleteShoppingList: () async => deleted = true,
    );

    await tester.pumpWidget(await makeTestableWidget(card));
    await tester.pumpAndSettle();

    final deleteBtn = find.widgetWithText(OutlinedButton, localizations.listSettingsDeleteList);
    expect(deleteBtn, findsOneWidget);
    await tester.tap(deleteBtn);
    await tester.pumpAndSettle();

    expect(loading, isTrue);
    expect(find.text(localizations.listSettingsDeleteListConfirmationText(info.name)), findsOneWidget);

    final confirmBtn = find.widgetWithText(ElevatedButton, localizations.ok);
    expect(confirmBtn, findsOneWidget);
    await tester.tap(confirmBtn);
    await tester.pumpAndSettle();

    expect(loading, isFalse);
    expect(deleted, isTrue);
  });
}
