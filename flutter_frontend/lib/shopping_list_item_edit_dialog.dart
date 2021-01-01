import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kaufhansel_client/model.dart';
import 'package:kaufhansel_client/rest_client.dart';

class EditShoppingListItemDialog extends StatefulWidget {
  final String shoppingListId;
  final ShoppingListItem item;
  final RestClient client;

  const EditShoppingListItemDialog({@required this.item, @required this.shoppingListId, @required this.client});

  @override
  _EditShoppingListItemDialogState createState() => _EditShoppingListItemDialogState();
}

class _EditShoppingListItemDialogState extends State<EditShoppingListItemDialog> {
  final TextEditingController _itemNameEditingController = TextEditingController();
  final FocusNode _focus = FocusNode();
  bool _editingItemName = false;
  bool _newItemNameIsValid = false;

  @override
  void initState() {
    super.initState();
    _itemNameEditingController.addListener(() {
      setState(() => _newItemNameIsValid = _itemNameEditingController.text.trim().isNotEmpty);
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    const bottomMargin = 10.0;

    final title = Container(
      child: buildTitle(theme),
      margin: EdgeInsets.only(bottom: bottomMargin),
    );

    final subTitle = Container(
      child: Text(
        "Wähle eine Kategorie",
        style: theme.textTheme.subtitle2,
      ),
      margin: EdgeInsets.only(bottom: bottomMargin),
    );

    final dialogContent = Container(
        padding: EdgeInsets.all(10.0),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          title,
          subTitle,
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  child: OutlineButton(
                      onPressed: () {},
                      child: Text("nächster"),
                      textColor: Theme.of(context).accentColor,
                      borderSide: BorderSide(color: Theme.of(context).accentColor)),
                  margin: EdgeInsets.only(bottom: bottomMargin),
                ),
                Container(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: "Neue Kategorie",
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                    ),
                    margin: EdgeInsets.only(bottom: bottomMargin)),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlineButton(onPressed: () => Navigator.pop(context), child: Text("Egal")),
              OutlineButton(
                onPressed: () {},
                child: Text("Keine"),
                textColor: Theme.of(context).accentColor,
                borderSide: BorderSide(color: Theme.of(context).accentColor),
              ),
              ElevatedButton(onPressed: () {}, child: Text("Zuweisen"))
            ],
          )
        ]));

    return Dialog(child: IntrinsicWidth(child: dialogContent));
  }

  Widget buildTitle(ThemeData theme) {
    final textStyle = theme.textTheme.headline6.apply(fontFamilyFallback: ['NotoColorEmoji']);
    if (_editingItemName) {
      return Row(children: [
        Expanded(
            child: TextField(
          controller: _itemNameEditingController,
          style: textStyle,
          onSubmitted: (_) => this.submitNewItemName(),
          focusNode: _focus,
          decoration: InputDecoration(
              suffixIcon:
                  IconButton(icon: Icon(Icons.check), onPressed: _newItemNameIsValid ? this.submitNewItemName : null)),
        )),
      ]);
    }
    return Row(children: [
      Expanded(
          child: Text(
        widget.item.name,
        style: textStyle,
      )),
      IconButton(
          icon: Icon(Icons.drive_file_rename_outline),
          onPressed: () {
            setState(() {
              _itemNameEditingController.text = widget.item.name;
              _itemNameEditingController.selection =
                  TextSelection(baseOffset: 0, extentOffset: widget.item.name.length);
              _editingItemName = true;
              _newItemNameIsValid = true;
              _focus.requestFocus();
            });
          })
    ]);
  }

  void submitNewItemName() async {
    if (_newItemNameIsValid) {
      // TODO: What if the following request fails?
      widget.item.name = _itemNameEditingController.text.trim();
      await widget.client.updateShoppingListItem(widget.shoppingListId, widget.item);
      setState(() {
        _editingItemName = false;
      });
    } else {
      _focus.requestFocus();
    }
  }
}
