import 'dart:collection';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

const CATEGORY_ALL = "Alle";

extension JsonParseExtension<K, V> on Map<K, V> {
  V get(K key) {
    V value = this[key];
    if (value == null) {
      throw Exception("No element with key $key in map. Available keys: ${this.keys}");
    }
    return value;
  }

  V getOpt(K key) {
    return this[key];
  }
}

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
    return ShoppingListItem(json.get('id'), json.get('name'), json.get('checked'), json.getOpt('category'));
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

// TODO: Can be modified concurrently... use locks
class ShoppingList extends ChangeNotifier {
  final ShoppingListInfo _info;
  final List<ShoppingListItem> _items;

  ShoppingList(this._info, this._items) {
    _items.forEach((item) {
      item.categoryChangedCallback = this.notifyListeners;
      item.checkedChangedCallback = this.notifyListeners;
    });
    _info.addListener(this.notifyListeners);
  }

  @override
  void dispose() {
    _info.removeListener(this.notifyListeners);
    super.dispose();
  }

  String get id => _info._id;

  String get name => _info.name;

  ShoppingListInfo get info => _info;

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

  void moveItem(ShoppingListItem item, int targetIndex) {
    if (targetIndex < 0) {
      throw ArgumentError.value("The target index must not be negative.");
    }

    final currentIndex = _items.indexOf(item);

    if (currentIndex < 0) {
      throw ArgumentError.value(item, item.name, "Item is not in the list");
    }

    _items.removeAt(currentIndex);
    int correctedTargetIndex = targetIndex > currentIndex ? targetIndex - 1 : targetIndex;
    _items.insert(min(correctedTargetIndex, _items.length), item);

    notifyListeners();
  }
}

enum ShoppingListRole { ADMIN, READ_WRITE, CHECK_ONLY, READ_ONLY }

const Map<String, ShoppingListRole> _strToRole = {
  'ADMIN': ShoppingListRole.ADMIN,
  'READ_WRITE': ShoppingListRole.READ_WRITE,
  'CHECK_ONLY': ShoppingListRole.CHECK_ONLY,
  'READ_ONLY': ShoppingListRole.READ_ONLY
};

extension ShoppingListRoles on ShoppingListRole {
  static ShoppingListRole fromRoleString(String roleStr) {
    final role = _strToRole[roleStr];
    if (role == null) {
      throw Exception("Unknown role: $roleStr");
    }
    return role;
  }

  String toRoleString() {
    final roleStr = _strToRole.entries.firstWhere((entry) => entry.value == this)?.key;
    if (roleStr == null) {
      throw Exception("No role string for $this");
    }
    return roleStr;
  }

  String toDisplayString() {
    switch (this) {
      case ShoppingListRole.ADMIN:
        return "Chefhansel";
      case ShoppingListRole.READ_WRITE:
        return "Schreibhansel";
      case ShoppingListRole.CHECK_ONLY:
        return "Kaufhansel";
      case ShoppingListRole.READ_ONLY:
        return "Guckhansel";
      default:
        return "Unbekannt";
    }
  }

  String toDescription() {
    switch (this) {
      case ShoppingListRole.ADMIN:
        return "Darf alles: Dinge hinzufügen und entfernen, Haken setzen und entfernen. Darf neue Hansel zur Liste " +
            "hinzufügen.\nEinmal Chefhansel, immer Chefhansel: diese Rolle kannst du nicht mehr ändern";
      case ShoppingListRole.READ_WRITE:
        return "Darf Dinge hinzufügen und entfernen, darf Haken setzen und entfernen";
      case ShoppingListRole.CHECK_ONLY:
        return "Darf Haken setzen und entfernen";
      case ShoppingListRole.READ_ONLY:
        return "Darf die Liste anschauen, aber nix ändern";
      default:
        return "Diese Rolle kennen wir nicht";
    }
  }

