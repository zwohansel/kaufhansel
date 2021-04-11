import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:kaufhansel_client/generated/l10n.dart';

import '../model.dart';
import 'error_dialog.dart';

class CategoryManager extends StatefulWidget {
  final String initialSelected;
  final List<String> categories;
  final ShoppingListInfo listInfo;
  final Future<void> Function(ShoppingListInfo) onUncheckAllItems;
  final Future<void> Function(ShoppingListInfo shoppingListInfo, {String ofCategory}) onDeleteChecked;
  final Future<void> Function(ShoppingListInfo, String category) onUncheckItemsOfCategory;
  final Future<void> Function(ShoppingListInfo) onRemoveAllCategories;
  final Future<void> Function(ShoppingListInfo, String category) onRemoveCategory;
  final Future<bool> Function(ShoppingListInfo, String oldCategory) onRenameCategory;
  final VoidCallback onClose;

  const CategoryManager({
    this.initialSelected,
    @required this.categories,
    @required this.listInfo,
    @required this.onUncheckItemsOfCategory,
    @required this.onDeleteChecked,
    @required this.onRemoveCategory,
    @required this.onRenameCategory,
    @required this.onUncheckAllItems,
    @required this.onRemoveAllCategories,
    this.onClose,
  });
  @override
  _CategoryManagerState createState() => _CategoryManagerState();
}

class _CategoryManagerState extends State<CategoryManager> {
  bool _loading = false;
  String _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialSelected;
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(child: Text(AppLocalizations.of(context).manageCategoriesTitle)),
            IconButton(
              icon: Icon(Icons.close),
              splashRadius: 24,
              onPressed: _loading ? null : () => widget?.onClose(),
            )
          ],
        ),
        children: [
          _buildProgress(),
          SizedBox(height: 12),
          Padding(
            padding: EdgeInsets.only(left: 24, right: 24, bottom: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLocalizations.of(context).manageCategoriesCategory, style: Theme.of(context).textTheme.caption),
                _buildDropdownMenu(context),
                SizedBox(height: 18),
                ..._buildOptions()
              ],
            ),
          ),
        ]);
  }

  List<Widget> _buildOptions() {
    if (_selected == null) {
      return [];
    } else {
      return [
        Text(AppLocalizations.of(context).manageCategoriesAction, style: Theme.of(context).textTheme.caption),
        SizedBox(height: 10),
        _buildUncheck(context),
        _buildRemoveChecked(context),
        _buildRemoveCategory(context),
        _buildRename(context),
      ];
    }
  }

  Widget _buildRemoveChecked(BuildContext context) {
    if (!widget.listInfo.permissions.canEditItems) {
      return Container();
    } else if (_selected == CATEGORY_ALL) {
      return _buildDialogOption(context, AppLocalizations.of(context).manageCategoriesRemoveChecked,
          Icons.delete_outlined, () => widget.onDeleteChecked(widget.listInfo));
    } else {
      return _buildDialogOption(
          context,
          AppLocalizations.of(context).manageCategoriesRemoveCheckedFromCategory(_selected),
          Icons.delete_outlined,
          () => widget.onDeleteChecked(widget.listInfo, ofCategory: _selected));
    }
  }

  Widget _buildRename(BuildContext context) {
    if (_selected == CATEGORY_ALL || !widget.listInfo.permissions.canEditItems) {
      return Container();
    } else {
      return _buildDialogOption(context, AppLocalizations.of(context).manageCategoriesRenameCategory(_selected),
          Icons.drive_file_rename_outline, () => widget.onRenameCategory(widget.listInfo, _selected));
    }
  }

  Widget _buildRemoveCategory(BuildContext context) {
    if (widget.categories.length == 1 || !widget.listInfo.permissions.canEditItems) {
      return Container();
    } else if (_selected == CATEGORY_ALL) {
      return _buildDialogOption(context, AppLocalizations.of(context).manageCategoriesRemoveCategories,
          Icons.more_outlined, () => widget.onRemoveAllCategories(widget.listInfo));
    } else {
      return _buildDialogOption(context, AppLocalizations.of(context).manageCategoriesRemoveCategory(_selected),
          Icons.more_outlined, () => widget.onRemoveCategory(widget.listInfo, _selected));
    }
  }

  Widget _buildUncheck(BuildContext context) {
    if (!widget.listInfo.permissions.canCheckItems) {
      return Container();
    } else if (_selected == CATEGORY_ALL) {
      return _buildDialogOption(context, AppLocalizations.of(context).manageCategoriesUncheckAll,
          Icons.browser_not_supported_outlined, () => widget.onUncheckAllItems(widget.listInfo));
    } else {
      return _buildDialogOption(context, AppLocalizations.of(context).manageCategoriesUncheckCategory(_selected),
          Icons.browser_not_supported_outlined, () => widget.onUncheckItemsOfCategory(widget.listInfo, _selected));
    }
  }

  DropdownButton<String> _buildDropdownMenu(BuildContext context) {
    return DropdownButton<String>(
      value: _selected,
      hint: Text(AppLocalizations.of(context).manageCategoriesWhich),
      isExpanded: true,
      icon: const Icon(Icons.arrow_downward),
      iconSize: 24,
      underline: Container(height: 2, color: Theme.of(context).primaryColor),
      onChanged: _loading ? null : (newValue) => setState(() => _selected = newValue),
      items: widget.categories.map((value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  Widget _buildDialogOption(BuildContext context, String text, IconData icon, Future<void> Function() onPressed) {
    return SimpleDialogOption(
      padding: EdgeInsets.only(top: 12, bottom: 12),
      child: Row(children: [
        Icon(
          icon,
          color: _loading ? Theme.of(context).disabledColor : null,
        ),
        SizedBox(width: 12),
        Flexible(child: Text(text, style: TextStyle(color: _loading ? Theme.of(context).disabledColor : null))),
      ]),
      onPressed: _loading ? null : () => executeOption(onPressed),
    );
  }

  Widget _buildProgress() {
    if (_loading) {
      return LinearProgressIndicator(minHeight: 5);
    } else {
      return SizedBox(height: 5);
    }
  }

  void executeOption(Future<void> Function() optionHandler) async {
    setState(() => _loading = true);
    try {
      await optionHandler();
      widget?.onClose();
    } on Exception catch (e) {
      log("Could not execute option for category $_selected", error: e);
      await showErrorDialogForException(context, e,
          altText: AppLocalizations.of(context).exceptionGeneralServerTooLazy);
    } finally {
      setState(() => _loading = false);
    }
  }
}
