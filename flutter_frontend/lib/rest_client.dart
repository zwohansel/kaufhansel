import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

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
  final Uri _serverUrl;

  RestClient(this._serverUrl);

  Future<List<ShoppingListItem>> fetchShoppingList(String shoppingListId) async {
    http.Response response =
        await http.get(_serverUrl.resolve(shoppingListId), headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      final String decoded = utf8.decode(response.bodyBytes);
      List<dynamic> items = jsonDecode(decoded);
      return items.map((e) => ShoppingListItem.fromJson(e)).toList();
    } else if (response.statusCode == 404) {
      throw Exception('Failed to load shopping list: could not find any list with the given id');
    } else {
      throw Exception('Failed to load shopping list');
    }
  }

  Future<ShoppingListItem> createShoppingListItem(String shoppingListId, String name) async {
    final body = utf8.encode(jsonEncode({'name': name}));
    http.Response response =
        await http.post(_serverUrl.resolve(shoppingListId), headers: {'Content-Type': 'application/json'}, body: body);

    if (response.statusCode == 200) {
      final decoded = utf8.decode(response.bodyBytes);
      return ShoppingListItem.fromJson(jsonDecode(decoded));
    } else {
      throw Exception('Failed to create new item: ' + name);
    }
  }

  Future<void> deleteShoppingListItem(String shoppingListId, String itemId) async {
    http.Response response = await http.delete(_serverUrl.resolve("$shoppingListId/item/$itemId"));

    if (response.statusCode != 204) {
      throw Exception('Failed to delete item: ' + itemId);
    }
  }
}