  IconData toIcon() {
    switch (this) {
      case ShoppingListRole.ADMIN:
        return Icons.gavel_outlined;
      case ShoppingListRole.READ_WRITE:
        return Icons.assignment_outlined;
      case ShoppingListRole.CHECK_ONLY:
        return Icons.assignment_turned_in_outlined;
      case ShoppingListRole.READ_ONLY:
        return Icons.remove_red_eye_outlined;
      default:
        return Icons.radio_button_off_outlined;
    }
  }

  bool isRemoveable() {
    return this != ShoppingListRole.ADMIN;
  }
}

class ShoppingListUserReference {
  final String _userId;
  final String _userName;
  final String _userEmailAddress;
  final ShoppingListRole _userRole;

  ShoppingListUserReference(this._userId, this._userName, this._userEmailAddress, this._userRole);

  factory ShoppingListUserReference.fromJson(Map<String, dynamic> json) {
    return ShoppingListUserReference(json.get('userId'), json.get('userName'), json.get('userEmailAddress'),
        ShoppingListRoles.fromRoleString(json.get('userRole')));
  }

  String get userId => _userId;
  String get userName => _userName;
  String get userEmailAddress => _userEmailAddress;
  ShoppingListRole get userRole => _userRole;
}

class ShoppingListInfo extends ChangeNotifier {
  final String _id;
  String _name;
  final ShoppingListPermissions _permissions;
  final List<ShoppingListUserReference> _users;

  ShoppingListInfo(this._id, this._name, this._permissions, this._users);

  factory ShoppingListInfo.fromJson(Map<String, dynamic> json) {
    return ShoppingListInfo(json.get('id'), json.get('name'), ShoppingListPermissions.fromJson(json.get('permissions')),
        _parseUserReferences(json.get('otherUsers')));
  }

  static List<ShoppingListUserReference> _parseUserReferences(List<dynamic> json) {
    return json.map((ref) => ShoppingListUserReference.fromJson(ref)).toList();
  }

  String get id => _id;
  String get name => _name;
  ShoppingListPermissions get permissions => _permissions;
  List<ShoppingListUserReference> get users => UnmodifiableListView(_users);

  void addUserToShoppingList(ShoppingListUserReference userReference) {
    _users.add(userReference);
    notifyListeners();
  }

  void removeUserFromShoppingList(ShoppingListUserReference user) {
    _users.removeWhere((ref) => ref.userId == user.userId);
    notifyListeners();
  }

  void updateShoppingListUser(ShoppingListUserReference changedUser) {
    final index = _users.indexWhere((element) => element.userId == changedUser.userId);
    if (index >= 0) {
      _users[index] = changedUser;
      notifyListeners();
    }
  }

  void updateShoppingListName(String newName) {
    _name = newName;
    notifyListeners();
  }
}

class ShoppingListPermissions {
  final ShoppingListRole _role;
  final bool _canEditList;
  final bool _canEditItems;
  final bool _canCheckItems;

  ShoppingListPermissions(this._role, this._canEditList, this._canEditItems, this._canCheckItems);

  factory ShoppingListPermissions.fromJson(Map<String, dynamic> json) {
    return new ShoppingListPermissions(ShoppingListRoles.fromRoleString(json.get('role')), json.get('canEditList'),
        json.get('canEditItems'), json.get('canCheckItems'));
  }

  ShoppingListRole get role => _role;
  bool get canCheckItems => _canCheckItems;
  bool get canEditItems => _canEditItems;
  bool get canEditList => _canEditList;
}

class ShoppingListUserInfo {
  final String _id;
  final String _username;
  final String _emailAddress;

  ShoppingListUserInfo(this._id, this._username, this._emailAddress);

  factory ShoppingListUserInfo.fromJson(Map<String, dynamic> json) {
    return new ShoppingListUserInfo(json.get('id'), json.get('username'), json.get('emailAddress'));
  }

  String get emailAddress => _emailAddress;
  String get username => _username;
  String get id => _id;
}
