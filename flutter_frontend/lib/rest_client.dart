import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:kaufhansel_client/sync/connection_status.dart';

import 'model.dart';

class HttpResponseException implements Exception {
  final int _statusCode;
  final String _message;

  HttpResponseException(this._statusCode, {String message = "Request failed"}) : _message = message;

  factory HttpResponseException.unAuthenticated() => HttpResponseException(401, message: "Unauthenticated");

  int get statusCode => _statusCode;

  bool isUnauthenticated() => _statusCode == 401;

  bool isNotFound() => _statusCode == 404;

  @override
  String toString() {
    return "$_message - HTTP status code: $_statusCode";
  }
}

/// Thrown if a request could not be delivered to the server at all because
/// there is no usable network connection (or the server cannot be reached).
class NoConnectionException implements Exception {
  final Object? _cause;

  NoConnectionException([this._cause]);

  /// True if the server did not answer in time, as opposed to not being
  /// reachable at all.
  bool isTimeout() => _cause is TimeoutException;

  @override
  String toString() {
    return "No connection to the server${_cause == null ? "" : " - $_cause"}";
  }
}

class RestClientWidget extends InheritedWidget {
  final RestClient _client;

  RestClientWidget(this._client, {required Widget child}) : super(child: child);

  static RestClient of(BuildContext context) {
    final client = context.dependOnInheritedWidgetOfExactType<RestClientWidget>()?._client;
    if (client == null) {
      throw Exception("RestClientWidget not found");
    }
    return client;
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => true;
}

/// Returns the user info containing a freshly obtained authentication token
/// or null if no new token could be obtained.
typedef TokenRefresh = Future<ShoppingListUserInfo?> Function();

/// The status code and the already decoded body of a server response.
class _Response {
  final int statusCode;
  final String body;

  _Response(this.statusCode, this.body);
}

class RestClient {
  /// A token is refreshed if it expires within this duration.
  static const _refreshTokenBefore = Duration(minutes: 30);

  late HttpClient _httpClient;
  String? _token;
  DateTime? _tokenExpiration;
  Future<ShoppingListUserInfo?>? _pendingTokenRefresh;
  VoidCallback _onUnauthenticated = () {};
  TokenRefresh? _onTokenExpired;
  late final ConnectionStatus _connection;
  final Uri _serverUrl;
  final Duration _timeout = Duration(seconds: 10);

  /// Creates a new rest client that sends its request to the given [_serverUrl].
  ///
  /// While the server cannot be reached it is probed every [probeInterval] so
  /// that [connection] notices on its own once it is back. Pass nothing to
  /// disable probing. [systemHasNetwork] makes the probing follow the operating
  /// system's idea of connectivity, which is quicker than the interval and
  /// leaves a device without a network alone.
  RestClient(this._serverUrl, {Duration? probeInterval, Stream<bool>? systemHasNetwork}) {
    // getBackendInfo needs no authentication and is cheap.
    _connection = ConnectionStatus(() async => await getBackendInfo(),
        probeInterval: probeInterval, systemHasNetwork: systemHasNetwork);
    _httpClient = HttpClient();
    _init();
  }

  /// Tells whether the server is currently reachable.
  ConnectionStatus get connection => _connection;

  /// Set a callback that is called if a request fails because the user is not authenticated [onUnauthenticated]
  /// (e.g. the auth token has expired or the login was never performed).
  set onUnauthenticated(VoidCallback onUnauthenticated) => _onUnauthenticated = onUnauthenticated;

  /// Set a callback that is called before a request is sent if the authentication token has expired
  /// or is about to expire. The callback must return a new token or null if no new token could be obtained.
  set onTokenExpired(TokenRefresh onTokenExpired) => _onTokenExpired = onTokenExpired;

  void _init() {
    _httpClient = HttpClient();
    //accept self signed certificates in debug mode
    _httpClient.badCertificateCallback = (cert, host, port) => kDebugMode;
  }

  void setAuthenticationToken(String token, DateTime expiresAt) {
    _token = token;
    _tokenExpiration = expiresAt;
  }

  void logOut() {
    _token = null;
    _tokenExpiration = null;
    _httpClient.close(force: true);
    _init();
  }

