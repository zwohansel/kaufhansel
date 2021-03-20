import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'model.dart';

class HttpResponseException implements Exception {
  final int _statusCode;
  final String _message;

  HttpResponseException(this._statusCode, {String message = "Request failed"}) : _message = message;

  factory HttpResponseException.unAuthenticated() => HttpResponseException(401, message: "Unauthenticated");

  bool isUnauthenticated() => _statusCode == 401;

  @override
  String toString() {
    return "$_message - HTTP status code: $_statusCode";
  }
}

class RestClientWidget extends InheritedWidget {
  final RestClient _client;

  RestClientWidget(this._client, {@required Widget child}) : super(child: child);

  static RestClient of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<RestClientWidget>()._client;
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => true;
}

class RestClient {
  HttpClient _httpClient;
  String _token;
  VoidCallback _onUnauthenticated = () {};
  final Uri _serverUrl;
  final Duration _timeout = Duration(seconds: 10);

  /// Creates a new rest client that sends its request to the given [_serverUrl].
  RestClient(this._serverUrl) {
    _init();
  }

  /// Set a callback that is called if a request fails because the user is not authenticated [onUnauthenticated]
  /// (e.g. the auth token has expired or the login was never performed).
  set onUnauthenticated(VoidCallback onUnauthenticated) => _onUnauthenticated = onUnauthenticated;

  void _init() {
    _httpClient = HttpClient();
    //accept self signed certificates in debug mode
    _httpClient.badCertificateCallback = (cert, host, port) => kDebugMode;
  }

  void setAuthenticationToken(String token) {
    _token = token;
  }

  void logOut() {
    _token = null;
    _httpClient.close(force: true);
    _init();
  }

  Future<ShoppingListUserInfo> login(String userEmail, String password) async {
    final body = jsonEncode({'emailAddress': userEmail, 'password': password});

    final request = await _httpClient.postUrl(_serverUrl.resolve("user/login"));
    request.headers.contentType = ContentType.json;
    request.write(body);
    final response = await request.close().timeout(_timeout);

    if (response.statusCode == 200) {
      final String decoded = await response.transform(utf8.decoder).join();
      return new ShoppingListUserInfo.fromJson(jsonDecode(decoded));
    } else if (response.statusCode == 401) {
      return null;
    } else {
      throw HttpResponseException(response.statusCode, message: "Failed to get user info for $userEmail");
    }
  }

  Future<List<ShoppingListInfo>> getShoppingLists() async {
    var request = await _httpClient.getUrl(_serverUrl.resolve("shoppinglists")).timeout(_timeout);
    _addAuthHeader(request);
    var response = await request.close().timeout(_timeout);

    if (response.statusCode == 200) {
      final String decoded = await response.transform(utf8.decoder).join();
      List<dynamic> lists = jsonDecode(decoded);
      return lists.map((json) => ShoppingListInfo.fromJson(json)).toList();
    } else {
      _invokeCallbackIfUnauthenticated(response);
      throw HttpResponseException(response.statusCode, message: 'Failed to load shopping list infos');
    }
  }

  void _invokeCallbackIfUnauthenticated(HttpClientResponse response) {
    if (response.statusCode == 401 && _onUnauthenticated != null) {
      _onUnauthenticated();
    }
  }

  void _addAuthHeader(HttpClientRequest request) {
    request.headers.add(HttpHeaders.authorizationHeader, "Bearer $_token");
  }

