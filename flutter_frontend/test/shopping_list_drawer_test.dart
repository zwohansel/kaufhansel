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
    final drawer = createDrawer(createAdminList());

    await tester.pumpWidget(await makeTestableWidget(drawer, restClient: client, locale: testLocale));
    await tester.pumpAndSettle();

    checkAlwaysPresentOptions(localizations);
    expect(find.widgetWithText(Container, localizations.appTitle), findsOneWidget);
    expect(find.widgetWithText(Container, "List0"), findsOneWidget);
    expect(find.widgetWithText(ListTile, localizations.listSettings), findsOneWidget);
    expect(find.widgetWithText(ListTile, localizations.listSettingsUncheckAllItems), findsOneWidget);
    expect(find.widgetWithText(ListTile, localizations.listSettingsRemoveAllCategories), findsOneWidget);
  });

  testWidgets('drawerWithReadWriteListSelected', (WidgetTester tester) async {
    final RestClientStub client = new RestClientStub();
    final drawer = createDrawer(createReadWriteList());

    await tester.pumpWidget(await makeTestableWidget(drawer, restClient: client, locale: testLocale));
    await tester.pumpAndSettle();

    checkAlwaysPresentOptions(localizations);
    expect(find.widgetWithText(Container, localizations.appTitle), findsOneWidget);
    expect(find.widgetWithText(Container, "List0"), findsOneWidget);
    expect(find.widgetWithText(ListTile, localizations.listSettings), findsOneWidget);
    expect(find.widgetWithText(ListTile, localizations.listSettingsUncheckAllItems), findsOneWidget);
    expect(find.widgetWithText(ListTile, localizations.listSettingsRemoveAllCategories), findsOneWidget);
  });

  testWidgets('drawerWithCheckOnlyListSelected', (WidgetTester tester) async {
    final RestClientStub client = new RestClientStub();
    final drawer = createDrawer(createCheckOnlyList());

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
    final drawer = createDrawer(createReadOnlyList());

    await tester.pumpWidget(await makeTestableWidget(drawer, restClient: client, locale: testLocale));
    await tester.pumpAndSettle();

    checkAlwaysPresentOptions(localizations);
    expect(find.widgetWithText(Container, localizations.appTitle), findsOneWidget);
    expect(find.widgetWithText(ListTile, localizations.listSettings), findsOneWidget);
    expect(find.widgetWithText(Container, "List0"), findsOneWidget);
  });

  testWidgets('drawerWithNoList', (WidgetTester tester) async {
    final RestClientStub client = new RestClientStub();
    final drawer = _buildDrawer();

    await tester.pumpWidget(await makeTestableWidget(drawer, restClient: client, locale: testLocale));
    await tester.pumpAndSettle();

    checkAlwaysPresentOptions(localizations);
    expect(find.widgetWithText(Container, localizations.general), findsOneWidget);
  });

  testWidgets('uncheckAllItems', (WidgetTester tester) async {
    final RestClientStub client = RestClientStub();

    final info = ShoppingListInfo("0", "List", ShoppingListPermissions(ShoppingListRole.ADMIN, true, true, true), []);

    ShoppingListInfo uncheckAllCallbackValue;
    final drawer = _buildDrawer(
      shoppingLists: [info],
      selectedShoppingListId: info.id,
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

  testWidgets('removeAllCategories', (WidgetTester tester) async {
    final RestClientStub client = RestClientStub();

    final info = ShoppingListInfo("0", "List", ShoppingListPermissions(ShoppingListRole.ADMIN, true, true, true), []);

    ShoppingListInfo removeAllCategoriesCallbackValue;
    final drawer = _buildDrawer(
      shoppingLists: [info],
      selectedShoppingListId: info.id,
      onRemoveAllCategories: (info) {
        removeAllCategoriesCallbackValue = info;
        return null;
      },
    );

    await tester.pumpWidget(await makeTestableWidget(drawer, restClient: client, locale: testLocale));
    await tester.pumpAndSettle();

    final removeAllCategoriesMenuItem = find.widgetWithText(ListTile, localizations.listSettingsRemoveAllCategories);
    expect(removeAllCategoriesMenuItem, findsOneWidget);
    await tester.tap(removeAllCategoriesMenuItem);
    await tester.pumpAndSettle();

    // Callback should not have been invoked yet... user has to confirm first
    expect(removeAllCategoriesCallbackValue, isNull);

    expect(find.text(localizations.listSettingsRemoveAllCategoriesConfirmationText), findsOneWidget);
    final confirmBtn = find.widgetWithText(ElevatedButton, localizations.yes);
    expect(confirmBtn, findsOneWidget);
    await tester.tap(confirmBtn);
    await tester.pumpAndSettle();

    expect(removeAllCategoriesCallbackValue, equals(info));
  });

  testWidgets('selectShoppingList', (WidgetTester tester) async {
    final RestClientStub client = RestClientStub();

    final info0 = ShoppingListInfo("0", "List0", ShoppingListPermissions(ShoppingListRole.ADMIN, true, true, true), []);
    final info1 = ShoppingListInfo("1", "List1", ShoppingListPermissions(ShoppingListRole.ADMIN, true, true, true), []);

    ShoppingListInfo selectedList;
    final drawer = _buildDrawer(
      shoppingLists: [info0, info1],
      selectedShoppingListId: info0.id,
      onShoppingListSelected: (info) => selectedList = info,
    );

    await tester.pumpWidget(await makeTestableWidget(drawer, restClient: client, locale: testLocale));
    await tester.pumpAndSettle();

    final listItem = find.widgetWithText(ListTile, info1.name);
    expect(listItem, findsOneWidget);
    await tester.tap(listItem);
    await tester.pumpAndSettle();

    expect(selectedList, equals(info1));
  });

  testWidgets('showInfoWhenSelectingReadOnlyList', (WidgetTester tester) async {
    final RestClientStub client = RestClientStub();

    final info0 = ShoppingListInfo(
      "0",
      "List0",
      ShoppingListPermissions(ShoppingListRole.ADMIN, true, true, true),
      [],
    );
    final info1 = ShoppingListInfo(
      "1",
      "List1",
      ShoppingListPermissions(ShoppingListRole.READ_ONLY, false, false, false),
      [],
    );

    final drawer = _buildDrawer(
      shoppingLists: [info0, info1],
      selectedShoppingListId: info0.id,
    );

    // We need a drawer for the snackbar that contains the info message
    final Scaffold scaffold = Scaffold(body: drawer);

    await tester.pumpWidget(await makeTestableWidget(scaffold, restClient: client, locale: testLocale));
    await tester.pumpAndSettle();

    final listItem = find.widgetWithText(ListTile, info1.name);
    expect(listItem, findsOneWidget);
    await tester.tap(listItem);
    await tester.pump(); // Do not pump and settle... it will block until the snackbar is gone

    expect(find.text(localizations.roleYoursRoleName(localizations.roleReadOnlyName)), findsOneWidget);
    expect(find.text(localizations.roleReadOnlyDescription), findsOneWidget);
  });

  testWidgets('showInfoWhenSelectingCheckOnlyList', (WidgetTester tester) async {
    final RestClientStub client = RestClientStub();

    final info0 = ShoppingListInfo(
      "0",
      "List0",
      ShoppingListPermissions(ShoppingListRole.ADMIN, true, true, true),
      [],
    );
    final info1 = ShoppingListInfo(
      "1",
      "List1",
      ShoppingListPermissions(ShoppingListRole.CHECK_ONLY, false, false, true),
      [],
    );

    final drawer = _buildDrawer(
      shoppingLists: [info0, info1],
      selectedShoppingListId: info0.id,
    );

    // We need a drawer for the snackbar that contains the info message
    final Scaffold scaffold = Scaffold(body: drawer);

    await tester.pumpWidget(await makeTestableWidget(scaffold, restClient: client, locale: testLocale));
    await tester.pumpAndSettle();

    final listItem = find.widgetWithText(ListTile, info1.name);
    expect(listItem, findsOneWidget);
    await tester.tap(listItem);
    await tester.pump(); // Do not pump and settle... it will block until the snackbar is gone

    expect(find.text(localizations.roleYoursRoleName(localizations.roleCheckOnlyName)), findsOneWidget);
    expect(find.text(localizations.roleCheckOnlyDescription), findsOneWidget);
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
  return _buildDrawer(shoppingLists: [singleShoppingList], selectedShoppingListId: "id0");
}

ShoppingListInfo buildShoppingListInfo(ShoppingListPermissions permissions) =>
    ShoppingListInfo("id0", "List0", permissions, []);

ShoppingListDrawer _buildDrawer({
  List<ShoppingListInfo> shoppingLists,
  String selectedShoppingListId,
  Future<void> onUncheckAllItems(ShoppingListInfo info),
  Future<void> onRemoveAllCategories(ShoppingListInfo info),
  void onShoppingListSelected(ShoppingListInfo info),
}) {
  return ShoppingListDrawer(
    shoppingListInfos: shoppingLists ?? [],
    selectedShoppingListId: selectedShoppingListId,
    userInfo: ShoppingListUserInfo("0", "Test", "test@test.de", "token"),
    onRefreshPressed: () {},
    onShoppingListSelected: onShoppingListSelected ?? (info) {},
    onCreateShoppingList: (name) => null,
    onDeleteShoppingList: (info) => null,
    onAddUserToShoppingListIfPresent: (info, user) => null,
    onUncheckAllItems: onUncheckAllItems ?? (info) => null,
    onRemoveAllCategories: onRemoveAllCategories ?? (info) => null,
    onRemoveAllItems: (info) => null,
    onChangeShoppingListPermissions: (info, string, role) => null,
    onRemoveUserFromShoppingList: (info, userRef) => null,
    onChangeShoppingListName: (info, name) => null,
    onLogOut: () => null,
    onDeleteUserAccount: () => null,
  );
}
