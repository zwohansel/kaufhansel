import 'dart:developer' as developer;
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:kaufhansel_client/generated/l10n.dart';
import 'package:kaufhansel_client/login/login_page.dart';
import 'package:kaufhansel_client/rest_client.dart';
import 'package:kaufhansel_client/settings/settings_store.dart';
import 'package:kaufhansel_client/settings/settings_store_widget.dart';
import 'package:kaufhansel_client/shopping_list_drawer.dart';
import 'package:kaufhansel_client/shopping_list_filter_options.dart';
import 'package:kaufhansel_client/shopping_list_filter_selection.dart';
import 'package:kaufhansel_client/shopping_list_mode.dart';
import 'package:kaufhansel_client/shopping_list_mode_selection.dart';
import 'package:kaufhansel_client/shopping_list_page.dart';
import 'package:kaufhansel_client/shopping_list_title.dart';
import 'package:kaufhansel_client/utils/semantic_versioning.dart';
import 'package:kaufhansel_client/utils/update_check.dart';
import 'package:kaufhansel_client/widgets/overlay_menu.dart';
import 'package:provider/provider.dart';

import 'model.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  static const _serverUrl = kDebugMode ? "https://localhost:8080/api/" : "https://zwohansel.de/kaufhansel/api/";
  static final _restClient = RestClient(Uri.parse(_serverUrl));
  static final _settingsStore = SettingsStore();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        // locale can be set here:
        // locale: Locale("de"),
        localizationsDelegates: [AppLocalizations.delegate, GlobalMaterialLocalizations.delegate],
        supportedLocales: [const Locale('de', '')],
        debugShowCheckedModeBanner: false,
        onGenerateTitle: (BuildContext context) => AppLocalizations.of(context).appTitle,
        theme: ThemeData(primarySwatch: Colors.green, fontFamily: 'Roboto'),
        home: ShoppingListApp(
          client: _restClient,
          settingsStore: _settingsStore,
          currentVersion: getCurrentVersion,
        ));
  }
}

class ShoppingListApp extends StatefulWidget {
  final RestClient client;
  final SettingsStore settingsStore;
  final Future<Version> Function() currentVersion;

  const ShoppingListApp({@required this.client, @required this.settingsStore, @required this.currentVersion});

  @override
  _ShoppingListAppState createState() => _ShoppingListAppState();
}

class _ShoppingListAppState extends State<ShoppingListApp> {
  ShoppingListFilter _filter = ShoppingListFilter();
  ShoppingListMode _mode = ShoppingListMode();

  GlobalKey<ScaffoldState> _drawerKey = new GlobalKey();

  String _error;
  List<ShoppingListInfo> _shoppingListInfos;
  ShoppingListInfo _currentShoppingListInfo; // TODO: unnecessary, also contained in _currentShoppingList
  ShoppingList _currentShoppingList;
  List<String> _currentShoppingListCategories;
  String _currentShoppingListCategory;
  ShoppingListUserInfo _userInfo;
  bool _initializing;
  Update _update = Update.none();

  void initState() {
    super.initState();
    _initializing = true;
    asyncInit();
  }

  void asyncInit() async {
    try {
      Version currentVersion = await widget.currentVersion();
      final updateOpt = await checkForUpdate(context, widget.client, widget.settingsStore, currentVersion);
      updateOpt.ifPresent((update) => setState(() => _update = update));
      if (!updateOpt.isPresent() || !updateOpt.get.isBreakingChange()) {
        await _loadUserInfo();
      }
    } finally {
      setState(() => _initializing = false);
    }
  }

  Future<void> _loadUserInfo() async {
    try {
      final userInfoOpt = await widget.settingsStore.getUserInfo();
      userInfoOpt.ifPresent(_logIn);
    } on Exception catch (e) {
      developer.log("Could not read user info from store.", error: e);
    }
  }

  bool _isLoggedIn() {
    // if userInfo == null, no user is logged in
    return _userInfo != null;
  }

  void _logIn(ShoppingListUserInfo userInfo) {
    widget.client.setAuthenticationToken(userInfo.token);
    setState(() => _userInfo = userInfo);
    _fetchShoppingListInfos();
  }

  Future<void> _logOut() async {
    widget.client.logOut();
    await widget.settingsStore.removeUserInfo();
    setState(() => _userInfo = null);
  }

