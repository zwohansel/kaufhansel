import 'package:flutter/material.dart';
import 'package:kaufhansel_client/generated/l10n.dart';
import 'package:kaufhansel_client/rest_client.dart';
import 'package:kaufhansel_client/settings/app_settings.dart';
import 'package:kaufhansel_client/widgets/confirm_dialog.dart';
import 'package:kaufhansel_client/widgets/error_dialog.dart';
import 'package:kaufhansel_client/widgets/invite_dialog.dart';
import 'package:provider/provider.dart';

import 'create_shopping_list_dialog.dart';
import 'list_settings/shopping_list_settings.dart';
import 'model.dart';

class ShoppingListDrawer extends StatelessWidget {
  const ShoppingListDrawer(
      {@required List<ShoppingListInfo> shoppingLists,
      @required VoidCallback onRefreshPressed,
      @required String selectedShoppingListId,
      @required void Function(ShoppingListInfo info) onShoppingListSelected,
      @required Future<void> Function(String) onCreateShoppingList,
      @required Future<void> Function(ShoppingListInfo) onDeleteShoppingList,
      @required Future<bool> Function(ShoppingListInfo, String) onAddUserToShoppingListIfPresent,
      @required Future<void> Function(ShoppingListInfo) onUncheckAllItems,
      @required Future<void> Function(ShoppingListInfo) onRemoveAllCategories,
      @required Future<void> Function(ShoppingListInfo) onRemoveAllItems,
      @required Future<void> Function(ShoppingListInfo, String, ShoppingListRole) onChangeShoppingListPermissions,
      @required Future<void> Function(ShoppingListInfo, ShoppingListUserReference) onRemoveUserFromShoppingList,
      @required Future<void> Function(ShoppingListInfo, String) onChangeShoppingListName,
      @required Future<void> Function() onLogOut,
      @required Future<void> Function() onDeleteUserAccount,
      @required ShoppingListUserInfo userInfo})
      : _onRefreshPressed = onRefreshPressed,
        _shoppingListInfos = shoppingLists,
        _selectedShoppingListId = selectedShoppingListId,
        _selectShoppingList = onShoppingListSelected,
        _onCreateShoppingList = onCreateShoppingList,
        _onDeleteShoppingList = onDeleteShoppingList,
        _onAddUserToShoppingListIfPresent = onAddUserToShoppingListIfPresent,
        _onRemoveUserFromShoppingList = onRemoveUserFromShoppingList,
        _onUncheckAllItems = onUncheckAllItems,
        _onRemoveAllCategories = onRemoveAllCategories,
        _onRemoveAllItems = onRemoveAllItems,
        _onChangeShoppingListPermissions = onChangeShoppingListPermissions,
        _onChangeShoppingListName = onChangeShoppingListName,
        _onLogOut = onLogOut,
        _onDeleteUserAccount = onDeleteUserAccount,
        _userInfo = userInfo;

  final List<ShoppingListInfo> _shoppingListInfos;
  final VoidCallback _onRefreshPressed;
  final void Function(ShoppingListInfo info) _selectShoppingList;
  final String _selectedShoppingListId;
  final Future<void> Function(String) _onCreateShoppingList;
  final Future<void> Function(ShoppingListInfo) _onDeleteShoppingList;
  final Future<bool> Function(ShoppingListInfo, String) _onAddUserToShoppingListIfPresent;
  final Future<void> Function(ShoppingListInfo, ShoppingListUserReference) _onRemoveUserFromShoppingList;
  final Future<void> Function(ShoppingListInfo) _onUncheckAllItems;
  final Future<void> Function(ShoppingListInfo) _onRemoveAllCategories;
  final Future<void> Function(ShoppingListInfo) _onRemoveAllItems;
  final Future<void> Function(ShoppingListInfo info, String affectedUserId, ShoppingListRole newRole)
      _onChangeShoppingListPermissions;
  final Future<void> Function(ShoppingListInfo, String) _onChangeShoppingListName;
  final Future<void> Function() _onLogOut;
  final Future<void> Function() _onDeleteUserAccount;
  final ShoppingListUserInfo _userInfo;

