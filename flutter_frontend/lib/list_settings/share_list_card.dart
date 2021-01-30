import 'package:flutter/material.dart';
import 'package:kaufhansel_client/widgets/error_dialog.dart';

import '../model.dart';
import '../widgets/confirm_dialog.dart';

class ShareListCard extends StatefulWidget {
  final ShoppingListInfo _shoppingListInfo;
  final void Function(bool) _setLoading;
  final bool _loading;

  final Future<void> Function(String) _onAddUserToShoppingList;
  final Future<void> Function(ShoppingListUserReference) _onRemoveUserFromShoppingList;
  final Future<void> Function(String affectedUserId, String newRole) _onChangeShoppingListPermissions;

  const ShareListCard(
    this._shoppingListInfo,
    this._loading,
    this._setLoading, {
    @required Future<void> Function(String) onAddUserToShoppingList,
    @required Future<void> Function(String, String) onChangeShoppingListPermissions,
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
    final sharedUsers = widget._shoppingListInfo.users.map((user) => ListTile(
        enabled: !widget._loading,
        leading: _getIcon(user.permissions.role),
        title: Text("${user.userName} (${user.userEmailAddress}): ${_mapRole(user.permissions.role)}"),
        onTap: () => _onChangePermissions(user),
        trailing: user.permissions.role == 'ADMIN'
            ? null
            : IconButton(icon: Icon(Icons.delete), onPressed: () => _onRemoveUserFromList(user))));

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
                children: ListTile.divideTiles(context: context, tiles: sharedUsers).toList(),
              ),
              SizedBox(height: 12),
              Text(
                "Mit einem weiteren Hansel teilen",
                style: Theme.of(context).textTheme.headline6,
              ),
              SizedBox(height: 12),
              Text(
                  "Wenn du nichts änderst, kann der neue Hansel Dinge hinzufügen und entfernen, " +
                      "er darf Haken setzen und entfernen. Er ist ein Schreibhansel.",
                  style: Theme.of(context).textTheme.subtitle2),
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
                            if (emailAddress.trim().isEmpty ||
                                !emailAddress.contains('@') ||
                                !emailAddress.contains('.')) {
                              return 'Dazu brauchen wir schon eine korrekte Emailadresse...';
                            }
                            return null;
                          },
                        ))),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: widget._loading ? null : _onAddUserToShoppingList,
                )
              ]),
            ],
          )),
    );
  }

  Future<String> _buildChangePermissionsDialog(BuildContext context, ShoppingListUserReference user) {
    if (user.permissions.role == "ADMIN") {
      showErrorDialog(context, "Einmal Chefhansel, immer Chefhansel. Daran kannst du nichts mehr ändern.");
      return null;
    }

    return showDialog<String>(
        context: context,
        builder: (context) => SimpleDialog(
              title: Text("Was ist ${user.userName} für ein Hansel?"),
              children: [
                _buildRoleOption(
                    context,
                    "ADMIN",
                    "ADMIN" == user.permissions.role,
                    "Chefhansel",
                    "Darf alles: Dinge hinzufügen und entfernen, Haken setzen und entfernen. Darf neue Hansel zur Liste " +
                        "hinzufügen.\nEinmal Chefhansel, immer Chefhansel: diese Rolle kannst du nicht mehr ändern"),
                _buildRoleOption(context, "READ_WRITE", "READ_WRITE" == user.permissions.role, "Schreibhansel",
                    "Darf Dinge hinzufügen und entfernen, darf Haken setzen und entfernen"),
                _buildRoleOption(context, "CHECK_ONLY", "CHECK_ONLY" == user.permissions.role, "Kaufhansel",
                    "Darf Haken setzen und entfernen"),
                _buildRoleOption(context, "READ_ONLY", "READ_ONLY" == user.permissions.role, "Guckhansel",
                    "Darf die Liste anschauen, aber nix ändern"),
              ],
            ));
  }

  Widget _buildRoleOption(BuildContext context, String role, bool selected, String title, String description) {
    return Container(
        color: selected ? Theme.of(context).highlightColor : null,
        child: SimpleDialogOption(
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _getIcon(role),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.headline6,
                ),
                Text(description)
              ],
            )
          ]),
          onPressed: () => Navigator.pop(context, role),
        ));
  }

  Icon _getIcon(String role) {
    switch (role) {
      case "ADMIN":
        return Icon(Icons.gavel_outlined);
      case "READ_WRITE":
        return Icon(Icons.assignment_outlined);
      case "CHECK_ONLY":
        return Icon(Icons.assignment_turned_in_outlined);
      case "READ_ONLY":
        return Icon(Icons.remove_red_eye_outlined);
      default:
        return Icon(Icons.radio_button_off_outlined);
    }
  }

  String _mapRole(String role) {
    switch (role) {
      case "ADMIN":
        return "Chefhansel";
      case "READ_WRITE":
        return "Schreibhansel";
      case "CHECK_ONLY":
        return "Kaufhansel";
      case "READ_ONLY":
        return "Guckhansel";
      default:
        return "UNGÜLTIG";
    }
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
    } catch (e) {
      showErrorDialog(context, "Hast du dich vertippt oder können wir den Hansel nicht finden?");
    } finally {
      widget._setLoading(false);
    }
  }

  void _onChangePermissions(ShoppingListUserReference user) async {
    widget._setLoading(true);
    try {
      final nextRole = await _buildChangePermissionsDialog(context, user);
      if (nextRole != null && nextRole != user.permissions.role) {
        await widget._onChangeShoppingListPermissions(user.userId, nextRole);
      }
    } catch (e) {
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
    } catch (e) {
      showErrorDialog(context, "Schläft der Server noch oder hast du kein Internet?");
    } finally {
      widget._setLoading(false);
    }
  }
}