  Future<void> _deleteUserAccount() async {
    await widget.client.deleteAccount(_userInfo.id);
    await _logOut();
  }

  void _setFilter(ShoppingListFilterOption nextFilter) {
    setState(() {
      _filter.set(nextFilter);
    });
  }

  void _setMode(ShoppingListModeOption nextMode) {
    setState(() {
      _mode.set(nextMode);
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
    ShoppingListInfo info = await widget.client.createShoppingList(shoppingListName);
    setState(() {
      _shoppingListInfos.add(info);
    });
    if (_currentShoppingListInfo == null) {
      _currentShoppingListInfo = _shoppingListInfos.first;
      _fetchCurrentShoppingList();
    }
  }

  Future<void> _deleteShoppingList(ShoppingListInfo info) async {
    await widget.client.deleteShoppingList(info.id);
    setState(() {
      _shoppingListInfos.remove(info);
    });
    if (_currentShoppingListInfo == info) {
      _currentShoppingListInfo = _shoppingListInfos.isNotEmpty ? _shoppingListInfos.first : null;
      _fetchCurrentShoppingList();
    }
  }

  Future<void> _uncheckAllItems(ShoppingListInfo info) async {
    await widget.client.uncheckAllItems(info.id);
    if (_currentShoppingListInfo == info) {
      _currentShoppingList?.items?.forEach((item) => item.checked = false);
    }
  }

  Future<void> _removeAllCategories(ShoppingListInfo info) async {
    await widget.client.removeAllCategories(info.id);
    if (_currentShoppingListInfo == info) {
      _currentShoppingList?.items?.forEach((item) => item.category = null);
    }
  }

  Future<void> _removeAllItems(ShoppingListInfo info) async {
    await widget.client.removeAllItems(info.id);
    if (_currentShoppingListInfo == info) {
      _currentShoppingList?.removeAllItems();
    }
  }

  Future<bool> _addUserToShoppingList(ShoppingListInfo info, String userEmailAddress) async {
    final userReference = await widget.client.addUserToShoppingList(info.id, userEmailAddress);
    if (userReference.isPresent()) {
      info.addUserToShoppingList(userReference.get);
      return true;
    } else {
      return false;
    }
  }

  Future<void> _removeUserFromShoppingList(ShoppingListInfo info, ShoppingListUserReference user) async {
    await widget.client.removeUserFromShoppingList(info.id, user.userId);
    info.removeUserFromShoppingList(user);
  }

  Future<void> _changeShoppingListPermissions(
      ShoppingListInfo info, String affectedUserId, ShoppingListRole newRole) async {
    final userReference = await widget.client.changeShoppingListPermissions(info.id, affectedUserId, newRole);
    info.updateShoppingListUser(userReference);
  }

  Future<void> _changeShoppingListName(ShoppingListInfo info, String newName) async {
    await widget.client.changeShoppingListName(info.id, newName);
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
      final lists = await widget.client.getShoppingLists();
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
    disposeShoppingListAfterNextFrame(oldShoppingList);

    await _refreshCurrentShoppingList(initialCategory: initialCategory);
  }

  void disposeShoppingListAfterNextFrame(ShoppingList list) {
    if (list != null) {
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) => list.dispose());
    }
  }

