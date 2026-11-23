import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaufhansel_client/model.dart';
import 'package:kaufhansel_client/rest_client.dart';
import 'package:kaufhansel_client/sync/connection_status.dart';

import 'utils.dart';

class User {
  final ShoppingListUserInfo _info;
  final String _password;
  final String _refreshToken;

  /// The authentication token the user gets when he refreshes his token
  final String _refreshedToken;

  ShoppingListUserInfo get info => _info;

  String get password => _password;

  String get refreshToken => _refreshToken;

  ShoppingListUserInfo get refreshedInfo =>
      ShoppingListUserInfo(_info.id, _info.username, _info.emailAddress, _refreshedToken, tokenExpiresAt);

  User(this._info, this._password, {String refreshToken = "refreshToken", String refreshedToken = "refreshedToken"})
      : _refreshToken = refreshToken,
        _refreshedToken = refreshedToken;
}

class RestClientStub implements RestClient {
  final RegistrationResult Function(String userName, String password, {String? emailAddress})? onRegister;
  final void Function(String emailAddress)? onPasswordResetRequest;
  final void Function(String emailAddress, String resetCode, String password)? onPasswordReset;
  final BackendInfo Function()? onGetBackendInfo;
  final List<ShoppingListInfo> Function()? onGetShoppingLists;
  final List<ShoppingListItem> Function(String id)? onFetchShoppingList;
  final ShoppingListItem Function(String shoppingListId, String name, String? category)? onCreateShoppingListItem;
  final void Function(String shoppingListId, ShoppingListItem item)? onUpdateShoppingListItem;
  final void Function(String shoppingListId, String? category)? onRemoveCategory;
  final void Function(String shoppingListId, String oldCategoryName, String newCategoryName)? onRenameCategory;
  final void Function(String shoppingListId, String? ofCategory)? onUncheckItems;
  final void Function(String shoppingListId, ShoppingListItem item)? onDeleteShoppingListItem;
  final void Function(String shoppingListId, ShoppingListItem item, int targetIndex)? onMoveShoppingListItem;
  final void Function(String shoppingListId, String newName)? onRenameShoppingList;
  final void Function(String shoppingListId)? onRemoveAllItems;
  final ShoppingListUserReference? Function(String shoppingListId, String userEmailAddress)? onAddUserToShoppingList;
  final ShoppingListUserReference Function(String shoppingListId, String userId, ShoppingListRole newRole)?
      onChangeShoppingListPermissions;
  final void Function(String emailAddress, {String? shoppingListId})? onSendInvite;
  final void Function(String shoppingListId, String userId)? onRemoveUserFromShoppingList;

  final List<User> _users = [];
  final List<String> _revokedRefreshTokens = [];
  VoidCallback? _onUnauthenticated;
  TokenRefresh? _onTokenExpired;
  late final ConnectionStatus _connection;

  bool _offline = false;

  /// While true every method throws a [NoConnectionException], as if the device
  /// had no network connection. Setting it also puts [connection] into the
  /// matching state, so that callers do not have to attempt a doomed request
  /// first.
  bool get offline => _offline;

  set offline(bool offline) {
    _offline = offline;
    if (offline) {
      _connection.reportFailure();
    } else {
      _connection.reportSuccess();
    }
  }

  /// Stops answering without telling [connection] about it, which is what
  /// really happens between a connection dropping and the first request that
  /// runs into it.
  void loseConnectionUnnoticed() => _offline = true;

