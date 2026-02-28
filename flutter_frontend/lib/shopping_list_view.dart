import 'package:animated_list_plus/animated_list_plus.dart';
import 'package:animated_list_plus/transitions.dart';
import 'package:flutter/material.dart';
import 'package:kaufhansel_client/shopping_list_item_tile.dart';
import 'package:kaufhansel_client/shopping_list_mode.dart';
import 'package:kaufhansel_client/synced_shoppinglist.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import 'model.dart';

class ShoppingListView extends StatelessWidget {
  ShoppingListView(
      {required this.scrollController,
      required this.onRefresh,
      required this.onItemMoved,
      this.category,
      this.editMode = false,
      this.enabled = true,
      String? filterText})
      : filterText = filterText?.trim().toLowerCase();

  final ScrollController scrollController;
  final Future<void> Function() onRefresh;
  final void Function(List<SyncedShoppingListItem> items, int oldIndex, int newIndex) onItemMoved;
  final String? category;
  final bool editMode;
  final bool enabled;
  final String? filterText;

  @override
  Widget build(BuildContext context) {
    return Selector<SyncedShoppingList, Tuple2<Iterable<SyncedShoppingListItem>, ShoppingListPermissions>>(
        selector: (_, shoppingList) => Tuple2(
            shoppingList.items.where((item) => item.isInCategory(category)).toList(growable: false),
            shoppingList.info.permissions),
        builder: (context, tuple, child) {
          return Scrollbar(
            controller: scrollController,
            child: RefreshIndicator(
              onRefresh: onRefresh,
              child: _buildListView(context, tuple.item1.toList(), tuple.item2.canEditItems),
            ),
          );
        });
  }

  Widget _buildListView(BuildContext context, List<SyncedShoppingListItem> items, bool canEditItems) {
    final visibleItems = items.where(_isItemVisible);
    final Decoration dividerDecoration = BoxDecoration(
      border: Border(
        bottom: Divider.createBorderSide(context),
      ),
    );
    final itemBuilder = (BuildContext context, Animation<double> animation, SyncedShoppingListItem item, int i) {
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

    if (editMode && canEditItems) {
      return ImplicitlyAnimatedReorderableList<SyncedShoppingListItem>(
        controller: scrollController,
        items: visibleItems.toList(),
        areItemsTheSame: (a, b) => a.id == b.id,
        // Disable computation of the diff in an isolate (thread).
        // A SyncedShoppingListItem can not be moved to an isolate because it is a ChangeNotifier
        // and therefore can have references (listeners) to other objects that live in the main isolate.
        spawnIsolate: false,
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

      return ImplicitlyAnimatedList<SyncedShoppingListItem>(
        physics: const AlwaysScrollableScrollPhysics(),
        // allow overscroll to trigger refresh indicator
        controller: scrollController,
        items: category == CATEGORY_ALL ? visibleItems.toList() : orderedItems,
        areItemsTheSame: (a, b) => a.id == b.id,
        spawnIsolate: false,
        // see above
        itemBuilder: itemBuilder,
      );
    }
  }

  bool _isItemVisible(SyncedShoppingListItem item) {
    final text = filterText;
    if (text == null || text.isEmpty) {
      return true;
    }
    return item.name.toLowerCase().contains(text);
  }

  Widget _createListTileForItem(SyncedShoppingListItem item) {
    ShoppingListModeOption mode = ShoppingListModeOption.DEFAULT;
    if (editMode) {
      mode = ShoppingListModeOption.EDITING;
    } else if (category != CATEGORY_ALL) {
      mode = ShoppingListModeOption.SHOPPING;
    }
    return ChangeNotifierProvider<SyncedShoppingListItem>.value(
        value: item,
        key: ValueKey(item.id),
        child: Selector<SyncedShoppingList, ShoppingListPermissions>(
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
