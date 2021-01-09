import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

const CATEGORY_ALL = "Alle";

class ShoppingListItem extends ChangeNotifier {
  String _id;
  String _name;
  bool _checked = false;
  String _category;
  VoidCallback _notifyCategoryChanged;
  VoidCallback _notifyCheckedChanged;

  ShoppingListItem.create(this._name);

  ShoppingListItem(this._id, this._name, this._checked, this._category);

  factory ShoppingListItem.fromJson(Map<String, dynamic> json) {
    return ShoppingListItem(json['id'], json['name'], json['checked'], json['category']);
  }

  String get id => _id;

  set name(String value) {
    if (value != _name) {
      _name = value;
      notifyListeners();
    }
  }

  String get name => _name;

  set checked(bool value) {
    if (value != _checked) {
      _checked = value;
      notifyListeners();
      _notifyCheckedChanged?.call();
    }
  }

  bool get checked => _checked;

  set categoryChangedCallback(VoidCallback callback) => _notifyCategoryChanged = callback;

  set checkedChangedCallback(VoidCallback callback) => _notifyCheckedChanged = callback;

  set category(String category) {
    if (category != _category) {
      _category = category;
      notifyListeners();
      _notifyCategoryChanged?.call();
    }
  }

  String get category => _category;

  bool hasUserCategory() {
    return category != null && category.trim().isNotEmpty;
  }

  bool isInCategory(String category) {
    return category == CATEGORY_ALL || category == _category;
  }

  @override
  bool operator ==(Object other) {
    return other is ShoppingListItem &&
        other._id == _id &&
        other._name == _name &&
        other._category == _category &&
        other._checked == _checked;
  }

  @override
  int get hashCode => _id.hashCode;
}

class ShoppingListModel extends ChangeNotifier {
  final String _id;
  final String _name;
  final List<ShoppingListItem> _items;

  ShoppingListModel(this._id, this._name, this._items) {
    _items.forEach((item) {
      item.categoryChangedCallback = this.notifyListeners;
      item.checkedChangedCallback = this.notifyListeners;
    });
  }

  String get id => _id;

  String get name => _name;

  void addItem(ShoppingListItem item) {
    _items.add(item);
    item.categoryChangedCallback = notifyListeners;
    item.checkedChangedCallback = notifyListeners;
    notifyListeners();
  }

  void removeItem(ShoppingListItem item) {
    _items.remove(item);
    item.categoryChangedCallback = null;
    item.checkedChangedCallback = null;
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
