import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kaufhansel_client/shopping_list_filter_options.dart';
import 'package:kaufhansel_client/shopping_list_item_input.dart';
import 'package:kaufhansel_client/shopping_list_item_tile.dart';
import 'package:kaufhansel_client/shopping_list_mode.dart';
import 'package:provider/provider.dart';

import 'model.dart';

class ShoppingListView extends StatelessWidget {
  ShoppingListView(
      {String category, @required ShoppingListFilterOption filter, ShoppingListMode mode = ShoppingListMode.DEFAULT})
      : _category = category,
        _filter = filter,
        _mode = mode,
        _scrollController = ScrollController();

  final ScrollController _scrollController;
  final String _category;
  final ShoppingListMode _mode;
  final ShoppingListFilterOption _filter;

  @override
  Widget build(BuildContext context) {
    return Selector<ShoppingList, Iterable<ShoppingListItem>>(
        selector: (_, shoppingList) =>
            shoppingList.items.where((item) => item.isInCategory(_category)).toList(growable: false),
        builder: (context, items, child) {
          return Column(children: [
            Expanded(child: _buildListView(items, context)),
            Container(
                child: Material(
                    child: ShoppingListItemInput(
                      shoppingListScrollController: _scrollController,
                      category: _category,
                    ),
                    type: MaterialType.transparency),
                decoration: BoxDecoration(color: Colors.white, boxShadow: [
                  BoxShadow(color: Colors.grey.withOpacity(0.5), spreadRadius: 3, blurRadius: 4, offset: Offset(0, 3))
                ])),
          ]);
        });
  }

  Widget _buildListView(List<ShoppingListItem> items, BuildContext context) {
    final tiles = items.where(_isItemVisible).map(_createListTileForItem);
    final dividedTiles = _divideTilesWithKey(tiles, context).toList();

    if (_mode == ShoppingListMode.EDITING) {
      return ReorderableListView(
        children: dividedTiles,
        onReorder: (oldIndex, newIndex) {
          final ShoppingList list = Provider.of<ShoppingList>(context, listen: false);
          final ShoppingListItem movedItem = items[oldIndex];
          if (newIndex < items.length) {
            list.moveItem(movedItem, before: items[newIndex]);
          } else {
            list.moveItem(movedItem, behind: items[items.length - 1]);
          }
        },
        scrollController: _scrollController,
      );
    } else {
      return Scrollbar(
          isAlwaysShown: true,
          controller: _scrollController,
          child: ListView(
            shrinkWrap: true,
            children: dividedTiles,
            controller: _scrollController,
          ));
    }
  }

  bool _isItemVisible(ShoppingListItem item) {
    switch (_filter) {
      case ShoppingListFilterOption.CHECKED:
        return item.checked;
      case ShoppingListFilterOption.UNCHECKED:
        return !item.checked;
      case ShoppingListFilterOption.ALL:
      default:
        return true;
    }
  }

  Widget _createListTileForItem(ShoppingListItem item) {
    return ChangeNotifierProvider<ShoppingListItem>.value(
        value: item,
        key: ValueKey(item.id),
        child: ShoppingListItemTile(
          mode: _mode,
          showUserCategory: _category == CATEGORY_ALL,
        ));
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
