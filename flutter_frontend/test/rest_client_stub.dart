import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaufhansel_client/model.dart';
import 'package:kaufhansel_client/rest_client.dart';

class User {
  final ShoppingListUserInfo _info;
  final String _password;

  ShoppingListUserInfo get info => _info;
  String get password => _password;

  User(this._info, this._password);
}

class RestClientStub implements RestClient {
  final RegistrationResult Function(String userName, String password, {String emailAddress}) onRegister;
  final void Function(String emailAddress) onPasswordResetRequest;
  final void Function(String emailAddress, String resetCode, String password) onPasswordReset;
  final BackendInfo Function() onGetBackendInfo;
  final List<ShoppingListInfo> Function() onGetShoppingLists;
  final List<ShoppingListItem> Function(String id) onFetchShoppingList;
  final ShoppingListItem Function(String shoppingListId, String name, String category) onCreateShoppingListItem;
  final void Function(String shoppingListId, ShoppingListItem item) onUpdateShoppingListItem;
  final void Function(String shoppingListId, String category) onRemoveCategory;
  final void Function(String shoppingListId, String oldCategoryName, String newCategoryName) onRenameCategory;
  final void Function(String shoppingListId, String ofCategory) onUncheckItems;
  final void Function(String shoppingListId, ShoppingListItem item) onDeleteShoppingListItem;
  final void Function(String shoppingListId, String newName) onRenameShoppingList;
  final void Function(String shoppingListId) onRemoveAllItems;
  final ShoppingListUserReference Function(String shoppingListId, String userEmailAddress) onAddUserToShoppingList;
  final ShoppingListUserReference Function(String shoppingListId, String userId, ShoppingListRole newRole)
      onChangeShoppingListPermissions;
  final void Function(String emailAddress, {String shoppingListId}) onSendInvite;
  final void Function(String shoppingListId, String userId) onRemoveUserFromShoppingList;

  final List<User> _users = [];
  final Map<String, RegistrationProcessType> _inviteCodes = {};
  VoidCallback _onUnauthenticated;

  RestClientStub(
      {this.onRegister,
      this.onPasswordResetRequest,
      this.onPasswordReset,
      this.onGetBackendInfo,
      this.onGetShoppingLists,
      this.onFetchShoppingList,
      this.onCreateShoppingListItem,
      this.onUpdateShoppingListItem,
      this.onRemoveCategory,
      this.onRenameCategory,
      this.onUncheckItems,
      this.onDeleteShoppingListItem,
      this.onRenameShoppingList,
      this.onRemoveAllItems,
      this.onAddUserToShoppingList,
      this.onChangeShoppingListPermissions,
      this.onSendInvite,
      this.onRemoveUserFromShoppingList});

  void addUser(User user) => _users.add(user);

  void addInviteCode(String code, RegistrationProcessType type) {
    _inviteCodes[code] = type;
  }

  set onUnauthenticated(VoidCallback onUnauthenticated) => _onUnauthenticated = onUnauthenticated;

  @override
  Future<BackendInfo> getBackendInfo() async {
    return onGetBackendInfo();
  }

  @override
  Future<ShoppingListUserInfo> login(String userEmail, String password) async {
    for (final user in _users) {
      if (user.info.emailAddress == userEmail && user.password == password) {
        return user.info;
      }
    }
    return null;
  }

  @override
  Future<RegistrationProcessType> checkInviteCode(String inviteCode) async {
    return _inviteCodes[inviteCode] ?? RegistrationProcessType.INVALID;
  }

  @override
  Future<RegistrationResult> register(String userName, String password, String inviteCode,
      {String emailAddress}) async {
    if (onRegister == null) {
      return RegistrationResult(RegistrationResultStatus.FAILURE);
    }

    final type = await checkInviteCode(inviteCode);
    if (type == RegistrationProcessType.FULL_REGISTRATION && emailAddress != null && emailAddress.isNotEmpty) {
      return onRegister(userName, password, emailAddress: emailAddress);
    } else if (type == RegistrationProcessType.WITHOUT_EMAIL) {
      return onRegister(userName, password);
    }
    return RegistrationResult(RegistrationResultStatus.FAILURE);
  }

  @override
  Future<Optional<ShoppingListUserReference>> addUserToShoppingList(
      String shoppingListId, String userEmailAddress) async {
    if (onAddUserToShoppingList == null) return throw UnimplementedError();
    return Optional(onAddUserToShoppingList(shoppingListId, userEmailAddress));
  }

