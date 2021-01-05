import 'package:flutter/foundation.dart';
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
  static const _serverUrl = kDebugMode ? "https://localhost:8080" : "https://zwohansel.de/kaufhansel/";
  final _client = RestClient(Uri.parse(_serverUrl));
  bool _loggedIn = false;

  @override
  Widget build(BuildContext context) {
    final home = _loggedIn ? ShoppingListPageLoader() : LoginPage(loggedIn: () => setState(() => _loggedIn = true));
    return MaterialApp(
        title: 'Kaufhansel',
        theme: ThemeData(primarySwatch: Colors.green, fontFamily: 'Roboto'),
        home: RestClientWidget(client: _client, child: home));
  }
}
