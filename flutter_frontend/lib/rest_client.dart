import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'model.dart';

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
  final HttpClient _httpClient;
  final Uri _serverUrl;
  final Duration timeout = Duration(seconds: 10);

  RestClient(this._serverUrl) : _httpClient = HttpClient() {
    //accept self signed certificates in debug mode
    _httpClient.badCertificateCallback = (cert, host, port) => kDebugMode;
  }

  Future<bool> login(String username, String password) async {
    _httpClient.addCredentials(_serverUrl, "", HttpClientBasicCredentials(username, password));
    final url = _serverUrl.resolve("rlogin");
    final request = await _httpClient.getUrl(url);
    final response = await request.close().timeout(timeout);
    return response.statusCode == 204;
  }

  Future<List<ShoppingListInfo>> getShoppingLists() async {
    var request = await _httpClient.getUrl(_serverUrl.resolve("shoppinglists"));
    var response = await request.close().timeout(timeout);

    if (response.statusCode == 200) {
      final String decoded = await response.transform(utf8.decoder).join();
      List<dynamic> lists = jsonDecode(decoded);
      return lists.map((json) => ShoppingListInfo.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load shopping list info');
    }
  }

  Future<ShoppingList> fetchShoppingList(String shoppingListId, String name) async {
    var request = await _httpClient.getUrl(_serverUrl.resolve("shoppinglist/$shoppingListId"));
    request.headers.contentType = ContentType.json;
    var response = await request.close().timeout(timeout);

    if (response.statusCode == 200) {
      final String decoded = await response.transform(utf8.decoder).join();
      List<dynamic> items = jsonDecode(decoded);
      return ShoppingList(shoppingListId, name, items.map((e) => ShoppingListItem.fromJson(e)).toList());
    } else if (response.statusCode == 404) {
      throw Exception('Failed to load shopping list: could not find any list with the given id');
    } else {
      throw Exception('Failed to load shopping list');
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
      throw Exception('Failed to create new item: ' + name);
    }
  }

  Future<void> deleteShoppingListItem(String shoppingListId, ShoppingListItem item) async {
    var request = await _httpClient.deleteUrl(_serverUrl.resolve("shoppinglist/$shoppingListId/item/${item.id}"));
    var response = await request.close().timeout(timeout);

    if (response.statusCode != 204) {
      throw Exception("Failed to delete item: ${item.name}");
    }
  }

  Future<void> updateShoppingListItem(String shoppingListId, ShoppingListItem item) async {
    final body = jsonEncode({'name': item.name, 'checked': item.checked, 'category': item.category});

    var request = await _httpClient.putUrl(_serverUrl.resolve("shoppinglist/$shoppingListId/item/${item.id}"));
    request.headers.contentType = ContentType.json;
    request.write(body);
    var response = await request.close().timeout(timeout);

    if (response.statusCode != 204) {
      throw Exception("Failed to update item: ${item.name}");
    }
  }

  Future<void> moveShoppingListItem(String shoppingListId, ShoppingListItem item, int targetIndex) async {
    final body = jsonEncode({'itemId': item.id, 'targetIndex': targetIndex});

    var request = await _httpClient.putUrl(_serverUrl.resolve("shoppinglist/$shoppingListId/moveitem"));
    request.headers.contentType = ContentType.json;
    request.write(body);
    var response = await request.close().timeout(timeout);

    if (response.statusCode != 204) {
      throw Exception("Failed to move item: ${item.name}");
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
      throw Exception("Failed to create new list: $shoppingListName");
    }
  }

  Future<void> deleteShoppingList(String shoppingListId) async {
    var request = await _httpClient.deleteUrl(_serverUrl.resolve("shoppinglist/$shoppingListId"));
    var response = await request.close().timeout(timeout);

    if (response.statusCode != 204) {
      throw Exception('Failed to delete shopping list');
    }
  }

  Future<ShoppingListUserReference> addUserToShoppingList(String shoppingListId, String userEmailAddress) async {
    final body = jsonEncode({'emailAddress': userEmailAddress});
    var request = await _httpClient.putUrl(_serverUrl.resolve("/shoppinglist/$shoppingListId/user"));
    request.headers.contentType = ContentType.json;
    request.write(body);
    var response = await request.close().timeout(timeout);

    if (response.statusCode == 200) {
      final String decoded = await response.transform(utf8.decoder).join();
      return ShoppingListUserReference.fromJson(jsonDecode(decoded));
    } else {
      throw Exception('Failed to add user to shopping list');
    }
  }

  Future<void> removeUserFromShoppingList(String shoppingListId, String userId) async {
    var request = await _httpClient.deleteUrl(_serverUrl.resolve("shoppinglist/$shoppingListId/user/$userId"));
    var response = await request.close().timeout(timeout);

    if (response.statusCode != 204) {
      throw Exception('Failed to remove user $userId from list $shoppingListId');
    }
  }

  Future<void> uncheckAllItems(String shoppingListId) async {
    var request = await _httpClient.postUrl(_serverUrl.resolve("shoppinglist/$shoppingListId/uncheckallitems"));
    var response = await request.close().timeout(timeout);

    if (response.statusCode != 204) {
      throw Exception('Failed to uncheck all items in the shopping list');
    }
  }

  Future<void> removeAllCategories(String shoppingListId) async {
    var request = await _httpClient.postUrl(_serverUrl.resolve("shoppinglist/$shoppingListId/removeallcategories"));
    var response = await request.close().timeout(timeout);

    if (response.statusCode != 204) {
      throw Exception('Failed to remove all categories from the shopping list');
    }
  }

  Future<void> removeAllItems(String shoppingListId) async {
    var request = await _httpClient.postUrl(_serverUrl.resolve("shoppinglist/$shoppingListId/clear"));
    var response = await request.close().timeout(timeout);

    if (response.statusCode != 204) {
      throw Exception('Failed to remove all items from the shopping list');
    }
  }

  Future<ShoppingListUserReference> changeShoppingListPermissions(
      String shoppingListId, String affectedUserId, String newRole) async {
    final body = jsonEncode({'userId': affectedUserId, 'role': newRole});
    var request = await _httpClient.putUrl(_serverUrl.resolve("shoppinglist/$shoppingListId/permissions"));
    request.headers.contentType = ContentType.json;
    request.write(body);
    var response = await request.close().timeout(timeout);

    if (response.statusCode == 200) {
      final String decoded = await response.transform(utf8.decoder).join();
      return ShoppingListUserReference.fromJson(jsonDecode(decoded));
    } else {
      throw Exception('Failed to add user to shopping list');
    }
  }

  Future<void> changeShoppingListName(String shoppingListId, String newName) async {
    final body = jsonEncode({'name': newName});
    var request = await _httpClient.putUrl(_serverUrl.resolve("shoppinglist/$shoppingListId/name"));
    request.headers.contentType = ContentType.json;
    request.write(body);
    var response = await request.close().timeout(timeout);

    if (response.statusCode != 204) {
      throw Exception('Failed to rename list $shoppingListId');
    }
  }
}