  /// Sends a request to [path] and returns the status code together with the
  /// response body.
  ///
  /// Throws a [NoConnectionException] if the request could not be delivered at all.
  Future<_Response> _send(String method, String path, {Object? body, bool authenticated = true}) async {
    try {
      final request = await _httpClient.openUrl(method, _serverUrl.resolve(path)).timeout(_timeout);
      if (body != null) {
        request.headers.contentType = ContentType.json;
      }
      if (authenticated) {
        await _addAuthHeader(request);
      }
      if (body != null) {
        request.write(jsonEncode(body));
      }
      final response = await request.close().timeout(_timeout);
      final decoded = await response.transform(utf8.decoder).join();
      _connection.reportSuccess();
      return _Response(response.statusCode, decoded);
    } on TimeoutException catch (e) {
      throw _noConnection(e);
    } on IOException catch (e) {
      // Covers SocketException (no route, DNS failure, connection refused),
      // HandshakeException/TlsException and HttpException (connection closed
      // while the response was being read).
      throw _noConnection(e);
    }
  }

  NoConnectionException _noConnection(Object cause) {
    developer.log("Could not reach the server.", error: cause);
    _connection.reportFailure();
    return NoConnectionException(cause);
  }

  /// Returns null if the credentials are invalid.
  Future<LoginResult?> login(String userEmail, String password) async {
    final response = await _send("POST", "user/login",
        body: {'emailAddress': userEmail, 'password': password}, authenticated: false);

    if (response.statusCode == 200) {
      return new LoginResult.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 401) {
      return null;
    } else {
      throw HttpResponseException(response.statusCode, message: "Failed to get user info for $userEmail");
    }
  }

  /// Obtains a new authentication token for the owner of the given [refreshToken].
  /// Returns null if the refresh token is no longer valid.
  Future<ShoppingListUserInfo?> refreshAuthenticationToken(String refreshToken) async {
    final response =
        await _send("POST", "user/token/refresh", body: {'refreshToken': refreshToken}, authenticated: false);

    if (response.statusCode == 200) {
      return new ShoppingListUserInfo.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 401) {
      return null;
    } else {
      throw HttpResponseException(response.statusCode, message: "Failed to refresh the authentication token");
    }
  }

  /// Invalidates the given [refreshToken] so that it can no longer be used to obtain
  /// a new authentication token.
  Future<void> revokeRefreshToken(String refreshToken) async {
    final response =
        await _send("POST", "user/token/revoke", body: {'refreshToken': refreshToken}, authenticated: false);

    if (response.statusCode != 204) {
      throw HttpResponseException(response.statusCode, message: "Failed to revoke the refresh token");
    }
  }

  Future<List<ShoppingListInfo>> getShoppingLists() async {
    final response = await _send("GET", "shoppinglists");

    if (response.statusCode == 200) {
      List<dynamic> lists = jsonDecode(response.body);
      return lists.map((json) => ShoppingListInfo.fromJson(json)).toList();
    } else {
      _invokeCallbackIfUnauthenticated(response);
      throw HttpResponseException(response.statusCode, message: 'Failed to load shopping list infos');
    }
  }

  void _invokeCallbackIfUnauthenticated(_Response response) {
    if (response.statusCode == 401) {
      _onUnauthenticated();
    }
  }

  Future<void> _addAuthHeader(HttpClientRequest request) async {
    await _refreshTokenIfExpired();
    request.headers.add(HttpHeaders.authorizationHeader, "Bearer $_token");
  }

  /// Obtains a new token if the current one has expired or expires soon.
  /// Concurrent requests share the same refresh attempt.
  Future<void> _refreshTokenIfExpired() async {
    final onTokenExpired = _onTokenExpired;
    if (_token == null || onTokenExpired == null || !_isTokenExpired()) {
      return;
    }

    try {
      final userInfo = await (_pendingTokenRefresh ??= onTokenExpired());
      if (userInfo != null) {
        setAuthenticationToken(userInfo.token, userInfo.tokenExpiresAt);
      }
    } on Exception catch (e) {
      // Send the request with the expired token: the server decides whether it is still valid.
      developer.log("Could not refresh the authentication token.", error: e);
    } finally {
      _pendingTokenRefresh = null;
    }
  }

  bool _isTokenExpired() {
    final expiration = _tokenExpiration;
    if (expiration == null) {
      return false;
    }
    return DateTime.now().toUtc().isAfter(expiration.subtract(_refreshTokenBefore));
  }

  Future<List<ShoppingListItem>> fetchShoppingList(String shoppingListId) async {
    final response = await _send("GET", "shoppinglist/$shoppingListId");

    if (response.statusCode == 200) {
      List<dynamic> items = jsonDecode(response.body);
      return items.map((e) => ShoppingListItem.fromJson(e)).toList();
    } else if (response.statusCode == 404) {
      throw HttpResponseException(
        response.statusCode,
        message: "Could not find list $shoppingListId",
      );
    } else {
      _invokeCallbackIfUnauthenticated(response);
      throw HttpResponseException(response.statusCode, message: 'Failed to load list $shoppingListId');
    }
  }

