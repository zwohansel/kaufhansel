import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaufhansel_client/generated/l10n.dart';
import 'package:kaufhansel_client/model.dart';
import 'package:kaufhansel_client/shopping_list_drawer.dart';

import 'rest_client_stub.dart';
import 'utils.dart';

void main() {
  const testLocale = Locale("de");
  AppLocalizations localizations;

  setUp(() async {
    localizations = await AppLocalizations.load(testLocale);
  });

  testWidgets('drawerWithAdminListSelected', (WidgetTester tester) async {
    final RestClientStub client = new RestClientStub();
    ShoppingListDrawer drawer = createDrawer(createAdminList());

    await tester.pumpWidget(await makeTestableWidget(drawer, restClient: client, locale: testLocale));
    await tester.pumpAndSettle();

    checkAlwaysPresentOptions(localizations);
    expect(find.widgetWithText(Container, localizations.appTitle), findsOneWidget);
    expect(find.widgetWithText(Container, "List0"), findsOneWidget);
    expect(find.widgetWithText(ListTile, localizations.listSettings), findsOneWidget);
    expect(find.widgetWithText(ListTile, localizations.listSettingsUncheckAllItems), findsOneWidget);
    expect(find.widgetWithText(ListTile, localizations.listSettingsClearAllCategories), findsOneWidget);
  });

  testWidgets('drawerWithReadWriteListSelected', (WidgetTester tester) async {
    final RestClientStub client = new RestClientStub();
    ShoppingListDrawer drawer = createDrawer(createReadWriteList());

    await tester.pumpWidget(await makeTestableWidget(drawer, restClient: client, locale: testLocale));
    await tester.pumpAndSettle();

    checkAlwaysPresentOptions(localizations);
    expect(find.widgetWithText(Container, localizations.appTitle), findsOneWidget);
    expect(find.widgetWithText(Container, "List0"), findsOneWidget);
    expect(find.widgetWithText(ListTile, localizations.listSettings), findsOneWidget);
    expect(find.widgetWithText(ListTile, localizations.listSettingsUncheckAllItems), findsOneWidget);
    expect(find.widgetWithText(ListTile, localizations.listSettingsClearAllCategories), findsOneWidget);
  });

  testWidgets('drawerWithCheckOnlyListSelected', (WidgetTester tester) async {
    final RestClientStub client = new RestClientStub();
    ShoppingListDrawer drawer = createDrawer(createCheckOnlyList());

    await tester.pumpWidget(await makeTestableWidget(drawer, restClient: client, locale: testLocale));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(Container, "List0"), findsOneWidget);
    expect(find.widgetWithText(ListTile, localizations.listSettings), findsOneWidget);
    // finds 2 widgets in this case: section header and role name
    expect(find.widgetWithText(Container, localizations.appTitle), findsNWidgets(2));
    expect(find.widgetWithText(ListTile, localizations.listSettingsUncheckAllItems), findsOneWidget);
    checkAlwaysPresentOptions(localizations);
  });

  testWidgets('drawerWithReadOnlyListSelected', (WidgetTester tester) async {
    final RestClientStub client = new RestClientStub();
    ShoppingListDrawer drawer = createDrawer(createReadOnlyList());

    await tester.pumpWidget(await makeTestableWidget(drawer, restClient: client, locale: testLocale));
    await tester.pumpAndSettle();

    checkAlwaysPresentOptions(localizations);
    expect(find.widgetWithText(Container, localizations.appTitle), findsOneWidget);
    expect(find.widgetWithText(ListTile, localizations.listSettings), findsOneWidget);
    expect(find.widgetWithText(Container, "List0"), findsOneWidget);
  });

  testWidgets('drawerWithNoList', (WidgetTester tester) async {
    final RestClientStub client = new RestClientStub();
    ShoppingListDrawer drawer = _buildDrawer([], null, null);

    await tester.pumpWidget(await makeTestableWidget(drawer, restClient: client, locale: testLocale));
    await tester.pumpAndSettle();

    checkAlwaysPresentOptions(localizations);
    expect(find.widgetWithText(Container, localizations.general), findsOneWidget);
  });

  testWidgets('uncheckAllItems', (WidgetTester tester) async {
    final RestClientStub client = RestClientStub();

    final info = ShoppingListInfo("0", "List", ShoppingListPermissions(ShoppingListRole.ADMIN, true, true, true), []);

    ShoppingListInfo uncheckAllCallbackValue;
    ShoppingListDrawer drawer = _buildDrawer(
      [info],
      info.id,
      null,
      onUncheckAllItems: (info) {
        uncheckAllCallbackValue = info;
        return null;
      },
    );

    await tester.pumpWidget(await makeTestableWidget(drawer, restClient: client, locale: testLocale));
    await tester.pumpAndSettle();

    final uncheckAllMenuItem = find.widgetWithText(ListTile, localizations.listSettingsUncheckAllItems);
    expect(uncheckAllMenuItem, findsOneWidget);
    await tester.tap(uncheckAllMenuItem);
    await tester.pumpAndSettle();

    // Callback should not have been invoked yet... user has to confirm first
    expect(uncheckAllCallbackValue, isNull);

    expect(find.text(localizations.listSettingsUncheckAllItemsConfirmationText), findsOneWidget);
    final confirmBtn = find.widgetWithText(ElevatedButton, localizations.yes);
    expect(confirmBtn, findsOneWidget);
    await tester.tap(confirmBtn);
    await tester.pumpAndSettle();

    expect(uncheckAllCallbackValue, equals(info));
  });
}

