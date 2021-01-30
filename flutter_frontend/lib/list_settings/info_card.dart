import 'package:flutter/material.dart';

import '../confirm_dialog.dart';
import '../error_dialog.dart';
import '../model.dart';

class InfoCard extends StatefulWidget {
  final ShoppingListInfo _shoppingListInfo;
  final void Function(bool) _setLoading;
  final bool _loading;

  final Future<void> Function() _onUncheckAllItems;
  final Future<void> Function() _onRemoveAllCategories;
  final Future<void> Function() _onRemoveAllItems;
  final Future<void> Function(String) _onChangeShoppingListName;

  const InfoCard(this._shoppingListInfo, this._loading, this._setLoading,
      {@required Future<void> Function() onUncheckAllItems,
      @required Future<void> Function() onRemoveAllCategories,
      @required Future<void> Function() onRemoveAllItems,
      @required Future<void> Function(String) onChangeShoppingListName})
      : _onUncheckAllItems = onUncheckAllItems,
        _onRemoveAllCategories = onRemoveAllCategories,
        _onRemoveAllItems = onRemoveAllItems,
        _onChangeShoppingListName = onChangeShoppingListName;

  @override
  _InfoCardState createState() => _InfoCardState();
}

class _InfoCardState extends State<InfoCard> {
  final _shoppingListNameEditingController = new TextEditingController();
  final _shoppingListNameEditingFocus = new FocusNode();
  bool _editingShoppingListName = false;
  bool _newShoppingListNameIsValid = false;

  @override
  void initState() {
    super.initState();
    _shoppingListNameEditingController.addListener(() {
      setState(() => _newShoppingListNameIsValid = _shoppingListNameEditingController.text.trim().isNotEmpty);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
          padding: EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              buildListName(context),
              SizedBox(height: 12),
              OutlinedButton(
                onPressed: widget._loading ? null : _onUncheckAllItemsPressed,
                child: Text("Alle Häckchen entfernen"),
              ),
              SizedBox(height: 6),
              OutlinedButton(
                onPressed: widget._loading ? null : _onRemoveAllCategoriesPressed,
                child: Text("Alle Kategorien entfernen"),
              ),
              SizedBox(height: 6),
              OutlinedButton(
                onPressed: widget._loading ? null : _onRemoveAllItemsPressed,
                child: Text("Liste leeren"),
              ),
            ],
          )),
    );
  }

  Row buildListName(BuildContext context) {
    if (_editingShoppingListName) {
      return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Flexible(
            child: TextField(
          controller: _shoppingListNameEditingController,
          textCapitalization: TextCapitalization.sentences,
          style: Theme.of(context).textTheme.headline5.apply(fontFamilyFallback: ['NotoColorEmoji']),
          focusNode: _shoppingListNameEditingFocus,
          onSubmitted: (_) => _submitNewShoppingListName(),
          decoration: InputDecoration(
              suffixIcon: IconButton(
            icon: Icon(Icons.check),
            onPressed: _newShoppingListNameIsValid ? _submitNewShoppingListName : null,
          )),
        )),
      ]);
    } else {
      return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Flexible(
            child: Text(
          widget._shoppingListInfo.name,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.headline5,
        )),
        IconButton(
            icon: Icon(Icons.drive_file_rename_outline),
            onPressed: widget._loading
                ? null
                : () => setState(() {
                      _shoppingListNameEditingController.text = widget._shoppingListInfo.name;
                      _shoppingListNameEditingController.selection =
                          TextSelection(baseOffset: 0, extentOffset: widget._shoppingListInfo.name.length);
                      _newShoppingListNameIsValid = true;
                      _editingShoppingListName = true;
                      _shoppingListNameEditingFocus.requestFocus();
                    }))
      ]);
    }
  }

  void _onUncheckAllItemsPressed() async {
    widget._setLoading(true);
    try {
      await widget._onUncheckAllItems();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Alle Häckchen in ${widget._shoppingListInfo.name} wurden entfernt."),
          duration: Duration(seconds: 1)));
    } catch (e) {
      showErrorDialog(context, "Ist der Server zu faul oder hast du kein Internet?");
    } finally {
      widget._setLoading(false);
    }
  }

  void _onRemoveAllCategoriesPressed() async {
    widget._setLoading(true);
    try {
      await widget._onRemoveAllCategories();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Alle Kategorien in ${widget._shoppingListInfo.name} wurden entfernt."),
          duration: Duration(seconds: 1)));
    } catch (e) {
      showErrorDialog(context, "Hat der Server keine Lust oder hast du kein Internet?");
    } finally {
      widget._setLoading(false);
    }
    widget._setLoading(false);
  }

  void _onRemoveAllItemsPressed() async {
    widget._setLoading(true);
    try {
      final removeItems = await showConfirmDialog(context,
          "Möchtest du wirklich alle Elemente aus ${widget._shoppingListInfo.name} unwiederbringlich entfernen?");
      if (removeItems) {
        await widget._onRemoveAllItems();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Alle Elemente in ${widget._shoppingListInfo.name} wurden entfernt."),
            duration: Duration(seconds: 1)));
      }
    } catch (e) {
      showErrorDialog(context, "Schläft der Server noch oder hast du kein Internet?");
    } finally {
      widget._setLoading(false);
    }
  }

  void _submitNewShoppingListName() async {
    if (_newShoppingListNameIsValid) {
      widget._setLoading(true);
      final newName = _shoppingListNameEditingController.text.trim();
      if (newName == widget._shoppingListInfo.name) {
        return;
      }
      try {
        await widget._onChangeShoppingListName(newName);
      } catch (e) {
        showErrorDialog(context, "Hast du dich vertippt oder schläft der Server noch?");
      } finally {
        widget._setLoading(false);
        setState(() {
          _editingShoppingListName = false;
        });
      }
    } else {
      _shoppingListNameEditingFocus.requestFocus();
    }
  }
}
