import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kaufhansel_client/shopping_list.dart';
import 'package:kaufhansel_client/shopping_list_title.dart';
import 'package:provider/provider.dart';

import 'model.dart';

class ShoppingListPage extends StatelessWidget {
  final String appTitle;
  final void Function() _onRefresh;

  ShoppingListPage({@required this.appTitle, @required onRefresh}) : _onRefresh = onRefresh;

  @override
  Widget build(BuildContext context) {
    return Selector<ShoppingListModel, List<String>>(
        selector: (_, shoppingList) => shoppingList.getAllCategories(),
        builder: (context, categories, child) {
          return DefaultTabController(
              length: categories.length,
              child: Builder(
                builder: (context) {
                  final tabController = DefaultTabController.of(context);
                  final tabIndex = tabController.index;
                  // when we delete the current tab, tab bar view does show the previous view,
                  // but tab bar marks the tab before the previous one as active.
                  // Nevertheless tab controller knows correct tab index!
                  // Setting the index to 0 and then back to the correct one, forces tab bar to re-render.
                  tabController.index = 0;
                  tabController.index = tabIndex;
                  return Scaffold(
                      appBar: AppBar(
                        title: ShoppingListTitle(appTitle),
                        actions: [
                          IconButton(
                            icon: Icon(Icons.refresh),
                            onPressed: _onRefresh,
                            tooltip: "Aktualisieren",
                          )
                        ],
                        bottom: TabBar(
                          tabs: categories.map((category) => Tab(text: category)).toList(),
                        ),
                      ),
                      body: TabBarView(
                          children: categories.map((category) => ShoppingList(category: category)).toList()));
                },
              ));
        });
  }
}
