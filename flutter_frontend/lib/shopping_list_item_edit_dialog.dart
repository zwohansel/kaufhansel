import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kaufhansel_client/model.dart';
import 'package:kaufhansel_client/rest_client.dart';
import 'package:kaufhansel_client/widgets/editable_text_label.dart';
import 'package:kaufhansel_client/widgets/error_dialog.dart';

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
  bool _loading = false;

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
  void dispose() {
    _newCategoryEditingController.dispose();
    _newCategoryEditionFocus.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    const bottomMargin = 10.0;

    final title = EditableTextLabel(
      text: widget._item.name,
      textStyle: theme.textTheme.headline6.apply(fontFamilyFallback: ['NotoColorEmoji']),
      onSubmit: (text) => submitNewItemName(text),
      enabled: !_loading,
    );

    final subTitle = Text(
      "Wähle eine Kategorie",
      style: theme.textTheme.subtitle2,
    );

    final categoryButtons = widget._categories.map((category) {
      final currentItemCategory = widget._item.category == category;
      final color = currentItemCategory ? Theme.of(context).accentColor : Theme.of(context).unselectedWidgetColor;
      return Padding(
        child: OutlinedButton(
            onPressed: !_loading ? () => setItemCategory(category) : null,
            child: Text(category),
            style: OutlinedButton.styleFrom(
                textStyle: TextStyle(color: color),
                primary: color,
                side: BorderSide(color: color, width: currentItemCategory ? 2.0 : 1.0))),
        padding: EdgeInsets.only(bottom: bottomMargin),
      );
    }).toList();

    final dialogContent = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(padding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 5), child: title),
        _buildProgress(),
        Padding(padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: bottomMargin), child: subTitle),
        Flexible(
          child: Padding(
            padding: EdgeInsets.only(left: 10, right: 10),
            child: Scrollbar(
                controller: _scrollController,
                child: ListView(
                  shrinkWrap: true,
                  controller: _scrollController,
                  children: categoryButtons,
                )),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 10, right: 10, bottom: bottomMargin),
          child: OutlinedButton(
            onPressed: !_loading ? () => setItemCategory(null) : null,
            child: Text("Keine"),
            style: OutlinedButton.styleFrom(primary: Colors.orange, side: BorderSide(color: Colors.orange)),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
          child: TextField(
            controller: _newCategoryEditingController,
            focusNode: _newCategoryEditionFocus,
            textCapitalization: TextCapitalization.sentences,
            onSubmitted: (_) => submitNewCategory(),
            enabled: !_loading,
            decoration: InputDecoration(
                labelText: "Neue Kategorie",
                isDense: true,
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                    icon: Icon(Icons.check), onPressed: !_loading && _newCategoryIsValid ? submitNewCategory : null)),
          ),
        ),
      ],
    );

    return Dialog(child: ConstrainedBox(constraints: BoxConstraints(maxWidth: 150), child: dialogContent));
  }

  Future<bool> submitNewItemName(String newItemName) async {
    try {
      await widget._client.updateShoppingListItem(widget._shoppingListId, widget._item);
      widget._item.name = newItemName;
      return true;
    } on Exception catch (e) {
      developer.log("Could not set item name.", error: e);
      showErrorDialog(context, "Findet der Server \"$newItemName\" doof oder hast du kein Internet?");
      return false;
    }
  }

  void submitNewCategory() async {
    if (_newCategoryIsValid) {
      final category = _newCategoryEditingController.text.trim();
      await setItemCategory(category);
    } else {
      _newCategoryEditionFocus.requestFocus();
    }
  }

  Future<void> setItemCategory(String category) async {
    if (category == widget._item.category) {
      Navigator.pop(context);
      return;
    }

    try {
      setState(() => _loading = true);
      await widget._client.updateShoppingListItem(widget._shoppingListId, widget._item);
      widget._item.category = category;
      Navigator.pop(context);
    } on Exception catch (e) {
      developer.log("Could not set item category.", error: e);
      showErrorDialog(context, "Das hat nicht funktioniert. Hast du vllt. kein Internet?");
    } finally {
      setState(() => _loading = false);
    }
  }

  Widget _buildProgress() {
    if (_loading) {
      return LinearProgressIndicator(minHeight: 5);
    }
    return SizedBox(height: 5);
  }
}
