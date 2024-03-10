import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaufhansel_client/generated/l10n.dart';
import 'package:kaufhansel_client/model.dart';
import 'package:kaufhansel_client/rest_client.dart';
import 'package:kaufhansel_client/shopping_list_drawer.dart';
import 'package:kaufhansel_client/synced_shoppinglist.dart';
import 'package:provider/provider.dart';

import 'rest_client_stub.dart';
import 'utils.dart';

void main() {
  const testLocale = Locale("de");
  late AppLocalizations localizations;

  setUp(() async {
    localizations = await AppLocalizations.load(testLocale);
  });

  testWidgets('drawerWithAdminListSelected', (WidgetTester tester) async {
    final RestClientStub client = new RestClientStub();
    final drawer = createDrawer(createAdminList(client));

    await tester.pumpWidget(await makeTestableWidget(drawer, restClient: client, locale: testLocale));
    await tester.pumpAndSettle();

    checkAlwaysPresentOptions(localizations);
    expect(find.widgetWithText(Container, localizations.appTitle), findsOneWidget);
    expect(find.widgetWithText(Container, "List0"), findsOneWidget);
    expect(find.widgetWithText(ListTile, localizations.listSettings), findsOneWidget);
    expect(find.widgetWithText(ListTile, localizations.manageCategories), findsOneWidget);
  });

  testWidgets('drawerWithReadWriteListSelected', (WidgetTester tester) async {
    final RestClientStub client = new RestClientStub();
    final drawer = createDrawer(createReadWriteList(client));

    await tester.pumpWidget(await makeTestableWidget(drawer, restClient: client, locale: testLocale));
    await tester.pumpAndSettle();

    checkAlwaysPresentOptions(localizations);
    expect(find.widgetWithText(Container, localizations.appTitle), findsOneWidget);
    expect(find.widgetWithText(Container, "List0"), findsOneWidget);
    expect(find.widgetWithText(ListTile, localizations.listSettings), findsOneWidget);
    expect(find.widgetWithText(ListTile, localizations.manageCategories), findsOneWidget);
  });

  testWidgets('drawerWithCheckOnlyListSelected', (WidgetTester tester) async {
    final RestClientStub client = new RestClientStub();
    final drawer = createDrawer(createCheckOnlyList(client));

    await tester.pumpWidget(await makeTestableWidget(drawer, restClient: client, locale: testLocale));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(Container, "List0"), findsOneWidget);
    expect(find.widgetWithText(ListTile, localizations.listSettings), findsOneWidget);
    // finds 2 widgets in this case: section header and role name
    expect(find.widgetWithText(Container, localizations.appTitle), findsNWidgets(2));
    expect(find.widgetWithText(ListTile, localizations.manageCategories), findsOneWidget);
    checkAlwaysPresentOptions(localizations);
  });

  testWidgets('drawerWithReadOnlyListSelected', (WidgetTester tester) async {
    final RestClientStub client = new RestClientStub();
    final drawer = createDrawer(createReadOnlyList(client));

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

  testWidgets('selectShoppingList', (WidgetTester tester) async {
    final RestClientStub client = RestClientStub();

    final info0 = ShoppingListInfo("0", "List0", ShoppingListPermissions(ShoppingListRole.ADMIN, true, true, true), []);
    final info1 = ShoppingListInfo("1", "List1", ShoppingListPermissions(ShoppingListRole.ADMIN, true, true, true), []);

    ShoppingListInfo? selectedList;
    final list = SyncedShoppingList(client, ShoppingList(info0, []));
    final drawer = _buildDrawer(
      shoppingLists: [info0, info1],
      selectedList: list,
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

    final list = SyncedShoppingList(client, ShoppingList(info0, []));

    final drawer = _buildDrawer(
      shoppingLists: [info0, info1],
      selectedList: list,
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

    final list = SyncedShoppingList(client, ShoppingList(info0, []));

    final drawer = _buildDrawer(
      shoppingLists: [info0, info1],
      selectedList: list,
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

SyncedShoppingList createAdminList(RestClient client) {
  final shoppingListRole = ShoppingListRole.ADMIN;
  final permissions = ShoppingListPermissions(shoppingListRole, true, true, true);
  return SyncedShoppingList(client, ShoppingList(buildShoppingListInfo(permissions), []));
}

SyncedShoppingList createReadWriteList(RestClient client) {
  final shoppingListRole = ShoppingListRole.READ_WRITE;
  final permissions = ShoppingListPermissions(shoppingListRole, false, true, true);
  return SyncedShoppingList(client, ShoppingList(buildShoppingListInfo(permissions), []));
}

SyncedShoppingList createCheckOnlyList(RestClient client) {
  final shoppingListRole = ShoppingListRole.CHECK_ONLY;
  final permissions = ShoppingListPermissions(shoppingListRole, false, false, true);
  return SyncedShoppingList(client, ShoppingList(buildShoppingListInfo(permissions), []));
}

SyncedShoppingList createReadOnlyList(RestClient client) {
  final shoppingListRole = ShoppingListRole.READ_ONLY;
  final permissions = ShoppingListPermissions(shoppingListRole, false, false, false);
  return SyncedShoppingList(client, ShoppingList(buildShoppingListInfo(permissions), []));
}

Widget createDrawer(SyncedShoppingList list) {
  return _buildDrawer(shoppingLists: [list.info], selectedList: list);
}

ShoppingListInfo buildShoppingListInfo(ShoppingListPermissions permissions) =>
    ShoppingListInfo("id0", "List0", permissions, []);

Widget _buildDrawer({
  List<ShoppingListInfo>? shoppingLists,
  SyncedShoppingList? selectedList,
  void onShoppingListSelected(ShoppingListInfo info)?,
}) {
  return ChangeNotifierProvider.value(
      value: selectedList,
      child: ShoppingListDrawer(
        shoppingListInfos: shoppingLists ?? [],
        userInfo: ShoppingListUserInfo("0", "Test", "test@test.de", "token"),
        onRefreshPressed: () {},
        onShoppingListSelected: onShoppingListSelected ?? (info) {},
        onCreateShoppingList: (name) async => null,
        onDeleteShoppingList: (info) async => null,
        onAddUserToShoppingListIfPresent: (info, user) async => false,
        onChangeShoppingListPermissions: (info, string, role) async => null,
        onRemoveUserFromShoppingList: (info, userRef) async => null,
        onChangeShoppingListName: (info, name) async => null,
        onLogOut: () async => null,
        onDeleteUserAccount: () async => null,
      ));
}