  Future<void> _refreshCurrentShoppingList({String initialCategory}) async {
    if (_currentShoppingListInfo == null) {
      return;
    }

    try {
      final items = await widget.client.fetchShoppingList(_currentShoppingListInfo.id);
      final shoppingList = new ShoppingList(_currentShoppingListInfo, items);
      final oldShoppingList = _currentShoppingList;
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
      disposeShoppingListAfterNextFrame(oldShoppingList);
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
    return SettingsStoreWidget(
      widget.settingsStore,
      child: RestClientWidget(widget.client, child: _buildContent(context)),
    );
  }

  Widget _buildOverlayMenuButton() {
    return OverlayMenuButton(
      widthOffset: (3 * 40.0), // ToggleButton width
      button: _buildModeMenuButton(),
      buttonOpen: Icon(Icons.close),
      child: ChangeNotifierProvider.value(
        value: _mode,
        builder: (_, child) => ChangeNotifierProvider.value(
          value: _filter,
          builder: (_, child) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(AppLocalizations.of(context).shoppingListFilterTitle, style: Theme.of(context).textTheme.caption),
              Consumer<ShoppingListFilter>(
                  builder: (_, value, __) =>
                      ShoppingListFilterSelection(context, (nextFilter) => _setFilter(nextFilter), _filter.get)),
              SizedBox(height: 8),
              Text(AppLocalizations.of(context).shoppingListModeTitle, style: Theme.of(context).textTheme.caption),
              Consumer<ShoppingListMode>(
                  builder: (_, value, __) =>
                      ShoppingListModeSelection(context, (nextMode) => _setMode(nextMode), _mode.get)),
            ],
          ),
        ),
      ),
    );
  }

  Icon _buildModeMenuButton() {
    if (_mode.get != ShoppingListModeOption.DEFAULT || _filter.get != ShoppingListFilterOption.ALL) {
      return Icon(Icons.filter_alt);
    } else {
      return Icon(Icons.filter_alt_outlined);
    }
  }

  Widget _buildContent(BuildContext context) {
    if (_isLoggedIn()) {
      return ChangeNotifierProvider.value(
        value: _currentShoppingList,
        builder: (context, child) {
          return Scaffold(
            key: _drawerKey,
            appBar: AppBar(
              actions: [
                _buildOverlayMenuButton(),
                IconButton(
                    icon: Icon(Icons.menu), splashRadius: 23, onPressed: () => _drawerKey.currentState.openEndDrawer()),
              ],
              title: ShoppingListTitle(_currentShoppingListCategory),
              shadowColor: Colors.transparent,
            ),
            endDrawer: ShoppingListDrawer(
                onRefreshPressed: _fetchShoppingListInfos,
                shoppingListInfos: _shoppingListInfos ?? [],
                selectedShoppingListId: _currentShoppingListInfo?.id,
                onShoppingListSelected: _selectShoppingList,
                onCreateShoppingList: _createShoppingList,
                onDeleteShoppingList: _deleteShoppingList,
                onUncheckAllItems: _uncheckAllItems,
                onRemoveAllCategories: _removeAllCategories,
                onRemoveAllItems: _removeAllItems,
                onAddUserToShoppingListIfPresent: _addUserToShoppingList,
                onRemoveUserFromShoppingList: _removeUserFromShoppingList,
                onChangeShoppingListPermissions: _changeShoppingListPermissions,
                onChangeShoppingListName: _changeShoppingListName,
                userInfo: _userInfo,
                onLogOut: _logOut,
                onDeleteUserAccount: _deleteUserAccount),
            body: _buildShoppingList(context),
          );
        },
      );
    }

    return LoginPage(
      loggedIn: _logIn,
      enabled: !_initializing,
      update: _update,
    );
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
      return _buildErrorView(context);
    } else if (_shoppingListInfos == null) {
      return Center(child: CircularProgressIndicator());
    } else if (_currentShoppingList == null) {
      if (_shoppingListInfos.isEmpty) {
        return Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  AppLocalizations.of(context).shoppingListEmpty,
                  style: TextStyle(
                      fontFamilyFallback: ["NotoColorEmoji"], fontSize: Theme.of(context).textTheme.headline2.fontSize),
                  textAlign: TextAlign.center,
                ),
              ),
              Text(
                AppLocalizations.of(context).shoppingListEmptyText,
                style: Theme.of(context).textTheme.headline6,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      } else {
        return Center(child: CircularProgressIndicator());
      }
    } else {
      return ShoppingListPage(
        _currentShoppingListCategories,
        _filter.get,
        mode: _mode.get,
        initialCategory: _currentShoppingListCategory,
        onCategoryChanged: _setCurrentShoppingListCategory,
        update: _update,
        onRefresh: () async => _refreshCurrentShoppingList(initialCategory: _currentShoppingListCategory),
      );
    }
  }

  Widget _buildErrorView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            child: Text(AppLocalizations.of(context).manShrugging,
                style: TextStyle(fontFamilyFallback: ["NotoColorEmoji"], fontSize: 100)),
            padding: EdgeInsets.all(20),
          ),
          Text(
            AppLocalizations.of(context).shoppingListError,
            style: Theme.of(context).textTheme.headline6,
          ),
          Padding(
              child: ElevatedButton(child: Text(AppLocalizations.of(context).tryAgain), onPressed: _handleRetry),
              padding: EdgeInsets.all(20))
        ],
      ),
    );
  }
}
