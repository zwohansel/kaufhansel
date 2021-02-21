import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kaufhansel_client/generated/l10n.dart';
import 'package:kaufhansel_client/model.dart';
import 'package:kaufhansel_client/rest_client.dart';
import 'package:kaufhansel_client/shopping_list_item_edit_dialog.dart';
import 'package:kaufhansel_client/shopping_list_mode.dart';
import 'package:kaufhansel_client/widgets/async_operation_icon_button.dart';
import 'package:provider/provider.dart';

class ShoppingListItemTile extends StatefulWidget {
  final bool _showUserCategory;
  final ShoppingListMode _mode;
  final bool _enabled;
  final bool _canEditItems;
  final bool _canCheckItems;

  const ShoppingListItemTile(
      {bool showUserCategory = false,
      ShoppingListMode mode = ShoppingListMode.DEFAULT,
      bool enabled = true,
      @required bool canEditItems,
      @required bool canCheckItems})
      : _showUserCategory = showUserCategory,
        _mode = mode,
        _enabled = enabled,
        _canEditItems = canEditItems,
        _canCheckItems = canCheckItems;

  @override
  _ShoppingListItemTileState createState() => _ShoppingListItemTileState();
}

class _ShoppingListItemTileState extends State<ShoppingListItemTile> {
  bool _loading = false;
  bool _deleting = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<ShoppingListItem>(builder: (context, item, child) {
      final List<Widget> titleElements = [
        Container(
          child: SelectableText(
            item.name,
            style: TextStyle(fontFamilyFallback: ['NotoColorEmoji']),
          ),
          margin: EdgeInsets.only(right: 10.0),
        )
      ];

      if (widget._showUserCategory && item.hasUserCategory()) {
        titleElements.add(Container(
          child: Text(item.category,
              style: Theme.of(context).textTheme.subtitle2.apply(fontSizeDelta: -1, color: Colors.white70)),
          padding: EdgeInsets.all(3.0),
          decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.all(Radius.circular(3))),
          //color: Colors.green,
        ));
      }

      if (widget._mode == ShoppingListMode.EDITING && widget._canEditItems) {
        return ListTile(
          title: Wrap(children: titleElements),
          trailing: _buildActionButton(item),
          onTap: () => widget._canEditItems ? _editItem(item) : null,
        );
      } else {
        if (widget._canCheckItems) {
          return buildCheckboxListTitle(titleElements, item);
        } else {
          return buildListTile(titleElements, item);
        }
      }
    });
  }

  CheckboxListTile buildCheckboxListTitle(List<Widget> titleElements, ShoppingListItem item) {
    return CheckboxListTile(
      title: Wrap(children: titleElements),
      controlAffinity: ListTileControlAffinity.leading,
      secondary: _buildActionButton(item),
      value: item.checked,
      onChanged: _allowInput() ? (checked) => _checkItem(item, checked) : null,
    );
  }

  ListTile buildListTile(List<Widget> titleElements, ShoppingListItem item) {
    return ListTile(
      title: Wrap(children: titleElements),
      leading: item.checked ? Icon(Icons.check_box_outlined) : Icon(Icons.check_box_outline_blank),
      trailing: _buildActionButton(item),
    );
  }

  bool _allowInput() {
    return widget._enabled && !_loading;
  }

  Widget _buildActionButton(ShoppingListItem item) {
    if (!widget._canEditItems) {
      return null;
    }

    switch (widget._mode) {
      case ShoppingListMode.EDITING:
        return AsyncOperationIconButton(
            icon: Icon(Icons.delete), loading: _deleting, onPressed: _allowInput() ? () => _deleteItem(item) : null);
      case ShoppingListMode.SHOPPING:
        return null;
      case ShoppingListMode.DEFAULT:
      default:
        return AsyncOperationIconButton(
            icon: Icon(Icons.edit), loading: false, onPressed: _allowInput() ? () => _editItem(item) : null);
    }
  }

  void _deleteItem(ShoppingListItem item) async {
    setState(() {
      _loading = true;
      _deleting = true;
    });
    try {
      final shoppingList = Provider.of<ShoppingList>(context, listen: false);
      await RestClientWidget.of(context).deleteShoppingListItem(shoppingList.id, item);
      shoppingList.removeItem(item);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context).exceptionDeleteItemFailed(item.name)),
          duration: Duration(seconds: 2)));
    } finally {
      setState(() {
        _loading = false;
        _deleting = false;
      });
    }
  }

  void _checkItem(ShoppingListItem item, bool checked) {
    // Checking and un-checking an item should be a fast and work under all circumstances (even if there is not internet connection)
    // Therefore we do not wait for the server reply and accept that the
    // checked state of an item may get out of sync with the state stored on the server.
    item.checked = checked;
    _performCheckItemRequest(item, checked);
  }

  void _performCheckItemRequest(ShoppingListItem item, bool checked) async {
    try {
      final shoppingList = Provider.of<ShoppingList>(context, listen: false);
      await RestClientWidget.of(context).updateShoppingListItem(shoppingList.id, item);
    } on Exception catch (e) {
      log("Could not check or uncheck item.", error: e);
    }
  }

  void _editItem(ShoppingListItem item) {
    final RestClient client = RestClientWidget.of(context);
    final shoppingList = Provider.of<ShoppingList>(context, listen: false);
    showDialog(
        context: context,
        builder: (context) {
          return EditShoppingListItemDialog(
            shoppingListId: shoppingList.id,
            item: item,
            categories: shoppingList.getUserCategories(),
            client: client,
          );
        });
  }
}
