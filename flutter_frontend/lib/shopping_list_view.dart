import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kaufhansel_client/shopping_list_filter_options.dart';
import 'package:kaufhansel_client/shopping_list_item_tile.dart';
import 'package:kaufhansel_client/shopping_list_mode.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import 'model.dart';

class ShoppingListView extends StatelessWidget {
  ShoppingListView(
      {@required this.filter,
      @required this.scrollController,
      @required this.onRefresh,
      @required this.onItemMoved,
      this.category,
      this.mode = ShoppingListModeOption.DEFAULT,
      this.enabled = true,
      String filterText})
      : filterText = filterText?.trim()?.toLowerCase();

  final ShoppingListFilterOption filter;
  final ScrollController scrollController;
  final Future<void> Function() onRefresh;
  final void Function(List<ShoppingListItem> items, int oldIndex, int newIndex) onItemMoved;
  final String category;
  final ShoppingListModeOption mode;
  final bool enabled;
  final String filterText;

  @override
  Widget build(BuildContext context) {
    return Selector<ShoppingList, Tuple2<Iterable<ShoppingListItem>, ShoppingListPermissions>>(
        selector: (_, shoppingList) => Tuple2(
            shoppingList.items.where((item) => item.isInCategory(category)).toList(growable: false),
            shoppingList.info.permissions),
        builder: (context, tuple, child) {
          return _buildListView(context, tuple.item1, tuple.item2.canEditItems);
        });
  }

  Widget _buildListView(BuildContext context, List<ShoppingListItem> items, bool canEditItems) {
    Iterable<ShoppingListItem> visibleItems = items.where(_isItemVisible);
    final dividedTiles = _divideTilesWithKey(visibleItems.map(_createListTileForItem), context).toList();

    if (mode == ShoppingListModeOption.EDITING && canEditItems) {
      return ReorderableListView(
        children: dividedTiles,
        onReorder: (oldIndex, newIndex) => onItemMoved(items, oldIndex, newIndex),
        scrollController: scrollController,
      );
    } else {
      return Scrollbar(
        isAlwaysShown: false, // Setting this value to true causes an assertion error when the first category is created
        controller: scrollController,
        child: RefreshIndicator(
          onRefresh: onRefresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(), // allow overscroll to trigger refresh indicator
            shrinkWrap: true,
            children: dividedTiles,
            controller: scrollController,
          ),
        ),
      );
    }
  }

  bool _isItemVisible(ShoppingListItem item) {
    return _matchesFilterMode(item) && _matchesFilterString(item);
  }

  bool _matchesFilterMode(ShoppingListItem item) {
    switch (filter) {
      case ShoppingListFilterOption.CHECKED:
        return item.checked;
      case ShoppingListFilterOption.UNCHECKED:
        return !item.checked;
      case ShoppingListFilterOption.ALL:
      default:
        return true;
    }
  }

  bool _matchesFilterString(ShoppingListItem item) {
    if (filterText == null || filterText.isEmpty) {
      return true;
    }
    return item.name.toLowerCase().contains(filterText);
  }

  Widget _createListTileForItem(ShoppingListItem item) {
    return ChangeNotifierProvider<ShoppingListItem>.value(
        value: item,
        key: ValueKey(item.id),
        child: Selector<ShoppingList, ShoppingListPermissions>(
            selector: (_, shoppingList) => shoppingList.info.permissions,
            builder: (context, permissions, child) => ShoppingListItemTile(
                  mode: mode,
                  enabled: enabled,
                  showUserCategory: category == CATEGORY_ALL,
                  canCheckItems: permissions.canCheckItems,
                  canEditItems: permissions.canEditItems,
                )));
  }
}

List<Widget> _divideTilesWithKey(Iterable<Widget> tiles, BuildContext context) {
  final Decoration decoration = BoxDecoration(
    border: Border(
      bottom: Divider.createBorderSide(context),
    ),
  );

  return tiles.map((tile) {
    return DecoratedBox(
      key: tile.key,
      position: DecorationPosition.foreground,
      decoration: decoration,
      child: tile,
    );
  }).toList(growable: false);
}
