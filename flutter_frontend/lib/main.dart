import 'dart:developer' as developer;
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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
  RestClient _client = RestClient(Uri.parse(_serverUrl));
  ShoppingListFilterOption _filter = ShoppingListFilterOption.ALL;
  ShoppingListMode _mode = ShoppingListMode.DEFAULT;

  String _error;
  List<ShoppingListInfo> _shoppingListInfos;
  ShoppingListInfo _currentShoppingListInfo; // TODO: unnecessary, also contained in _currentShoppingList
  ShoppingList _currentShoppingList;
  List<String> _currentShoppingListCategories;
  String _currentShoppingListCategory;

  // if userInfo == null, no user is logged in
  ShoppingListUserInfo _userInfo;
  bool _isLoggedIn() {
    return _userInfo != null;
  }

  void _logIn(ShoppingListUserInfo fetchedUserInfo) {
    setState(() => _userInfo = fetchedUserInfo);
    _fetchShoppingListInfos();
  }

  void _logOut() {
    _client.close();
    setState(() => _userInfo = null);
    _client = RestClient(Uri.parse(_serverUrl));
  }

  void _setFilter(ShoppingListFilterOption nextFilter) {
    setState(() {
      _filter = nextFilter;
    });
  }

  void _setMode(ShoppingListMode nextMode) {
    setState(() {
      _mode = nextMode;
    });
  }

  void _setCurrentShoppingListCategory(String nextCategory) {
    setState(() {
      _currentShoppingListCategory = nextCategory;
    });
  }

  void _selectShoppingList(ShoppingListInfo info) {
    if (info != _currentShoppingListInfo) {
      setState(() {
        _currentShoppingListInfo = info;
        _fetchCurrentShoppingList();
      });
    }
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

  Future<void> _removeUserFromShoppingList(ShoppingListInfo info, ShoppingListUserReference user) async {
    await _client.removeUserFromShoppingList(info.id, user.userId);
    info.removeUserFromShoppingList(user);
  }

  Future<void> _changeShoppingListPermissions(
      ShoppingListInfo info, String affectedUserId, ShoppingListRole newRole) async {
    final userReference = await _client.changeShoppingListPermissions(info.id, affectedUserId, newRole);
    info.updateShoppingListUser(userReference);
  }

  Future<void> _changeShoppingListName(ShoppingListInfo info, String newName) async {
    await _client.changeShoppingListName(info.id, newName);
    info.updateShoppingListName(newName);
  }

  void _fetchShoppingListInfos() async {
    final oldShoppingList = _currentShoppingList;
    final oldCategory = _currentShoppingListCategory;
    setState(() {
      _shoppingListInfos = null;
      _currentShoppingList = null;
      _currentShoppingListCategories = null;
      _currentShoppingListCategory = null;
      _error = null;
    });
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) => oldShoppingList?.dispose());

    try {
      final lists = await _client.getShoppingLists();
      setState(() {
        _shoppingListInfos = lists;
        _currentShoppingListInfo = lists.firstWhere(
          (list) => list.id == oldShoppingList?.id,
          orElse: () => lists.firstOrNull,
        );
        _fetchCurrentShoppingList(initialCategory: oldCategory);
      });
    } on Exception catch (e) {
      developer.log("Failed to fetch shopping list infos.", error: e);
      setState(() {
        _error = e.toString();
      });
    }
  }

  void _fetchCurrentShoppingList({String initialCategory}) async {
    final oldShoppingList = _currentShoppingList;
    setState(() {
      _currentShoppingList = null;
      _currentShoppingListCategories = null;
      _currentShoppingListCategory = null;
      _error = null;
    });
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) => oldShoppingList?.dispose());

    if (_currentShoppingListInfo == null) {
      return;
    }

    try {
      final items = await _client.fetchShoppingList(_currentShoppingListInfo.id);
      final shoppingList = new ShoppingList(_currentShoppingListInfo, items);
      setState(() {
        _currentShoppingList = shoppingList;
        _currentShoppingListCategories = shoppingList.getAllCategories();
        if (initialCategory != null && _currentShoppingListCategories.contains(initialCategory)) {
          _currentShoppingListCategory = initialCategory;
        } else {
          _currentShoppingListCategory = _currentShoppingListCategories.first;
        }
        _currentShoppingList.addListener(setCurrentShoppingListCategories);
      });
    } on Exception catch (e) {
      developer.log("Failed to fetch shopping list.", error: e);
      setState(() {
        _error = e.toString();
      });
    }
  }

  void setCurrentShoppingListCategories() {
    if (_currentShoppingList == null) {
      return;
    }

    final listEq = const ListEquality().equals;
    final nextCategories = _currentShoppingList.getAllCategories();
    if (listEq(nextCategories, _currentShoppingListCategories)) {
      return;
    }

    var nextCategory = _currentShoppingListCategory;
    if (!nextCategories.contains(nextCategory)) {
      final lastCategoryIndex = _currentShoppingListCategories.indexOf(nextCategory);
      // If the category no longer exists choose the category that tool the place of the removed category
      // or the one left to it.
      // Due to a bug in the TabBarView we can not choose the category left of the removed category
      // by default. If there is a category that took the place of the removed category
      // TabBarView will always show that and does not honor the tab index set in the TabController.
      nextCategory = nextCategories[max(0, min(lastCategoryIndex, nextCategories.length - 1))];
    }

    setState(() {
      _currentShoppingListCategories = nextCategories;
      _currentShoppingListCategory = nextCategory;
    });
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
    if (_isLoggedIn()) {
      return ChangeNotifierProvider.value(
        value: _currentShoppingList,
        builder: (context, child) {
          return Scaffold(
            appBar: AppBar(
              title: ShoppingListTitle(_currentShoppingListCategory),
              shadowColor: Colors.transparent,
            ),
            endDrawer: ShoppingListDrawer(
              onRefreshPressed: _fetchShoppingListInfos,
              filter: _filter,
              onFilterChanged: _setFilter,
              mode: _mode,
              onModeChanged: _setMode,
              shoppingLists: _shoppingListInfos,
              selectedShoppingListId: _currentShoppingList?.id,
              onShoppingListSelected: _selectShoppingList,
              onCreateShoppingList: _createShoppingList,
              onDeleteShoppingList: _deleteShoppingList,
              onUncheckAllItems: _uncheckAllItems,
              onRemoveAllCategories: _removeAllCategories,
              onRemoveAllItems: _removeAllItems,
              onAddUserToShoppingList: _addUserToShoppingList,
              onRemoveUserFromShoppingList: _removeUserFromShoppingList,
              onChangeShoppingListPermissions: _changeShoppingListPermissions,
              onChangeShoppingListName: _changeShoppingListName,
              userInfo: _userInfo,
              onLogOut: _logOut,
            ),
            body: _buildShoppingList(context),
          );
        },
      );
    }

    return LoginPage(loggedIn: _logIn);
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
      return ShoppingListPage(
        _currentShoppingListCategories,
        _filter,
        mode: _mode,
        initialCategory: _currentShoppingListCategory,
        onCategoryChanged: _setCurrentShoppingListCategory,
      );
    }
  }
}