  Future<ShoppingListItem> createShoppingListItem(String shoppingListId, String name, String? category) async {
    final response =
        await _send("POST", "shoppinglist/$shoppingListId", body: {'name': name, 'category': category});

    if (response.statusCode == 200) {
      return ShoppingListItem.fromJson(jsonDecode(response.body));
    } else {
      _invokeCallbackIfUnauthenticated(response);
      throw HttpResponseException(
        response.statusCode,
        message: "Failed to create new item $name in category $category for list $shoppingListId",
      );
    }
  }

  Future<void> deleteShoppingListItem(String shoppingListId, ShoppingListItem item) async {
    final response = await _send("DELETE", "shoppinglist/$shoppingListId/item/${item.id}");

    if (response.statusCode != 204) {
      _invokeCallbackIfUnauthenticated(response);
      throw HttpResponseException(
        response.statusCode,
        message: "Failed to delete item ${item.name} (${item.id}) in list $shoppingListId",
      );
    }
  }

  Future<void> updateShoppingListItem(String shoppingListId, ShoppingListItem item) async {
    final response = await _send("PUT", "shoppinglist/$shoppingListId/item/${item.id}",
        body: {'name': item.name, 'checked': item.checked, 'category': item.category});

    if (response.statusCode != 204) {
      _invokeCallbackIfUnauthenticated(response);
      throw HttpResponseException(
        response.statusCode,
        message: "Failed to update item ${item.id} in list $shoppingListId",
      );
    }
  }

  Future<void> moveShoppingListItem(String shoppingListId, ShoppingListItem item, int targetIndex) async {
    final response = await _send("PUT", "shoppinglist/$shoppingListId/moveitem",
        body: {'itemId': item.id, 'targetIndex': targetIndex});

    if (response.statusCode != 204) {
      _invokeCallbackIfUnauthenticated(response);
      throw HttpResponseException(
        response.statusCode,
        message: "Failed to move item ${item.name} (${item.id}) to $targetIndex in list $shoppingListId",
      );
    }
  }

  Future<ShoppingListInfo> createShoppingList(String shoppingListName) async {
    final response = await _send("POST", "shoppinglist", body: {'name': shoppingListName});

    if (response.statusCode == 200) {
      return ShoppingListInfo.fromJson(jsonDecode(response.body));
    } else {
      _invokeCallbackIfUnauthenticated(response);
      throw HttpResponseException(response.statusCode,
          message: "Failed to create new list with name $shoppingListName");
    }
  }

  Future<void> deleteShoppingList(String shoppingListId) async {
    final response = await _send("DELETE", "shoppinglist/$shoppingListId");

    if (response.statusCode != 204) {
      _invokeCallbackIfUnauthenticated(response);
      throw HttpResponseException(response.statusCode, message: "Failed to delete list $shoppingListId");
    }
  }

  Future<ShoppingListUserReference?> addUserToShoppingList(String shoppingListId, String userEmailAddress) async {
    final response =
        await _send("PUT", "shoppinglist/$shoppingListId/user", body: {'emailAddress': userEmailAddress});

    if (response.statusCode == 200) {
      return ShoppingListUserReference.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      _invokeCallbackIfUnauthenticated(response);
      throw HttpResponseException(
        response.statusCode,
        message: "Failed to add $userEmailAddress to list $shoppingListId.",
      );
    }
  }

  Future<void> removeUserFromShoppingList(String shoppingListId, String userId) async {
    final response = await _send("DELETE", "shoppinglist/$shoppingListId/user/$userId");

    if (response.statusCode != 204) {
      _invokeCallbackIfUnauthenticated(response);
      throw HttpResponseException(
        response.statusCode,
        message: 'Failed to remove user $userId from list $shoppingListId',
      );
    }
  }

  Future<void> uncheckItems(String shoppingListId, {String? ofCategory}) async {
    final response =
        await _send("PUT", "shoppinglist/$shoppingListId/uncheckitems", body: {'category': ofCategory});

    if (response.statusCode != 204) {
      _invokeCallbackIfUnauthenticated(response);
      throw HttpResponseException(
        response.statusCode,
        message: 'Failed to uncheck items of category in list $shoppingListId',
      );
    }
  }

