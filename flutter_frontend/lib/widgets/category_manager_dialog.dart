import 'package:flutter/material.dart';
import 'package:kaufhansel_client/generated/l10n.dart';

import '../model.dart';

class CategoryManager extends StatefulWidget {
  final String selected;
  final List<String> categories;
  final bool canCheckItems;
  final bool canEditItems;
  final Future<void> Function() onUncheckAll;
  final Future<void> Function() onDeleteAllChecked;
  final Future<void> Function(String category) onDeleteChecked;
  final Future<void> Function(String category) onUncheckCategory;
  final Future<void> Function() onRemoveCategories;
  final Future<void> Function(String category) onRemoveCategory;
  final Future<void> Function(String category) onRenameCategory;

  const CategoryManager(
      {this.selected,
      @required this.categories,
      @required this.canCheckItems,
      @required this.canEditItems,
      @required this.onUncheckCategory,
      @required this.onDeleteAllChecked,
      @required this.onDeleteChecked,
      @required this.onRemoveCategory,
      @required this.onRenameCategory,
      @required this.onUncheckAll,
      @required this.onRemoveCategories});
  @override
  _CategoryManagerState createState() => _CategoryManagerState();
}

class _CategoryManagerState extends State<CategoryManager> {
  bool _loading = false;
  String _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.selected;
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
              onPressed: _loading ? null : () => Navigator.pop(context, null),
            )
          ],
        ),
        children: [
          _buildProgress(),
          SizedBox(height: 12),
          Padding(
              padding: EdgeInsets.only(left: 24, right: 24, bottom: 0),
              child: Text(AppLocalizations.of(context).manageCategoriesCategory,
                  style: Theme.of(context).textTheme.caption)),
          Padding(
            padding: EdgeInsets.only(left: 24, right: 24, bottom: 18),
            child: _buildDropdownMenu(context),
          ),
          ..._buildOptions(),
        ]);
  }

  List<Widget> _buildOptions() {
    if (_selected == null) {
      return [];
    } else {
      return [
        Padding(
            padding: EdgeInsets.only(left: 24, right: 24, bottom: 10),
            child:
                Text(AppLocalizations.of(context).manageCategoriesAction, style: Theme.of(context).textTheme.caption)),
        _buildUncheck(context),
        _buildRemoveChecked(context),
        _buildRemoveCategory(context),
        _buildRename(context),
      ];
    }
  }

  Widget _buildRemoveChecked(BuildContext context) {
    if (!widget.canEditItems) {
      return Container();
    } else if (_selected == CATEGORY_ALL) {
      return _buildDialogOption(context, AppLocalizations.of(context).manageCategoriesRemoveChecked,
          Icons.delete_outlined, () => widget.onDeleteAllChecked());
    } else {
      return _buildDialogOption(
          context,
          AppLocalizations.of(context).manageCategoriesRemoveCheckedFromCategory(_selected),
          Icons.delete_outlined,
          () => widget.onDeleteChecked(_selected));
    }
  }

  Widget _buildRename(BuildContext context) {
    if (_selected == CATEGORY_ALL || !widget.canEditItems) {
      return Container();
    } else {
      return _buildDialogOption(context, AppLocalizations.of(context).manageCategoriesRenameCategory(_selected),
          Icons.drive_file_rename_outline, () => widget.onRenameCategory(_selected));
    }
  }

  Widget _buildRemoveCategory(BuildContext context) {
    if (widget.categories.length == 1 || !widget.canEditItems) {
      return Container();
    } else if (_selected == CATEGORY_ALL) {
      return _buildDialogOption(context, AppLocalizations.of(context).manageCategoriesRemoveCategories,
          Icons.more_outlined, () => widget.onRemoveCategories());
    } else {
      return _buildDialogOption(context, AppLocalizations.of(context).manageCategoriesRemoveCategory(_selected),
          Icons.more_outlined, () => widget.onRemoveCategory(_selected));
    }
  }

  Widget _buildUncheck(BuildContext context) {
    if (!widget.canCheckItems) {
      return Container();
    } else if (_selected == CATEGORY_ALL) {
      return _buildDialogOption(context, AppLocalizations.of(context).manageCategoriesUncheckAll,
          Icons.browser_not_supported_outlined, () => widget.onUncheckAll(),
          option: "uncheck-all");
    } else {
      return _buildDialogOption(context, AppLocalizations.of(context).manageCategoriesUncheckCategory(_selected),
          Icons.browser_not_supported_outlined, () => widget.onUncheckCategory(_selected),
          option: "uncheck");
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
      onChanged: _loading ? null : (String newValue) => blubb(newValue),
      items: widget.categories.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value, key: ValueKey<String>("menuitem-" + value.replaceAll(" ", "_"))),
        );
      }).toList(),
    );
  }

  void blubb(String newValue) {
    setState(() {
      _selected = newValue;
    });
  }

  Widget _buildDialogOption(BuildContext context, String text, IconData icon, Future<void> Function() onPressed,
      {String option}) {
    return SimpleDialogOption(
      padding: EdgeInsets.only(left: 24, right: 24, top: 12, bottom: 12),
      child: Row(children: [
        Icon(
          icon,
          color: _loading ? Theme.of(context).disabledColor : null,
        ),
        SizedBox(width: 12),
        Flexible(
            child: Text(text,
                key: ValueKey<String>("option-$option"),
                style: TextStyle(color: _loading ? Theme.of(context).disabledColor : null))),
      ]),
      onPressed: _loading ? null : () => _handleLoading(onPressed),
    );
  }

  Widget _buildProgress() {
    if (_loading) {
      return LinearProgressIndicator(minHeight: 5);
    } else {
      return SizedBox(height: 5);
    }
  }

  void _handleLoading(Future<void> Function() fn) async {
    setState(() => _loading = true);
    try {
      await fn();
    } finally {
      setState(() => _loading = false);
    }
  }
}
