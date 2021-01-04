import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kaufhansel_client/shopping_list.dart';
import 'package:provider/provider.dart';

import 'model.dart';

class ShoppingListPage extends StatelessWidget {
  final String title;
  final String shoppingListId;

  ShoppingListPage({@required this.title, @required this.shoppingListId});

  @override
  Widget build(BuildContext context) {
    return Consumer<ShoppingListModel>(builder: (context, shoppingList, child) {
      return DefaultTabController(
          length: shoppingList.getCategories().length + 1,
          child: Scaffold(
              appBar: AppBar(
                title: Text(title),
                bottom: TabBar(
                  tabs: [Tab(text: 'Alle'), ...shoppingList.getCategories().map((category) => Tab(text: category))],
                ),
              ),
              body: TabBarView(children: [
                ShoppingList(
                  shoppingList: shoppingList,
                  shoppingListId: shoppingListId,
                ),
                ...shoppingList.getCategories().map((category) =>
                    ShoppingList(shoppingListId: shoppingListId, shoppingList: shoppingList, category: category))
              ])));
    });
  }
}
