import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kaufhansel_client/shopping_list.dart';
import 'package:kaufhansel_client/shopping_list_drawer.dart';
import 'package:kaufhansel_client/shopping_list_filter_options.dart';
import 'package:kaufhansel_client/shopping_list_title.dart';
import 'package:provider/provider.dart';

import 'model.dart';

class ShoppingListPage extends StatelessWidget {
  final String appTitle;
  final void Function() _onRefresh;
  final void Function(ShoppingListFilterOption nextFilter) _onFilterChanged;
  final ShoppingListFilterOption _filter;

  ShoppingListPage(
      {@required this.appTitle,
      @required onRefresh,
      @required ShoppingListFilterOption filter,
      @required void Function(ShoppingListFilterOption nextFilter) onFilterChanged})
      : _onRefresh = onRefresh,
        _onFilterChanged = onFilterChanged,
        _filter = filter;

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
                        shadowColor: Colors.transparent,
                      ),
                      endDrawer: ShoppingListDrawer(
                        onRefreshPressed: _onRefresh,
                        filter: _filter,
                        onFilterChanged: _onFilterChanged,
                      ),
                      body: Column(children: [
                        Container(
                            decoration: BoxDecoration(color: Theme.of(context).primaryColor, boxShadow: [
                              BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 3,
                                  blurRadius: 4,
                                  offset: Offset(0, 3))
                            ]),
                            child: Material(
                                type: MaterialType.transparency,
                                child: TabBar(
                                  tabs: categories.map((category) => Tab(text: category)).toList(),
                                  indicator:
                                      BoxDecoration(border: Border(bottom: BorderSide(width: 3, color: Colors.white))),
                                ))),
                        Expanded(
                            child: TabBarView(
                                children: categories
                                    .map((category) => ShoppingList(
                                          category: category,
                                          filter: _filter,
                                        ))
                                    .toList()))
                      ]));
                },
              ));
        });
  }
}
