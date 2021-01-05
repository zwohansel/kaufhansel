import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kaufhansel_client/model.dart';
import 'package:kaufhansel_client/rest_client.dart';
import 'package:kaufhansel_client/shopping_list_item_edit_dialog.dart';
import 'package:provider/provider.dart';

class ShoppingListItemTile extends StatelessWidget {
  final bool _showCategory;

  const ShoppingListItemTile(key, {bool showCategory = false})
      : _showCategory = showCategory,
        super(key: key);

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

      if (_showCategory && item.hasCategory()) {
        titleElements.add(Container(
          child: Text(item.category,
              style: Theme.of(context).textTheme.subtitle2.apply(fontSizeDelta: -1, color: Colors.white70)),
          padding: EdgeInsets.all(3.0),
          decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.all(Radius.circular(3))),
          //color: Colors.green,
        ));
      }

      return CheckboxListTile(
        title: Wrap(children: titleElements),
        controlAffinity: ListTileControlAffinity.leading,
        secondary: Wrap(children: [
          IconButton(icon: Icon(Icons.delete), onPressed: () => this.deleteItem(item, context)),
          IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                final RestClient client = RestClientWidget.of(context);
                final shoppingList = Provider.of<ShoppingListModel>(context);
                showDialog(
                    context: context,
                    builder: (context) {
                      return EditShoppingListItemDialog(
                        shoppingListId: shoppingList.id,
                        item: item,
                        categories: shoppingList.getCategories(),
                        client: client,
                      );
                    });
              })
        ]),
        value: item.checked,
        onChanged: (checked) => this.checkItem(item, checked, context),
      );
    });
  }

  void deleteItem(ShoppingListItem item, BuildContext context) async {
    final shoppingList = Provider.of<ShoppingListModel>(context, listen: false);
    await RestClientWidget.of(context).deleteShoppingListItem(shoppingList.id, item);
    shoppingList.removeItem(item);
  }

  checkItem(ShoppingListItem item, bool checked, BuildContext context) async {
    item.checked = checked; // TODO: What if the following request fails?
    final shoppingList = Provider.of<ShoppingListModel>(context, listen: false);
    await RestClientWidget.of(context).updateShoppingListItem(shoppingList.id, item);
  }
}
