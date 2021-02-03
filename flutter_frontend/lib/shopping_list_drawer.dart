import 'package:flutter/material.dart';
import 'package:kaufhansel_client/list_settings/shopping_list_settings.dart';
import 'package:kaufhansel_client/rest_client.dart';
import 'package:kaufhansel_client/settings/app_settings.dart';
import 'package:kaufhansel_client/shopping_list_filter_options.dart';
import 'package:kaufhansel_client/shopping_list_filter_selection.dart';
import 'package:kaufhansel_client/shopping_list_mode.dart';
import 'package:kaufhansel_client/shopping_list_mode_selection.dart';
import 'package:kaufhansel_client/widgets/invite_dialog.dart';
import 'package:provider/provider.dart';

import 'create_shopping_list_dialog.dart';
import 'model.dart';

class ShoppingListDrawer extends StatelessWidget {
  const ShoppingListDrawer(
      {@required ShoppingListFilterOption filter,
      @required void Function(ShoppingListFilterOption nextFilter) onFilterChanged,
      @required ShoppingListMode mode,
      @required final void Function(ShoppingListMode nextMode) onModeChanged,
      @required List<ShoppingListInfo> shoppingLists,
      @required VoidCallback onRefreshPressed,
      @required String selectedShoppingListId,
      @required void Function(ShoppingListInfo info) onShoppingListSelected,
      @required Future<void> Function(String) onCreateShoppingList,
      @required Future<void> Function(ShoppingListInfo) onDeleteShoppingList,
      @required Future<bool> Function(ShoppingListInfo, String) onAddUserToShoppingListIfPresent,
      @required Future<void> Function(ShoppingListInfo) onUncheckAllItems,
      @required Future<void> Function(ShoppingListInfo) onRemoveAllCategories,
      @required Future<void> Function(ShoppingListInfo) onRemoveAllItems,
      @required Future<void> Function(ShoppingListInfo, String, ShoppingListRole) onChangeShoppingListPermissions,
      @required Future<void> Function(ShoppingListInfo, ShoppingListUserReference) onRemoveUserFromShoppingList,
      @required Future<void> Function(ShoppingListInfo, String) onChangeShoppingListName,
      @required void Function() onLogOut,
      @required ShoppingListUserInfo userInfo})
      : _onRefreshPressed = onRefreshPressed,
        _filter = filter,
        _changeFilter = onFilterChanged,
        _mode = mode,
        _changeMode = onModeChanged,
        _shoppingListInfos = shoppingLists,
        _selectedShoppingListId = selectedShoppingListId,
        _selectShoppingList = onShoppingListSelected,
        _onCreateShoppingList = onCreateShoppingList,
        _onDeleteShoppingList = onDeleteShoppingList,
        _onAddUserToShoppingListIfPresent = onAddUserToShoppingListIfPresent,
        _onRemoveUserFromShoppingList = onRemoveUserFromShoppingList,
        _onUncheckAllItems = onUncheckAllItems,
        _onRemoveAllCategories = onRemoveAllCategories,
        _onRemoveAllItems = onRemoveAllItems,
        _onChangeShoppingListPermissions = onChangeShoppingListPermissions,
        _onChangeShoppingListName = onChangeShoppingListName,
        _onLogOut = onLogOut,
        _userInfo = userInfo;

  final ShoppingListFilterOption _filter;
  final ShoppingListMode _mode;
  final List<ShoppingListInfo> _shoppingListInfos;
  final VoidCallback _onRefreshPressed;
  final void Function(ShoppingListFilterOption nextFilter) _changeFilter;
  final void Function(ShoppingListMode nextMode) _changeMode;
  final void Function(ShoppingListInfo info) _selectShoppingList;
  final String _selectedShoppingListId;
  final Future<void> Function(String) _onCreateShoppingList;
  final Future<void> Function(ShoppingListInfo) _onDeleteShoppingList;
  final Future<bool> Function(ShoppingListInfo, String) _onAddUserToShoppingListIfPresent;
  final Future<void> Function(ShoppingListInfo, ShoppingListUserReference) _onRemoveUserFromShoppingList;
  final Future<void> Function(ShoppingListInfo) _onUncheckAllItems;
  final Future<void> Function(ShoppingListInfo) _onRemoveAllCategories;
  final Future<void> Function(ShoppingListInfo) _onRemoveAllItems;
  final Future<void> Function(ShoppingListInfo info, String affectedUserId, ShoppingListRole newRole)
      _onChangeShoppingListPermissions;
  final Future<void> Function(ShoppingListInfo, String) _onChangeShoppingListName;
  final void Function() _onLogOut;
  final ShoppingListUserInfo _userInfo;

