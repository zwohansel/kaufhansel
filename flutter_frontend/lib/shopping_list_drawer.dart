import 'package:flutter/material.dart';

class ShoppingListDrawer extends StatelessWidget {
  const ShoppingListDrawer({
    Key key,
    @required void Function() onRefreshPressed,
  })  : _onRefreshPressed = onRefreshPressed,
        super(key: key);

  final void Function() _onRefreshPressed;

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
                            Icon(Icons.check_box_outline_blank),
                            Icon(Icons.check_box_outlined),
                            Icon(Icons.indeterminate_check_box_outlined),
                          ],
                          onPressed: (index) {},
                          isSelected: [true, false, false]),
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
                ListTile(title: Text("Meine Liste"), onTap: () {}),
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