  /// Records every call that actually reached the stub, in order, so that tests
  /// can assert which requests were sent and with which arguments.
  final List<String> callLog = [];

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
      this.onMoveShoppingListItem,
      this.onRenameShoppingList,
      this.onRemoveAllItems,
      this.onAddUserToShoppingList,
      this.onChangeShoppingListPermissions,
      this.onSendInvite,
      this.onRemoveUserFromShoppingList}) {
    // No probe interval: a pending timer would outlive the test.
    _connection = ConnectionStatus(() async => await getBackendInfo());
  }

  void addUser(User user) => _users.add(user);

  set onUnauthenticated(VoidCallback onUnauthenticated) => _onUnauthenticated = onUnauthenticated;

  @override
  set onTokenExpired(TokenRefresh onTokenExpired) => _onTokenExpired = onTokenExpired;

  @override
  ConnectionStatus get connection => _connection;

  /// Simulates an expired authentication token: returns the user info containing
  /// the newly obtained token or null if no new token could be obtained.
  Future<ShoppingListUserInfo?> expireToken() async => await _onTokenExpired?.call();

  /// Throws if the stub is [offline], otherwise records the call in [callLog]
  /// and invokes [callee], forwarding an unauthenticated response to the
  /// `onUnauthenticated` callback just like the real client does.
  T _guard<T>(String call, T Function() callee) {
    if (_offline) {
      _connection.reportFailure();
      throw NoConnectionException("stub is offline");
    }
    callLog.add(call);
    try {
      final result = callee();
      _connection.reportSuccess();
      return result;
    } on HttpResponseException catch (e) {
      _connection.reportSuccess();
      if (e.isUnauthenticated() && _onUnauthenticated != null) {
        _onUnauthenticated!();
      }
      rethrow;
    }
  }

  @override
  Future<BackendInfo> getBackendInfo() async {
    if (onGetBackendInfo == null) throw UnimplementedError();
    return _guard("getBackendInfo", () => onGetBackendInfo!());
  }

  @override
  Future<LoginResult?> login(String userEmail, String password) async {
    return _guard("login:$userEmail", () => _login(userEmail, password));
  }

  LoginResult? _login(String userEmail, String password) {
    for (final user in _users) {
      if (user.info.emailAddress == userEmail && user.password == password) {
        _revokedRefreshTokens.remove(user.refreshToken);
        return LoginResult(user.info, user.refreshToken);
      }
    }
    return null;
  }

  @override
  Future<ShoppingListUserInfo?> refreshAuthenticationToken(String refreshToken) async {
    return _guard("refreshToken", () => _refreshAuthenticationToken(refreshToken));
  }

  ShoppingListUserInfo? _refreshAuthenticationToken(String refreshToken) {
    if (_revokedRefreshTokens.contains(refreshToken)) {
      return null;
    }
    for (final user in _users) {
      if (user.refreshToken == refreshToken) {
        return user.refreshedInfo;
      }
    }
    return null;
  }

  @override
  Future<void> revokeRefreshToken(String refreshToken) async {
    _guard("revokeRefreshToken", () => _revokedRefreshTokens.add(refreshToken));
  }

  bool isRefreshTokenRevoked(String refreshToken) => _revokedRefreshTokens.contains(refreshToken);

  @override
  Future<RegistrationResult> register(String userName, String password, String? inviteCode,
      {String? emailAddress}) async {
    return _guard("register:$emailAddress", () => _register(userName, password, emailAddress));
  }

  RegistrationResult _register(String userName, String password, String? emailAddress) {
    if (onRegister == null) {
      return RegistrationResult(RegistrationResultStatus.FAILURE);
    }
    if (emailAddress != null && emailAddress.isNotEmpty) {
      return onRegister!(userName, password, emailAddress: emailAddress);
    }
    return RegistrationResult(RegistrationResultStatus.FAILURE);
  }

  @override
  Future<ShoppingListUserReference?> addUserToShoppingList(String shoppingListId, String userEmailAddress) async {
    if (onAddUserToShoppingList == null) return throw UnimplementedError();
    return _guard("addUser:$shoppingListId:$userEmailAddress",
        () => onAddUserToShoppingList!(shoppingListId, userEmailAddress));
  }

  @override
  Future<void> changeShoppingListName(String shoppingListId, String newName) async {
    if (onRenameShoppingList == null) throw UnimplementedError();
    _guard("renameList:$shoppingListId", () => onRenameShoppingList!(shoppingListId, newName));
  }

  @override
  Future<ShoppingListUserReference> changeShoppingListPermissions(
      String shoppingListId, String userId, ShoppingListRole newRole) async {
    if (onChangeShoppingListPermissions == null) throw UnimplementedError();
    return _guard("changePermissions:$shoppingListId:$userId",
        () => onChangeShoppingListPermissions!(shoppingListId, userId, newRole));
  }

  @override
  void logOut() {}

  @override
  Future<ShoppingListInfo> createShoppingList(String shoppingListName) {
    throw UnimplementedError();
  }

  @override
  Future<ShoppingListItem> createShoppingListItem(String shoppingListId, String name, String? category) async {
    if (onCreateShoppingListItem == null) throw UnimplementedError();
    return _guard(
        "createItem:$shoppingListId:$name", () => onCreateShoppingListItem!(shoppingListId, name, category));
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
  Future<void> deleteShoppingListItem(String shoppingListId, ShoppingListItem item) async {
    if (onDeleteShoppingListItem == null) throw UnimplementedError();
    return _guard("deleteItem:$shoppingListId:${item.id}", () => onDeleteShoppingListItem!(shoppingListId, item));
  }

  @override
  Future<List<ShoppingListInfo>> getShoppingLists() async {
    if (onGetShoppingLists == null) throw UnimplementedError();
    return _guard("getLists", onGetShoppingLists!);
  }

  @override
  Future<List<ShoppingListItem>> fetchShoppingList(String shoppingListId) async {
    if (onFetchShoppingList == null) throw UnimplementedError();
    return _guard("fetchList:$shoppingListId", () => onFetchShoppingList!(shoppingListId));
  }

  @override
  Future<void> moveShoppingListItem(String shoppingListId, ShoppingListItem item, int targetIndex) async {
    if (onMoveShoppingListItem == null) throw UnimplementedError();
    _guard("moveItem:$shoppingListId:${item.id}:$targetIndex",
        () => onMoveShoppingListItem!(shoppingListId, item, targetIndex));
  }

  @override
  Future<void> removeAllItems(String shoppingListId) async {
    if (this.onRemoveAllItems == null) throw UnimplementedError();
    _guard("removeAllItems:$shoppingListId", () => this.onRemoveAllItems!(shoppingListId));
  }

  @override
  Future<void> removeUserFromShoppingList(String shoppingListId, String userId) async {
    if (onRemoveUserFromShoppingList == null) throw UnimplementedError();
    _guard("removeUser:$shoppingListId:$userId", () => onRemoveUserFromShoppingList!(shoppingListId, userId));
  }

  @override
  Future<void> requestPasswordReset(String emailAddress) async {
    if (onPasswordResetRequest == null) throw UnimplementedError();
    _guard("requestPasswordReset:$emailAddress", () => onPasswordResetRequest!(emailAddress));
  }

  @override
  Future<void> resetPassword(String emailAddress, String resetCode, String password) async {
    if (onPasswordReset == null) throw UnimplementedError();
    _guard("resetPassword:$emailAddress", () => onPasswordReset!(emailAddress, resetCode, password));
  }

  @override
  Future<void> sendInvite(String emailAddress, {String? shoppingListId}) async {
    if (onSendInvite == null) throw UnimplementedError();
    _guard("sendInvite:$emailAddress", () => onSendInvite!(emailAddress, shoppingListId: shoppingListId));
  }

  @override
  void setAuthenticationToken(String token, DateTime expiresAt) {}

  @override
  Future<void> updateShoppingListItem(String shoppingListId, ShoppingListItem item) async {
    if (onUpdateShoppingListItem == null) throw UnimplementedError();
    _guard("updateItem:$shoppingListId:${item.id}", () => onUpdateShoppingListItem!(shoppingListId, item));
  }

  @override
  Future<void> removeCategory(String shoppingListId, {String? category}) async {
    if (onRemoveCategory == null) throw UnimplementedError();
    _guard("removeCategory:$shoppingListId:$category", () => onRemoveCategory!(shoppingListId, category));
  }

  @override
  Future<void> renameCategory(String shoppingListId, String oldCategoryName, String newCategoryName) async {
    if (onRenameCategory == null) throw UnimplementedError();
    _guard("renameCategory:$shoppingListId:$oldCategoryName:$newCategoryName",
        () => onRenameCategory!(shoppingListId, oldCategoryName, newCategoryName));
  }

  @override
  Future<void> uncheckItems(String shoppingListId, {String? ofCategory}) async {
    if (onUncheckItems == null) throw UnimplementedError();
    _guard("uncheckItems:$shoppingListId:$ofCategory", () => onUncheckItems!(shoppingListId, ofCategory));
  }
}