  @override
  Widget build(BuildContext context) {
    final infoTiles = _shoppingListInfos?.map((info) => ChangeNotifierProvider.value(
        value: info,
        builder: (context, child) => ListTile(
            key: ValueKey(info.id),
            title: Consumer<ShoppingListInfo>(builder: (context, info, child) => Text(info.name)),
            tileColor: _getTileColor(context, info),
            leading: Tooltip(
                message: info.permissions.role.toDisplayString(),
                child: Icon(info.permissions.role.toIcon(), size: 18)),
            trailing: IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  final client = RestClientWidget.of(context);
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) {
                      // Providers are scoped and not shared between routes. We need to pass it explicitly to the new route
                      return ChangeNotifierProvider.value(
                          value: info,
                          child: RestClientWidget(
                              client: client,
                              child: ShoppingListSettings(
                                  onDeleteShoppingList: () => _onDeleteShoppingList(info),
                                  onUncheckAllItems: () => _onUncheckAllItems(info),
                                  onRemoveAllCategories: () => _onRemoveAllCategories(info),
                                  onRemoveAllItems: () => _onRemoveAllItems(info),
                                  onAddUserToShoppingListIfPresent: (userEmailAddress) =>
                                      _onAddUserToShoppingListIfPresent(info, userEmailAddress),
                                  onRemoveUserFromShoppingList: (user) => _onRemoveUserFromShoppingList(info, user),
                                  onChangeShoppingListPermissions: (affectedUserId, newRole) =>
                                      _onChangeShoppingListPermissions(info, affectedUserId, newRole),
                                  onChangeShoppingListName: (newName) => _onChangeShoppingListName(info, newName))));
                    },
                  ));
                }),
            onTap: () => _onShoppingListSelected(context, info))));

    return Drawer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 104,
            margin: EdgeInsets.zero,
            padding: EdgeInsets.zero,
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            child: Material(
              type: MaterialType.transparency,
              child: Padding(
                padding: EdgeInsets.only(left: 15, right: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ShoppingListFilterSelection((nextFilter) => _onFilterChanged(context, nextFilter), _filter),
                    buildShoppingListModeSelection(),
                    IconButton(
                      icon: Icon(Icons.refresh),
                      color: Theme.of(context).primaryIconTheme.color,
                      splashRadius: 25,
                      onPressed: () {
                        _onRefreshPressed();
                        Navigator.pop(context);
                      },
                      tooltip: "Aktualisieren",
                    ),
                  ],
                ),
              ),
            ),
          ),
          Flexible(
            child: ListView(
              children: ListTile.divideTiles(context: context, tiles: infoTiles ?? []).toList(),
            ),
          ),
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OutlinedButton(
                  child: Text("Neue Liste"),
                  style: OutlinedButton.styleFrom(
                      primary: Theme.of(context).primaryIconTheme.color,
                      side: BorderSide(color: Theme.of(context).primaryIconTheme.color)),
                  onPressed: () {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) {
                        return CreateShoppingListDialog(_onCreateShoppingList);
                      },
                    );
                  },
                ),
                SizedBox(height: 10),
                OutlinedButton(
                  child: Text("Einladungs-Code generieren"),
                  style: OutlinedButton.styleFrom(
                      primary: Theme.of(context).primaryIconTheme.color,
                      side: BorderSide(color: Theme.of(context).primaryIconTheme.color)),
                  onPressed: () {
                    final RestClient client = RestClientWidget.of(context);
                    showDialog(
                        context: context,
                        builder: (context) {
                          return InviteDialog(client);
                        });
                  },
                ),
                SizedBox(height: 10),
                OutlinedButton(
                  child: Text("Einstellungen"),
                  style: OutlinedButton.styleFrom(
                      primary: Theme.of(context).primaryIconTheme.color,
                      side: BorderSide(color: Theme.of(context).primaryIconTheme.color)),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => new AppSettings(userInfo: _userInfo, onLogOut: _onLogOut),
                        ));
                  },
                )
              ],
            ),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
          )
        ],
      ),
    );
  }

  void _onShoppingListSelected(BuildContext context, ShoppingListInfo info) {
    _selectShoppingList(info);

    if (info.permissions.role == ShoppingListRole.READ_ONLY || info.permissions.role == ShoppingListRole.CHECK_ONLY) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        duration: Duration(seconds: 3),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Hier bist du ${info.permissions.role.toDisplayString()}:"),
            Text(info.permissions.role.toDescription()),
          ],
        ),
      ));
    }

    Navigator.pop(context);
  }

  void _onFilterChanged(BuildContext context, ShoppingListFilterOption nextFilter) {
    _changeFilter(nextFilter);
    Navigator.pop(context);
  }

  Widget buildShoppingListModeSelection() {
    return Selector<ShoppingList, bool>(
        selector: (_, shoppingList) => shoppingList != null ? shoppingList.info.permissions.canEditItems : false,
        builder: (context, canEditItems, child) {
          if (canEditItems) {
            return ShoppingListModeSelection((nextMode) => _onModeChanged(context, nextMode), _mode);
          } else {
            return Container();
          }
        });
  }

  void _onModeChanged(BuildContext context, ShoppingListMode nextMode) {
    _changeMode(nextMode);
    Navigator.pop(context);
  }

  Color _getTileColor(BuildContext context, ShoppingListInfo info) {
    return _selectedShoppingListId != null
        ? (info.id == _selectedShoppingListId ? Theme.of(context).highlightColor : null)
        : null;
  }
}
