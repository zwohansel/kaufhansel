import 'package:flutter/material.dart';
import 'package:kaufhansel_client/login_page.dart';
import 'package:kaufhansel_client/rest_client.dart';
import 'package:kaufhansel_client/shopping_list_drawer.dart';
import 'package:kaufhansel_client/shopping_list_filter_options.dart';
import 'package:kaufhansel_client/shopping_list_page.dart';
import 'package:kaufhansel_client/shopping_list_title.dart';
import 'package:provider/provider.dart';

import 'model.dart';

void main() {
  runApp(ShoppingListApp());
}

class ShoppingListApp extends StatefulWidget {
  @override
  _ShoppingListAppState createState() => _ShoppingListAppState();
}

class _ShoppingListAppState extends State<ShoppingListApp> {
  static const _serverUrl = kDebugMode ? "https://localhost:8080" : "https://zwohansel.de/kaufhansel/";
  final _client = RestClient(Uri.parse(_serverUrl));
  bool _loggedIn = false;
  ShoppingListFilterOption _filter = ShoppingListFilterOption.ALL;

  ShoppingListModel _shoppingList;
  bool _loadingShoppingList = true;
  String _shoppingListLoadError;

  void _onFilterChanged(ShoppingListFilterOption nextFilter) {
    setState(() {
      _filter = nextFilter;
    });
  }

  void _onLoggedIn() {
    setState(() => _loggedIn = true);
    _getMainShoppingList();
  }

  void _getMainShoppingList() async {
    setState(() {
      _loadingShoppingList = true;
      _shoppingListLoadError = null;
    });
    try {
      final lists = await _client.getShoppingLists();
      final list = await _client.fetchShoppingList(lists.first.id, lists.first.name);
      setState(() {
        _shoppingList = list;
        _loadingShoppingList = false;
      });
    } catch (e) {
      setState(() {
        _shoppingListLoadError = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Kaufhansel',
        theme: ThemeData(primarySwatch: Colors.green, fontFamily: 'Roboto'),
        home: RestClientWidget(client: _client, child: _buildContent(context)));
  }

  Widget _buildContent(BuildContext context) {
    if (_loggedIn) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: _shoppingList),
          ChangeNotifierProvider(create: (context) => ShoppingListTabSelection(0))
        ],
        builder: (context, child) {
          return Scaffold(
            appBar: AppBar(
              title: ShoppingListTitle(),
              shadowColor: Colors.transparent,
            ),
            endDrawer: ShoppingListDrawer(
              onRefreshPressed: _getMainShoppingList,
              filter: _filter,
              onFilterChanged: _onFilterChanged,
            ),
            body: _buildShoppingList(context),
          );
        },
      );
    }

    return LoginPage(loggedIn: _onLoggedIn);
  }

  Widget _buildShoppingList(BuildContext context) {
    if (_shoppingListLoadError != null) {
      return Center(
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
      ));
    } else if (_loadingShoppingList) {
      return Center(child: CircularProgressIndicator());
    } else {
      return ChangeNotifierProvider.value(
        value: _shoppingList,
        child: ShoppingListPage(filter: _filter),
      );
    }
  }
}
