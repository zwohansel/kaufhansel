import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'model.dart';

class HttpResponseException implements Exception {
  final int _statusCode;
  final String _message;

  HttpResponseException(this._statusCode, {String message = "Request failed"}) : _message = message;

  @override
  String toString() {
    return "$_message - HTTP status code: $_statusCode";
  }
}

class RestClientWidget extends InheritedWidget {
  final RestClient client;

  RestClientWidget({@required this.client, @required Widget child}) : super(child: child);

  static RestClient of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<RestClientWidget>().client;
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => true;
}

class RestClient {
  HttpClient _httpClient;
  final Uri _serverUrl;
  final Duration timeout = Duration(seconds: 10);

  RestClient(this._serverUrl) : _httpClient = HttpClient() {
    //accept self signed certificates in debug mode
    _httpClient.badCertificateCallback = (cert, host, port) => kDebugMode;
  }

  void close() {
    _httpClient.close(force: true);
    _httpClient = null;
  }

  Future<ShoppingListUserInfo> login(String userEmail, String password) async {
    _httpClient.addCredentials(_serverUrl, "", HttpClientBasicCredentials(userEmail, password));
    final url = _serverUrl.resolve("user");
    final request = await _httpClient.getUrl(url);
    final response = await request.close().timeout(timeout);

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
    var request = await _httpClient.getUrl(_serverUrl.resolve("shoppinglists"));
    var response = await request.close().timeout(timeout);

    if (response.statusCode == 200) {
      final String decoded = await response.transform(utf8.decoder).join();
      List<dynamic> lists = jsonDecode(decoded);
      return lists.map((json) => ShoppingListInfo.fromJson(json)).toList();
    } else {
      throw HttpResponseException(response.statusCode, message: 'Failed to load shopping list infos');
    }
  }

