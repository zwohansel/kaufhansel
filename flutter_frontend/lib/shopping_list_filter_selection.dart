import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:kaufhansel_client/shopping_list_filter_options.dart';

class ShoppingListFilterSelection extends StatelessWidget {
  final void Function(ShoppingListFilterOption nextFilter) _onFilterChanged;
  final ShoppingListFilterOption _filter;

  const ShoppingListFilterSelection(this._onFilterChanged, this._filter);

  List<bool> _calculateSelection() {
    switch (_filter) {
      case ShoppingListFilterOption.UNCHECKED:
        return [true, false];
      case ShoppingListFilterOption.CHECKED:
        return [false, true];
      case ShoppingListFilterOption.ALL:
      default:
        return [false, false];
    }
  }

  void _setSelection(int index) {
    if (index == 0) {
      if (_filter == ShoppingListFilterOption.UNCHECKED) {
        _onFilterChanged(ShoppingListFilterOption.ALL);
      } else {
        _onFilterChanged(ShoppingListFilterOption.UNCHECKED);
      }
    } else if (index == 1) {
      if (_filter == ShoppingListFilterOption.CHECKED) {
        _onFilterChanged(ShoppingListFilterOption.ALL);
      } else {
        _onFilterChanged(ShoppingListFilterOption.CHECKED);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ToggleButtons(
        borderWidth: 2,
        fillColor: Colors.white,
        color: Colors.white,
        selectedColor: Colors.black,
        hoverColor: Theme.of(context).secondaryHeaderColor,
        constraints: BoxConstraints.tightFor(height: 40, width: 40),
        children: [
          Tooltip(
              message: AppLocalizations.of(context).shoppingListFilterNeeded,
              child: Icon(Icons.check_box_outline_blank)),
          Tooltip(
              message: AppLocalizations.of(context).shoppingListFilterAlreadyInCart,
              child: Icon(Icons.check_box_outlined)),
        ],
        onPressed: _setSelection,
        isSelected: _calculateSelection());
  }
}
