import 'dart:async';
import 'dart:collection';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(ShoppingListApp());
}

Future<List<ShoppingListItem>> fetchShoppingList() async {
  return Future.delayed(Duration(seconds: 2), () => [ShoppingListItem('Kaffee'), ShoppingListItem('Milch')]);
}

class ShoppingListItem extends ChangeNotifier {
  String _name;
  bool _checked = false;

  ShoppingListItem(this._name);

  set checked(bool value) {
    _checked = value;
    notifyListeners();
  }

  bool get checked => _checked;

  String get name => _name;
}

class ShoppingListModel extends ChangeNotifier {
  final List<ShoppingListItem> _items;

  ShoppingListModel(this._items);

  void addItem(ShoppingListItem item) {
    _items.add(item);
    notifyListeners();
  }

  void removeItem(ShoppingListItem item) {
    _items.remove(item);
    notifyListeners();
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
    const String title = "Kaufhansel";
    return FutureBuilder<List<ShoppingListItem>>(
      future: _futureShoppingList,
      builder: (context, shoppingList) {
        if (shoppingList.hasData) {
          return ChangeNotifierProvider(
              create: (context) => ShoppingListModel(shoppingList.data), child: ShoppingListView(title));
        } else if (shoppingList.hasError) {
          return Text("ERROR");
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

class ShoppingListView extends StatelessWidget {
  String _title;

  ShoppingListView(this._title);

  @override
  Widget build(BuildContext context) {
    return Consumer<ShoppingListModel>(builder: (context, shoppingList, child) {
      final tiles = shoppingList.items
          .map((item) => ChangeNotifierProvider<ShoppingListItem>.value(value: item, child: ShoppingListItemTile()));
      final dividedTiles = ListTile.divideTiles(tiles: tiles, context: context).toList();
      return Scaffold(
        appBar: AppBar(title: Text(_title)),
        body: ListView(
          children: dividedTiles,
        ),
        bottomNavigationBar: BottomAppBar(
          child: ShoppingListItemInput(),
        ),
      );
    });
  }
}

class ShoppingListItemInput extends StatefulWidget {
  @override
  _ShoppingListItemInputState createState() => _ShoppingListItemInputState();
}

class _ShoppingListItemInputState extends State<ShoppingListItemInput> {
  TextEditingController _newItemNameController;
  bool _enabled = false;
  FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _newItemNameController = TextEditingController();
    _newItemNameController.addListener(() => setState(() => _enabled = _newItemNameController.text.isNotEmpty));
  }

  void addNewItem() {
    var name = _newItemNameController.value.text;
    Provider.of<ShoppingListModel>(context).addItem(ShoppingListItem(name));
    _newItemNameController.clear();
    _focus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
                child: TextField(
                    focusNode: _focus,
                    decoration: InputDecoration(border: OutlineInputBorder(), hintText: "New Item"),
                    controller: _newItemNameController,
                    onSubmitted: _enabled ? (text) => addNewItem() : null)),
            Container(
              child: IconButton(icon: Icon(Icons.add), onPressed: _enabled ? addNewItem : null),
              margin: EdgeInsets.only(left: 5.0),
            )
          ],
        ));
  }
}

class ShoppingListItemTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ShoppingListItem>(builder: (context, item, child) {
      return CheckboxListTile(
        title: Text(item.name),
        controlAffinity: ListTileControlAffinity.leading,
        secondary: IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => Provider.of<ShoppingListModel>(context, listen: false).removeItem(item)),
        value: item.checked,
        onChanged: (checked) => item.checked = checked,
      );
    });
  }
}
