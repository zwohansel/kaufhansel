import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kaufhansel_client/model.dart';
import 'package:kaufhansel_client/rest_client.dart';
import 'package:kaufhansel_client/shopping_list_page.dart';
import 'package:provider/provider.dart';

class ShoppingListPageLoader extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ShoppingListPageLoaderState();
}

class _ShoppingListPageLoaderState extends State<ShoppingListPageLoader> {
  Future<ShoppingListModel> _futureShoppingList;

  @override
  void didChangeDependencies() {
    // Called after initState.
    // Unlike initState this method is called again if the RestClientWidget is exchanged.
    super.didChangeDependencies();
    _futureShoppingList = _getMainShoppingList();
  }

  Future<ShoppingListModel> _getMainShoppingList() async {
    final client = RestClientWidget.of(context);
    final lists = await client.getShoppingLists();
    return client.fetchShoppingList(lists.first.id);
  }

  @override
  Widget build(BuildContext context) {
    const String title = "Kaufhansel";
    return FutureBuilder<ShoppingListModel>(
      future: _futureShoppingList,
      builder: (context, shoppingList) {
        if (shoppingList.hasData) {
          return ChangeNotifierProvider.value(value: shoppingList.data, child: ShoppingListPage(title: title));
        } else if (shoppingList.hasError) {
          return Text("ERROR: ${shoppingList.error}");
        }
        return Scaffold(
            appBar: AppBar(
              title: Text(title),
            ),
            body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
