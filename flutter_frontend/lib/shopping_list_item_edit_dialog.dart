import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kaufhansel_client/model.dart';
import 'package:kaufhansel_client/rest_client.dart';

class EditShoppingListItemDialog extends StatefulWidget {
  final String shoppingListId;
  final ShoppingListItem item;
  final List<String> categories;
  final RestClient client;

  const EditShoppingListItemDialog(
      {@required this.item, @required this.shoppingListId, @required this.client, @required this.categories});

  @override
  _EditShoppingListItemDialogState createState() => _EditShoppingListItemDialogState();
}

class _EditShoppingListItemDialogState extends State<EditShoppingListItemDialog> {
  final TextEditingController _itemNameEditingController = TextEditingController();
  final TextEditingController _newCategoryEditingController = TextEditingController();
  final FocusNode _itemNameEditingFocus = FocusNode();
  final FocusNode _newCategoryEditionFocus = FocusNode();
  bool _editingItemName = false;
  bool _newItemNameIsValid = false;
  bool _newCategoryIsValid = false;

  @override
  void initState() {
    super.initState();
    _itemNameEditingController.addListener(() {
      setState(() => _newItemNameIsValid = _itemNameEditingController.text.trim().isNotEmpty);
    });
    _newCategoryEditingController.addListener(() {
      setState(() => _newCategoryIsValid = _newCategoryEditingController.text.trim().isNotEmpty);
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

    final categoryButtons = widget.categories.map((category) {
      final currentItemCategory = widget.item.category == category;
      final color = currentItemCategory ? Theme.of(context).accentColor : Theme.of(context).unselectedWidgetColor;
      return Container(
        child: OutlineButton(
            onPressed: () {
              setItemCategory(category);
              Navigator.pop(context);
            },
            child: Text(category),
            textColor: color,
            highlightedBorderColor: color,
            borderSide: BorderSide(color: color, width: currentItemCategory ? 2.0 : 1.0)),
        margin: EdgeInsets.only(bottom: bottomMargin),
      );
    });

    final dialogContent = Container(
        padding: EdgeInsets.all(10.0),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          title,
          subTitle,
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ...categoryButtons,
                Container(
                    child: OutlineButton(
                      onPressed: () {
                        setItemCategory(null);
                        Navigator.pop(context);
                      },
                      child: Text("Keine"),
                      textColor: Colors.orange,
                      highlightedBorderColor: Colors.orange,
                      borderSide: BorderSide(color: Colors.orange),
                    ),
                    margin: EdgeInsets.only(bottom: bottomMargin)),
                Container(
                  child: TextField(
                    controller: _newCategoryEditingController,
                    focusNode: _newCategoryEditionFocus,
                    onSubmitted: (_) => submitNewCategory(),
                    decoration: InputDecoration(
                        labelText: "Neue Kategorie",
                        isDense: true,
                        border: OutlineInputBorder(),
                        suffixIcon: IconButton(
                            icon: Icon(Icons.check), onPressed: _newCategoryIsValid ? submitNewCategory : null)),
                  ),
                ),
              ],
            ),
          ),
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
          focusNode: _itemNameEditingFocus,
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
              _itemNameEditingFocus.requestFocus();
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
      _itemNameEditingFocus.requestFocus();
    }
  }

  void submitNewCategory() async {
    if (_newCategoryIsValid) {
      final category = _newCategoryEditingController.text.trim();
      setItemCategory(category);
      Navigator.pop(context);
    } else {
      _newCategoryEditionFocus.requestFocus();
    }
  }

  void setItemCategory(String category) async {
    // TODO: What if the following request fails?
    widget.item.category = category;
    await widget.client.updateShoppingListItem(widget.shoppingListId, widget.item);
  }
}