  Future<List<ShoppingListItem>> fetchShoppingList(String shoppingListId) async {
    var request = await _httpClient.getUrl(_serverUrl.resolve("shoppinglist/$shoppingListId")).timeout(_timeout);
    request.headers.contentType = ContentType.json;
    _addAuthHeader(request);
    var response = await request.close().timeout(_timeout);

    if (response.statusCode == 200) {
      final String decoded = await response.transform(utf8.decoder).join();
      List<dynamic> items = jsonDecode(decoded);
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

  Future<ShoppingListItem> createShoppingListItem(String shoppingListId, String name, String category) async {
    final body = jsonEncode({'name': name, 'category': category});

    var request = await _httpClient.postUrl(_serverUrl.resolve("shoppinglist/$shoppingListId")).timeout(_timeout);
    request.headers.contentType = ContentType.json;
    _addAuthHeader(request);
    request.write(body);
    var response = await request.close().timeout(_timeout);

    if (response.statusCode == 200) {
      final decoded = await response.transform(utf8.decoder).join();
      return ShoppingListItem.fromJson(jsonDecode(decoded));
    } else {
      _invokeCallbackIfUnauthenticated(response);
      throw HttpResponseException(
        response.statusCode,
        message: "Failed to create new item $name in category $category for list $shoppingListId",
      );
    }
  }

  Future<void> deleteShoppingListItem(String shoppingListId, ShoppingListItem item) async {
    var request = await _httpClient
        .deleteUrl(_serverUrl.resolve("shoppinglist/$shoppingListId/item/${item.id}"))
        .timeout(_timeout);
    _addAuthHeader(request);
    var response = await request.close().timeout(_timeout);

    if (response.statusCode != 204) {
      _invokeCallbackIfUnauthenticated(response);
      throw HttpResponseException(
        response.statusCode,
        message: "Failed to delete item ${item.name} (${item.id}) in list $shoppingListId",
      );
    }
  }

  Future<void> deleteShoppingListItems(String shoppingListId, String ofCategory) async {
    final body = jsonEncode({'ofCategory': ofCategory});
    var request =
        await _httpClient.deleteUrl(_serverUrl.resolve("shoppinglist/$shoppingListId/item")).timeout(_timeout);
    request.headers.contentType = ContentType.json;
    _addAuthHeader(request);
    request.write(body);
    var response = await request.close().timeout(_timeout);

    if (response.statusCode != 204) {
      _invokeCallbackIfUnauthenticated(response);
      throw HttpResponseException(
        response.statusCode,
        message:
            "Failed to delete items of category ${ofCategory != null ? ofCategory : "ALL"} in list $shoppingListId",
      );
    }
  }

  Future<void> updateShoppingListItem(String shoppingListId, ShoppingListItem item) async {
    final body = jsonEncode({'name': item.name, 'checked': item.checked, 'category': item.category});

    var request =
        await _httpClient.putUrl(_serverUrl.resolve("shoppinglist/$shoppingListId/item/${item.id}")).timeout(_timeout);
    request.headers.contentType = ContentType.json;
    _addAuthHeader(request);
    request.write(body);
    var response = await request.close().timeout(_timeout);

    if (response.statusCode != 204) {
      _invokeCallbackIfUnauthenticated(response);
      throw HttpResponseException(
        response.statusCode,
        message: "Failed to update item ${item.id} in list $shoppingListId",
      );
    }
  }

  Future<void> moveShoppingListItem(String shoppingListId, ShoppingListItem item, int targetIndex) async {
    final body = jsonEncode({'itemId': item.id, 'targetIndex': targetIndex});

    var request =
        await _httpClient.putUrl(_serverUrl.resolve("shoppinglist/$shoppingListId/moveitem")).timeout(_timeout);
    request.headers.contentType = ContentType.json;
    _addAuthHeader(request);
    request.write(body);
    var response = await request.close().timeout(_timeout);

    if (response.statusCode != 204) {
      _invokeCallbackIfUnauthenticated(response);
      throw HttpResponseException(
        response.statusCode,
        message: "Failed to move item ${item.name} (${item.id}) to $targetIndex in list $shoppingListId",
      );
    }
  }

  Future<ShoppingListInfo> createShoppingList(String shoppingListName) async {
    final body = jsonEncode({'name': shoppingListName});

    var request = await _httpClient.postUrl(_serverUrl.resolve("shoppinglist")).timeout(_timeout);
    request.headers.contentType = ContentType.json;
    _addAuthHeader(request);
    request.write(body);
    var response = await request.close().timeout(_timeout);

    if (response.statusCode == 200) {
      final String decoded = await response.transform(utf8.decoder).join();
      return ShoppingListInfo.fromJson(jsonDecode(decoded));
    } else {
      _invokeCallbackIfUnauthenticated(response);
      throw HttpResponseException(response.statusCode,
          message: "Failed to create new list with name $shoppingListName");
    }
  }

  Future<void> deleteShoppingList(String shoppingListId) async {
    var request = await _httpClient.deleteUrl(_serverUrl.resolve("shoppinglist/$shoppingListId")).timeout(_timeout);
    _addAuthHeader(request);
    var response = await request.close().timeout(_timeout);

    if (response.statusCode != 204) {
      _invokeCallbackIfUnauthenticated(response);
      throw HttpResponseException(response.statusCode, message: "Failed to delete list $shoppingListId");
    }
  }

  Future<Optional<ShoppingListUserReference>> addUserToShoppingList(
      String shoppingListId, String userEmailAddress) async {
    final body = jsonEncode({'emailAddress': userEmailAddress});
    var request = await _httpClient.putUrl(_serverUrl.resolve("shoppinglist/$shoppingListId/user")).timeout(_timeout);
    request.headers.contentType = ContentType.json;
    _addAuthHeader(request);
    request.write(body);
    var response = await request.close().timeout(_timeout);

    if (response.statusCode == 200) {
      final String decoded = await response.transform(utf8.decoder).join();
      return Optional(ShoppingListUserReference.fromJson(jsonDecode(decoded)));
    } else if (response.statusCode == 404) {
      return Optional.empty();
    } else {
      _invokeCallbackIfUnauthenticated(response);
      throw HttpResponseException(
        response.statusCode,
        message: "Failed to add $userEmailAddress to list $shoppingListId.",
      );
    }
  }

  Future<void> removeUserFromShoppingList(String shoppingListId, String userId) async {
    var request =
        await _httpClient.deleteUrl(_serverUrl.resolve("shoppinglist/$shoppingListId/user/$userId")).timeout(_timeout);
    _addAuthHeader(request);
    var response = await request.close().timeout(_timeout);

    if (response.statusCode != 204) {
      _invokeCallbackIfUnauthenticated(response);
      throw HttpResponseException(
        response.statusCode,
        message: 'Failed to remove user $userId from list $shoppingListId',
      );
    }
  }

  Future<void> uncheckItems(String shoppingListId, {String ofCategory}) async {
    final body = jsonEncode({'category': ofCategory});
    var request =
        await _httpClient.putUrl(_serverUrl.resolve("shoppinglist/$shoppingListId/uncheckitems")).timeout(_timeout);
    request.headers.contentType = ContentType.json;
    _addAuthHeader(request);
    request.write(body);
    var response = await request.close().timeout(_timeout);

    if (response.statusCode != 204) {
      _invokeCallbackIfUnauthenticated(response);
      throw HttpResponseException(
        response.statusCode,
        message: 'Failed to uncheck items of category in list $shoppingListId',
      );
    }
  }

  removeCategory(String shoppingListId, {String category}) async {
    final body = jsonEncode({'category': category});
    var request =
        await _httpClient.putUrl(_serverUrl.resolve("shoppinglist/$shoppingListId/removecategory")).timeout(_timeout);
    request.headers.contentType = ContentType.json;
    _addAuthHeader(request);
    request.write(body);
    var response = await request.close().timeout(_timeout);

    if (response.statusCode != 204) {
      throw HttpResponseException(
        response.statusCode,
        message: 'Failed to remove category from list $shoppingListId',
      );
    }
  }

  renameCategory(String shoppingListId, String oldCategoryName, String newCategoryName) async {
    final body = jsonEncode({'oldCategory': oldCategoryName, 'newCategory': newCategoryName});
    var request =
        await _httpClient.putUrl(_serverUrl.resolve("shoppinglist/$shoppingListId/renamecategory")).timeout(_timeout);
    request.headers.contentType = ContentType.json;
    _addAuthHeader(request);
    request.write(body);
    var response = await request.close().timeout(_timeout);

    if (response.statusCode != 204) {
      _invokeCallbackIfUnauthenticated(response);
      throw HttpResponseException(
        response.statusCode,
        message: 'Failed to rename category in list $shoppingListId',
      );
    }
  }

  Future<void> removeAllItems(String shoppingListId) async {
    var request = await _httpClient.postUrl(_serverUrl.resolve("shoppinglist/$shoppingListId/clear")).timeout(_timeout);
    _addAuthHeader(request);
    var response = await request.close().timeout(_timeout);

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
    final body = jsonEncode({'userId': affectedUserId, 'role': newRole.toRoleString()});
    var request =
        await _httpClient.putUrl(_serverUrl.resolve("shoppinglist/$shoppingListId/permissions")).timeout(_timeout);
    request.headers.contentType = ContentType.json;
    _addAuthHeader(request);
    request.write(body);
    var response = await request.close().timeout(_timeout);

    if (response.statusCode == 200) {
      final String decoded = await response.transform(utf8.decoder).join();
      return ShoppingListUserReference.fromJson(jsonDecode(decoded));
    } else {
      _invokeCallbackIfUnauthenticated(response);
      throw HttpResponseException(
        response.statusCode,
        message: 'Could not change role of user $affectedUserId to $newRole in list $shoppingListId',
      );
    }
  }

  Future<void> changeShoppingListName(String shoppingListId, String newName) async {
    final body = jsonEncode({'name': newName});
    var request = await _httpClient.putUrl(_serverUrl.resolve("shoppinglist/$shoppingListId/name")).timeout(_timeout);
    request.headers.contentType = ContentType.json;
    _addAuthHeader(request);
    request.write(body);
    var response = await request.close().timeout(_timeout);

    if (response.statusCode != 204) {
      _invokeCallbackIfUnauthenticated(response);
      throw HttpResponseException(response.statusCode, message: 'Failed to rename list $shoppingListId to $newName');
    }
  }

  Future<RegistrationProcessType> checkInviteCode(String inviteCode) async {
    var request = await _httpClient.getUrl(_serverUrl.resolve("user/register/type/$inviteCode")).timeout(_timeout);
    var response = await request.close().timeout(_timeout);

    if (response.statusCode == 200) {
      final String decoded = await response.transform(utf8.decoder).join();
      final Map<String, dynamic> json = jsonDecode(decoded);
      return RegistrationProcessTypes.fromString(json.get('type'));
    } else {
      throw HttpResponseException(response.statusCode, message: "Failed to check invite code.");
    }
  }

  Future<RegistrationResult> register(String userName, String password, String inviteCode,
      {String emailAddress}) async {
    final body = jsonEncode(
        {'userName': userName, 'emailAddress': emailAddress, 'password': password, 'inviteCode': inviteCode});

    var request = await _httpClient.postUrl(_serverUrl.resolve("user/register")).timeout(_timeout);
    request.headers.contentType = ContentType.json;
    request.write(body);
    var response = await request.close().timeout(_timeout);

    if (response.statusCode == 200) {
      final String decoded = await response.transform(utf8.decoder).join();
      return RegistrationResult.fromJson(jsonDecode(decoded));
    } else {
      throw HttpResponseException(response.statusCode,
          message: "Failed to register user $emailAddress with name $userName and invite code $inviteCode.");
    }
  }

  Future<String> generateInviteCode() async {
    var request = await _httpClient.getUrl(_serverUrl.resolve("user/invite")).timeout(_timeout);
    _addAuthHeader(request);
    var response = await request.close().timeout(_timeout);

    if (response.statusCode == 200) {
      final String decoded = await response.transform(utf8.decoder).join();
      final Map<String, dynamic> json = jsonDecode(decoded);
      return json.get('code');
    } else {
      _invokeCallbackIfUnauthenticated(response);
      throw HttpResponseException(response.statusCode, message: "Failed to generate invite code.");
    }
  }

  Future<void> sendInvite(String emailAddress, {String shoppingListId}) async {
    final body = jsonEncode({'emailAddress': emailAddress, 'shoppingListId': shoppingListId});

    var request = await _httpClient.postUrl(_serverUrl.resolve("user/invite")).timeout(_timeout);
    request.headers.contentType = ContentType.json;
    _addAuthHeader(request);
    request.write(body);
    var response = await request.close().timeout(_timeout);

    if (response.statusCode != 204) {
      _invokeCallbackIfUnauthenticated(response);
      throw HttpResponseException(response.statusCode,
          message: "Failed to invite user $emailAddress to shopping list $shoppingListId.");
    }
  }

  Future<BackendInfo> getBackendInfo() async {
    var request = await _httpClient.getUrl(_serverUrl.resolve("info")).timeout(_timeout);
    var response = await request.close().timeout(_timeout);

    if (response.statusCode == 200) {
      final String decoded = await response.transform(utf8.decoder).join();
      return BackendInfo.fromJson(jsonDecode(decoded));
    } else {
      throw HttpResponseException(response.statusCode, message: "Failed to get backend info.");
    }
  }

  Future<void> requestPasswordReset(String emailAddress) async {
    final body = jsonEncode({'emailAddress': emailAddress});

    var request = await _httpClient.postUrl(_serverUrl.resolve("user/password/requestreset")).timeout(_timeout);
    request.headers.contentType = ContentType.json;
    request.write(body);
    var response = await request.close().timeout(_timeout);

    if (response.statusCode != 200) {
      throw HttpResponseException(
        response.statusCode,
        message: "Failed to request password request code for $emailAddress.",
      );
    }
  }

  Future<void> resetPassword(String emailAddress, String resetCode, String password) async {
    final body = jsonEncode({'emailAddress': emailAddress, 'resetCode': resetCode, 'password': password});

    var request = await _httpClient.postUrl(_serverUrl.resolve("user/password/reset")).timeout(_timeout);
    request.headers.contentType = ContentType.json;
    request.write(body);
    var response = await request.close().timeout(_timeout);

    if (response.statusCode != 200) {
      throw HttpResponseException(
        response.statusCode,
        message: "Failed attempt to reset password for $emailAddress.",
      );
    }
  }

  Future<void> deleteAccount(String userId) async {
    var request = await _httpClient.deleteUrl(_serverUrl.resolve("user/$userId")).timeout(_timeout);
    _addAuthHeader(request);
    var response = await request.close().timeout(_timeout);

    if (response.statusCode != 204) {
      _invokeCallbackIfUnauthenticated(response);
      throw HttpResponseException(
        response.statusCode,
        message: "Failed attempt to delete account of user $userId.",
      );
    }
  }
}
