import 'package:flutter/material.dart';
import 'package:kaufhansel_client/generated/l10n.dart';
import 'package:kaufhansel_client/rest_client.dart';
import 'package:kaufhansel_client/settings/app_settings.dart';
import 'package:kaufhansel_client/synced_shoppinglist.dart';
import 'package:kaufhansel_client/widgets/category_manager_dialog.dart';
import 'package:kaufhansel_client/widgets/invite_dialog.dart';
import 'package:kaufhansel_client/widgets/text_input_dialog.dart';
import 'package:provider/provider.dart';

import 'list_settings/shopping_list_settings.dart';
import 'model.dart';

class ShoppingListDrawer extends StatelessWidget {
  const ShoppingListDrawer({
    @required this.shoppingListInfos,
    this.selectedShoppingList,
    @required this.userInfo,
    @required this.onRefreshPressed,
    @required this.shoppingListCategories,
    @required this.onShoppingListSelected,
    @required this.onCreateShoppingList,
    @required this.onDeleteShoppingList,
    @required this.onAddUserToShoppingListIfPresent,
    @required this.onRemoveUserFromShoppingList,
    @required this.onChangeShoppingListPermissions,
    @required this.onChangeShoppingListName,
    @required this.onLogOut,
    @required this.onDeleteUserAccount,
  }) : assert(shoppingListInfos != null);

  final List<ShoppingListInfo> shoppingListInfos;
  final SyncedShoppingList selectedShoppingList;
  final ShoppingListUserInfo userInfo;
  final VoidCallback onRefreshPressed;
  final void Function(ShoppingListInfo info) onShoppingListSelected;
  final Future<void> Function(String) onCreateShoppingList;
  final Future<void> Function(ShoppingListInfo) onDeleteShoppingList;
  final Future<bool> Function(ShoppingListInfo, String) onAddUserToShoppingListIfPresent;
  final Future<void> Function(ShoppingListInfo, ShoppingListUserReference) onRemoveUserFromShoppingList;
  final List<String> shoppingListCategories;
  final Future<void> Function(ShoppingListInfo info, String affectedUserId, ShoppingListRole newRole)
      onChangeShoppingListPermissions;
  final Future<void> Function(ShoppingListInfo, String) onChangeShoppingListName;
  final Future<void> Function() onLogOut;
  final Future<void> Function() onDeleteUserAccount;

  @override
  Widget build(BuildContext context) {
    final infoTiles = shoppingListInfos.where((info) => info.id != selectedShoppingList?.list?.id)?.map(
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
            child: _buildDrawerHeader(context, selectedShoppingList),
          ),
          ListTile(
            leading: Icon(Icons.refresh_outlined),
            title: Text(AppLocalizations.of(context).refresh),
            onTap: () {
              onRefreshPressed();
              Navigator.pop(context);
            },
          ),
          _buildManageCategoriesMenuItem(context, selectedShoppingList),
          _buildListSettingsMenuItem(context, selectedShoppingList),
          _buildMenuCategoryItem(context, AppLocalizations.of(context).shoppingListMyLists),
          ...infoTiles,
          Container(height: 2, color: Theme.of(context).hoverColor),
          ListTile(
            // tileColor: Theme.of(context).primaryColorLight,
            leading: Icon(Icons.post_add),
            title: Text(AppLocalizations.of(context).shoppingListCreateNew),
            onTap: () => showTextInputDialog(context,
                title: AppLocalizations.of(context).shoppingListCreateNewTitle,
                hintText: AppLocalizations.of(context).shoppingListCreateNewEnterNameHint,
                confirmBtnLabel: AppLocalizations.of(context).shoppingListCreateNewConfirm,
                onConfirm: onCreateShoppingList),
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
                    userInfo: userInfo,
                    onLogOut: onLogOut,
                    onDeleteAccount: onDeleteUserAccount,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context, SyncedShoppingList currentList) {
    return Padding(
      padding: EdgeInsets.only(left: 15, top: 10, right: 15, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: currentList == null
                ? Text(AppLocalizations.of(context).general, style: Theme.of(context).primaryTextTheme.bodyText1)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(currentList.list.name, style: Theme.of(context).primaryTextTheme.headline6),
                      SizedBox(height: 5),
                      Text(currentList.list.info.permissions.role.toDisplayString(context),
                          style: Theme.of(context).primaryTextTheme.bodyText1)
                    ],
                  ),
          ),
          Icon(currentList?.list?.info?.permissions?.role?.toIcon(),
              color: Theme.of(context).primaryTextTheme.bodyText1.color)
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

  StatelessWidget _buildListSettingsMenuItem(BuildContext context, SyncedShoppingList currentList) {
    if (currentList == null) {
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
              value: currentList.list,
              child: RestClientWidget(
                client,
                child: ShoppingListSettings(
                  onDeleteShoppingList: () => onDeleteShoppingList(currentList.list.info),
                  onRemoveAllItems: currentList.removeAllItems,
                  onAddUserToShoppingListIfPresent: (userEmailAddress) =>
                      onAddUserToShoppingListIfPresent(currentList.list.info, userEmailAddress),
                  onRemoveUserFromShoppingList: (user) => onRemoveUserFromShoppingList(currentList.list.info, user),
                  onChangeShoppingListPermissions: (affectedUserId, newRole) =>
                      onChangeShoppingListPermissions(currentList.list.info, affectedUserId, newRole),
                  onChangeShoppingListName: (newName) => onChangeShoppingListName(currentList.list.info, newName),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  StatelessWidget _buildManageCategoriesMenuItem(BuildContext context, SyncedShoppingList currentList) {
    if (currentList == null ||
        (!currentList.list.info.permissions.canEditItems && !currentList.list.info.permissions.canCheckItems)) {
      return Container();
    }
    return ListTile(
      leading: Icon(Icons.more_outlined),
      title: Text(AppLocalizations.of(context).manageCategories),
      onTap: () => _onManageCategoriesPressed(context, currentList),
    );
  }

  Future<void> _onManageCategoriesPressed(BuildContext context, SyncedShoppingList currentList) async {
    await showDialog(
        context: context,
        builder: (context) => CategoryManager(
              categories: shoppingListCategories,
              list: currentList,
              onClose: () => Navigator.pop(context),
            ));
  }

  void _onShoppingListSelected(BuildContext context, ShoppingListInfo info) async {
    Navigator.pop(context);
    onShoppingListSelected(info);
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
