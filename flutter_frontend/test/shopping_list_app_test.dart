import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaufhansel_client/main.dart';
import 'package:kaufhansel_client/model.dart';
import 'package:kaufhansel_client/utils/semantic_versioning.dart';

import 'rest_client_stub.dart';
import 'settings_store_stub.dart';
import 'utils.dart';

void main() {
  const testLocale = Locale("de");

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
