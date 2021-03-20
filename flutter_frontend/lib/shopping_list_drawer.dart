import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:kaufhansel_client/generated/l10n.dart';
import 'package:kaufhansel_client/rest_client.dart';
import 'package:kaufhansel_client/settings/app_settings.dart';
import 'package:kaufhansel_client/widgets/category_manager_dialog.dart';
import 'package:kaufhansel_client/widgets/error_dialog.dart';
import 'package:kaufhansel_client/widgets/invite_dialog.dart';
import 'package:kaufhansel_client/widgets/text_input_dialog.dart';
import 'package:provider/provider.dart';

import 'list_settings/shopping_list_settings.dart';
import 'model.dart';

class ShoppingListDrawer extends StatelessWidget {
  const ShoppingListDrawer({
    @required this.shoppingListInfos,
    this.selectedShoppingListId,
    @required this.userInfo,
    @required this.onRefreshPressed,
    @required this.onUncheckAllItems,
    @required this.onRemoveAllCategories,
    @required this.onRemoveCategory,
    @required this.onRenameCategory,
    @required this.shoppingListCategories,
    @required this.onUncheckItemsOfCategory,
    @required this.onRemoveAllItems,
    @required this.onShoppingListSelected,
    @required this.onCreateShoppingList,
    @required this.onDeleteShoppingList,
    @required this.onAddUserToShoppingListIfPresent,
    @required this.onRemoveUserFromShoppingList,
    @required this.onChangeShoppingListPermissions,
    @required this.onChangeShoppingListName,
    @required this.onLogOut,
    @required this.onDeleteUserAccount,
    @required this.onDeleteChecked,
  }) : assert(shoppingListInfos != null);

  final List<ShoppingListInfo> shoppingListInfos;
  final String selectedShoppingListId;
  final ShoppingListUserInfo userInfo;
  final VoidCallback onRefreshPressed;
  final void Function(ShoppingListInfo info) onShoppingListSelected;
  final Future<void> Function(String) onCreateShoppingList;
  final Future<void> Function(ShoppingListInfo) onDeleteShoppingList;
  final Future<bool> Function(ShoppingListInfo, String) onAddUserToShoppingListIfPresent;
  final Future<void> Function(ShoppingListInfo, ShoppingListUserReference) onRemoveUserFromShoppingList;
  final Future<void> Function(ShoppingListInfo) onUncheckAllItems;
  final Future<void> Function(ShoppingListInfo shoppingListInfo, {String ofCategory}) onDeleteChecked;
  final List<String> shoppingListCategories;
  final Future<void> Function(ShoppingListInfo, String category) onUncheckItemsOfCategory;
  final Future<void> Function(ShoppingListInfo) onRemoveAllCategories;
  final Future<void> Function(ShoppingListInfo, String category) onRemoveCategory;
  final Future<bool> Function(ShoppingListInfo, String oldCategory) onRenameCategory;
  final Future<void> Function(ShoppingListInfo) onRemoveAllItems;
  final Future<void> Function(ShoppingListInfo info, String affectedUserId, ShoppingListRole newRole)
      onChangeShoppingListPermissions;
  final Future<void> Function(ShoppingListInfo, String) onChangeShoppingListName;
  final Future<void> Function() onLogOut;
  final Future<void> Function() onDeleteUserAccount;

