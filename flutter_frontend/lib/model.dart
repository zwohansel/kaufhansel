import 'dart:collection';

import 'package:flutter/foundation.dart';

class ShoppingListItem extends ChangeNotifier {
  String _id;
  String _name;
  bool _checked = false;

  ShoppingListItem.create(this._name);

  ShoppingListItem(this._id, this._name, this._checked);

  factory ShoppingListItem.fromJson(Map<String, dynamic> json) {
    return ShoppingListItem(json['id'], json['name'], json['checked']);
  }

  set checked(bool value) {
    _checked = value;
    notifyListeners();
  }

  String get id => _id;

  String get name => _name;

  bool get checked => _checked;
}

class ShoppingListModel extends ChangeNotifier {
  final List<ShoppingListItem> _items;

  ShoppingListModel(this._items);

  void addItem(ShoppingListItem item) {
    _items.add(item);
    notifyListeners();
  }

  void removeItem(ShoppingListItem item) {
    _items.remove(item);
    notifyListeners();
  }

  UnmodifiableListView<ShoppingListItem> get items => UnmodifiableListView(_items);
}
