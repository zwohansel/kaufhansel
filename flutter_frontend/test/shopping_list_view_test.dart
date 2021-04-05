import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaufhansel_client/generated/l10n.dart';
import 'package:kaufhansel_client/model.dart';
import 'package:kaufhansel_client/shopping_list_filter_options.dart';
import 'package:kaufhansel_client/shopping_list_item_tile.dart';
import 'package:kaufhansel_client/shopping_list_view.dart';
import 'package:provider/provider.dart';

import 'utils.dart';

void main() {
  const testLocale = Locale("de");
  AppLocalizations localizations;
  ScrollController scrollController;

  setUp(() async {
    localizations = await AppLocalizations.load(testLocale);
    scrollController = ScrollController();
  });

  tearDown(() async {
    scrollController.dispose();
  });

  testWidgets('Show unchecked items before checked items', (WidgetTester tester) async {
    final list = ShoppingList(
      ShoppingListInfo("1", "TestList", ShoppingListPermissions(ShoppingListRole.ADMIN, true, true, true), []),
      [
        ShoppingListItem("1", "A", true, null), // Checked
        ShoppingListItem("2", "B", false, null), // Unchecked
        ShoppingListItem("3", "C", true, null), // Checked
        ShoppingListItem("4", "D", false, null), // Unchecked
      ],
    );

    final view = ShoppingListView(
      filter: ShoppingListFilterOption.ALL,
      scrollController: scrollController,
      onRefresh: () => null,
      onItemMoved: (items, oldIndex, newIndex) {},
    );
    final provider = ChangeNotifierProvider.value(value: list, child: Material(child: view));
    await tester.pumpWidget(await makeTestableWidget(provider, locale: testLocale));
    await tester.pumpAndSettle();

    final itemTileA = find.widgetWithText(ShoppingListItemTile, "A");
    final itemTileB = find.widgetWithText(ShoppingListItemTile, "B");
    final itemTileC = find.widgetWithText(ShoppingListItemTile, "C");
    final itemTileD = find.widgetWithText(ShoppingListItemTile, "D");

    expect(itemTileA, findsOneWidget);
    expect(itemTileB, findsOneWidget);
    expect(itemTileC, findsOneWidget);
    expect(itemTileD, findsOneWidget);

    final itemTileAOffset = tester.getTopLeft(itemTileA);
    final itemTileBOffset = tester.getTopLeft(itemTileB);
    final itemTileCOffset = tester.getTopLeft(itemTileC);
    final itemTileDOffset = tester.getTopLeft(itemTileD);

    // Expect the following (vertical) order B, D, A, C
    expect(itemTileBOffset.dy, lessThan(itemTileDOffset.dy));
    expect(itemTileDOffset.dy, lessThan(itemTileAOffset.dy));
    expect(itemTileAOffset.dy, lessThan(itemTileCOffset.dy));
  });
}
