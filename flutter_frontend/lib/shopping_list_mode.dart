import 'package:flutter/material.dart';

enum ShoppingListModeOption { DEFAULT, EDITING, SHOPPING }

class ShoppingListMode extends ChangeNotifier {
  ShoppingListModeOption _current = ShoppingListModeOption.DEFAULT;

  set(ShoppingListModeOption nextMode) {
    if (_current != nextMode) {
      _current = nextMode;
      notifyListeners();
    }
  }

  ShoppingListModeOption get get => _current;
}
