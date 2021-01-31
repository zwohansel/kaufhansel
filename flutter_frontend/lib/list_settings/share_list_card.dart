import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:kaufhansel_client/list_settings/card_style.dart';
import 'package:kaufhansel_client/list_settings/user_role_tile.dart';
import 'package:kaufhansel_client/widgets/error_dialog.dart';

import '../model.dart';
import '../widgets/confirm_dialog.dart';

class ShareListCard extends StatefulWidget {
  final ShoppingListInfo _shoppingListInfo;
  final void Function(bool) _setLoading;
  final bool _loading;

  final Future<void> Function(String) _onAddUserToShoppingList;
  final Future<void> Function(ShoppingListUserReference) _onRemoveUserFromShoppingList;
  final Future<void> Function(String affectedUserId, ShoppingListRole newRole) _onChangeShoppingListPermissions;

  const ShareListCard(
    this._shoppingListInfo,
    this._loading,
    this._setLoading, {
    @required Future<void> Function(String) onAddUserToShoppingList,
    @required Future<void> Function(String, ShoppingListRole) onChangeShoppingListPermissions,
    @required Future<void> Function(ShoppingListUserReference) onRemoveUserFromShoppingList,
  })  : _onAddUserToShoppingList = onAddUserToShoppingList,
        _onRemoveUserFromShoppingList = onRemoveUserFromShoppingList,
        _onChangeShoppingListPermissions = onChangeShoppingListPermissions;

  @override
  _ShareListCardState createState() => _ShareListCardState();
}

class _ShareListCardState extends State<ShareListCard> {
  final TextEditingController _addUserTextEditingController = new TextEditingController();
  final FocusNode _addUserToShoppingListFocusNode = new FocusNode();
  final _addUserToShoppingListFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final currentUserCanEditList = widget._shoppingListInfo.permissions.canEditList;
    final currentUser = UserRoleTile(widget._shoppingListInfo.permissions.role, Text("Dir"));
    final otherUsers = widget._shoppingListInfo.users.map((user) => UserRoleTile(
          user.userRole,
          Text(user.userName),
          subTitle: Text(user.userEmailAddress),
          onChangePermissionPressed: currentUserCanEditList ? () => _onChangePermissions(user) : null,
          onRemoveUserFromListPressed:
              currentUserCanEditList && user.userRole.isRemoveable() ? () => _onRemoveUserFromList(user) : null,
          enabled: !widget._loading,
        ));

    return Card(
      child: Padding(
          padding: EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Du teilst die Liste mit",
                style: Theme.of(context).textTheme.headline6,
              ),
              SizedBox(height: 12),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: ListTile.divideTiles(context: context, tiles: [currentUser, ...otherUsers]).toList(),
              ),
              _buildAddUserWidget(context)
            ],
          )),
    );
  }

  Widget _buildAddUserWidget(BuildContext context) {
    if (!widget._shoppingListInfo.permissions.canEditList) {
      return Container();
    }

    return Padding(
      padding: EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Mit einem weiteren Hansel teilen", style: getCardHeadlineStyle(context)),
          SizedBox(height: 12),
          Text(
              "Wenn du nichts änderst, kann der neue Hansel Dinge hinzufügen und entfernen, " +
                  "er darf Haken setzen und entfernen. Er ist ein Schreibhansel.",
              style: getCardSubtitleStyle(context)),
          SizedBox(height: 12),
          Row(children: [
            Expanded(
                child: Form(
                    key: _addUserToShoppingListFormKey,
                    child: TextFormField(
                      focusNode: _addUserToShoppingListFocusNode,
                      controller: _addUserTextEditingController,
                      enabled: !widget._loading,
                      onFieldSubmitted: (_) => _onAddUserToShoppingList(),
                      decoration: const InputDecoration(
                        hintText: 'Emailadresse vom Hansel',
                      ),
                      validator: (emailAddress) {
                        if (emailAddress.trim().isEmpty || !emailAddress.contains('@') || !emailAddress.contains('.')) {
                          return 'Dazu brauchen wir schon eine korrekte Emailadresse...';
                        }
                        return null;
                      },
                    ))),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: widget._loading ? null : _onAddUserToShoppingList,
            )
          ])
        ],
      ),
    );
  }

  Future<ShoppingListRole> _buildChangePermissionsDialog(BuildContext context, ShoppingListUserReference user) {
    if (user.userRole == ShoppingListRole.ADMIN) {
      showErrorDialog(context, "Einmal Chefhansel, immer Chefhansel. Daran kannst du nichts mehr ändern.");
      return null;
    }

    return showDialog<ShoppingListRole>(
        context: context,
        builder: (context) => SimpleDialog(
            title: Text("Was ist ${user.userName} für ein Hansel?"),
            children: ShoppingListRole.values
                .map((role) => _buildRoleOption(context, role, user.userRole == role))
                .toList()));
  }

  Widget _buildRoleOption(BuildContext context, ShoppingListRole role, bool selected) {
    return Container(
        color: selected ? Theme.of(context).highlightColor : null,
        child: SimpleDialogOption(
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(role.toIcon()),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  role.toDisplayString(),
                  style: Theme.of(context).textTheme.headline6,
                ),
                Text(role.toDescription())
              ],
            )
          ]),
          onPressed: () => Navigator.pop(context, role),
        ));
  }

  void _onAddUserToShoppingList() async {
    if (!_addUserToShoppingListFormKey.currentState.validate()) {
      _addUserToShoppingListFocusNode.requestFocus();
      return;
    }

    widget._setLoading(true);
    try {
      final userEmail = _addUserTextEditingController.value.text.trim().toLowerCase();
      await widget._onAddUserToShoppingList(userEmail);
      _addUserTextEditingController.clear();
    } on Exception catch (e) {
      log("Could not add user to shopping list.", error: e);
      showErrorDialog(context, "Hast du dich vertippt oder können wir den Hansel nicht finden?");
    } finally {
      widget._setLoading(false);
    }
  }

  void _onChangePermissions(ShoppingListUserReference user) async {
    widget._setLoading(true);
    try {
      final nextRole = await _buildChangePermissionsDialog(context, user);
      if (nextRole != null && nextRole != user.userRole) {
        await widget._onChangeShoppingListPermissions(user.userId, nextRole);
      }
    } on Exception catch (e) {
      log("Could not change user permissions.", error: e);
      showErrorDialog(context, "Schläft der Server noch oder hast du kein Internet?");
    } finally {
      widget._setLoading(false);
    }
  }

  void _onRemoveUserFromList(ShoppingListUserReference user) async {
    widget._setLoading(true);
    try {
      final removeUser = await showConfirmDialog(
          context, "Möchtest du ${user.userName} wirklich von ${widget._shoppingListInfo.name} entfernen?");
      if (removeUser) {
        await widget._onRemoveUserFromShoppingList(user);
      }
    } on Exception catch (e) {
      log("Could not remove user from shopping list.", error: e);
      showErrorDialog(context, "Schläft der Server noch oder hast du kein Internet?");
    } finally {
      widget._setLoading(false);
    }
  }
}
