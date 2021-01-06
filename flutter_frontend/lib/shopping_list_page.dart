import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kaufhansel_client/shopping_list.dart';
import 'package:provider/provider.dart';

import 'model.dart';

class ShoppingListPage extends StatelessWidget {
  final String title;
  final void Function() _onRefresh;

  ShoppingListPage({@required this.title, @required onRefresh}) : _onRefresh = onRefresh;

  @override
  Widget build(BuildContext context) {
    return Consumer<ShoppingListModel>(builder: (context, shoppingList, child) {
      final categories = shoppingList.getCategories();

      return DefaultTabController(
          length: categories.length + 1,
          child: Scaffold(
              appBar: AppBar(
                title: Text(title),
                actions: [
                  IconButton(
                    icon: Icon(Icons.refresh),
                    onPressed: _onRefresh,
                    tooltip: "Aktualisieren",
                  )
                ],
                bottom: TabBar(
                  tabs: [Tab(text: 'Alle'), ...categories.map((category) => Tab(text: category))],
                ),
              ),
              body: TabBarView(children: [
                ShoppingList(
                  shoppingList: shoppingList,
                ),
                ...categories.map((category) => ShoppingList(shoppingList: shoppingList, category: category))
              ])));
    });
  }
}
