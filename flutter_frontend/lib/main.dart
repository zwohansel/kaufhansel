import 'package:flutter/material.dart';
import 'package:kaufhansel_client/login_page.dart';
import 'package:kaufhansel_client/rest_client.dart';
import 'package:kaufhansel_client/shopping_list_page_loader.dart';

void main() {
  runApp(ShoppingListApp());
}

class ShoppingListApp extends StatefulWidget {
  @override
  _ShoppingListAppState createState() => _ShoppingListAppState();
}

class _ShoppingListAppState extends State<ShoppingListApp> {
  final client = RestClient(Uri.parse("https://192.168.188.60:8080"));
  bool _loggedIn = false;

  @override
  Widget build(BuildContext context) {
    final home = _loggedIn ? ShoppingListPageLoader() : LoginPage(loggedIn: () => setState(() => _loggedIn = true));
    return MaterialApp(
        title: 'Kaufhansel',
        theme: ThemeData(primarySwatch: Colors.green, fontFamily: 'Roboto'),
        home: RestClientWidget(client: client, child: home));
  }
}