  @override
  Future<void> changeShoppingListName(String shoppingListId, String newName) async {
    if (onRenameShoppingList == null) throw UnimplementedError();
    onRenameShoppingList(shoppingListId, newName);
  }

  @override
  Future<ShoppingListUserReference> changeShoppingListPermissions(
      String shoppingListId, String userId, ShoppingListRole newRole) async {
    if (onChangeShoppingListPermissions == null) throw UnimplementedError();
    return onChangeShoppingListPermissions(shoppingListId, userId, newRole);
  }

  @override
  void logOut() {}

  @override
  Future<ShoppingListInfo> createShoppingList(String shoppingListName) {
    throw UnimplementedError();
  }

  @override
  Future<ShoppingListItem> createShoppingListItem(String shoppingListId, String name, String category) async {
    if (onCreateShoppingListItem == null) throw UnimplementedError();
    return _tryCall(() => onCreateShoppingListItem(shoppingListId, name, category));
  }

  T _tryCall<T>(T Function() callee) {
    try {
      return callee();
    } on HttpResponseException catch (e) {
      if (e.isUnauthenticated() && _onUnauthenticated != null) {
        _onUnauthenticated();
      }
      rethrow;
    }
  }

  @override
  Future<void> deleteAccount(String userId) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteShoppingList(String shoppingListId) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteShoppingListItems(String shoppingListId, String ofCategory) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteShoppingListItem(String shoppingListId, ShoppingListItem item) async {
    if (onDeleteShoppingListItem == null) throw UnimplementedError();
    return _tryCall(() => onDeleteShoppingListItem(shoppingListId, item));
  }

  @override
  Future<String> generateInviteCode() {
    throw UnimplementedError();
  }

  @override
  Future<List<ShoppingListInfo>> getShoppingLists() async {
    if (onGetShoppingLists == null) throw UnimplementedError();
    return _tryCall(onGetShoppingLists);
  }

  @override
  Future<List<ShoppingListItem>> fetchShoppingList(String shoppingListId) async {
    if (onFetchShoppingList == null) throw UnimplementedError();
    return _tryCall(() => onFetchShoppingList(shoppingListId));
  }

  @override
  Future<void> moveShoppingListItem(String shoppingListId, ShoppingListItem item, int targetIndex) {
    throw UnimplementedError();
  }

  @override
  Future<void> removeAllItems(String shoppingListId) async {
    if (this.onRemoveAllItems == null) throw UnimplementedError();
    this.onRemoveAllItems(shoppingListId);
  }

  @override
  Future<void> removeUserFromShoppingList(String shoppingListId, String userId) async {
    if (onRemoveUserFromShoppingList == null) throw UnimplementedError();
    onRemoveUserFromShoppingList(shoppingListId, userId);
  }

  @override
  Future<void> requestPasswordReset(String emailAddress) async {
    if (onPasswordResetRequest == null) throw UnimplementedError();
    onPasswordResetRequest(emailAddress);
  }

  @override
  Future<void> resetPassword(String emailAddress, String resetCode, String password) async {
    if (onPasswordReset == null) throw UnimplementedError();
    onPasswordReset(emailAddress, resetCode, password);
  }

  @override
  Future<void> sendInvite(String emailAddress, {String shoppingListId}) async {
    if (onSendInvite == null) throw UnimplementedError();
    onSendInvite(emailAddress, shoppingListId: shoppingListId);
  }

  @override
  void setAuthenticationToken(String token) {}

  @override
  Future<void> updateShoppingListItem(String shoppingListId, ShoppingListItem item) async {
    if (onUpdateShoppingListItem == null) throw UnimplementedError();
    _tryCall(() => onUpdateShoppingListItem(shoppingListId, item));
  }

  @override
  Future<void> removeCategory(String shoppingListId, {String category}) async {
    if (onRemoveCategory == null) throw UnimplementedError();
    onRemoveCategory(shoppingListId, category);
  }

  @override
  Future<void> renameCategory(String shoppingListId, String oldCategoryName, String newCategoryName) async {
    if (onRenameCategory == null) throw UnimplementedError();
    onRenameCategory(shoppingListId, oldCategoryName, newCategoryName);
  }

  @override
  Future<void> uncheckItems(String shoppingListId, {String ofCategory}) async {
    if (onUncheckItems == null) throw UnimplementedError();
    onUncheckItems(shoppingListId, ofCategory);
  }
}
