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

  Future<ShoppingListModel> fetchShoppingList(String shoppingListId) async {
    var request = await _httpClient.getUrl(_serverUrl.resolve("shoppinglist/$shoppingListId"));
    request.headers.contentType = ContentType.json;
    var response = await request.close().timeout(timeout);

    if (response.statusCode == 200) {
      final String decoded = await response.transform(utf8.decoder).join();
      List<dynamic> items = jsonDecode(decoded);
      return ShoppingListModel(shoppingListId, items.map((e) => ShoppingListItem.fromJson(e)).toList());
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
      throw Exception('Failed to delete item: ' + item.name);
    }
  }

  Future<void> updateShoppingListItem(String shoppingListId, ShoppingListItem item) async {
    final body = jsonEncode({'name': item.name, 'checked': item.checked, 'category': item.category});

    var request = await _httpClient.putUrl(_serverUrl.resolve("shoppinglist/$shoppingListId/item/${item.id}"));
    request.headers.contentType = ContentType.json;
    request.write(body);
    var response = await request.close().timeout(timeout);

    if (response.statusCode != 204) {
      throw Exception('Failed to update item: ' + item.name);
    }
  }
}
