import 'package:flutter/material.dart';
import 'package:kaufhansel_client/rest_client.dart';
import 'package:kaufhansel_client/shopping_list_page_loader.dart';

void main() {
  runApp(ShoppingListApp());
}

class ShoppingListApp extends StatelessWidget {
  final client = RestClient(Uri.parse("https://localhost:8080/shoppinglist/"));
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kaufhansel',
      theme: ThemeData(primarySwatch: Colors.green, fontFamily: 'Roboto'),
      home: RestClientWidget(client: client, child: ShoppingListPageLoader(shoppingListId: "5f0a01054ccfbf87d8c754f4")),
    );
  }
}
