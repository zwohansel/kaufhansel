import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

const CATEGORY_ALL = "Alle";

class ShoppingListItem extends ChangeNotifier {
  String _id;
  String _name;
  bool _checked = false;
  String _category;
  void Function() _notifyCategoryChanged;

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

  set categoryChangedCallback(void Function() callback) => _notifyCategoryChanged = callback;

  set category(String category) {
    _category = category;
    notifyListeners();
    if (_notifyCategoryChanged != null) {
      _notifyCategoryChanged();
    }
  }

  String get category => _category;

  bool hasUserCategory() {
    return category != null && category.trim().isNotEmpty;
  }

  bool isInCategory(String category) {
    return category == CATEGORY_ALL || category == _category;
  }
}

class ShoppingListModel extends ChangeNotifier {
  final String _id;
  final String _name;
  final List<ShoppingListItem> _items;

  ShoppingListModel(this._id, this._name, this._items) {
    _items.forEach((item) => item.categoryChangedCallback = this.notifyListeners);
  }

  String get id => _id;

  String get name => _name;

  void addItem(ShoppingListItem item) {
    _items.add(item);
    item.categoryChangedCallback = notifyListeners;
    notifyListeners();
  }

  void removeItem(ShoppingListItem item) {
    _items.remove(item);
    item.categoryChangedCallback = null;
    notifyListeners();
  }

  UnmodifiableListView<ShoppingListItem> get items => UnmodifiableListView(_items);

  List<String> getAllCategories() {
    return [CATEGORY_ALL, ...getUserCategories()];
  }

  List<String> getUserCategories() {
    final categories = _items
        .map((item) => item.category)
        .where((category) => category != null)
        .where((category) => category.trim().isNotEmpty)
        .toSet()
        .toList();
    categories.sort((l, r) => l.toLowerCase().compareTo(r.toLowerCase()));
    return categories;
  }
}

class ShoppingListInfo {
  String _id;
  String _name;

  ShoppingListInfo(this._id, this._name);

  factory ShoppingListInfo.fromJson(Map<String, dynamic> json) {
    return ShoppingListInfo(json['id'], json['name']);
  }

  String get id => _id;

  String get name => _name;
}
