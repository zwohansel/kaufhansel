import 'package:flutter/material.dart';
import 'package:kaufhansel_client/model.dart';

class DeleteShoppingListDialog extends StatelessWidget {
  final ShoppingListInfo _info;
  final VoidCallback _onDeleteShoppingList;

  const DeleteShoppingListDialog(this._info, this._onDeleteShoppingList);

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(title: Text("Achtung!"), children: [
      Padding(
          padding: EdgeInsets.only(left: 24, right: 24, top: 12),
          child: Column(
            children: [
              Text("Möchtest du ${_info.name} wirklich für immer und unwiederbringlich löschen?"),
              SizedBox(height: 20),
              Flex(
                direction: Axis.horizontal,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: OutlineButton(child: Text("Abbrechen"), onPressed: () => Navigator.pop(context))),
                  SizedBox(width: 10),
                  Expanded(
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(primary: Colors.red),
                          onPressed: () {
                            _onDeleteShoppingList();
                            Navigator.pop(context);
                          },
                          child: Text("Löschen")))
                ],
              )
            ],
          ))
    ]);
  }
}
