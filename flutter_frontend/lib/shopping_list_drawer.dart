import 'package:flutter/material.dart';
import 'package:kaufhansel_client/shopping_list_filter_options.dart';
import 'package:kaufhansel_client/shopping_list_filter_selection.dart';
import 'package:kaufhansel_client/shopping_list_mode.dart';
import 'package:kaufhansel_client/shopping_list_mode_selection.dart';
import 'package:kaufhansel_client/shopping_list_settings.dart';

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
      @required Future<void> Function(ShoppingListInfo, String) onAddUserToShoppingList,
      @required Future<void> Function(ShoppingListInfo) onUncheckAllItems,
      @required Future<void> Function(ShoppingListInfo) onRemoveAllCategories,
      @required Future<void> Function(ShoppingListInfo) onRemoveAllItems,
      @required Future<void> Function(ShoppingListInfo, String, String) onChangeShoppingListPermissions,
      @required Future<void> Function(ShoppingListInfo, ShoppingListUserReference) onRemoveUserFromShoppingList,
      @required Future<void> Function(ShoppingListInfo, String) onChangeShoppingListName})
      : _onRefreshPressed = onRefreshPressed,
        _filter = filter,
        _onFilterChanged = onFilterChanged,
        _mode = mode,
        _onModeChanged = onModeChanged,
        _shoppingLists = shoppingLists,
        _selectedShoppingListId = selectedShoppingListId,
        _onShoppingListSelected = onShoppingListSelected,
        _onCreateShoppingList = onCreateShoppingList,
        _onDeleteShoppingList = onDeleteShoppingList,
        _onAddUserToShoppingList = onAddUserToShoppingList,
        _onRemoveUserFromShoppingList = onRemoveUserFromShoppingList,
        _onUncheckAllItems = onUncheckAllItems,
        _onRemoveAllCategories = onRemoveAllCategories,
        _onRemoveAllItems = onRemoveAllItems,
        _onChangeShoppingListPermissions = onChangeShoppingListPermissions,
        _onChangeShoppingListName = onChangeShoppingListName;

  final ShoppingListFilterOption _filter;
  final ShoppingListMode _mode;
  final List<ShoppingListInfo> _shoppingLists;
  final VoidCallback _onRefreshPressed;
  final void Function(ShoppingListFilterOption nextFilter) _onFilterChanged;
  final void Function(ShoppingListMode nextMode) _onModeChanged;
  final void Function(ShoppingListInfo info) _onShoppingListSelected;
  final String _selectedShoppingListId;
  final Future<void> Function(String) _onCreateShoppingList;
  final Future<void> Function(ShoppingListInfo) _onDeleteShoppingList;
  final Future<void> Function(ShoppingListInfo, String) _onAddUserToShoppingList;
  final Future<void> Function(ShoppingListInfo, ShoppingListUserReference) _onRemoveUserFromShoppingList;
  final Future<void> Function(ShoppingListInfo) _onUncheckAllItems;
  final Future<void> Function(ShoppingListInfo) _onRemoveAllCategories;
  final Future<void> Function(ShoppingListInfo) _onRemoveAllItems;
  final Future<void> Function(ShoppingListInfo info, String affectedUserId, String newRole)
      _onChangeShoppingListPermissions;
  final Future<void> Function(ShoppingListInfo, String) _onChangeShoppingListName;

  @override
  Widget build(BuildContext context) {
    final infoTiles = _shoppingLists?.map((info) => ListTile(
        key: ValueKey(info.id),
        title: Text(info.name),
        tileColor: _getTileColor(context, info),
        trailing: IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) {
                  return ShoppingListSettings(info,
                      onDeleteShoppingList: () => _onDeleteShoppingList(info),
                      onUncheckAllItems: () => _onUncheckAllItems(info),
                      onRemoveAllCategories: () => _onRemoveAllCategories(info),
                      onRemoveAllItems: () => _onRemoveAllItems(info),
                      onAddUserToShoppingList: (userEmailAddress) => _onAddUserToShoppingList(info, userEmailAddress),
                      onRemoveUserFromShoppingList: (user) => _onRemoveUserFromShoppingList(info, user),
                      onChangeShoppingListPermissions: (affectedUserId, newRole) =>
                          _onChangeShoppingListPermissions(info, affectedUserId, newRole),
                      onChangeShoppingListName: (newName) => _onChangeShoppingListName(info, newName));
                },
              ));
            }),
        onTap: () {
          _onShoppingListSelected(info);
          Navigator.pop(context);
        }));

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
                    ShoppingListFilterSelection(_onFilterChanged, _filter),
                    ShoppingListModeSelection(_onModeChanged, _mode),
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
                  child: Text("Einstellungen"),
                  style: OutlinedButton.styleFrom(
                      primary: Theme.of(context).primaryIconTheme.color,
                      side: BorderSide(color: Theme.of(context).primaryIconTheme.color)),
                  onPressed: () {
                    //TODO
                    Navigator.pop(context);
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

  Color _getTileColor(BuildContext context, ShoppingListInfo info) {
    return _selectedShoppingListId != null
        ? (info.id == _selectedShoppingListId ? Theme.of(context).highlightColor : null)
        : null;
  }
}
