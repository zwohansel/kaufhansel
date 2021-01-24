import 'package:flutter/material.dart';
import 'package:kaufhansel_client/delete_shopping_list_dialog.dart';
import 'package:kaufhansel_client/error_dialog.dart';
import 'package:kaufhansel_client/model.dart';
import 'package:kaufhansel_client/title_widget.dart';

class ShoppingListSettings extends StatefulWidget {
  final ShoppingListInfo _shoppingListInfo;

  const ShoppingListSettings(this._shoppingListInfo,
      {@required Future<void> Function() onDeleteShoppingList,
      @required Future<void> Function(String) onAddUserToShoppingList})
      : _onDeleteShoppingList = onDeleteShoppingList,
        _onAddUserToShoppingList = onAddUserToShoppingList;

  final Future<void> Function() _onDeleteShoppingList;
  final Future<void> Function(String) _onAddUserToShoppingList;

  @override
  _ShoppingListSettingsState createState() => _ShoppingListSettingsState();
}

class _ShoppingListSettingsState extends State<ShoppingListSettings> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _addUserTextEditingController = new TextEditingController();
  final FocusNode _addUserToShoppingListFocusNode = new FocusNode();
  final _addUserToShoppingListFormKey = GlobalKey<FormState>();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final sharedUsers = widget._shoppingListInfo.users.map((user) => ListTile(
          title: Text("${user.userName} (${user.userEmailAddress})"),
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
                                        children: ListTile.divideTiles(context: context, tiles: sharedUsers).toList(),
                                      ),
                                      SizedBox(height: 12),
                                      Text(
                                        "Mit einem weiteren Hansel teilen",
                                        style: Theme.of(context).textTheme.headline6,
                                      ),
                                      SizedBox(height: 12),
                                      Row(children: [
                                        Expanded(
                                            child: Form(
                                                key: _addUserToShoppingListFormKey,
                                                child: TextFormField(
                                                  focusNode: _addUserToShoppingListFocusNode,
                                                  controller: _addUserTextEditingController,
                                                  enabled: !_loading,
                                                  onFieldSubmitted: (_) => _onAddUserToShoppingList(),
                                                  decoration: const InputDecoration(
                                                    hintText: 'Emailadresse vom Hansel',
                                                  ),
                                                  validator: (emailAddress) {
                                                    if (emailAddress.trim().isEmpty ||
                                                        !emailAddress.contains('@') ||
                                                        !emailAddress.contains('.')) {
                                                      return 'Dazu brauchen wir schon eine korrekte Emailadresse...';
                                                    }
                                                    return null;
                                                  },
                                                ))),
                                        IconButton(
                                          icon: Icon(Icons.add),
                                          onPressed: _loading ? null : _onAddUserToShoppingList,
                                        )
                                      ]),
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

  void _onAddUserToShoppingList() {
    if (!_addUserToShoppingListFormKey.currentState.validate()) {
      _addUserToShoppingListFocusNode.requestFocus();
      return;
    }

    setState(() {
      _loading = true;
    });
    widget
        ._onAddUserToShoppingList(_addUserTextEditingController.value.text.trim().toLowerCase())
        .then((_) => _addUserTextEditingController.text == "")
        .catchError((e) {
      showErrorDialog(context, "Hast du dich vertippt oder können wir den Hansel nicht finden?");
      _addUserToShoppingListFocusNode.requestFocus();
    }).whenComplete(() => setState(() {
              _loading = false;
            }));
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
