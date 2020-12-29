import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';

void main() {
  runApp(ShoppingListApp());
}

Future<List<ShoppingListItem>> fetchShoppingList() async {
  return Future.delayed(Duration(seconds: 10), () => [ShoppingListItem('Kaffee'), ShoppingListItem('Milch')]);
}

class ShoppingListItem {
  String _name;
  bool checked = false;

  ShoppingListItem(this._name);

  String get name => _name;
}

class ShoppingListModel {
  // TODO extends ChangeNotifier
  final List<ShoppingListItem> _items;

  ShoppingListModel(this._items);

  void addItem(ShoppingListItem item) {
    _items.add(item);
    //TODO: notifyListeners();
  }

  void removeItem(ShoppingListItem item) {
    _items.remove(item);
    //TODO: notifyListeners();
  }

  UnmodifiableListView<ShoppingListItem> get items => UnmodifiableListView(_items);
}

class ShoppingListApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kaufhansel',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: ShoppingList(),
    );
  }
}

class ShoppingList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ShoppingListState();
}

class _ShoppingListState extends State<ShoppingList> {
  Future<List<ShoppingListItem>> _futureShoppingList;

  @override
  void initState() {
    super.initState();
    _futureShoppingList = fetchShoppingList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kaufhansel'),
      ),
      body: FutureBuilder<List<ShoppingListItem>>(
        future: _futureShoppingList,
        builder: (context, shoppingList) {
          if (shoppingList.hasData) {
            final tiles = shoppingList.data.map((e) => ListTile(title: Text(e.name)));
            final dividedTiles = ListTile.divideTiles(tiles: tiles, context: context).toList();
            return ListView(
              children: dividedTiles,
            );
          } else if (shoppingList.hasError) {
            return Text("ERROR");
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
