import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kaufhansel_client/model.dart';
import 'package:kaufhansel_client/rest_client.dart';
import 'package:kaufhansel_client/shopping_list_page.dart';
import 'package:provider/provider.dart';

class ShoppingListPageLoader extends StatefulWidget {
  final String shoppingListId;

  const ShoppingListPageLoader({@required this.shoppingListId});

  @override
  State<StatefulWidget> createState() => _ShoppingListPageLoaderState();
}

class _ShoppingListPageLoaderState extends State<ShoppingListPageLoader> {
  Future<List<ShoppingListItem>> _futureShoppingList;

  @override
  void didChangeDependencies() {
    // Called after initState.
    // Unlike initState this method is called again if the RestClientWidget is exchanged.
    super.didChangeDependencies();
    _futureShoppingList = RestClientWidget.of(context).fetchShoppingList(widget.shoppingListId);
  }

  @override
  Widget build(BuildContext context) {
    const String title = "Kaufhansel";
    return FutureBuilder<List<ShoppingListItem>>(
      future: _futureShoppingList,
      builder: (context, shoppingList) {
        if (shoppingList.hasData) {
          return ChangeNotifierProvider(
              create: (context) => ShoppingListModel(widget.shoppingListId, shoppingList.data),
              child: ShoppingListPage(title: title));
        } else if (shoppingList.hasError) {
          return Text("ERROR: ${shoppingList.error}");
        }
        return Scaffold(
            appBar: AppBar(
              title: Text(title),
            ),
            body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
