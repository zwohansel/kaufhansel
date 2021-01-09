import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'model.dart';

class ShoppingListTitle extends StatefulWidget {
  final String _appTitle;

  ShoppingListTitle(String appTitle) : _appTitle = appTitle;

  @override
  _ShoppingListTitleState createState() => _ShoppingListTitleState();
}

class _ShoppingListTitleState extends State<ShoppingListTitle> {
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
    return Selector<ShoppingListModel, _ShoppingListTitleInfo>(
      selector: (_, shoppingList) {
        final currentCategory = shoppingList.getAllCategories()[_currentTabIndex];
        final itemsInCategory = shoppingList.items.where((item) => item.isInCategory(currentCategory));
        final checkedItemsInCategory = itemsInCategory.where((item) => item.checked);
        return _ShoppingListTitleInfo(shoppingList.name, itemsInCategory.length, checkedItemsInCategory.length);
      },
      builder: (context, titleInfo, child) {
        return Flex(
          direction: Axis.horizontal,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.ideographic,
          //mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget._appTitle),
            Padding(
              child: Text(
                "${titleInfo.shoppingListName}: ${titleInfo.numChecked}/${titleInfo.numTotal}",
                style: Theme.of(context).primaryTextTheme.subtitle1.apply(color: Colors.white70),
              ),
              padding: EdgeInsets.only(left: 10),
            )
          ],
        );
      },
    );
  }
}

class _ShoppingListTitleInfo {
  final String _shoppingListName;
  final int _numTotal;
  final int _numChecked;

  _ShoppingListTitleInfo(this._shoppingListName, this._numTotal, this._numChecked);

  String get shoppingListName => _shoppingListName;

  int get numTotal => _numTotal;

  int get numChecked => _numChecked;

  @override
  bool operator ==(Object other) {
    return other is _ShoppingListTitleInfo &&
        other._shoppingListName == _shoppingListName &&
        other._numTotal == _numTotal &&
        other._numChecked == _numChecked;
  }

  @override
  int get hashCode => _shoppingListName.hashCode + _numTotal.hashCode + _numChecked.hashCode;
}
