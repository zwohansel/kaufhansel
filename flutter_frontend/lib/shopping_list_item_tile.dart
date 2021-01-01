import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kaufhansel_client/model.dart';
import 'package:kaufhansel_client/rest_client.dart';
import 'package:kaufhansel_client/shopping_list_item_edit_dialog.dart';
import 'package:provider/provider.dart';

class ShoppingListItemTile extends StatelessWidget {
  final String shoppingListId;

  const ShoppingListItemTile({@required this.shoppingListId});

  @override
  Widget build(BuildContext context) {
    return Consumer<ShoppingListItem>(builder: (context, item, child) {
      return CheckboxListTile(
        title: SelectableText(
          item.name,
          style: TextStyle(fontFamilyFallback: ['NotoColorEmoji']),
        ),
        controlAffinity: ListTileControlAffinity.leading,
        secondary: Wrap(children: [
          IconButton(icon: Icon(Icons.delete), onPressed: () => this.deleteItem(item, context)),
          IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return EditShoppingListItemDialog(
                        item: item,
                      );
                    });
              })
        ]),
        value: item.checked,
        onChanged: (checked) => item.checked = checked,
      );
    });
  }

  void deleteItem(ShoppingListItem item, BuildContext context) async {
    await RestClientWidget.of(context).deleteShoppingListItem(shoppingListId, item.id);
    Provider.of<ShoppingListModel>(context, listen: false).removeItem(item);
  }
}
