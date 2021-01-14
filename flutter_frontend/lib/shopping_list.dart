import 'package:flutter/material.dart';
import 'package:kaufhansel_client/shopping_list_filter_options.dart';
import 'package:kaufhansel_client/shopping_list_item_input.dart';
import 'package:kaufhansel_client/shopping_list_item_tile.dart';
import 'package:provider/provider.dart';

import 'model.dart';

class ShoppingList extends StatelessWidget {
  ShoppingList({String category, @required ShoppingListFilterOption filter})
      : _category = category,
        _filter = filter,
        _scrollController = ScrollController();

  final ScrollController _scrollController;
  final String _category;
  final ShoppingListFilterOption _filter;

  @override
  Widget build(BuildContext context) {
    return Selector<ShoppingListModel, Iterable<ShoppingListItem>>(
        selector: (_, shoppingList) =>
            shoppingList.items.where((item) => item.isInCategory(_category)).toList(growable: false),
        builder: (context, shoppingListItems, child) {
          final tiles = shoppingListItems.where((item) {
            switch (_filter) {
              case ShoppingListFilterOption.CHECKED:
                return item.checked;
              case ShoppingListFilterOption.UNCHECKED:
                return !item.checked;
              case ShoppingListFilterOption.ALL:
              default:
                return true;
            }
          }).map((item) => ChangeNotifierProvider<ShoppingListItem>.value(
              value: item,
              child: ShoppingListItemTile(
                ValueKey(item.id),
                showUserCategory: _category == CATEGORY_ALL,
              )));
          final dividedTiles = ListTile.divideTiles(tiles: tiles, context: context).toList();
          return Column(children: [
            Expanded(
                child: Scrollbar(
                    isAlwaysShown: true,
                    controller: _scrollController,
                    child: ListView(
                      shrinkWrap: true,
                      children: dividedTiles,
                      controller: _scrollController,
                    ))),
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
}
