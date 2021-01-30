import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kaufhansel_client/model.dart';
import 'package:kaufhansel_client/rest_client.dart';
import 'package:kaufhansel_client/widgets/editable_text_label.dart';

class EditShoppingListItemDialog extends StatefulWidget {
  final String _shoppingListId;
  final ShoppingListItem _item;
  final List<String> _categories;
  final RestClient _client;

  const EditShoppingListItemDialog(
      {@required ShoppingListItem item,
      @required String shoppingListId,
      @required RestClient client,
      @required List<String> categories})
      : _shoppingListId = shoppingListId,
        _item = item,
        _categories = categories,
        _client = client;

  @override
  _EditShoppingListItemDialogState createState() => _EditShoppingListItemDialogState();
}

class _EditShoppingListItemDialogState extends State<EditShoppingListItemDialog> {
  final TextEditingController _newCategoryEditingController = TextEditingController();
  final FocusNode _newCategoryEditionFocus = FocusNode();
  bool _newCategoryIsValid = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _newCategoryEditingController.addListener(() {
      setState(() {
        final category = _newCategoryEditingController.text.trim();
        _newCategoryIsValid = category != CATEGORY_ALL && category.isNotEmpty;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    const bottomMargin = 10.0;

    final title = Container(
      child: EditableTextLabel(
        text: widget._item.name,
        textStyle: theme.textTheme.headline6.apply(fontFamilyFallback: ['NotoColorEmoji']),
        onSubmit: (text) => submitNewItemName(text),
      ),
      margin: EdgeInsets.only(bottom: bottomMargin),
    );

    final subTitle = Container(
      child: Text(
        "Wähle eine Kategorie",
        style: theme.textTheme.subtitle2,
      ),
      margin: EdgeInsets.only(bottom: bottomMargin),
    );

    final categoryButtons = widget._categories.map((category) {
      final currentItemCategory = widget._item.category == category;
      final color = currentItemCategory ? Theme.of(context).accentColor : Theme.of(context).unselectedWidgetColor;
      return OutlinedButton(
          onPressed: () {
            setItemCategory(category);
            Navigator.pop(context);
          },
          child: Text(category),
          style: OutlinedButton.styleFrom(
              textStyle: TextStyle(color: color),
              primary: color,
              side: BorderSide(color: color, width: currentItemCategory ? 2.0 : 1.0)));
    }).toList();

    final dialogContent = Container(
        padding: EdgeInsets.all(10.0),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          title,
          subTitle,
          Flexible(
              child: Padding(
                  child: Scrollbar(
                      controller: _scrollController,
                      child: ListView(
                        shrinkWrap: true,
                        controller: _scrollController,
                        children: categoryButtons,
                      )),
                  padding: EdgeInsets.only(bottom: bottomMargin))),
          Container(
            child: OutlinedButton(
              onPressed: () {
                setItemCategory(null);
                Navigator.pop(context);
              },
              child: Text("Keine"),
              style: OutlinedButton.styleFrom(primary: Colors.orange, side: BorderSide(color: Colors.orange)),
            ),
            margin: EdgeInsets.only(bottom: bottomMargin),
          ),
          Container(
            child: TextField(
              controller: _newCategoryEditingController,
              focusNode: _newCategoryEditionFocus,
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: (_) => submitNewCategory(),
              decoration: InputDecoration(
                  labelText: "Neue Kategorie",
                  isDense: true,
                  border: OutlineInputBorder(),
                  suffixIcon:
                      IconButton(icon: Icon(Icons.check), onPressed: _newCategoryIsValid ? submitNewCategory : null)),
            ),
          ),
        ]));

    return Dialog(child: ConstrainedBox(constraints: BoxConstraints(maxWidth: 150), child: dialogContent));
  }

  Future<bool> submitNewItemName(String newItemName) async {
    // TODO: What if the following request fails?
    widget._item.name = newItemName;
    await widget._client.updateShoppingListItem(widget._shoppingListId, widget._item);
    return true;
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
    widget._item.category = category;
    await widget._client.updateShoppingListItem(widget._shoppingListId, widget._item);
  }
}
