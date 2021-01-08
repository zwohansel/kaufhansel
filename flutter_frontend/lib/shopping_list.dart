import 'package:flutter/material.dart';
import 'package:kaufhansel_client/shopping_list_item_input.dart';
import 'package:kaufhansel_client/shopping_list_item_tile.dart';
import 'package:provider/provider.dart';

import 'model.dart';

class ShoppingList extends StatelessWidget {
  ShoppingList({@required shoppingList, category})
      : _shoppingList = shoppingList,
        _category = category,
        _scrollController = ScrollController();

  final ScrollController _scrollController;
  final ShoppingListModel _shoppingList;
  final String _category;

  @override
  Widget build(BuildContext context) {
    final tiles = _shoppingList.items
        .where((item) => item.isInCategory(_category))
        .map((item) => ChangeNotifierProvider<ShoppingListItem>.value(
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
  }
}
