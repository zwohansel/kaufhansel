import 'dart:collection';

import 'package:flutter/foundation.dart';

class ShoppingListItem extends ChangeNotifier {
  String _id;
  String _name;
  bool _checked = false;
  String _category;

  ShoppingListItem.create(this._name);

  ShoppingListItem(this._id, this._name, this._checked, this._category);

  factory ShoppingListItem.fromJson(Map<String, dynamic> json) {
    return ShoppingListItem(json['id'], json['name'], json['checked'], json['category']);
  }

  String get id => _id;

  set name(String value) {
    _name = value;
    notifyListeners();
  }

  String get name => _name;

  set checked(bool value) {
    _checked = value;
    notifyListeners();
  }

  bool get checked => _checked;

  set category(String category) {
    _category = category;
    notifyListeners();
  }

  String get category => _category;
}

class ShoppingListModel extends ChangeNotifier {
  final String _id;
  final List<ShoppingListItem> _items;

  ShoppingListModel(this._id, this._items);

  get id => _id;

  void addItem(ShoppingListItem item) {
    _items.add(item);
    notifyListeners();
  }

  void removeItem(ShoppingListItem item) {
    _items.remove(item);
    notifyListeners();
  }

  UnmodifiableListView<ShoppingListItem> get items => UnmodifiableListView(_items);

  List<String> getCategories() {
    final categories = _items
        .map((item) => item.category)
        .where((category) => category != null)
        .where((category) => category.trim().isNotEmpty)
        .toSet()
        .toList();
    categories.sort();
    return categories;
  }
}
