import 'package:flutter/material.dart';
import 'package:kaufhansel_client/generated/l10n.dart';
import 'package:kaufhansel_client/shopping_list_mode.dart';

class ShoppingListModeSelection extends StatelessWidget {
  final void Function(ShoppingListMode nextMode) _onModeChanged;
  final ShoppingListMode _mode;

  const ShoppingListModeSelection(this._onModeChanged, this._mode);

  List<bool> _calculateSelection() {
    switch (_mode) {
      case ShoppingListMode.SHOPPING:
        return [true, false];
      case ShoppingListMode.EDITING:
        return [false, true];
      case ShoppingListMode.DEFAULT:
      default:
        return [false, false];
    }
  }

  void _setSelection(int index) {
    if (index == 0) {
      if (_mode == ShoppingListMode.SHOPPING) {
        _onModeChanged(ShoppingListMode.DEFAULT);
      } else {
        _onModeChanged(ShoppingListMode.SHOPPING);
      }
    } else if (index == 1) {
      if (_mode == ShoppingListMode.EDITING) {
        _onModeChanged(ShoppingListMode.DEFAULT);
      } else {
        _onModeChanged(ShoppingListMode.EDITING);
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
              message: AppLocalizations.of(context).shoppingListModeShopping,
              child: Icon(Icons.shopping_cart_outlined)),
          Tooltip(message: AppLocalizations.of(context).shoppingListModeEditing, child: Icon(Icons.edit_outlined)),
        ],
        onPressed: _setSelection,
        isSelected: _calculateSelection());
  }
}
