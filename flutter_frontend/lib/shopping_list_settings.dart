import 'package:flutter/material.dart';
import 'package:kaufhansel_client/delete_shopping_list_dialog.dart';
import 'package:kaufhansel_client/error_dialog.dart';
import 'package:kaufhansel_client/model.dart';
import 'package:kaufhansel_client/title_widget.dart';

class ShoppingListSettings extends StatefulWidget {
  final ShoppingListInfo _shoppingListInfo;

  const ShoppingListSettings(this._shoppingListInfo, {@required Future<void> Function() onDeleteShoppingList})
      : _onDeleteShoppingList = onDeleteShoppingList;

  final Future<void> Function() _onDeleteShoppingList;

  @override
  _ShoppingListSettingsState createState() => _ShoppingListSettingsState();
}

class _ShoppingListSettingsState extends State<ShoppingListSettings> {
  final ScrollController _scrollController = ScrollController();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final sharedUsers = widget._shoppingListInfo.users.map((user) => ListTile(
          title: Text(user.userName),
          onTap: () {},
        ));

    return Scaffold(
        appBar: AppBar(
          title: TitleWidget(),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildProgressBar(),
            Expanded(
              child: Scrollbar(
                  controller: _scrollController,
                  child: ListView(children: [
                    Padding(
                        padding: EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(height: 12),
                            Card(
                              child: Padding(
                                  padding: EdgeInsets.all(18),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                        Flexible(
                                            child: Text(
                                          widget._shoppingListInfo.name,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context).textTheme.headline5,
                                        )),
                                        IconButton(icon: Icon(Icons.drive_file_rename_outline), onPressed: null)
                                      ]),
                                      SizedBox(height: 12),
                                      OutlineButton(
                                        onPressed: null,
                                        child: Text("Alle Häckchen entfernen"),
                                      ),
                                      SizedBox(height: 6),
                                      OutlineButton(
                                        onPressed: null,
                                        child: Text("Alle Kategorien entfernen"),
                                      ),
                                      SizedBox(height: 6),
                                      OutlineButton(
                                        onPressed: null,
                                        child: Text("Alle Elemente löschen"),
                                      ),
                                    ],
                                  )),
                            ),
                            SizedBox(height: 12),
                            Card(
                              child: Padding(
                                  padding: EdgeInsets.all(18),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "Du teilst die Liste mit",
                                        style: Theme.of(context).textTheme.headline6,
                                      ),
                                      SizedBox(height: 12),
                                      ListView(
                                        shrinkWrap: true,
                                        children: ListTile.divideTiles(context: context, tiles: [
                                          ...sharedUsers,
                                          ListTile(
                                            title: TextField(
                                                onSubmitted: (text) {},
                                                decoration: InputDecoration(
                                                    suffixIcon: IconButton(icon: Icon(Icons.add), onPressed: () {}),
                                                    labelText: "",
                                                    hintText: "Mit einem weiteren Hansel teilen",
                                                    contentPadding: EdgeInsets.zero)),
                                          )
                                        ]).toList(),
                                      )
                                    ],
                                  )),
                            ),
                            SizedBox(height: 12),
                            Card(
                              child: Padding(
                                  padding: EdgeInsets.all(18),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "Gefahrenzone",
                                        style: Theme.of(context).textTheme.headline6,
                                      ),
                                      SizedBox(height: 12),
                                      OutlineButton(
                                        child: Text("Liste löschen..."),
                                        textColor: Colors.red,
                                        highlightedBorderColor: Colors.red,
                                        borderSide: BorderSide(color: Colors.red),
                                        onPressed: _loading
                                            ? null
                                            : () {
                                                showDialog(
                                                    context: context,
                                                    barrierDismissible: false,
                                                    builder: (context) {
                                                      return DeleteShoppingListDialog(
                                                          widget._shoppingListInfo, _onDeleteShoppingList);
                                                    });
                                              },
                                      ),
                                      SizedBox(height: 12),
                                      OutlineButton(
                                          child: Text("Liste übertragen..."),
                                          textColor: Colors.red,
                                          highlightedBorderColor: Colors.red,
                                          borderSide: BorderSide(color: Colors.red),
                                          onPressed: null)
                                    ],
                                  )),
                            )
                          ],
                        ))
                  ])),
            )
          ],
        ));
  }

  void _onDeleteShoppingList() {
    setState(() {
      _loading = true;
    });
    widget
        ._onDeleteShoppingList()
        .then((value) => Navigator.pop(context))
        .catchError((e) =>
            showErrorDialog(context, "Wollen wir nicht, dass du die Liste löschst oder hast du etwas falsch gemacht?"))
        .whenComplete(() => setState(() {
              _loading = false;
            }));
  }

  Widget _buildProgressBar() {
    if (_loading) {
      return LinearProgressIndicator(
        minHeight: 5,
      );
    } else {
      return Container();
    }
  }
}
