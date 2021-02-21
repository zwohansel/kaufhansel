import 'dart:collection';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kaufhansel_client/generated/l10n.dart';
import 'package:kaufhansel_client/utils/semantic_versioning.dart';

const CATEGORY_ALL = "Alle";

class Optional<T> {
  final T _t;

  factory Optional.empty() => Optional(null);
  Optional(T t) : this._t = t;

  T get get => _t;
  bool isPresent() => _t != null;
  void ifPresent(void Function(T) then) {
    if (isPresent()) {
      then(_t);
    }
  }
}

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

  ShoppingListItem copy() {
    return ShoppingListItem(_id, _name, _checked, _category);
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

  String toDisplayString(BuildContext context) {
    switch (this) {
      case ShoppingListRole.ADMIN:
        return AppLocalizations.of(context).roleAdminName;
      case ShoppingListRole.READ_WRITE:
        return AppLocalizations.of(context).roleReadWriteName;
      case ShoppingListRole.CHECK_ONLY:
        return AppLocalizations.of(context).roleCheckOnlyName;
      case ShoppingListRole.READ_ONLY:
        return AppLocalizations.of(context).roleReadOnlyName;
      default:
        return AppLocalizations.of(context).exceptionFatal;
    }
  }

  String toDescription(BuildContext context) {
    switch (this) {
      case ShoppingListRole.ADMIN:
        return AppLocalizations.of(context).roleAdminDescription;
      case ShoppingListRole.READ_WRITE:
        return AppLocalizations.of(context).roleReadWriteDescription;
      case ShoppingListRole.CHECK_ONLY:
        return AppLocalizations.of(context).roleCheckOnlyDescription;
      case ShoppingListRole.READ_ONLY:
        return AppLocalizations.of(context).roleReadOnlyDescription;
      default:
        return AppLocalizations.of(context).exceptionFatal;
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShoppingListPermissions &&
          runtimeType == other.runtimeType &&
          _role == other._role &&
          _canEditList == other._canEditList &&
          _canEditItems == other._canEditItems &&
          _canCheckItems == other._canCheckItems;

  @override
  int get hashCode => _role.hashCode ^ _canEditList.hashCode ^ _canEditItems.hashCode ^ _canCheckItems.hashCode;
}

class ShoppingListUserInfo {
  final String _id;
  final String _username;
  final String _emailAddress;
  final String _token;

  ShoppingListUserInfo(this._id, this._username, this._emailAddress, this._token);

  factory ShoppingListUserInfo.fromJson(Map<String, dynamic> json) {
    return new ShoppingListUserInfo(json.get('id'), json.get('username'), json.get('emailAddress'), json.get('token'));
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'username': username, 'emailAddress': emailAddress, 'token': token};
  }

  String get id => _id;
  String get username => _username;
  String get emailAddress => _emailAddress;
  String get token => _token;
}

enum RegistrationProcessType { INVALID, FULL_REGISTRATION, WITHOUT_EMAIL }

const Map<String, RegistrationProcessType> _strToType = {
  'INVALID': RegistrationProcessType.INVALID,
  'FULL_REGISTRATION': RegistrationProcessType.FULL_REGISTRATION,
  'WITHOUT_EMAIL': RegistrationProcessType.WITHOUT_EMAIL,
};

extension RegistrationProcessTypes on RegistrationProcessType {
  static RegistrationProcessType fromString(String typeStr) {
    final type = _strToType[typeStr];
    if (type == null) {
      return RegistrationProcessType.INVALID;
    }
    return type;
  }
}

enum _RegistrationResultStatus { SUCCESS, EMAIL_INVALID, INVITE_CODE_INVALID, PASSWORD_INVALID, FAILURE }

const Map<String, _RegistrationResultStatus> _strToStatus = {
  'SUCCESS': _RegistrationResultStatus.SUCCESS,
  'EMAIL_INVALID': _RegistrationResultStatus.EMAIL_INVALID,
  'INVITE_CODE_INVALID': _RegistrationResultStatus.INVITE_CODE_INVALID,
  'PASSWORD_INVALID': _RegistrationResultStatus.PASSWORD_INVALID,
};

extension _RegistrationResultStates on _RegistrationResultStatus {
  static _RegistrationResultStatus fromString(String statusStr) {
    final status = _strToStatus[statusStr];
    if (status == null) {
      return _RegistrationResultStatus.FAILURE;
    }
    return status;
  }
}

class RegistrationResult {
  final _RegistrationResultStatus _status;

  RegistrationResult(this._status);

  factory RegistrationResult.fromJson(Map<String, dynamic> json) {
    return new RegistrationResult(_RegistrationResultStates.fromString(json.get("status")));
  }

  bool isSuccess() => _status == _RegistrationResultStatus.SUCCESS;

  bool isInviteCodeInvalid() => _status == _RegistrationResultStatus.INVITE_CODE_INVALID;

  bool isEMailAddressInvalid() => _status == _RegistrationResultStatus.EMAIL_INVALID;

  bool isPasswordInvalid() => _status == _RegistrationResultStatus.PASSWORD_INVALID;
}

enum InfoMessageSeverity { CRITICAL, INFO }

const Map<String, InfoMessageSeverity> _strToSeverity = {
  'CRITICAL': InfoMessageSeverity.CRITICAL,
  'INFO': InfoMessageSeverity.INFO,
};

extension _InfoMessageSeverities on _RegistrationResultStatus {
  static InfoMessageSeverity fromString(String severityStr) {
    final severity = _strToSeverity[severityStr];
    if (severity == null) {
      return InfoMessageSeverity.INFO;
    }
    return severity;
  }
}

class InfoMessage {
  final InfoMessageSeverity _severity;
  final String _message;
  final String _dismissLabel;

  InfoMessage(this._severity, this._message, this._dismissLabel);

  factory InfoMessage.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }
    return new InfoMessage(
        _InfoMessageSeverities.fromString(json.get("severity")), json.get("message"), json.getOpt("dismissLabel"));
  }

  InfoMessageSeverity get severity => _severity;
  String get message => _message;
  String get dismissLabel => _dismissLabel;
}

class BackendInfo {
  final Version _version;
  final InfoMessage _message;

  BackendInfo(this._version, this._message);

  factory BackendInfo.fromJson(Map<String, dynamic> json) {
    return new BackendInfo(Version.fromString(json.get("apiVersion")), InfoMessage.fromJson(json.getOpt("message")));
  }

  InfoMessage get message => _message;
  Version get version => _version;
}
