import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kaufhansel_client/shopping_list.dart';
import 'package:provider/provider.dart';

import 'model.dart';

class ShoppingListPage extends StatelessWidget {
  final String appTitle;
  final void Function() _onRefresh;

  ShoppingListPage({@required this.appTitle, @required onRefresh}) : _onRefresh = onRefresh;

  @override
  Widget build(BuildContext context) {
    return Consumer<ShoppingListModel>(builder: (context, shoppingList, child) {
      final categories = shoppingList.getAllCategories();

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
                    title: ShoppingListTitleWidget(appTitle),
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
                      children: categories
                          .map((category) => ShoppingList(shoppingList: shoppingList, category: category))
                          .toList()));
            },
          ));
    });
  }
}

class ShoppingListTitleWidget extends StatefulWidget {
  final String _appTitle;
  ShoppingListTitleWidget(String appTitle) : _appTitle = appTitle;

  @override
  _ShoppingListTitleWidgetState createState() => _ShoppingListTitleWidgetState();
}

class _ShoppingListTitleWidgetState extends State<ShoppingListTitleWidget> {
  int _currentTabIndex;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final tabController = DefaultTabController.of(context);
    setState(() {
      _currentTabIndex = tabController.index;
    });
    tabController.addListener(() {
      setState(() {
        _currentTabIndex = tabController.index;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final shoppingList = Provider.of<ShoppingListModel>(context);
    final currentCategory = shoppingList.getAllCategories()[_currentTabIndex];
    final itemsInCategory = shoppingList.items.where((item) => item.isInCategory(currentCategory));
    final checkedItemsInCategory = itemsInCategory.where((item) => item.checked);

    return Flex(
      direction: Axis.horizontal,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.ideographic,
      //mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(widget._appTitle),
        Padding(
          child: Text(
            "${shoppingList.name}: ${checkedItemsInCategory.length}/${itemsInCategory.length}",
            style: Theme.of(context).primaryTextTheme.subtitle1.apply(color: Colors.white70),
          ),
          padding: EdgeInsets.only(left: 10),
        )
      ],
    );
  }
}
