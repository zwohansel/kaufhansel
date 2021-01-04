import 'package:flutter/material.dart';
import 'package:kaufhansel_client/shopping_list_item_input.dart';
import 'package:kaufhansel_client/shopping_list_item_tile.dart';
import 'package:provider/provider.dart';

import 'model.dart';

class ShoppingList extends StatelessWidget {
  ShoppingList({@required shoppingListId, @required shoppingList, category})
      : _shoppingList = shoppingList,
        _shoppingListId = shoppingListId,
        _category = category,
        _scrollController = ScrollController();

  final ScrollController _scrollController;
  final String _shoppingListId;
  final ShoppingListModel _shoppingList;
  final String _category;

  @override
  Widget build(BuildContext context) {
    final tiles = _shoppingList.items
        .where((item) => _category == null || item.category == _category)
        .map((item) => ChangeNotifierProvider<ShoppingListItem>.value(
            value: item,
            child: ShoppingListItemTile(
              shoppingListId: _shoppingListId,
              key: ValueKey(item.id),
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
                shoppingListId: _shoppingListId,
                category: _category,
              ),
              type: MaterialType.transparency),
          decoration: BoxDecoration(color: Colors.white, boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.5), spreadRadius: 3, blurRadius: 4, offset: Offset(0, 3))
          ])),
    ]);
  }
}
