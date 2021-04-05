import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:implicitly_animated_reorderable_list/implicitly_animated_reorderable_list.dart';
import 'package:implicitly_animated_reorderable_list/transitions.dart';
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
    final visibleItems = items.where(_isItemVisible);
    final Decoration dividerDecoration = BoxDecoration(
      border: Border(
        bottom: Divider.createBorderSide(context),
      ),
    );
    final itemBuilder = (BuildContext context, Animation animation, ShoppingListItem item, int i) {
      final tile = _createListTileForItem(item);
      return SizeFadeTransition(
        animation: animation,
        curve: Curves.easeInOut,
        sizeFraction: 0.7,
        child: DecoratedBox(
          key: tile.key,
          position: DecorationPosition.foreground,
          decoration: dividerDecoration,
          child: tile,
        ),
      );
    };

    if (mode == ShoppingListModeOption.EDITING && canEditItems) {
      return ImplicitlyAnimatedReorderableList<ShoppingListItem>(
        // TODO: Add scrollbar once dispose bug is fixed.
        // The ImplicitlyAnimatedReorderableList supports shrinkWrap (the native reorderable list does not).
        // This means we can finally add a scrollbar around the reorderable list.
        // However; ImplicitlyAnimatedReorderableList disposes the ScrollController in its dispose method
        // although it has not created the controller. This has to be fixed first: https://github.com/bnxm/implicitly_animated_reorderable_list/issues/72

        // shrinkWrap: true,
        // controller: scrollController,
        items: visibleItems.toList(),
        areItemsTheSame: (a, b) => a.id == b.id,
        itemBuilder: (context, animation, item, i) {
          return Reorderable(
            key: ValueKey(item.id),
            builder: (context, dragAnimation, inDrag) {
              final tile = itemBuilder(context, animation, item, i);
              return Material(
                child: tile,
                elevation: inDrag ? 5 : 0,
              );
            },
          );
        },
        onReorderFinished: (item, oldIndex, newIndex, newItems) => onItemMoved(items, oldIndex, newIndex),
      );
    } else {
      final checkedItems = visibleItems.where((item) => item.checked);
      final uncheckedItems = visibleItems.where((item) => !item.checked);
      final orderedItems = [...uncheckedItems, ...checkedItems];

      return Scrollbar(
        isAlwaysShown: false, // Setting this value to true causes an assertion error when the first category is created
        controller: scrollController,
        child: RefreshIndicator(
          onRefresh: onRefresh,
          child: ImplicitlyAnimatedList<ShoppingListItem>(
            physics: const AlwaysScrollableScrollPhysics(), // allow overscroll to trigger refresh indicator
            shrinkWrap: true,
            controller: scrollController,
            items: orderedItems,
            areItemsTheSame: (a, b) => a.id == b.id,
            itemBuilder: itemBuilder,
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

  Widget _createListTileForItem(ShoppingListItem item, {bool showReorderHandle = false}) {
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
