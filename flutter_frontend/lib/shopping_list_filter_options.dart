import 'package:flutter/material.dart';

enum ShoppingListFilterOption { ALL, CHECKED, UNCHECKED }

class ShoppingListFilter extends ChangeNotifier {
  ShoppingListFilterOption _current = ShoppingListFilterOption.ALL;

  set(ShoppingListFilterOption nextFilter) {
    if (_current != nextFilter) {
      _current = nextFilter;
      notifyListeners();
    }
  }

  ShoppingListFilterOption get get => _current;
}
