import 'package:flutter/material.dart';
import 'package:kaufhansel_client/error_dialog.dart';
import 'package:kaufhansel_client/shopping_list_filter.dart';
import 'package:kaufhansel_client/shopping_list_filter_options.dart';

import 'create_shopping_list_dialog.dart';
import 'model.dart';

class ShoppingListDrawer extends StatelessWidget {
  const ShoppingListDrawer(
      {@required VoidCallback onRefreshPressed,
      @required ShoppingListFilterOption filter,
      @required void Function(ShoppingListFilterOption nextFilter) onFilterChanged,
      @required List<ShoppingListInfo> shoppingLists,
      @required void Function(ShoppingListInfo info) onShoppingListSelected,
      @required Future<void> Function(String) onCreateShoppingList})
      : _onRefreshPressed = onRefreshPressed,
        _onFilterChanged = onFilterChanged,
        _filter = filter,
        _shoppingLists = shoppingLists,
        _onShoppingListSelected = onShoppingListSelected,
        _onCreateShoppingList = onCreateShoppingList;

  final VoidCallback _onRefreshPressed;
  final void Function(ShoppingListFilterOption nextFilter) _onFilterChanged;
  final void Function(ShoppingListInfo info) _onShoppingListSelected;
  final ShoppingListFilterOption _filter;
  final List<ShoppingListInfo> _shoppingLists;
  final Future<void> Function(String) _onCreateShoppingList;

  @override
  Widget build(BuildContext context) {
    final infoTiles = _shoppingLists?.map((info) => ListTile(
        key: ValueKey(info.id),
        title: Text(info.name),
        trailing: IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              showErrorDialog(context, "Kannst du nicht schreiben?");
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
            child: DrawerHeader(
              margin: EdgeInsets.zero,
              padding: EdgeInsets.zero,
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              child: Material(
                type: MaterialType.transparency,
                child: Padding(
                  padding: EdgeInsets.only(left: 15, right: 15),
                  child: Flex(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    direction: Axis.horizontal,
                    children: [
                      ShoppingListFilter(_onFilterChanged, _filter),
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
                OutlineButton(
                  child: Text("Neue Liste"),
                  textColor: Theme.of(context).primaryIconTheme.color,
                  borderSide: BorderSide(color: Theme.of(context).primaryIconTheme.color),
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
                OutlineButton(
                  child: Text("Einstellungen"),
                  textColor: Theme.of(context).primaryIconTheme.color,
                  borderSide: BorderSide(color: Theme.of(context).primaryIconTheme.color),
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
}
