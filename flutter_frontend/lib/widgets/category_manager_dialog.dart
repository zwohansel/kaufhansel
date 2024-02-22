import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:kaufhansel_client/generated/l10n.dart';
import 'package:kaufhansel_client/synced_shoppinglist.dart';
import 'package:kaufhansel_client/widgets/text_input_dialog.dart';

import '../model.dart';
import 'error_dialog.dart';

class CategoryManager extends StatefulWidget {
  final String? initialSelected;
  final SyncedShoppingList list;
  final VoidCallback? onClose;

  const CategoryManager({
    this.initialSelected,
    required this.list,
    this.onClose,
  });

  @override
  _CategoryManagerState createState() => _CategoryManagerState();
}

class _CategoryManagerState extends State<CategoryManager> {
  bool _loading = false;
  String? _selectedCategory;
  List<String> _categories = [];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialSelected;
    updateAndObserveShoppingListCategories();
  }

  void updateAndObserveShoppingListCategories() {
    widget.list.addListener(shoppingListChanged);
    updateCategories();
  }

  void shoppingListChanged() {
    setState(updateCategories);
  }

  void updateCategories() {
    final categories = widget.list.getAllCategories();
    _categories = categories;
    _selectedCategory = categories.contains(_selectedCategory) ? _selectedCategory : null;
  }

  @override
  void didUpdateWidget(covariant CategoryManager oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.list.removeListener(shoppingListChanged);
    updateAndObserveShoppingListCategories();
  }

  @override
  void dispose() {
    widget.list.removeListener(shoppingListChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final onClose = widget.onClose ?? () => null;
    return SimpleDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(child: Text(AppLocalizations.of(context).manageCategoriesTitle)),
            IconButton(
              icon: Icon(Icons.close),
              splashRadius: 24,
              onPressed: _loading ? null : () => onClose(),
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
                Text(AppLocalizations.of(context).manageCategoriesCategory,
                    style: Theme.of(context).textTheme.bodySmall),
                _buildDropdownMenu(context),
                SizedBox(height: 18),
                ..._buildOptions()
              ],
            ),
          ),
        ]);
  }

  List<Widget> _buildOptions() {
    if (_selectedCategory == null) {
      return [];
    } else {
      return [
        Text(AppLocalizations.of(context).manageCategoriesAction, style: Theme.of(context).textTheme.bodySmall),
        SizedBox(height: 10),
        _buildUncheck(context),
        _buildRemoveChecked(context),
        _buildRemoveCategory(context),
        _buildRename(context),
      ];
    }
  }

  Widget _buildRemoveChecked(BuildContext context) {
    if (widget.list.info.permissions.canEditItems) {
      return Container();
    } else if (_selectedCategory == CATEGORY_ALL) {
      return _buildDialogOption(context, AppLocalizations.of(context).manageCategoriesRemoveChecked,
          Icons.delete_outlined, () => widget.list.deleteCheckedItems());
    } else {
      return _buildDialogOption(
          context,
          AppLocalizations.of(context).manageCategoriesRemoveCheckedFromCategory(_selectedCategory ?? ""),
          Icons.delete_outlined,
          () => widget.list.deleteCheckedItems(ofCategory: _selectedCategory));
    }
  }

  Widget _buildRename(BuildContext context) {
    if (_selectedCategory == CATEGORY_ALL || !widget.list.info.permissions.canEditItems) {
      return Container();
    } else {
      return _buildDialogOption(
          context,
          AppLocalizations.of(context).manageCategoriesRenameCategory(_selectedCategory ?? ""),
          Icons.drive_file_rename_outline,
          () => _renameSelectedCategory());
    }
  }

  Future<void> _renameSelectedCategory() async {
    final selectedCategory = _selectedCategory;
    if (selectedCategory == null) {
      return;
    }
    String? newCategoryName = await showTextInputDialog(context,
        title: AppLocalizations.of(context).manageCategoriesRenameCategoryDialogTitle,
        initialValue: _selectedCategory,
        hintText: AppLocalizations.of(context).shoppingListCreateNewEnterNameHint);

    if (newCategoryName == null || newCategoryName.isEmpty || newCategoryName == _selectedCategory) {
      return;
    }

    await widget.list.renameCategory(selectedCategory, newCategoryName);
  }

  Widget _buildRemoveCategory(BuildContext context) {
    if (widget.list.getAllCategories().length == 1 || !widget.list.info.permissions.canEditItems) {
      return Container();
    } else if (_selectedCategory == CATEGORY_ALL) {
      return _buildDialogOption(context, AppLocalizations.of(context).manageCategoriesRemoveCategories,
          Icons.more_outlined, () => widget.list.removeAllCategories());
    } else {
      return _buildDialogOption(
          context,
          AppLocalizations.of(context).manageCategoriesRemoveCategory(_selectedCategory ?? ""),
          Icons.more_outlined,
          () => widget.list.removeCategory(_selectedCategory));
    }
  }

  Widget _buildUncheck(BuildContext context) {
    if (widget.list.info.permissions.canCheckItems) {
      return Container();
    } else if (_selectedCategory == CATEGORY_ALL) {
      return _buildDialogOption(context, AppLocalizations.of(context).manageCategoriesUncheckAll,
          Icons.browser_not_supported_outlined, () => widget.list.uncheckItems());
    } else {
      return _buildDialogOption(
          context,
          AppLocalizations.of(context).manageCategoriesUncheckCategory(_selectedCategory ?? ""),
          Icons.browser_not_supported_outlined,
          () => widget.list.uncheckItems(ofCategory: _selectedCategory));
    }
  }

  DropdownButton<String> _buildDropdownMenu(BuildContext context) {
    return DropdownButton<String>(
      value: _selectedCategory,
      hint: Text(AppLocalizations.of(context).manageCategoriesWhich),
      isExpanded: true,
      icon: const Icon(Icons.arrow_downward),
      iconSize: 24,
      underline: Container(height: 2, color: Theme.of(context).primaryColor),
      onChanged: _loading ? null : (newValue) => setState(() => _selectedCategory = newValue),
      items: _categories.map((value) {
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
      final onClose = widget.onClose;
      if (onClose != null) {
        onClose();
      }
    } on Exception catch (e) {
      log("Could not execute option for category $_selectedCategory", error: e);
      await showErrorDialogForException(context, e,
          altText: AppLocalizations.of(context).exceptionGeneralServerTooLazy);
    } finally {
      setState(() => _loading = false);
    }
  }
}
