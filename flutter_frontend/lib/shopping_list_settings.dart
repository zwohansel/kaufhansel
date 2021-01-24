import 'package:flutter/material.dart';
import 'package:kaufhansel_client/confirm_dialog.dart';
import 'package:kaufhansel_client/error_dialog.dart';
import 'package:kaufhansel_client/model.dart';
import 'package:kaufhansel_client/title_widget.dart';

class ShoppingListSettings extends StatefulWidget {
  final ShoppingListInfo _shoppingListInfo;

  const ShoppingListSettings(this._shoppingListInfo,
      {@required Future<void> Function() onDeleteShoppingList,
      @required Future<void> Function() onUncheckAllItems,
      @required Future<void> Function() onRemoveAllCategories,
      @required Future<void> Function() onRemoveAllItems,
      @required Future<void> Function(String) onAddUserToShoppingList})
      : _onDeleteShoppingList = onDeleteShoppingList,
        _onUncheckAllItems = onUncheckAllItems,
        _onRemoveAllCategories = onRemoveAllCategories,
        _onRemoveAllItems = onRemoveAllItems,
        _onAddUserToShoppingList = onAddUserToShoppingList;

  final Future<void> Function() _onDeleteShoppingList;
  final Future<void> Function() _onUncheckAllItems;
  final Future<void> Function() _onRemoveAllCategories;
  final Future<void> Function() _onRemoveAllItems;
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

    return WillPopScope(
        onWillPop: () async => !_loading,
        child: Scaffold(
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
                                          OutlinedButton(
                                            onPressed: _loading ? null : _onUncheckAllItemsPressed,
                                            child: Text("Alle Häckchen entfernen"),
                                          ),
                                          SizedBox(height: 6),
                                          OutlinedButton(
                                            onPressed: _loading ? null : _onRemoveAllCategoriesPressed,
                                            child: Text("Alle Kategorien entfernen"),
                                          ),
                                          SizedBox(height: 6),
                                          OutlinedButton(
                                            onPressed: _loading ? null : _onRemoveAllItemsPressed,
                                            child: Text("Liste leeren"),
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
                                            children:
                                                ListTile.divideTiles(context: context, tiles: sharedUsers).toList(),
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
                                          OutlinedButton(
                                            child: Text("Liste löschen..."),
                                            style: OutlinedButton.styleFrom(primary: Colors.red),
                                            onPressed: _loading ? null : _onDeleteShoppingList,
                                          ),
                                          SizedBox(height: 12),
                                          OutlinedButton(
                                              child: Text("Liste übertragen..."),
                                              style: OutlinedButton.styleFrom(primary: Colors.red),
                                              onPressed: null)
                                        ],
                                      )),
                                )
                              ],
                            ))
                      ])),
                )
              ],
            )));
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

  void _onAddUserToShoppingList() async {
    if (!_addUserToShoppingListFormKey.currentState.validate()) {
      _addUserToShoppingListFocusNode.requestFocus();
      return;
    }

    setState(() => _loading = true);
    try {
      final userEmail = _addUserTextEditingController.value.text.trim().toLowerCase();
      await widget._onAddUserToShoppingList(userEmail);
      _addUserTextEditingController.clear();
    } catch (e) {
      showErrorDialog(context, "Hast du dich vertippt oder können wir den Hansel nicht finden?");
    } finally {
      setState(() => _loading = false);
    }
  }

  void _onDeleteShoppingList() async {
    setState(() => _loading = true);
    try {
      final deleteList = await showConfirmDialog(
          context, "Möchtest du ${widget._shoppingListInfo.name} wirklich für immer und unwiederbringlich löschen?");
      if (deleteList) {
        await widget._onDeleteShoppingList();
        Navigator.pop(context);
      }
    } catch (e) {
      showErrorDialog(context, "Kann die Liste nicht gelöscht werden oder hast du kein Internet?");
    } finally {
      setState(() => _loading = false);
    }
  }

  void _onUncheckAllItemsPressed() async {
    setState(() => _loading = true);
    try {
      await widget._onUncheckAllItems();
    } catch (e) {
      showErrorDialog(context, "Ist der Server zu faul oder hast du kein Internet?");
    } finally {
      setState(() => _loading = false);
    }
  }

  void _onRemoveAllCategoriesPressed() async {
    setState(() => _loading = true);
    try {
      await widget._onRemoveAllCategories();
    } catch (e) {
      showErrorDialog(context, "Hat der Server keine Lust oder hast du kein Internet?");
    } finally {
      setState(() => _loading = false);
    }
    setState(() {
      _loading = false;
    });
  }

  void _onRemoveAllItemsPressed() async {
    setState(() => _loading = true);
    try {
      final removeItems = await showConfirmDialog(context,
          "Möchtest du wirklich alle Elemente aus ${widget._shoppingListInfo.name} unwiederbringlich entfernen?");
      if (removeItems) {
        await widget._onRemoveAllItems();
      }
    } catch (e) {
      showErrorDialog(context, "Schläft der Server noch oder hast du kein Internet?");
    } finally {
      setState(() => _loading = false);
    }
  }
}
