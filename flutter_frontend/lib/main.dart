import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kaufhansel_client/login_page.dart';
import 'package:kaufhansel_client/rest_client.dart';
import 'package:kaufhansel_client/shopping_list_drawer.dart';
import 'package:kaufhansel_client/shopping_list_filter_options.dart';
import 'package:kaufhansel_client/shopping_list_mode.dart';
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
  ShoppingListMode _mode = ShoppingListMode.DEFAULT;

  String _error;
  List<ShoppingListInfo> _shoppingListInfos;
  ShoppingListInfo _currentShoppingListInfo;
  ShoppingList _currentShoppingList;

  void _onFilterChanged(ShoppingListFilterOption nextFilter) {
    setState(() {
      _filter = nextFilter;
    });
  }

  void _onModeChanged(ShoppingListMode nextMode) {
    setState(() {
      stdout.writeln(nextMode);
      _mode = nextMode;
    });
  }

  void _onShoppingListSelected(ShoppingListInfo info) {
    if (info != _currentShoppingListInfo) {
      setState(() {
        _currentShoppingListInfo = info;
        _fetchCurrentShoppingList();
      });
    }
  }

  void _onLoggedIn() {
    setState(() => _loggedIn = true);
    _fetchShoppingListInfos();
  }

  Future<void> _createShoppingList(String shoppingListName) async {
    ShoppingListInfo info = await _client.createShoppingList(shoppingListName);
    setState(() {
      _shoppingListInfos.add(info);
    });
  }

  Future<void> _deleteShoppingList(ShoppingListInfo info) async {
    await _client.deleteShoppingList(info.id);
    setState(() {
      _shoppingListInfos.remove(info);
      if (_currentShoppingListInfo == info) {
        _currentShoppingListInfo = _shoppingListInfos.isNotEmpty ? _shoppingListInfos.first : null;
        _fetchCurrentShoppingList();
      }
    });
  }

  Future<void> _uncheckAllItems(ShoppingListInfo info) async {
    await _client.uncheckAllItems(info.id);
    if (_currentShoppingListInfo == info) {
      _currentShoppingList?.items?.forEach((item) => item.checked = false);
    }
  }

  Future<void> _removeAllCategories(ShoppingListInfo info) async {
    await _client.removeAllCategories(info.id);
    if (_currentShoppingListInfo == info) {
      _currentShoppingList?.items?.forEach((item) => item.category = null);
    }
  }

  Future<void> _removeAllItems(ShoppingListInfo info) async {
    await _client.removeAllItems(info.id);
    if (_currentShoppingListInfo == info) {
      _currentShoppingList?.removeAllItems();
    }
  }

  Future<void> _addUserToShoppingList(ShoppingListInfo info, String userEmailAddress) async {
    final userReference = await _client.addUserToShoppingList(info.id, userEmailAddress);
    info.addUserToShoppingList(userReference);
  }

  void _fetchShoppingListInfos() async {
    setState(() {
      _shoppingListInfos = null;
      _currentShoppingList = null;
      _error = null;
    });

    try {
      final lists = await _client.getShoppingLists();
      setState(() {
        _shoppingListInfos = lists;
        _currentShoppingListInfo = lists.isNotEmpty ? lists.first : null;
        _fetchCurrentShoppingList();
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
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
          ChangeNotifierProvider.value(value: _currentShoppingList),
          ChangeNotifierProvider(create: (context) => ShoppingListTabSelection(0))
        ],
        builder: (context, child) {
          return Scaffold(
            appBar: AppBar(
              title: ShoppingListTitle(),
              shadowColor: Colors.transparent,
            ),
            endDrawer: ShoppingListDrawer(
              onRefreshPressed: _fetchShoppingListInfos,
              filter: _filter,
              onFilterChanged: _onFilterChanged,
              mode: _mode,
              onModeChanged: _onModeChanged,
              shoppingLists: _shoppingListInfos,
              selectedShoppingListId: _currentShoppingList?.id,
              onShoppingListSelected: _onShoppingListSelected,
              onCreateShoppingList: _createShoppingList,
              onDeleteShoppingList: _deleteShoppingList,
              onUncheckAllItems: _uncheckAllItems,
              onRemoveAllCategories: _removeAllCategories,
              onRemoveAllItems: _removeAllItems,
              onAddUserToShoppingList: _addUserToShoppingList,
            ),
            body: _buildShoppingList(context),
          );
        },
      );
    }

    return LoginPage(loggedIn: _onLoggedIn);
  }

  void _handleRetry() {
    if (_shoppingListInfos == null) {
      _fetchShoppingListInfos();
    } else if (_currentShoppingList == null) {
      _fetchCurrentShoppingList();
    }
  }

  Widget _buildShoppingList(BuildContext context) {
    if (_error != null) {
      return Center(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            child: Text("🤷‍♂️", style: TextStyle(fontFamilyFallback: ["NotoColorEmoji"], fontSize: 100)),
            padding: EdgeInsets.all(20),
          ),
          Text(
            "Oh nein! Haben wir Deine Einkaufslisten etwa verlegt?",
            style: Theme.of(context).textTheme.headline6,
          ),
          Padding(
              child: ElevatedButton(child: Text("Nochmal versuchen"), onPressed: _handleRetry),
              padding: EdgeInsets.all(20))
        ],
      ));
    } else if (_shoppingListInfos == null || _currentShoppingList == null) {
      return Center(child: CircularProgressIndicator());
    } else {
      return ShoppingListPage(filter: _filter, mode: _mode);
    }
  }

  void _fetchCurrentShoppingList() async {
    setState(() {
      _currentShoppingList = null;
      _error = null;
    });

    if (_currentShoppingListInfo == null) {
      return;
    }

    try {
      final fetchedList = await _client.fetchShoppingList(_currentShoppingListInfo.id, _currentShoppingListInfo.name);
      setState(() {
        _currentShoppingList = fetchedList;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }
}
