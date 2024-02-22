import 'dart:developer';

import 'package:animated_list_plus/animated_list_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kaufhansel_client/generated/l10n.dart';
import 'package:kaufhansel_client/shopping_list_item_edit_dialog.dart';
import 'package:kaufhansel_client/shopping_list_mode.dart';
import 'package:kaufhansel_client/synced_shoppinglist.dart';
import 'package:kaufhansel_client/widgets/async_operation_icon_button.dart';
import 'package:kaufhansel_client/widgets/error_dialog.dart';
import 'package:provider/provider.dart';

class ShoppingListItemTile extends StatefulWidget {
  final bool _showUserCategory;
  final ShoppingListModeOption _mode;
  final bool _enabled;
  final bool _canEditItems;
  final bool _canCheckItems;

  const ShoppingListItemTile(
      {bool showUserCategory = false,
      ShoppingListModeOption mode = ShoppingListModeOption.DEFAULT,
      bool enabled = true,
      required bool canEditItems,
      required bool canCheckItems})
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
    return Consumer<SyncedShoppingListItem>(builder: (context, item, child) {
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
          child: Text(item.category ?? "",
              style: Theme.of(context).textTheme.titleSmall?.apply(fontSizeDelta: -1, color: Colors.white70)),
          padding: EdgeInsets.all(3.0),
          decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.all(Radius.circular(3))),
          //color: Colors.green,
        ));
      }

      if (widget._mode == ShoppingListModeOption.EDITING && widget._canEditItems) {
        return ListTile(
          title: Wrap(children: titleElements),
          trailing: _buildActionButton(item),
          enabled: _allowInput(),
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

  CheckboxListTile buildCheckboxListTitle(List<Widget> titleElements, SyncedShoppingListItem item) {
    return CheckboxListTile(
      title: Wrap(children: titleElements),
      controlAffinity: ListTileControlAffinity.leading,
      secondary: _buildActionButton(item),
      value: item.checked,
      onChanged: _allowInput() ? (checked) => _checkItem(item, checked ?? false) : null,
    );
  }

  ListTile buildListTile(List<Widget> titleElements, SyncedShoppingListItem item) {
    return ListTile(
      title: Wrap(children: titleElements),
      leading: item.checked ? Icon(Icons.check_box_outlined) : Icon(Icons.check_box_outline_blank),
      trailing: _buildActionButton(item),
    );
  }

  bool _allowInput() {
    return widget._enabled && !_loading;
  }

  Widget? _buildActionButton(SyncedShoppingListItem item) {
    if (!widget._canEditItems) {
      return null;
    }

    switch (widget._mode) {
      case ShoppingListModeOption.EDITING:
        return Wrap(
          children: [
            AsyncOperationIconButton(
              icon: Icon(Icons.delete),
              loading: _deleting,
              onPressed: _allowInput() ? () => _deleteItem(item) : null,
            ),
            SizedBox(width: 5),
            Handle(child: SizedBox(width: 48, height: 48, child: Center(child: Icon(Icons.drag_handle))))
          ],
        );
      case ShoppingListModeOption.SHOPPING:
        return null;
      case ShoppingListModeOption.DEFAULT:
      default:
        return AsyncOperationIconButton(
            icon: Icon(Icons.edit), loading: false, onPressed: _allowInput() ? () => _editItem(item) : null);
    }
  }

  void _deleteItem(SyncedShoppingListItem item) async {
    setState(() {
      _loading = true;
      _deleting = true;
    });
    try {
      await item.delete();
    } on Exception catch (e) {
      log("Could not remove item", error: e);
      showErrorDialogForException(context, e,
          altText: AppLocalizations.of(context).exceptionDeleteItemFailed(item.name));
    } finally {
      setState(() {
        _loading = false;
        _deleting = false;
      });
    }
  }

  void _checkItem(SyncedShoppingListItem item, bool checked) async {
    try {
      await item.setChecked(checked);
    } on Exception catch (e) {
      log("Could not check or uncheck item.", error: e);
    }
  }

  void _editItem(SyncedShoppingListItem item) {
    final shoppingList = Provider.of<SyncedShoppingList>(context, listen: false);
    showDialog(
        context: context,
        builder: (context) {
          return EditShoppingListItemDialog(
            item: item,
            categories: shoppingList.getUserCategories(),
          );
        });
  }
}
