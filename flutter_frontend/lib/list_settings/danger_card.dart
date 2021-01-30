import 'package:flutter/material.dart';

import '../confirm_dialog.dart';
import '../error_dialog.dart';

class DangerCard extends StatelessWidget {
  final void Function(bool) _setLoading;
  final bool _loading;

  final String _shoppingListName;
  final Future<void> Function() _deleteShoppingList;

  const DangerCard(this._loading, this._setLoading,
      {@required String shoppingListName, @required Future<void> Function() deleteShoppingList})
      : _deleteShoppingList = deleteShoppingList,
        _shoppingListName = shoppingListName;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
          padding: EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Gefahrenzone",
                style: Theme.of(context).textTheme.headline6,
              ),
              SizedBox(height: 12),
              OutlinedButton(
                child: Text("Liste löschen..."),
                style: OutlinedButton.styleFrom(primary: Colors.red),
                onPressed: () => _loading ? null : _onDeleteShoppingList(context),
              ),
              SizedBox(height: 12),
              OutlinedButton(
                  child: Text("Liste übertragen..."),
                  style: OutlinedButton.styleFrom(primary: Colors.red),
                  onPressed: null)
            ],
          )),
    );
  }

  void _onDeleteShoppingList(BuildContext context) async {
    _setLoading(true);
    try {
      final deleteList = await showConfirmDialog(
          context, "Möchtest du $_shoppingListName wirklich für immer und unwiederbringlich löschen?");
      if (deleteList) {
        await _deleteShoppingList();
        Navigator.pop(context);
      }
    } catch (e) {
      showErrorDialog(context, "Kann die Liste nicht gelöscht werden oder hast du kein Internet?");
    } finally {
      _setLoading(false);
    }
  }
}
