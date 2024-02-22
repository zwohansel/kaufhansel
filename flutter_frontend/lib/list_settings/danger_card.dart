import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:kaufhansel_client/generated/l10n.dart';
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
      {required ShoppingListInfo shoppingListInfo, required Future<void> Function() deleteShoppingList})
      : _deleteShoppingList = deleteShoppingList,
        _shoppingListInfo = shoppingListInfo;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(AppLocalizations.of(context).listSettingsDangerZoneTitle, style: getCardHeadlineStyle(context)),
            SizedBox(height: 12),
            OutlinedButton(
              child: Text(_willDeleteList()
                  ? AppLocalizations.of(context).listSettingsDeleteList
                  : AppLocalizations.of(context).listSettingsLeaveList),
              style: OutlinedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => _loading ? null : _onDeleteShoppingList(context),
            ),
            _buildDeleteLeaveBtnExplanation(context),
          ],
        ),
      ),
    );
  }

  bool _willDeleteList() {
    // The user will delete the list if he is the only ADMIN
    return _shoppingListInfo.permissions.role == ShoppingListRole.ADMIN &&
        !_shoppingListInfo.users.any((element) => element.userRole == ShoppingListRole.ADMIN);
  }

  Widget _buildDeleteLeaveBtnExplanation(BuildContext context) {
    String? explanation;
    if (_willDeleteList() && _shoppingListInfo.users.length > 0) {
      explanation = AppLocalizations.of(context)
          .listSettingsLeaveExplanationOnlyAdmin(ShoppingListRole.ADMIN.toDisplayString(context));
    } else if (_shoppingListInfo.permissions.role == ShoppingListRole.ADMIN && !_willDeleteList()) {
      explanation = AppLocalizations.of(context)
          .listSettingsLeaveExplanationOtherAdminsPresent(ShoppingListRole.ADMIN.toDisplayString(context));
    }

    if (explanation != null) {
      return Padding(padding: EdgeInsets.only(top: 12), child: Text(explanation, style: getCardSubtitleStyle(context)));
    }
    return Container();
  }

  void _onDeleteShoppingList(BuildContext context) async {
    final localization = AppLocalizations.of(context);
    _setLoading(true);
    try {
      final deleteList = await showConfirmDialog(
        context,
        _willDeleteList()
            ? localization.listSettingsDeleteListConfirmationText(_shoppingListInfo.name)
            : localization.listSettingsLeaveListConfirmationText(_shoppingListInfo.name),
      );
      if (deleteList ?? false) {
        await _deleteShoppingList();
        Navigator.pop(context);
      }
    } on Exception catch (e) {
      log("Could not delete shopping list", error: e);
      showErrorDialogForException(context, e, altText: localization.exceptionDeleteListFailed);
    } finally {
      _setLoading(false);
    }
  }
}
