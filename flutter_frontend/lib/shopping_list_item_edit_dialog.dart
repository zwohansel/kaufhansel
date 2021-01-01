import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kaufhansel_client/model.dart';

class EditShoppingListItemDialog extends StatelessWidget {
  final ShoppingListItem item;

  const EditShoppingListItemDialog({@required this.item});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    const bottomMargin = 10.0;

    final title = Container(
      child: Row(children: [
        Expanded(
            child: Text(
          item.name,
          style: theme.textTheme.headline6,
        )),
        IconButton(icon: Icon(Icons.drive_file_rename_outline), onPressed: () {})
      ]),
      margin: EdgeInsets.only(bottom: bottomMargin),
    );

    var subTitle = Container(
      child: Text(
        "Wähle eine Kategorie",
        style: theme.textTheme.subtitle2,
      ),
      margin: EdgeInsets.only(bottom: bottomMargin),
    );

    final dialogContent = Container(
        padding: EdgeInsets.all(10.0),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          title,
          subTitle,
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  child: OutlineButton(
                      onPressed: () {},
                      child: Text("nächster"),
                      textColor: Theme.of(context).accentColor,
                      borderSide: BorderSide(color: Theme.of(context).accentColor)),
                  margin: EdgeInsets.only(bottom: bottomMargin),
                ),
                Container(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: "Neue Kategorie",
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                    ),
                    margin: EdgeInsets.only(bottom: bottomMargin)),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlineButton(onPressed: () {}, child: Text("Egal")),
              OutlineButton(
                onPressed: () {},
                child: Text("Keine"),
                textColor: Theme.of(context).accentColor,
                borderSide: BorderSide(color: Theme.of(context).accentColor),
              ),
              ElevatedButton(onPressed: () {}, child: Text("Zuweisen"))
            ],
          )
        ]));

    return Dialog(child: IntrinsicWidth(child: dialogContent));
  }
}
