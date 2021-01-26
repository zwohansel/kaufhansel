import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kaufhansel_client/async_operation_icon_button.dart';
import 'package:kaufhansel_client/model.dart';
import 'package:kaufhansel_client/rest_client.dart';
import 'package:kaufhansel_client/shopping_list_item_edit_dialog.dart';
import 'package:kaufhansel_client/shopping_list_mode.dart';
import 'package:provider/provider.dart';

class ShoppingListItemTile extends StatefulWidget {
  final bool _showUserCategory;
  final ShoppingListMode _mode;

  const ShoppingListItemTile({bool showUserCategory = false, ShoppingListMode mode = ShoppingListMode.DEFAULT})
      : _showUserCategory = showUserCategory,
        _mode = mode;

  @override
  _ShoppingListItemTileState createState() => _ShoppingListItemTileState();
}

class _ShoppingListItemTileState extends State<ShoppingListItemTile> {
  bool _enabled = true;
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

      if (widget._mode == ShoppingListMode.EDITING) {
        return ListTile(title: Wrap(children: titleElements), trailing: _buildAction(item, context));
      } else {
        return CheckboxListTile(
          title: Wrap(children: titleElements),
          controlAffinity: ListTileControlAffinity.leading,
          secondary: _buildAction(item, context),
          value: item.checked,
          onChanged: _enabled ? (checked) => _handleCheckItemPressed(item, checked, context) : null,
        );
      }
    });
  }

  Widget _buildAction(ShoppingListItem item, BuildContext context) {
    switch (widget._mode) {
      case ShoppingListMode.EDITING:
        return AsyncOperationIconButton(
            icon: Icon(Icons.delete),
            loading: _deleting,
            onPressed: _enabled ? () => _handleDeleteItemPressed(item, context) : null);
      case ShoppingListMode.SHOPPING:
        return null;
      case ShoppingListMode.DEFAULT:
      default:
        return AsyncOperationIconButton(
            icon: Icon(Icons.edit),
            loading: false,
            onPressed: _enabled ? () => _handleEditItemPressed(item, context) : null);
    }
  }

  void _handleDeleteItemPressed(ShoppingListItem item, BuildContext context) {
    setState(() {
      _enabled = false;
      _deleting = true;
    });
    _deleteItem(item, context).whenComplete(() => setState(() {
          _enabled = true;
          _deleting = false;
        }));
  }

  Future<void> _deleteItem(ShoppingListItem item, BuildContext context) async {
    final shoppingList = Provider.of<ShoppingList>(context, listen: false);
    await RestClientWidget.of(context).deleteShoppingListItem(shoppingList.id, item);
    shoppingList.removeItem(item);
  }

  void _handleCheckItemPressed(ShoppingListItem item, bool checked, BuildContext context) {
    setState(() => _enabled = false);
    _checkItem(item, checked, context).whenComplete(() => setState(() => _enabled = true));
  }

  Future<void> _checkItem(ShoppingListItem item, bool checked, BuildContext context) async {
    item.checked = checked; // TODO: What if the following request fails?
    final shoppingList = Provider.of<ShoppingList>(context, listen: false);
    await RestClientWidget.of(context).updateShoppingListItem(shoppingList.id, item);
  }

  void _handleEditItemPressed(ShoppingListItem item, BuildContext context) {
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
