import 'package:flutter/material.dart';
import 'package:kaufhansel_client/error_dialog.dart';
import 'package:kaufhansel_client/shopping_list_filter.dart';
import 'package:kaufhansel_client/shopping_list_filter_options.dart';

import 'model.dart';

class ShoppingListDrawer extends StatelessWidget {
  const ShoppingListDrawer(
      {@required VoidCallback onRefreshPressed,
      @required ShoppingListFilterOption filter,
      @required void Function(ShoppingListFilterOption nextFilter) onFilterChanged,
      @required List<ShoppingListInfo> shoppingListInfos})
      : _onRefreshPressed = onRefreshPressed,
        _onFilterChanged = onFilterChanged,
        _filter = filter,
        _shoppingListInfos = shoppingListInfos;

  final VoidCallback _onRefreshPressed;
  final void Function(ShoppingListFilterOption nextFilter) _onFilterChanged;
  final ShoppingListFilterOption _filter;
  final List<ShoppingListInfo> _shoppingListInfos;

  @override
  Widget build(BuildContext context) {
    final infoTiles = _shoppingListInfos.map((info) => ListTile(
        key: ValueKey(info.id),
        title: Text(info.name),
        trailing: IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              showErrorDialog(context, "Kannst du nicht schreiben?");
            }),
        onTap: () {
          showErrorDialog(context, "Bringt noch nix.");
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
              children: ListTile.divideTiles(context: context, tiles: infoTiles).toList(),
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
                    // TODO
                    Navigator.pop(context);
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