  Future<List<ShoppingListItem>> fetchShoppingList(String shoppingListId) async {
    var request = await _httpClient.getUrl(_serverUrl.resolve("shoppinglist/$shoppingListId"));
    request.headers.contentType = ContentType.json;
    var response = await request.close().timeout(timeout);

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
      throw HttpResponseException(response.statusCode, message: 'Failed to load list $shoppingListId');
    }
  }

  Future<ShoppingListItem> createShoppingListItem(String shoppingListId, String name, String category) async {
    final body = jsonEncode({'name': name, 'category': category});

    var request = await _httpClient.postUrl(_serverUrl.resolve("shoppinglist/$shoppingListId"));
    request.headers.contentType = ContentType.json;
    request.write(body);
    var response = await request.close().timeout(timeout);

    if (response.statusCode == 200) {
      final decoded = await response.transform(utf8.decoder).join();
      return ShoppingListItem.fromJson(jsonDecode(decoded));
    } else {
      throw HttpResponseException(
        response.statusCode,
        message: "Failed to create new item $name in category $category for list $shoppingListId",
      );
    }
  }

  Future<void> deleteShoppingListItem(String shoppingListId, ShoppingListItem item) async {
    var request = await _httpClient.deleteUrl(_serverUrl.resolve("shoppinglist/$shoppingListId/item/${item.id}"));
    var response = await request.close().timeout(timeout);

    if (response.statusCode != 204) {
      throw HttpResponseException(
        response.statusCode,
        message: "Failed to delete item ${item.name} (${item.id}) in list $shoppingListId",
      );
    }
  }

  Future<void> updateShoppingListItem(String shoppingListId, ShoppingListItem item) async {
    final body = jsonEncode({'name': item.name, 'checked': item.checked, 'category': item.category});

    var request = await _httpClient.putUrl(_serverUrl.resolve("shoppinglist/$shoppingListId/item/${item.id}"));
    request.headers.contentType = ContentType.json;
    request.write(body);
    var response = await request.close().timeout(timeout);

    if (response.statusCode != 204) {
      throw HttpResponseException(
        response.statusCode,
        message: "Failed to update item ${item.id} in list $shoppingListId",
      );
    }
  }

  Future<void> moveShoppingListItem(String shoppingListId, ShoppingListItem item, int targetIndex) async {
    final body = jsonEncode({'itemId': item.id, 'targetIndex': targetIndex});

    var request = await _httpClient.putUrl(_serverUrl.resolve("shoppinglist/$shoppingListId/moveitem"));
    request.headers.contentType = ContentType.json;
    request.write(body);
    var response = await request.close().timeout(timeout);

    if (response.statusCode != 204) {
      throw HttpResponseException(
        response.statusCode,
        message: "Failed to move item ${item.name} (${item.id}) to $targetIndex in list $shoppingListId",
      );
    }
  }

  Future<ShoppingListInfo> createShoppingList(String shoppingListName) async {
    final body = jsonEncode({'name': shoppingListName});

    var request = await _httpClient.postUrl(_serverUrl.resolve("shoppinglist"));
    request.headers.contentType = ContentType.json;
    request.write(body);
    var response = await request.close().timeout(timeout);

    if (response.statusCode == 200) {
      final String decoded = await response.transform(utf8.decoder).join();
      return ShoppingListInfo.fromJson(jsonDecode(decoded));
    } else {
      throw HttpResponseException(response.statusCode,
          message: "Failed to create new list with name $shoppingListName");
    }
  }

  Future<void> deleteShoppingList(String shoppingListId) async {
    var request = await _httpClient.deleteUrl(_serverUrl.resolve("shoppinglist/$shoppingListId"));
    var response = await request.close().timeout(timeout);

    if (response.statusCode != 204) {
      throw HttpResponseException(response.statusCode, message: "Failed to delete list $shoppingListId");
    }
  }

  Future<Optional<ShoppingListUserReference>> addUserToShoppingList(
      String shoppingListId, String userEmailAddress) async {
    final body = jsonEncode({'emailAddress': userEmailAddress});
    var request = await _httpClient.putUrl(_serverUrl.resolve("shoppinglist/$shoppingListId/user"));
    request.headers.contentType = ContentType.json;
    request.write(body);
    var response = await request.close().timeout(timeout);

    if (response.statusCode == 200) {
      final String decoded = await response.transform(utf8.decoder).join();
      return Optional(ShoppingListUserReference.fromJson(jsonDecode(decoded)));
    } else if (response.statusCode == 404) {
      return Optional.empty();
    } else {
      throw HttpResponseException(
        response.statusCode,
        message: "Failed to add $userEmailAddress to list $shoppingListId.",
      );
    }
  }

  Future<void> removeUserFromShoppingList(String shoppingListId, String userId) async {
    var request = await _httpClient.deleteUrl(_serverUrl.resolve("shoppinglist/$shoppingListId/user/$userId"));
    var response = await request.close().timeout(timeout);

    if (response.statusCode != 204) {
      throw HttpResponseException(
        response.statusCode,
        message: 'Failed to remove user $userId from list $shoppingListId',
      );
    }
  }

  Future<void> uncheckAllItems(String shoppingListId) async {
    var request = await _httpClient.postUrl(_serverUrl.resolve("shoppinglist/$shoppingListId/uncheckallitems"));
    var response = await request.close().timeout(timeout);

    if (response.statusCode != 204) {
      throw HttpResponseException(
        response.statusCode,
        message: 'Failed to uncheck all items in list $shoppingListId',
      );
    }
  }

  Future<void> removeAllCategories(String shoppingListId) async {
    var request = await _httpClient.postUrl(_serverUrl.resolve("shoppinglist/$shoppingListId/removeallcategories"));
    var response = await request.close().timeout(timeout);

    if (response.statusCode != 204) {
      throw HttpResponseException(
        response.statusCode,
        message: 'Failed to remove all categories from list $shoppingListId',
      );
    }
  }

  Future<void> removeAllItems(String shoppingListId) async {
    var request = await _httpClient.postUrl(_serverUrl.resolve("shoppinglist/$shoppingListId/clear"));
    var response = await request.close().timeout(timeout);

    if (response.statusCode != 204) {
      throw HttpResponseException(
        response.statusCode,
        message: 'Failed to remove all items from the shopping list $shoppingListId',
      );
    }
  }

  Future<ShoppingListUserReference> changeShoppingListPermissions(
      String shoppingListId, String affectedUserId, ShoppingListRole newRole) async {
    final body = jsonEncode({'userId': affectedUserId, 'role': newRole.toRoleString()});
    var request = await _httpClient.putUrl(_serverUrl.resolve("shoppinglist/$shoppingListId/permissions"));
    request.headers.contentType = ContentType.json;
    request.write(body);
    var response = await request.close().timeout(timeout);

    if (response.statusCode == 200) {
      final String decoded = await response.transform(utf8.decoder).join();
      return ShoppingListUserReference.fromJson(jsonDecode(decoded));
    } else {
      throw HttpResponseException(
        response.statusCode,
        message: 'Could not change role of user $affectedUserId to $newRole in list $shoppingListId',
      );
    }
  }

  Future<void> changeShoppingListName(String shoppingListId, String newName) async {
    final body = jsonEncode({'name': newName});
    var request = await _httpClient.putUrl(_serverUrl.resolve("shoppinglist/$shoppingListId/name"));
    request.headers.contentType = ContentType.json;
    request.write(body);
    var response = await request.close().timeout(timeout);

    if (response.statusCode != 204) {
      throw HttpResponseException(response.statusCode, message: 'Failed to rename list $shoppingListId to $newName');
    }
  }

  Future<RegistrationProcessType> checkInviteCode(String inviteCode) async {
    var request = await _httpClient.getUrl(_serverUrl.resolve("register/type/$inviteCode")).timeout(timeout);
    var response = await request.close().timeout(timeout);

    if (response.statusCode == 200) {
      final String decoded = await response.transform(utf8.decoder).join();
      final Map<String, dynamic> json = jsonDecode(decoded);
      return RegistrationProcessTypes.fromString(json.get('type'));
    } else {
      throw HttpResponseException(response.statusCode, message: "Failed to check invite code.");
    }
  }

  Future<RegistrationResult> register(String userName, String emailAddress, String password, String inviteCode) async {
    final body = jsonEncode(
        {'userName': userName, 'emailAddress': emailAddress, 'password': password, 'inviteCode': inviteCode});

    var request = await _httpClient.postUrl(_serverUrl.resolve("register"));
    request.headers.contentType = ContentType.json;
    request.write(body);
    var response = await request.close().timeout(timeout);

    if (response.statusCode == 200) {
      final String decoded = await response.transform(utf8.decoder).join();
      return RegistrationResult.fromJson(jsonDecode(decoded));
    } else {
      throw HttpResponseException(response.statusCode,
          message: "Failed to register user $emailAddress with name $userName and invite code $inviteCode.");
    }
  }

  Future<String> generateInviteCode() async {
    var request = await _httpClient.getUrl(_serverUrl.resolve("invite")).timeout(timeout);
    var response = await request.close().timeout(timeout);

    if (response.statusCode == 200) {
      final String decoded = await response.transform(utf8.decoder).join();
      final Map<String, dynamic> json = jsonDecode(decoded);
      return json.get('code');
    } else {
      throw HttpResponseException(response.statusCode, message: "Failed to generate invite code.");
    }
  }

  Future<void> sendInvite(String emailAddress, {String shoppingListId}) async {
    final body = jsonEncode({'emailAddress': emailAddress, 'shoppingListId': shoppingListId});

    var request = await _httpClient.postUrl(_serverUrl.resolve("invite"));
    request.headers.contentType = ContentType.json;
    request.write(body);
    var response = await request.close().timeout(timeout);

    if (response.statusCode != 204) {
      throw HttpResponseException(response.statusCode,
          message: "Failed to invite user $emailAddress to shopping list $shoppingListId.");
    }
  }
}
