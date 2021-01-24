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
      @required Future<void> Function() onRemoveAllItems})
      : _onDeleteShoppingList = onDeleteShoppingList,
        _onUncheckAllItems = onUncheckAllItems,
        _onRemoveAllCategories = onRemoveAllCategories,
        _onRemoveAllItems = onRemoveAllItems;

  final Future<void> Function() _onDeleteShoppingList;
  final Future<void> Function() _onUncheckAllItems;
  final Future<void> Function() _onRemoveAllCategories;
  final Future<void> Function() _onRemoveAllItems;

  @override
  _ShoppingListSettingsState createState() => _ShoppingListSettingsState();
}

class _ShoppingListSettingsState extends State<ShoppingListSettings> {
  final ScrollController _scrollController = ScrollController();
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
                                          OutlinedButton(
                                            child: Text("Liste löschen..."),
                                            style: OutlinedButton.styleFrom(primary: Colors.red),
                                            onPressed: _loading ? null : _onDeleteShoppingList,
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
