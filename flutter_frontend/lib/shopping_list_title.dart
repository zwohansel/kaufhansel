import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:kaufhansel_client/widgets/title_widget.dart';
import 'package:provider/provider.dart';

import 'model.dart';

class ShoppingListTitle extends StatelessWidget {
  final String _currentCategory;

  const ShoppingListTitle(this._currentCategory);

  @override
  Widget build(BuildContext context) {
    return Selector<ShoppingList, _ShoppingListTitleInfo>(
      selector: (_, shoppingList) {
        if (shoppingList == null) {
          return null;
        }

        if (_currentCategory == null) {
          return null;
        }

        final itemsInCategory = shoppingList.items.where((item) => item.isInCategory(_currentCategory));
        final checkedItemsInCategory = itemsInCategory.where((item) => item.checked);
        return _ShoppingListTitleInfo(shoppingList.name, itemsInCategory.length, checkedItemsInCategory.length);
      },
      builder: (context, titleInfo, child) {
        return TitleWidget(AppLocalizations.of(context).appTitle,
            subTitle: _buildShoppingListSubtitle(context, titleInfo));
      },
    );
  }

  String _buildShoppingListSubtitle(BuildContext context, _ShoppingListTitleInfo titleInfo) {
    if (titleInfo != null) {
      return "${titleInfo.shoppingListName}: ${titleInfo.numChecked}/${titleInfo.numTotal}";
    }
    return "";
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