  @override
  Widget build(BuildContext context) {
    ShoppingListInfo currentList = shoppingListInfos.firstWhere(
      (info) => info.id == selectedShoppingListId,
      orElse: () => null,
    );

    final infoTiles = shoppingListInfos.where((info) => info.id != selectedShoppingListId)?.map(
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
            child: _buildDrawerHeader(context, currentList),
          ),
          ListTile(
            leading: Icon(Icons.refresh_outlined),
            title: Text(AppLocalizations.of(context).refresh),
            onTap: () {
              onRefreshPressed();
              Navigator.pop(context);
            },
          ),
          _buildManageCategoriesMenuItem(context, currentList),
          _buildListSettingsMenuItem(context, currentList),
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

  Widget _buildDrawerHeader(BuildContext context, ShoppingListInfo currentList) {
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
                      Text(currentList.name, style: Theme.of(context).primaryTextTheme.headline6),
                      SizedBox(height: 5),
                      Text(currentList.permissions.role.toDisplayString(context),
                          style: Theme.of(context).primaryTextTheme.bodyText1)
                    ],
                  ),
          ),
          Icon(currentList?.permissions?.role?.toIcon(), color: Theme.of(context).primaryTextTheme.bodyText1.color)
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

  StatelessWidget _buildListSettingsMenuItem(BuildContext context, ShoppingListInfo currentList) {
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
              value: currentList,
              child: RestClientWidget(
                client,
                child: ShoppingListSettings(
                  onDeleteShoppingList: () => onDeleteShoppingList(currentList),
                  onRemoveAllItems: () => onRemoveAllItems(currentList),
                  onAddUserToShoppingListIfPresent: (userEmailAddress) =>
                      onAddUserToShoppingListIfPresent(currentList, userEmailAddress),
                  onRemoveUserFromShoppingList: (user) => onRemoveUserFromShoppingList(currentList, user),
                  onChangeShoppingListPermissions: (affectedUserId, newRole) =>
                      onChangeShoppingListPermissions(currentList, affectedUserId, newRole),
                  onChangeShoppingListName: (newName) => onChangeShoppingListName(currentList, newName),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  StatelessWidget _buildManageCategoriesMenuItem(BuildContext context, ShoppingListInfo currentList) {
    if (currentList == null || (!currentList.permissions.canEditItems && !currentList.permissions.canCheckItems)) {
      return Container();
    }
    return ListTile(
      leading: Icon(Icons.more_outlined),
      title: Text(AppLocalizations.of(context).manageCategories),
      onTap: () => _onManageCategoriesPressed(context, currentList),
    );
  }

  Future<void> _onManageCategoriesPressed(BuildContext context, ShoppingListInfo currentList) async {
    await showDialog<String>(
        context: context,
        builder: (context) => CategoryManager(
              canCheckItems: currentList.permissions.canCheckItems,
              canEditItems: currentList.permissions.canEditItems,
              categories: shoppingListCategories,
              onUncheckAll: () => uncheckAllItems(context, currentList),
              onUncheckCategory: (category) => uncheckItems(context, currentList, category),
              onRemoveCategories: () => removeAllCategories(context, currentList),
              onRemoveCategory: (category) => removeCategory(context, currentList, category),
              onRenameCategory: (category) => renameCategory(context, currentList, category),
              onDeleteChecked: (category) => deleteChecked(context, currentList, category),
              onDeleteAllChecked: () => deleteAllChecked(context, currentList),
            ));
  }

  Future<void> uncheckItems(BuildContext context, ShoppingListInfo currentList, String category) async {
    try {
      await onUncheckItemsOfCategory(currentList, category);
      Navigator.of(context).pop();
    } on Exception catch (e) {
      log("Could not uncheck items of category $category", error: e);
      await showErrorDialogForException(context, e,
          altText: AppLocalizations.of(context).exceptionGeneralServerTooLazy);
    }
  }

  Future<void> uncheckAllItems(BuildContext context, ShoppingListInfo currentList) async {
    try {
      await onUncheckAllItems(currentList);
      Navigator.of(context).pop();
    } on Exception catch (e) {
      log("Could not uncheck all items", error: e);
      await showErrorDialogForException(context, e,
          altText: AppLocalizations.of(context).exceptionGeneralServerTooLazy);
    }
  }

  Future<void> deleteAllChecked(BuildContext context, ShoppingListInfo currentList) async {
    try {
      await onDeleteChecked(currentList);
      Navigator.of(context).pop();
    } on Exception catch (e) {
      log("Could not uncheck all items", error: e);
      await showErrorDialogForException(context, e,
          altText: AppLocalizations.of(context).exceptionGeneralServerTooLazy);
    }
  }

  Future<void> deleteChecked(BuildContext context, ShoppingListInfo currentList, String category) async {
    try {
      await onDeleteChecked(currentList, ofCategory: category);
      Navigator.of(context).pop();
    } on Exception catch (e) {
      log("Could not uncheck all items", error: e);
      await showErrorDialogForException(context, e,
          altText: AppLocalizations.of(context).exceptionGeneralServerTooLazy);
    }
  }

  Future<void> removeCategory(BuildContext context, ShoppingListInfo currentList, String category) async {
    try {
      await onRemoveCategory(currentList, category);
      Navigator.of(context).pop();
    } on Exception catch (e) {
      log("Could not remove category $category", error: e);
      await showErrorDialogForException(context, e,
          altText: AppLocalizations.of(context).exceptionGeneralServerTooLazy);
    }
  }

  Future<void> removeAllCategories(BuildContext context, ShoppingListInfo currentList) async {
    try {
      await onRemoveAllCategories(currentList);
      Navigator.of(context).pop();
    } on Exception catch (e) {
      log("Could not remove all categories", error: e);
      await showErrorDialogForException(context, e,
          altText: AppLocalizations.of(context).exceptionGeneralServerTooLazy);
    }
  }

  Future<void> renameCategory(BuildContext context, ShoppingListInfo currentList, String oldCategory) async {
    try {
      if (await onRenameCategory(currentList, oldCategory)) {
        Navigator.of(context).pop();
      }
    } on Exception catch (e) {
      log("Could not rename category $oldCategory", error: e);
      await showErrorDialogForException(context, e,
          altText: AppLocalizations.of(context).exceptionGeneralServerTooLazy);
    }
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
