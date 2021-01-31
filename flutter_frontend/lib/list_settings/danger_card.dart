import 'package:flutter/material.dart';
import 'package:kaufhansel_client/model.dart';

import '../widgets/confirm_dialog.dart';
import '../widgets/error_dialog.dart';
import 'card_style.dart';

class DangerCard extends StatelessWidget {
  final void Function(bool) _setLoading;
  final bool _loading;

  final ShoppingListInfo _shoppingListInfo;
  final Future<void> Function() _deleteShoppingList;

  const DangerCard(this._loading, this._setLoading,
      {@required ShoppingListInfo shoppingListInfo, @required Future<void> Function() deleteShoppingList})
      : _deleteShoppingList = deleteShoppingList,
        _shoppingListInfo = shoppingListInfo;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
          padding: EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Gefahrenzone", style: getCardHeadlineStyle(context)),
              SizedBox(height: 12),
              OutlinedButton(
                child: Text(_canDeleteList() ? "Liste löschen..." : "Liste verlassen..."),
                style: OutlinedButton.styleFrom(primary: Colors.red),
                onPressed: () => _loading ? null : _onDeleteShoppingList(context),
              ),
              _buildDeleteLeaveBtnExplanation(context),
            ],
          )),
    );
  }

  bool _canDeleteList() {
    // The user can delete the list if he is the only ADMIN
    return _shoppingListInfo.permissions.role == ShoppingListRole.ADMIN &&
        !_shoppingListInfo.users.any((element) => element.userRole == ShoppingListRole.ADMIN);
  }

  Widget _buildDeleteLeaveBtnExplanation(BuildContext context) {
    String explanation;
    if (_canDeleteList() && _shoppingListInfo.users.length > 0) {
      explanation =
          "Du bist der einzige ${ShoppingListRole.ADMIN.toDisplayString()} der Liste. Wenn du die Liste löschst, können auch die anderen Hansel mit denen du die Liste teilst nicht mehr darauf zugreifen.";
    } else if (_shoppingListInfo.permissions.role == ShoppingListRole.ADMIN && !_canDeleteList()) {
      explanation =
          "Es gibt noch andere ${ShoppingListRole.ADMIN.toDisplayString()} in der Liste, daher kannst du sie nicht löschen. Wenn du die Liste verlässt, können die anderen Hansel weiterhin darauf zugreifen.";
    }

    if (explanation != null) {
      return Padding(padding: EdgeInsets.only(top: 12), child: Text(explanation, style: getCardSubtitleStyle(context)));
    }
    return Container();
  }

  void _onDeleteShoppingList(BuildContext context) async {
    _setLoading(true);
    try {
      final deleteList = await showConfirmDialog(
          context, "Möchtest du ${_shoppingListInfo.name} wirklich für immer und unwiederbringlich löschen?");
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
