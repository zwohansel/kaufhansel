import 'package:flutter/material.dart';
import 'package:kaufhansel_client/generated/l10n.dart';
import 'package:kaufhansel_client/list_settings/danger_card.dart';
import 'package:kaufhansel_client/list_settings/info_card.dart';
import 'package:kaufhansel_client/list_settings/share_list_card.dart';
import 'package:kaufhansel_client/model.dart';
import 'package:kaufhansel_client/widgets/title_widget.dart';
import 'package:provider/provider.dart';

class ShoppingListSettings extends StatefulWidget {
  const ShoppingListSettings(
      {required Future<void> Function() onDeleteShoppingList,
      required Future<void> Function() onRemoveAllItems,
      required Future<bool> Function(String) onAddUserToShoppingListIfPresent,
      required Future<void> Function(String, ShoppingListRole) onChangeShoppingListPermissions,
      required Future<void> Function(ShoppingListUserReference) onRemoveUserFromShoppingList,
      required Future<void> Function(String) onChangeShoppingListName})
      : _onDeleteShoppingList = onDeleteShoppingList,
        _onRemoveAllItems = onRemoveAllItems,
        _onAddUserToShoppingListIfPresent = onAddUserToShoppingListIfPresent,
        _onRemoveUserFromShoppingList = onRemoveUserFromShoppingList,
        _onChangeShoppingListPermissions = onChangeShoppingListPermissions,
        _onChangeShoppingListName = onChangeShoppingListName;

  final Future<void> Function() _onDeleteShoppingList;
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
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: 0, maxWidth: 600),
                  child: Scrollbar(
                    controller: _scrollController,
                    child: ListView(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(5),
                          child: Consumer<ShoppingListInfo>(
                            builder: (context, info, child) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  InfoCard(
                                    info,
                                    _loading,
                                    _setLoading,
                                    onChangeShoppingListName: widget._onChangeShoppingListName,
                                    onRemoveAllItems: widget._onRemoveAllItems,
                                  ),
                                  ShareListCard(
                                    info,
                                    _loading,
                                    _setLoading,
                                    onAddUserToShoppingListIfPresent: widget._onAddUserToShoppingListIfPresent,
                                    onChangeShoppingListPermissions: widget._onChangeShoppingListPermissions,
                                    onRemoveUserFromShoppingList: widget._onRemoveUserFromShoppingList,
                                  ),
                                  DangerCard(
                                    _loading,
                                    _setLoading,
                                    deleteShoppingList: widget._onDeleteShoppingList,
                                    shoppingListInfo: info,
                                  )
                                ],
                              );
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
