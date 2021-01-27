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

class ShoppingList extends ChangeNotifier {
  final String _id;
  final String _name;
  final List<ShoppingListItem> _items;

  ShoppingList(this._id, this._name, this._items) {
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

  void removeAllItems() {
    _items.forEach((item) {
      item.categoryChangedCallback = null;
      item.checkedChangedCallback = null;
    });
    _items.clear();
    notifyListeners();
  }

  List<ShoppingListItem> get items => UnmodifiableListView(_items);

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

  void moveItem(ShoppingListItem item, {ShoppingListItem before, ShoppingListItem behind}) {
    assert((before == null) ^ (behind == null), "Either before or behind must be defined but not both.");

    if (!_items.contains(item)) {
      throw ArgumentError.value(item, item.name, "Item is not in the list");
    }

    final refItem = before ?? behind;
    if (!_items.contains(refItem)) {
      throw ArgumentError.value(refItem, refItem.name, "Item is not in the list");
    }

    if (item == refItem) {
      throw ArgumentError.value(item, item.name, "Can't move item relative to itself");
    }

    _items.remove(item);
    final refItemIndex = _items.indexOf(refItem);

    if (before != null) {
      _items.insert(refItemIndex, item);
    } else {
      _items.insert(refItemIndex + 1, item);
    }
    notifyListeners();
  }
}

class ShoppingListTabSelection extends ChangeNotifier {
  int _currentTabIndex;

  ShoppingListTabSelection(this._currentTabIndex);

  int get currentTabIndex => _currentTabIndex;
  set currentTabIndex(int index) {
    if (index != _currentTabIndex) {
      _currentTabIndex = index;
      notifyListeners();
    }
  }
}

class ShoppingListUserReference {
  final String _userId;
  final String _userName;
  final String _userEmailAddress;
  final ShoppingListPermissions permissions;

  ShoppingListUserReference(this._userId, this._userName, this._userEmailAddress, this.permissions);

  factory ShoppingListUserReference.fromJson(Map<String, dynamic> json) {
    return ShoppingListUserReference(json['userId'], json['userName'], json['userEmailAddress'],
        new ShoppingListPermissions.fromJson(json['permissions']));
  }

  String get userId => _userId;
  String get userName => _userName;
  String get userEmailAddress => _userEmailAddress;
}

class ShoppingListInfo {
  final String _id;
  final String _name;
  final List<ShoppingListUserReference> _users;

  ShoppingListInfo(this._id, this._name, this._users);

  factory ShoppingListInfo.fromJson(Map<String, dynamic> json) {
    return ShoppingListInfo(json['id'], json['name'], _parseUserReferences(json['users']));
  }

  static List<ShoppingListUserReference> _parseUserReferences(List<dynamic> json) {
    return json.map((ref) => ShoppingListUserReference.fromJson(ref)).toList();
  }

  void addUserToShoppingList(ShoppingListUserReference userReference) {
    _users.add(userReference);
  }

  void removeUserFromShoppingList(ShoppingListUserReference user) {
    _users.removeWhere((ref) => ref.userId == user.userId);
  }

  String get id => _id;
  String get name => _name;
  List<ShoppingListUserReference> get users => UnmodifiableListView(_users);

  void updateShoppingListUser(ShoppingListUserReference changedUser) {
    final index = _users.indexWhere((element) => element.userId == changedUser.userId);
    if (index >= 0) {
      _users[index] = changedUser;
    }
  }
}

class ShoppingListPermissions {
  final String _role;
  final bool _canEditList;
  final bool _canEditItems;
  final bool _canCheckItems;

  ShoppingListPermissions(this._role, this._canEditList, this._canEditItems, this._canCheckItems);

  factory ShoppingListPermissions.fromJson(Map<String, dynamic> json) {
    return new ShoppingListPermissions(json['role'], json['canEditList'], json['canEditItems'], json['canCheckItems']);
  }

  String get role => _role;
  bool get canCheckItems => _canCheckItems;
  bool get canEditItems => _canEditItems;
  bool get canEditList => _canEditList;
}
