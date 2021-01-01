import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kaufhansel_client/shopping_list_item_input.dart';
import 'package:kaufhansel_client/shopping_list_item_tile.dart';
import 'package:provider/provider.dart';

import 'model.dart';

class ShoppingListView extends StatelessWidget {
  final String title;
  final String shoppingListId;
  final ScrollController _scrollController = ScrollController();

  ShoppingListView({@required this.title, @required this.shoppingListId});

  @override
  Widget build(BuildContext context) {
    return Consumer<ShoppingListModel>(builder: (context, shoppingList, child) {
      final tiles = shoppingList.items
          .map((item) => ChangeNotifierProvider<ShoppingListItem>.value(value: item, child: ShoppingListItemTile()));
      final dividedTiles = ListTile.divideTiles(tiles: tiles, context: context).toList();
      return Scaffold(
          appBar: AppBar(title: Text(title)),
          body: Column(children: [
            Expanded(
                child: ListView(
              children: dividedTiles,
              controller: _scrollController,
            )),
            Container(
                child: Material(
                    child: ShoppingListItemInput(
                        shoppingListScrollController: _scrollController, shoppingListId: shoppingListId),
                    type: MaterialType.transparency),
                decoration: BoxDecoration(color: Colors.white, boxShadow: [
                  BoxShadow(color: Colors.grey.withOpacity(0.5), spreadRadius: 3, blurRadius: 4, offset: Offset(0, 3))
                ])),
          ]));
    });
  }
}
