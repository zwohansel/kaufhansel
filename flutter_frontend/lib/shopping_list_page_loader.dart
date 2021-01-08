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
  ShoppingListModel _shoppingList;
  bool _loading = true;
  String _error;

  @override
  void didChangeDependencies() {
    // Called after initState.
    // Unlike initState this method is called again if the RestClientWidget is exchanged.
    super.didChangeDependencies();
    _getMainShoppingList();
  }

  void _getMainShoppingList() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final client = RestClientWidget.of(context);
      final lists = await client.getShoppingLists();
      final list = await client.fetchShoppingList(lists.first.id, lists.first.name);
      setState(() {
        _shoppingList = list;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const String title = "Kaufhansel";
    if (_error != null) {
      return Scaffold(
          body: Center(
              child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            child: Text("🤷‍♂️", style: TextStyle(fontFamilyFallback: ["NotoColorEmoji"], fontSize: 100)),
            padding: EdgeInsets.all(20),
          ),
          Text(
            "Oh nein! Haben wir Deine Einkaufsliste etwa verlegt?",
            style: Theme.of(context).textTheme.headline6,
          ),
          Padding(
              child: ElevatedButton(
                child: Text("Nochmal versuchen"),
                onPressed: _getMainShoppingList,
              ),
              padding: EdgeInsets.all(20))
        ],
      )));
    } else if (_loading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    } else {
      return ChangeNotifierProvider.value(
        value: _shoppingList,
        child: ShoppingListPage(appTitle: title, onRefresh: _getMainShoppingList),
      );
    }
  }
}
