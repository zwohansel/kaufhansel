import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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
  final String _title;
  final ScrollController _scrollController = ScrollController();

  ShoppingListView(this._title);

  @override
  Widget build(BuildContext context) {
    return Consumer<ShoppingListModel>(builder: (context, shoppingList, child) {
      final tiles = shoppingList.items
          .map((item) => ChangeNotifierProvider<ShoppingListItem>.value(value: item, child: ShoppingListItemTile()));
      final dividedTiles = ListTile.divideTiles(tiles: tiles, context: context).toList();
      return Scaffold(
          appBar: AppBar(title: Text(_title)),
          body: Column(children: [
            Expanded(
                child: ListView(
              children: dividedTiles,
              controller: _scrollController,
            )),
            Container(
                child: Material(child: ShoppingListItemInput(_scrollController), type: MaterialType.transparency),
                decoration: BoxDecoration(color: Colors.white, boxShadow: [
                  BoxShadow(color: Colors.grey.withOpacity(0.5), spreadRadius: 3, blurRadius: 4, offset: Offset(0, 3))
                ])),
          ]));
    });
  }
}

class ShoppingListItemInput extends StatefulWidget {
  final ScrollController _shoppingListScrollController;

  ShoppingListItemInput(this._shoppingListScrollController);

  @override
  _ShoppingListItemInputState createState() => _ShoppingListItemInputState(_shoppingListScrollController);
}

class _ShoppingListItemInputState extends State<ShoppingListItemInput> {
  final ScrollController _shoppingListScrollController;
  TextEditingController _newItemNameController;
  bool _enabled = false;
  FocusNode _focus = FocusNode();

  _ShoppingListItemInputState(this._shoppingListScrollController);

  @override
  void initState() {
    super.initState();
    _newItemNameController = TextEditingController();
    _newItemNameController.addListener(() => setState(() => _enabled = _newItemNameController.text.isNotEmpty));
  }

  void addNewItem() {
    var name = _newItemNameController.value.text;
    if (name.isNotEmpty) {
      Provider.of<ShoppingListModel>(context).addItem(ShoppingListItem(name));
      _newItemNameController.clear();
      // Scroll to the new element after it has been added and rendered (at the end of this frame).
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _shoppingListScrollController.animateTo(_shoppingListScrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      });
    }
    _focus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
        child: Row(
          children: [
            Expanded(
                child: TextField(
                    focusNode: _focus,
                    decoration: InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.fromLTRB(12, 8, 12, 8),
                        border: OutlineInputBorder(),
                        hintText: "New Item"),
                    controller: _newItemNameController,
                    onSubmitted: (_) => addNewItem())),
            Container(
              child: IconButton(
                splashRadius: 23,
                icon: Icon(Icons.add),
                onPressed: _enabled ? addNewItem : null,
              ),
              margin: EdgeInsets.only(left: 10.0, right: 3.0),
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
        title: SelectableText(item.name),
        controlAffinity: ListTileControlAffinity.leading,
        secondary: Wrap(children: [
          IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => Provider.of<ShoppingListModel>(context, listen: false).removeItem(item)),
          IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return Dialog(
                          child: Column(
                        children: [
                          Row(children: [
                            Expanded(child: Text(item.name)),
                            IconButton(icon: Icon(Icons.drive_file_rename_outline), onPressed: () {})
                          ]),
                          Container(
                            child: Text(
                              "Wählstu oder sagstu!",
                              style: TextStyle(color: Colors.grey),
                            ),
                            margin: EdgeInsets.only(left: 12.0, right: 12.0),
                          ),
                          Divider(),
                          Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Container(
                                  child: OutlineButton(onPressed: () {}, child: Text("nächster")),
                                  margin: EdgeInsets.only(bottom: 5),
                                ),
                                TextField(
                                  decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding: EdgeInsets.fromLTRB(12, 8, 12, 8),
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ],
                            ),
                            margin: EdgeInsets.only(left: 12.0, right: 12.0),
                          ),
                          Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              OutlineButton(onPressed: () {}, child: Text("Egal")),
                              OutlineButton(
                                onPressed: () {},
                                child: Text("Niemand"),
                                textColor: Theme.of(context).accentColor,
                                borderSide: BorderSide(color: Theme.of(context).accentColor),
                              ),
                              ElevatedButton(onPressed: () {}, child: Text("Zuweisen"))
                            ],
                          )
                        ],
                      ));
                    });
              })
        ]),
        value: item.checked,
        onChanged: (checked) => item.checked = checked,
      );
    });
  }
}