void checkAlwaysPresentOptions(AppLocalizations localizations) {
  expect(find.widgetWithText(ListTile, localizations.refresh), findsOneWidget);
  expect(find.widgetWithText(Container, localizations.shoppingListMyLists), findsOneWidget);
  expect(find.widgetWithText(ListTile, localizations.shoppingListCreateNew), findsOneWidget);
  expect(find.widgetWithText(ListTile, localizations.invitationCodeGenerate), findsOneWidget);
  expect(find.widgetWithText(ListTile, localizations.appSettings), findsOneWidget);
}

ShoppingListInfo createAdminList() {
  final shoppingListRole = ShoppingListRole.ADMIN;
  final permissions = ShoppingListPermissions(shoppingListRole, true, true, true);
  return buildShoppingListInfo(permissions);
}

ShoppingListInfo createReadWriteList() {
  final shoppingListRole = ShoppingListRole.READ_WRITE;
  final permissions = ShoppingListPermissions(shoppingListRole, false, true, true);
  return buildShoppingListInfo(permissions);
}

ShoppingListInfo createCheckOnlyList() {
  final shoppingListRole = ShoppingListRole.CHECK_ONLY;
  final permissions = ShoppingListPermissions(shoppingListRole, false, false, true);
  return buildShoppingListInfo(permissions);
}

ShoppingListInfo createReadOnlyList() {
  final shoppingListRole = ShoppingListRole.READ_ONLY;
  final permissions = ShoppingListPermissions(shoppingListRole, false, false, false);
  return buildShoppingListInfo(permissions);
}

ShoppingListDrawer createDrawer(ShoppingListInfo singleShoppingList) {
  final shoppingLists = [singleShoppingList];
  final selectedShoppingListId = "id0";
  return _buildDrawer(shoppingLists, selectedShoppingListId, null);
}

ShoppingListInfo buildShoppingListInfo(ShoppingListPermissions permissions) =>
    ShoppingListInfo("id0", "List0", permissions, []);

ShoppingListDrawer _buildDrawer(
    List<ShoppingListInfo> shoppingLists, String selectedShoppingListId, ShoppingListUserInfo userInfo,
    {Future<void> onUncheckAllItems(ShoppingListInfo info)}) {
  return ShoppingListDrawer(
    shoppingLists: shoppingLists,
    selectedShoppingListId: selectedShoppingListId,
    userInfo: userInfo,
    onRefreshPressed: () {},
    onShoppingListSelected: (info) {},
    onCreateShoppingList: (name) => null,
    onDeleteShoppingList: (info) => null,
    onAddUserToShoppingListIfPresent: (info, user) => null,
    onUncheckAllItems: onUncheckAllItems ?? (info) => null,
    onRemoveAllCategories: (info) => null,
    onRemoveAllItems: (info) => null,
    onChangeShoppingListPermissions: (info, string, role) => null,
    onRemoveUserFromShoppingList: (info, userRef) => null,
    onChangeShoppingListName: (info, name) => null,
    onLogOut: () => null,
    onDeleteUserAccount: () => null,
  );
}
