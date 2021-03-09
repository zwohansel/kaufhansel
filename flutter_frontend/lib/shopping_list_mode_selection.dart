import 'package:flutter/material.dart';
import 'package:kaufhansel_client/generated/l10n.dart';
import 'package:kaufhansel_client/shopping_list_mode.dart';

class ShoppingListModeSelection extends StatelessWidget {
  final BuildContext _context;
  final void Function(ShoppingListModeOption nextMode) _onModeChanged;
  final ShoppingListModeOption _mode;

  const ShoppingListModeSelection(this._context, this._onModeChanged, this._mode);

  List<bool> _calculateSelection() {
    switch (_mode) {
      case ShoppingListModeOption.SHOPPING:
        return [false, true, false];
      case ShoppingListModeOption.EDITING:
        return [false, false, true];
      case ShoppingListModeOption.DEFAULT:
      default:
        return [true, false, false];
    }
  }

  void _setSelection(int index) {
    switch (index) {
      case 1:
        _onModeChanged(ShoppingListModeOption.SHOPPING);
        break;
      case 2:
        _onModeChanged(ShoppingListModeOption.EDITING);
        break;
      case 0:
      default:
        _onModeChanged(ShoppingListModeOption.DEFAULT);
    }
  }

  @override
  Widget build(_) {
    return ToggleButtons(
        borderWidth: 2,
        fillColor: Theme.of(_context).primaryColor,
        color: Theme.of(_context).primaryColorDark,
        selectedColor: Colors.white,
        hoverColor: Theme.of(_context).secondaryHeaderColor,
        constraints: BoxConstraints.tightFor(height: 40, width: 40),
        children: [
          Tooltip(
              message: AppLocalizations.of(_context).shoppingListModeDefault,
              child: Icon(Icons.remove_red_eye_outlined)),
          Tooltip(
              message: AppLocalizations.of(_context).shoppingListModeShopping,
              child: Icon(Icons.shopping_cart_outlined)),
          Tooltip(message: AppLocalizations.of(_context).shoppingListModeEditing, child: Icon(Icons.edit_outlined)),
        ],
        onPressed: _setSelection,
        isSelected: _calculateSelection());
  }
}