  Future<void> removeCategory(String shoppingListId, {String? category}) async {
    final response =
        await _send("PUT", "shoppinglist/$shoppingListId/removecategory", body: {'category': category});

    if (response.statusCode != 204) {
      throw HttpResponseException(
        response.statusCode,
        message: 'Failed to remove category from list $shoppingListId',
      );
    }
  }

  Future<void> renameCategory(String shoppingListId, String oldCategoryName, String newCategoryName) async {
    final response = await _send("PUT", "shoppinglist/$shoppingListId/renamecategory",
        body: {'oldCategory': oldCategoryName, 'newCategory': newCategoryName});

    if (response.statusCode != 204) {
      _invokeCallbackIfUnauthenticated(response);
      throw HttpResponseException(
        response.statusCode,
        message: 'Failed to rename category in list $shoppingListId',
      );
    }
  }

  Future<void> removeAllItems(String shoppingListId) async {
    final response = await _send("POST", "shoppinglist/$shoppingListId/clear");

    if (response.statusCode != 204) {
      _invokeCallbackIfUnauthenticated(response);
      throw HttpResponseException(
        response.statusCode,
        message: 'Failed to remove all items from the shopping list $shoppingListId',
      );
    }
  }

  Future<ShoppingListUserReference> changeShoppingListPermissions(
      String shoppingListId, String affectedUserId, ShoppingListRole newRole) async {
    final response = await _send("PUT", "shoppinglist/$shoppingListId/permissions",
        body: {'userId': affectedUserId, 'role': newRole.toRoleString()});

    if (response.statusCode == 200) {
      return ShoppingListUserReference.fromJson(jsonDecode(response.body));
    } else {
      _invokeCallbackIfUnauthenticated(response);
      throw HttpResponseException(
        response.statusCode,
        message: 'Could not change role of user $affectedUserId to $newRole in list $shoppingListId',
      );
    }
  }

  Future<void> changeShoppingListName(String shoppingListId, String newName) async {
    final response = await _send("PUT", "shoppinglist/$shoppingListId/name", body: {'name': newName});

    if (response.statusCode != 204) {
      _invokeCallbackIfUnauthenticated(response);
      throw HttpResponseException(response.statusCode, message: 'Failed to rename list $shoppingListId to $newName');
    }
  }

  Future<RegistrationResult> register(String userName, String password, String? inviteCode,
      {String? emailAddress}) async {
    final response = await _send("POST", "user/register",
        body: {'userName': userName, 'emailAddress': emailAddress, 'password': password, 'inviteCode': inviteCode},
        authenticated: false);

    if (response.statusCode == 200) {
      return RegistrationResult.fromJson(jsonDecode(response.body));
    } else {
      throw HttpResponseException(response.statusCode,
          message: "Failed to register user $emailAddress with name $userName and invite code $inviteCode.");
    }
  }

  Future<void> sendInvite(String emailAddress, {String? shoppingListId}) async {
    final response = await _send("POST", "user/invite",
        body: {'emailAddress': emailAddress, 'shoppingListId': shoppingListId});

    if (response.statusCode != 204) {
      _invokeCallbackIfUnauthenticated(response);
      throw HttpResponseException(response.statusCode,
          message: "Failed to invite user $emailAddress to shopping list $shoppingListId.");
    }
  }

  Future<BackendInfo> getBackendInfo() async {
    final response = await _send("GET", "info", authenticated: false);

    if (response.statusCode == 200) {
      return BackendInfo.fromJson(jsonDecode(response.body));
    } else {
      throw HttpResponseException(response.statusCode, message: "Failed to get backend info.");
    }
  }

  Future<void> requestPasswordReset(String emailAddress) async {
    final response = await _send("POST", "user/password/requestreset",
        body: {'emailAddress': emailAddress}, authenticated: false);

    if (response.statusCode != 200) {
      throw HttpResponseException(
        response.statusCode,
        message: "Failed to request password request code for $emailAddress.",
      );
    }
  }

  Future<void> resetPassword(String emailAddress, String resetCode, String password) async {
    final response = await _send("POST", "user/password/reset",
        body: {'emailAddress': emailAddress, 'resetCode': resetCode, 'password': password}, authenticated: false);

    if (response.statusCode != 200) {
      throw HttpResponseException(
        response.statusCode,
        message: "Failed attempt to reset password for $emailAddress.",
      );
    }
  }

  Future<void> deleteAccount(String userId) async {
    final response = await _send("DELETE", "user/$userId");

    if (response.statusCode != 204) {
      _invokeCallbackIfUnauthenticated(response);
      throw HttpResponseException(
        response.statusCode,
        message: "Failed attempt to delete account of user $userId.",
      );
    }
  }
}
