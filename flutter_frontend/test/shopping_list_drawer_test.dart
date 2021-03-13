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
  final users = [new ShoppingListUserReference("userId0", "Test User", "test@test.de", shoppingListRole)];
  final permissions = new ShoppingListPermissions(shoppingListRole, true, true, true);
  return new ShoppingListInfo("id0", "List0", permissions, users);
}

ShoppingListInfo createReadWriteList() {
  final shoppingListRole = ShoppingListRole.READ_WRITE;
  final users = [new ShoppingListUserReference("userId0", "Test User", "test@test.de", shoppingListRole)];
  final permissions = new ShoppingListPermissions(shoppingListRole, false, true, true);
  return new ShoppingListInfo("id0", "List0", permissions, users);
}

ShoppingListInfo createCheckOnlyList() {
  final shoppingListRole = ShoppingListRole.CHECK_ONLY;
  final users = [new ShoppingListUserReference("userId0", "Test User", "test@test.de", shoppingListRole)];
  final permissions = new ShoppingListPermissions(shoppingListRole, false, false, true);
  return new ShoppingListInfo("id0", "List0", permissions, users);
}

ShoppingListInfo createReadOnlyList() {
  final shoppingListRole = ShoppingListRole.READ_ONLY;
  final users = [new ShoppingListUserReference("userId0", "Test User", "test@test.de", shoppingListRole)];
  final permissions = new ShoppingListPermissions(shoppingListRole, false, false, false);
  return new ShoppingListInfo("id0", "List0", permissions, users);
}

ShoppingListDrawer createDrawer(ShoppingListInfo singleShoppingList) {
  final shoppingLists = [singleShoppingList];
  final selectedShoppingListId = "id0";
  final userInfo = new ShoppingListUserInfo("userId0", "Test User", "test@test.de", "VERY_SECRET_TOKEN");
  return _buildDrawer(shoppingLists, selectedShoppingListId, userInfo);
}

ShoppingListDrawer _buildDrawer(
    List<ShoppingListInfo> shoppingLists, String selectedShoppingListId, ShoppingListUserInfo userInfo) {
  return ShoppingListDrawer(
      shoppingLists: shoppingLists,
      selectedShoppingListId: selectedShoppingListId,
      userInfo: userInfo,
      onRefreshPressed: () {},
      onShoppingListSelected: (info) {},
      onCreateShoppingList: (name) {
        return null;
      },
      onDeleteShoppingList: (info) {
        return null;
      },
      onAddUserToShoppingListIfPresent: (info, user) {
        return null;
      },
      onUncheckAllItems: (info) {
        return null;
      },
      onRemoveAllCategories: (info) {
        return null;
      },
      onRemoveAllItems: (info) {
        return null;
      },
      onChangeShoppingListPermissions: (info, string, role) {
        return null;
      },
      onRemoveUserFromShoppingList: (info, userRef) {
        return null;
      },
      onChangeShoppingListName: (info, name) {
        return null;
      },
      onLogOut: () {
        return null;
      },
      onDeleteUserAccount: () {
        return null;
      });
}
