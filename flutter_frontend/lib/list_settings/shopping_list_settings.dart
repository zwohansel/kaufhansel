import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:kaufhansel_client/list_settings/danger_card.dart';
import 'package:kaufhansel_client/list_settings/info_card.dart';
import 'package:kaufhansel_client/list_settings/share_list_card.dart';
import 'package:kaufhansel_client/model.dart';
import 'package:kaufhansel_client/widgets/title_widget.dart';
import 'package:provider/provider.dart';

class ShoppingListSettings extends StatefulWidget {
  const ShoppingListSettings(
      {@required Future<void> Function() onDeleteShoppingList,
      @required Future<void> Function() onUncheckAllItems,
      @required Future<void> Function() onRemoveAllCategories,
      @required Future<void> Function() onRemoveAllItems,
      @required Future<bool> Function(String) onAddUserToShoppingListIfPresent,
      @required Future<void> Function(String, ShoppingListRole) onChangeShoppingListPermissions,
      @required Future<void> Function(ShoppingListUserReference) onRemoveUserFromShoppingList,
      @required Future<void> Function(String) onChangeShoppingListName})
      : _onDeleteShoppingList = onDeleteShoppingList,
        _onUncheckAllItems = onUncheckAllItems,
        _onRemoveAllCategories = onRemoveAllCategories,
        _onRemoveAllItems = onRemoveAllItems,
        _onAddUserToShoppingListIfPresent = onAddUserToShoppingListIfPresent,
        _onRemoveUserFromShoppingList = onRemoveUserFromShoppingList,
        _onChangeShoppingListPermissions = onChangeShoppingListPermissions,
        _onChangeShoppingListName = onChangeShoppingListName;

  final Future<void> Function() _onDeleteShoppingList;
  final Future<void> Function() _onUncheckAllItems;
  final Future<void> Function() _onRemoveAllCategories;
  final Future<void> Function() _onRemoveAllItems;
  final Future<bool> Function(String) _onAddUserToShoppingListIfPresent;
  final Future<void> Function(ShoppingListUserReference) _onRemoveUserFromShoppingList;
  final Future<void> Function(String affectedUserId, ShoppingListRole newRole) _onChangeShoppingListPermissions;
  final Future<void> Function(String) _onChangeShoppingListName;

  @override
  _ShoppingListSettingsState createState() => _ShoppingListSettingsState();
}

class _ShoppingListSettingsState extends State<ShoppingListSettings> {
  final ScrollController _scrollController = ScrollController();

  bool _loading = false;
  void _setLoading(bool value) {
    setState(() => _loading = value);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => !_loading,
        child: Scaffold(
            appBar: AppBar(
              title: TitleWidget(AppLocalizations.of(context).appTitle),
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildProgressBar(),
                Expanded(
                  child: Scrollbar(
                      controller: _scrollController,
                      child: ListView(children: [
                        Padding(
                            padding: EdgeInsets.all(24),
                            child: Consumer<ShoppingListInfo>(
                              builder: (context, info, child) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    SizedBox(height: 12),
                                    InfoCard(
                                      info,
                                      _loading,
                                      _setLoading,
                                      onChangeShoppingListName: widget._onChangeShoppingListName,
                                      onRemoveAllCategories: widget._onRemoveAllCategories,
                                      onRemoveAllItems: widget._onRemoveAllItems,
                                      onUncheckAllItems: widget._onUncheckAllItems,
                                    ),
                                    SizedBox(height: 12),
                                    ShareListCard(
                                      info,
                                      _loading,
                                      _setLoading,
                                      onAddUserToShoppingListIfPresent: widget._onAddUserToShoppingListIfPresent,
                                      onChangeShoppingListPermissions: widget._onChangeShoppingListPermissions,
                                      onRemoveUserFromShoppingList: widget._onRemoveUserFromShoppingList,
                                    ),
                                    SizedBox(height: 12),
                                    DangerCard(
                                      _loading,
                                      _setLoading,
                                      deleteShoppingList: widget._onDeleteShoppingList,
                                      shoppingListInfo: info,
                                    )
                                  ],
                                );
                              },
                            ))
                      ])),
                )
              ],
            )));
  }

  Widget _buildProgressBar() {
    if (_loading) {
      return LinearProgressIndicator(
        minHeight: 5,
      );
    } else {
      return Container();
    }
  }
}