  @override
  Widget build(BuildContext context) {
    final _currentList = _shoppingListInfos.firstWhere((info) => info.id == _selectedShoppingListId);

    final infoTiles = _shoppingListInfos.where((info) => info.id != _selectedShoppingListId)?.map(
          (info) => ChangeNotifierProvider.value(
            value: info,
            builder: (context, child) => ListTile(
                key: ValueKey(info.id),
                title: Consumer<ShoppingListInfo>(builder: (context, info, child) => Text(info.name)),
                leading: Tooltip(
                    message: info.permissions.role.toDisplayString(context),
                    child: Icon(info.permissions.role.toIcon(), size: 18)),
                onTap: () => _onShoppingListSelected(context, info)),
          ),
        );

    return Drawer(
      child: ListView(
        children: [
          Container(
            color: Theme.of(context).primaryColor,
            child: Padding(
                padding: EdgeInsets.only(left: 15, top: 10, right: 15, bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_currentList.name, style: Theme.of(context).primaryTextTheme.headline6),
                          SizedBox(height: 5),
                          Text(_currentList.permissions.role.toDisplayString(context),
                              style: Theme.of(context).primaryTextTheme.bodyText1)
                        ],
                      ),
                    ),
                    Icon(_currentList?.permissions?.role?.toIcon(),
                        color: Theme.of(context).primaryTextTheme.bodyText1.color)
                  ],
                )),
          ),
          ListTile(
            leading: Icon(Icons.refresh_outlined),
            title: Text(AppLocalizations.of(context).refresh),
            onTap: () {
              _onRefreshPressed();
              Navigator.pop(context);
            },
          ),
          _buildUncheckMenuItem(_currentList, context),
          _buildClearCategoriesMenuItem(_currentList, context),
          _buildListSettingsMenuItem(_currentList, context),
          _buildMenuCategoryItem(context, AppLocalizations.of(context).shoppingListMyLists),
          ...infoTiles,
          Container(height: 2, color: Theme.of(context).hoverColor),
          ListTile(
            // tileColor: Theme.of(context).primaryColorLight,
            leading: Icon(Icons.post_add),
            title: Text(AppLocalizations.of(context).shoppingListCreateNew),
            onTap: () {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) {
                  return CreateShoppingListDialog(_onCreateShoppingList);
                },
              );
            },
          ),
          _buildMenuCategoryItem(context, AppLocalizations.of(context).appTitle),
          ListTile(
            // tileColor: Theme.of(context).primaryColorLight,
            leading: Icon(Icons.person_add),
            title: Text(AppLocalizations.of(context).invitationCodeGenerate),
            onTap: () {
              final RestClient client = RestClientWidget.of(context);
              showDialog(
                  context: context,
                  builder: (context) {
                    return InviteDialog(client);
                  });
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text(AppLocalizations.of(context).appSettings),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => new AppSettings(
                    userInfo: _userInfo,
                    onLogOut: _onLogOut,
                    onDeleteAccount: _onDeleteUserAccount,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Container _buildMenuCategoryItem(BuildContext context, String text) {
    return Container(
      color: Theme.of(context).primaryColor,
      child: Padding(
        padding: EdgeInsets.only(left: 15, top: 10, right: 15, bottom: 10),
        child: Text(text, style: Theme.of(context).primaryTextTheme.bodyText1),
      ),
    );
  }

  StatelessWidget _buildListSettingsMenuItem(ShoppingListInfo _currentList, BuildContext context) {
    if (!_currentList.permissions.canEditList) {
      return Container();
    }
    return ListTile(
      leading: Icon(Icons.more_horiz_outlined),
      title: Text(AppLocalizations.of(context).listSettings),
      onTap: () {
        final client = RestClientWidget.of(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) {
            // Providers are scoped and not shared between routes. We need to pass it explicitly to the new route
            return ChangeNotifierProvider.value(
              value: _currentList,
              child: RestClientWidget(
                client,
                child: ShoppingListSettings(
                  onDeleteShoppingList: () => _onDeleteShoppingList(_currentList),
                  onRemoveAllItems: () => _onRemoveAllItems(_currentList),
                  onAddUserToShoppingListIfPresent: (userEmailAddress) =>
                      _onAddUserToShoppingListIfPresent(_currentList, userEmailAddress),
                  onRemoveUserFromShoppingList: (user) => _onRemoveUserFromShoppingList(_currentList, user),
                  onChangeShoppingListPermissions: (affectedUserId, newRole) =>
                      _onChangeShoppingListPermissions(_currentList, affectedUserId, newRole),
                  onChangeShoppingListName: (newName) => _onChangeShoppingListName(_currentList, newName),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  StatelessWidget _buildClearCategoriesMenuItem(ShoppingListInfo _currentList, BuildContext context) {
    if (!_currentList.permissions.canEditItems) {
      return Container();
    }
    return ListTile(
      leading: Icon(Icons.more_outlined),
      title: Text(AppLocalizations.of(context).listSettingsClearAllCategories),
      onTap: () => _onRemoveAllCategoriesPressed(context, _currentList),
    );
  }

  StatelessWidget _buildUncheckMenuItem(ShoppingListInfo _currentList, BuildContext context) {
    if (!_currentList.permissions.canCheckItems) {
      return Container();
    }
    return ListTile(
      leading: Icon(Icons.check_box_outline_blank_outlined),
      title: Text(AppLocalizations.of(context).listSettingsUncheckAllItems),
      onTap: () => _onUncheckAllItemsPressed(context, _currentList),
    );
  }

  Future<void> _onUncheckAllItemsPressed(BuildContext context, ShoppingListInfo shoppingListInfo) async {
    if (await showConfirmDialog(context, AppLocalizations.of(context).listSettingsUncheckAllItemsConfirmationText,
        confirmBtnLabel: AppLocalizations.of(context).yes, cancelBtnLabel: AppLocalizations.of(context).no)) {
      await _onUncheckAllItemsPressed(context, shoppingListInfo);
      try {
        await _onUncheckAllItems(shoppingListInfo);
      } catch (e) {
        showErrorDialog(context, AppLocalizations.of(context).exceptionGeneralServerTooLazy);
      }
      Navigator.of(context).pop();
    }
  }

  Future<void> _onRemoveAllCategoriesPressed(BuildContext context, ShoppingListInfo shoppingListInfo) async {
    if (await showConfirmDialog(context, AppLocalizations.of(context).listSettingsClearAllCategoriesConfirmationText,
        confirmBtnLabel: AppLocalizations.of(context).yes, cancelBtnLabel: AppLocalizations.of(context).no)) {
      try {
        await _onRemoveAllCategories(shoppingListInfo);
      } catch (e) {
        showErrorDialog(context, AppLocalizations.of(context).exceptionGeneralServerTooLazy);
      }
      Navigator.of(context).pop();
    }
  }

  void _onShoppingListSelected(BuildContext context, ShoppingListInfo info) async {
    Navigator.pop(context);
    _selectShoppingList(info);
    if (info.permissions.role == ShoppingListRole.READ_ONLY || info.permissions.role == ShoppingListRole.CHECK_ONLY) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        duration: Duration(seconds: 3),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context).roleYoursRoleName(info.permissions.role.toDisplayString(context))),
            Text(info.permissions.role.toDescription(context)),
          ],
        ),
      ));
    }
  }
}
