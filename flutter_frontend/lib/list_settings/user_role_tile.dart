import 'package:flutter/material.dart';
import 'package:kaufhansel_client/model.dart';

class UserRoleTile extends StatelessWidget {
  final ShoppingListRole _userRole;
  final Widget _title;
  final Widget _subTitle;
  final VoidCallback _onChangePermissionPressed;
  final VoidCallback _onRemoveUserFromListPressed;
  final bool _enabled;

  UserRoleTile(this._userRole, this._title,
      {Widget subTitle,
      VoidCallback onChangePermissionPressed,
      VoidCallback onRemoveUserFromListPressed,
      bool enabled = true})
      : _subTitle = subTitle,
        _onChangePermissionPressed = onChangePermissionPressed,
        _onRemoveUserFromListPressed = onRemoveUserFromListPressed,
        _enabled = enabled;

  @override
  Widget build(BuildContext context) {
    List<Widget> subTitleChildren = [];
    if (_subTitle != null) {
      subTitleChildren.add(Padding(
        child: _subTitle,
        padding: EdgeInsets.only(bottom: 5),
      ));
    }
    subTitleChildren.add(Text(_userRole.toDisplayString()));

    return ListTile(
        enabled: _enabled,
        leading: Icon(_userRole.toIcon()),
        title: Padding(child: _title, padding: EdgeInsets.only(bottom: 5)),
        subtitle: Wrap(
          direction: Axis.vertical,
          children: subTitleChildren,
        ),
        onTap: _onChangePermissionPressed,
        trailing: _onRemoveUserFromListPressed != null
            ? IconButton(icon: Icon(Icons.delete), onPressed: _onRemoveUserFromListPressed)
            : null);
  }
}