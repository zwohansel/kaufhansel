import 'package:flutter/material.dart';
import 'package:kaufhansel_client/shopping_list_filter_options.dart';

class ShoppingListDrawer extends StatelessWidget {
  const ShoppingListDrawer(
      {@required VoidCallback onRefreshPressed,
      @required ShoppingListFilterOption filter,
      @required void Function(ShoppingListFilterOption nextFilter) onFilterChanged})
      : _onRefreshPressed = onRefreshPressed,
        _onFilterChanged = onFilterChanged,
        _filter = filter;

  final VoidCallback _onRefreshPressed;
  final void Function(ShoppingListFilterOption nextFilter) _onFilterChanged;
  final ShoppingListFilterOption _filter;

  List<bool> _calculateSelection() {
    switch (_filter) {
      case ShoppingListFilterOption.UNCHECKED:
        return [true, false];
      case ShoppingListFilterOption.CHECKED:
        return [false, true];
      case ShoppingListFilterOption.ALL:
      default:
        return [false, false];
    }
  }

  void _setSelection(int index) {
    if (index == 0) {
      if (_filter == ShoppingListFilterOption.UNCHECKED) {
        _onFilterChanged(ShoppingListFilterOption.ALL);
      } else {
        _onFilterChanged(ShoppingListFilterOption.UNCHECKED);
      }
    } else if (index == 1) {
      if (_filter == ShoppingListFilterOption.CHECKED) {
        _onFilterChanged(ShoppingListFilterOption.ALL);
      } else {
        _onFilterChanged(ShoppingListFilterOption.CHECKED);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      ToggleButtons(
                          fillColor: Colors.white,
                          color: Colors.white,
                          selectedColor: Colors.black,
                          hoverColor: Theme.of(context).secondaryHeaderColor,
                          children: [
                            Tooltip(message: "Was muss ich noch kaufen", child: Icon(Icons.check_box_outline_blank)),
                            Tooltip(message: "Was ist schon im Einkaufswagen", child: Icon(Icons.check_box_outlined)),
                          ],
                          onPressed: _setSelection,
                          isSelected: _calculateSelection()),
                      IconButton(
                        icon: Icon(Icons.refresh),
                        color: Theme.of(context).primaryIconTheme.color,
                        splashRadius: 25,
                        onPressed: _onRefreshPressed,
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
              children: ListTile.divideTiles(context: context, tiles: [
                ListTile(
                    title: Text("Meine Liste"),
                    trailing: IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {},
                    ),
                    onTap: () {}),
                ListTile(title: Text("Schindlers Liste"), onTap: () {})
              ]).toList(),
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
                  onPressed: () {},
                ),
                SizedBox(height: 10),
                OutlineButton(
                  child: Text("Einstellungen"),
                  textColor: Theme.of(context).primaryIconTheme.color,
                  borderSide: BorderSide(color: Theme.of(context).primaryIconTheme.color),
                  onPressed: () {},
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
