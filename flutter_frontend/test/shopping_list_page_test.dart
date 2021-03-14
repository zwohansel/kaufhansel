import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaufhansel_client/generated/l10n.dart';
import 'package:kaufhansel_client/model.dart';
import 'package:kaufhansel_client/shopping_list_filter_options.dart';
import 'package:kaufhansel_client/shopping_list_page.dart';
import 'package:kaufhansel_client/utils/semantic_versioning.dart';
import 'package:kaufhansel_client/utils/update_check.dart';
import 'package:provider/provider.dart';

import 'settings_store_stub.dart';
import 'utils.dart';

void main() {
  const testLocale = Locale("de");
  AppLocalizations localizations;

  setUp(() async {
    localizations = await AppLocalizations.load(testLocale);
  });

  testWidgets('DismissUpdateMessage', (WidgetTester tester) async {
    final store = SettingsStoreStub();
    final latestVersion = Version(1, 3, 4);
    final update = Update(store, Version(1, 2, 3), latestVersion, null, false);

    final list = ShoppingList(
      ShoppingListInfo("1", "TestList", ShoppingListPermissions(ShoppingListRole.ADMIN, true, true, true), []),
      [],
    );

    final page = ShoppingListPage(list.getAllCategories(), ShoppingListFilterOption.ALL, update: update);
    final provider = ChangeNotifierProvider.value(value: list, child: Material(child: page));
    await tester.pumpWidget(await makeTestableWidget(provider, store: store, locale: testLocale));
    await tester.pumpAndSettle();

    expect(find.text(localizations.newerVersionAvailable(latestVersion.toString())), findsOneWidget);

    final dismissBtn = find.widgetWithText(OutlinedButton, localizations.ok);
    await tester.tap(dismissBtn);
    await tester.pumpAndSettle();

    expect(find.text(localizations.newerVersionAvailable(latestVersion.toString())), findsNothing);
  });
}
