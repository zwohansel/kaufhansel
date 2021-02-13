import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:kaufhansel_client/widgets/editable_text_label.dart';

import '../model.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/error_dialog.dart';

class InfoCard extends StatefulWidget {
  final ShoppingListInfo _shoppingListInfo;
  final void Function(bool) _setLoading;
  final bool _loading;

  final Future<void> Function() _onUncheckAllItems;
  final Future<void> Function() _onRemoveAllCategories;
  final Future<void> Function() _onRemoveAllItems;
  final Future<void> Function(String) _onChangeShoppingListName;

  const InfoCard(this._shoppingListInfo, this._loading, this._setLoading,
      {@required Future<void> Function() onUncheckAllItems,
      @required Future<void> Function() onRemoveAllCategories,
      @required Future<void> Function() onRemoveAllItems,
      @required Future<void> Function(String) onChangeShoppingListName})
      : _onUncheckAllItems = onUncheckAllItems,
        _onRemoveAllCategories = onRemoveAllCategories,
        _onRemoveAllItems = onRemoveAllItems,
        _onChangeShoppingListName = onChangeShoppingListName;

  @override
  _InfoCardState createState() => _InfoCardState();
}

class _InfoCardState extends State<InfoCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
          padding: EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              EditableTextLabel(
                  text: widget._shoppingListInfo.name,
                  textStyle: Theme.of(context).textTheme.headline5.apply(fontFamilyFallback: ['NotoColorEmoji']),
                  enabled: widget._shoppingListInfo.permissions.canEditList,
                  onSubmit: (text) => _submitNewShoppingListName(text)),
              SizedBox(height: 12),
              OutlinedButton(
                onPressed: widget._loading || !widget._shoppingListInfo.permissions.canCheckItems
                    ? null
                    : _onUncheckAllItemsPressed,
                child: Text(AppLocalizations.of(context).listSettingsUncheckAllItems),
              ),
              SizedBox(height: 6),
              OutlinedButton(
                onPressed: widget._loading || !widget._shoppingListInfo.permissions.canEditItems
                    ? null
                    : _onRemoveAllCategoriesPressed,
                child: Text(AppLocalizations.of(context).listSettingsClearAllCategories),
              ),
              SizedBox(height: 6),
              OutlinedButton(
                onPressed: widget._loading || !widget._shoppingListInfo.permissions.canEditItems
                    ? null
                    : _onRemoveAllItemsPressed,
                child: Text(AppLocalizations.of(context).listSettingsClearList),
              ),
            ],
          )),
    );
  }

  void _onUncheckAllItemsPressed() async {
    widget._setLoading(true);
    try {
      await widget._onUncheckAllItems();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context).listSettingsAllItemsUnchecked(widget._shoppingListInfo.name)),
          duration: Duration(seconds: 1)));
    } catch (e) {
      showErrorDialog(context, AppLocalizations.of(context).exceptionGeneralServerTooLazy);
    } finally {
      widget._setLoading(false);
    }
  }

  void _onRemoveAllCategoriesPressed() async {
    widget._setLoading(true);
    try {
      await widget._onRemoveAllCategories();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context).listSettingsAllCategoriesCleared(widget._shoppingListInfo.name)),
          duration: Duration(seconds: 1)));
    } catch (e) {
      showErrorDialog(context, AppLocalizations.of(context).exceptionGeneralServerTooLazy);
    } finally {
      widget._setLoading(false);
    }
    widget._setLoading(false);
  }

  void _onRemoveAllItemsPressed() async {
    widget._setLoading(true);
    try {
      final removeItems = await showConfirmDialog(
          context, AppLocalizations.of(context).listSettingsClearListConfirmationText(widget._shoppingListInfo.name));
      if (removeItems) {
        await widget._onRemoveAllItems();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(AppLocalizations.of(context).listSettingsListCleared(widget._shoppingListInfo.name)),
            duration: Duration(seconds: 1)));
      }
    } catch (e) {
      showErrorDialog(context, AppLocalizations.of(context).exceptionGeneralServerSleeping);
    } finally {
      widget._setLoading(false);
    }
  }

  Future<bool> _submitNewShoppingListName(String newName) async {
    try {
      await widget._onChangeShoppingListName(newName);
      return true;
    } on Exception catch (e) {
      developer.log("Could not change shopping list name to $newName", error: e);
      showErrorDialog(context, AppLocalizations.of(context).exceptionGeneralTryAgainLater);
      return false;
    }
  }
}
