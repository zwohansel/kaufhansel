import 'package:flutter/material.dart';
import 'package:kaufhansel_client/generated/l10n.dart';
import 'package:kaufhansel_client/shopping_list_filter_options.dart';

class ShoppingListFilterSelection extends StatelessWidget {
  final BuildContext _context;
  final void Function(ShoppingListFilterOption nextFilter) _onFilterChanged;
  final ShoppingListFilterOption _filter;

  const ShoppingListFilterSelection(this._context, this._onFilterChanged, this._filter);

  List<bool> _calculateSelection() {
    switch (_filter) {
      case ShoppingListFilterOption.UNCHECKED:
        return [false, true, false];
      case ShoppingListFilterOption.CHECKED:
        return [false, false, true];
      case ShoppingListFilterOption.ALL:
      default:
        return [true, false, false];
    }
  }

  void _setSelection(int index) {
    switch (index) {
      case 1:
        _onFilterChanged(ShoppingListFilterOption.UNCHECKED);
        break;
      case 2:
        _onFilterChanged(ShoppingListFilterOption.CHECKED);
        break;
      case 0:
      default:
        _onFilterChanged(ShoppingListFilterOption.ALL);
    }
  }

  @override
  Widget build(_) {
    return ToggleButtons(
        borderWidth: 2,
        constraints: BoxConstraints.tightFor(height: 40, width: 40),
        children: [
          Tooltip(
              message: AppLocalizations.of(_context).shoppingListFilterNone,
              child: Icon(Icons.browser_not_supported_outlined)),
          Tooltip(
              message: AppLocalizations.of(_context).shoppingListFilterNeeded,
              child: Icon(Icons.check_box_outline_blank)),
          Tooltip(
              message: AppLocalizations.of(_context).shoppingListFilterAlreadyInCart,
              child: Icon(Icons.check_box_outlined)),
        ],
        onPressed: _setSelection,
        isSelected: _calculateSelection());
  }
}
