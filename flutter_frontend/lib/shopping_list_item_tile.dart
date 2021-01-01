import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kaufhansel_client/model.dart';
import 'package:kaufhansel_client/rest_client.dart';
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
                      return Dialog(
                          child: Column(
                        children: [
                          Row(children: [
                            Expanded(child: Text(item.name)),
                            IconButton(icon: Icon(Icons.drive_file_rename_outline), onPressed: () {})
                          ]),
                          Container(
                            child: Text(
                              "Wählstu oder sagstu!",
                              style: TextStyle(color: Colors.grey),
                            ),
                            margin: EdgeInsets.only(left: 12.0, right: 12.0),
                          ),
                          Divider(),
                          Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Container(
                                  child: OutlineButton(onPressed: () {}, child: Text("nächster")),
                                  margin: EdgeInsets.only(bottom: 5),
                                ),
                                TextField(
                                  decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding: EdgeInsets.fromLTRB(12, 8, 12, 8),
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ],
                            ),
                            margin: EdgeInsets.only(left: 12.0, right: 12.0),
                          ),
                          Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              OutlineButton(onPressed: () {}, child: Text("Egal")),
                              OutlineButton(
                                onPressed: () {},
                                child: Text("Niemand"),
                                textColor: Theme.of(context).accentColor,
                                borderSide: BorderSide(color: Theme.of(context).accentColor),
                              ),
                              ElevatedButton(onPressed: () {}, child: Text("Zuweisen"))
                            ],
                          )
                        ],
                      ));
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
