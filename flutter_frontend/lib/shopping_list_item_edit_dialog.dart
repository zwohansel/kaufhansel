import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kaufhansel_client/generated/l10n.dart';
import 'package:kaufhansel_client/model.dart';
import 'package:kaufhansel_client/synced_shoppinglist.dart';
import 'package:kaufhansel_client/widgets/error_dialog.dart';

class EditShoppingListItemDialog extends StatefulWidget {
  final SyncedShoppingListItem _item;
  final List<String> _categories;

  const EditShoppingListItemDialog({
    required SyncedShoppingListItem item,
    required List<String> categories,
  })  : _item = item,
        _categories = categories;

  @override
  _EditShoppingListItemDialogState createState() => _EditShoppingListItemDialogState();
}

class _EditShoppingListItemDialogState extends State<EditShoppingListItemDialog> {
  final TextEditingController _newCategoryEditingController = TextEditingController();
  final FocusNode _newCategoryEditionFocus = FocusNode();
  bool _newCategoryIsValid = false;
  final ScrollController _scrollController = ScrollController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _newCategoryEditingController.addListener(() {
      setState(() {
        final category = _newCategoryEditingController.text.trim();
        _newCategoryIsValid = category != CATEGORY_ALL && category.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _newCategoryEditingController.dispose();
    _newCategoryEditionFocus.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    const bottomMargin = 10.0;

    final title = MoreOptionsEditableTextLabel(
      text: widget._item.name,
      textStyle: theme.textTheme.titleLarge?.apply(fontFamilyFallback: ['NotoColorEmoji']),
      onEditItemName: (text) => submitNewItemName(text),
      onDelete: onDelete,
      enabled: !_loading,
    );

    final subTitle = Text(AppLocalizations.of(context).categoryChooseOne, style: theme.textTheme.titleSmall);

    final categoryButtons = widget._categories.map((category) {
      final currentItemCategory = widget._item.category == category;
      final color = currentItemCategory ? Theme.of(context).colorScheme.secondary : Theme.of(context).unselectedWidgetColor;
      return Padding(
        child: OutlinedButton(
            onPressed: !_loading ? () => setItemCategory(category) : null,
            child: Text(category),
            style: OutlinedButton.styleFrom(
                textStyle: TextStyle(color: color),
                backgroundColor: color,
                side: BorderSide(color: color, width: currentItemCategory ? 2.0 : 1.0))),
        padding: EdgeInsets.only(bottom: bottomMargin),
      );
    }).toList();

    final dialogContent = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(padding: EdgeInsets.only(left: 10, right: 10, top: 10), child: title),
        _buildProgress(),
        Padding(padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: bottomMargin), child: subTitle),
        Flexible(
          child: Padding(
            padding: EdgeInsets.only(left: 10, right: 10),
            child: Scrollbar(
                controller: _scrollController,
                child: ListView(
                  shrinkWrap: true,
                  controller: _scrollController,
                  children: categoryButtons,
                )),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 10, right: 10, bottom: bottomMargin),
          child: OutlinedButton(
            onPressed: !_loading ? () => setItemCategory(null) : null,
            child: Text(AppLocalizations.of(context).categoryNone),
            style: OutlinedButton.styleFrom(backgroundColor: Colors.orange, side: BorderSide(color: Colors.orange)),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
          child: TextField(
            controller: _newCategoryEditingController,
            focusNode: _newCategoryEditionFocus,
            textCapitalization: TextCapitalization.sentences,
            onSubmitted: (_) => submitNewCategory(),
            enabled: !_loading,
            decoration: InputDecoration(
                labelText: AppLocalizations.of(context).categoryCreateNew,
                isDense: true,
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                    icon: Icon(Icons.check), onPressed: !_loading && _newCategoryIsValid ? submitNewCategory : null)),
          ),
        ),
      ],
    );

    return Dialog(child: ConstrainedBox(constraints: BoxConstraints(maxWidth: 150), child: dialogContent));
  }

  Future<void> submitNewItemName(String newItemName) async {
    setState(() => _loading = true);
    try {
      await widget._item.setName(newItemName);
    } on Exception catch (e) {
      developer.log("Could not set item name", error: e);
      showErrorDialogForException(context, e,
          altText: AppLocalizations.of(context).exceptionRenameItemFailed(newItemName));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> submitNewCategory() async {
    if (_newCategoryIsValid) {
      final category = _newCategoryEditingController.text.trim();
      await setItemCategory(category);
    } else {
      _newCategoryEditionFocus.requestFocus();
    }
  }

  Future<void> setItemCategory(String? category) async {
    if (category == widget._item.category) {
      Navigator.pop(context);
      return;
    }

    try {
      setState(() => _loading = true);
      await widget._item.setCategory(category);
      Navigator.pop(context);
    } on Exception catch (e) {
      developer.log("Could not set item category", error: e);
      showErrorDialogForException(context, e, altText: AppLocalizations.of(context).exceptionNoInternetDidNotWork);
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> onDelete() async {
    try {
      setState(() => _loading = true);
      await widget._item.delete();
      Navigator.pop(context);
    } on Exception catch (e) {
      developer.log("Could not remove item", error: e);
      showErrorDialogForException(context, e,
          altText: AppLocalizations.of(context).exceptionDeleteItemFailed(widget._item.name));
    } finally {
      setState(() => _loading = false);
    }
  }

  Widget _buildProgress() {
    if (_loading) {
      return LinearProgressIndicator(minHeight: 5);
    }
    return SizedBox(height: 5);
  }
}

class MoreOptionsEditableTextLabel extends StatefulWidget {
  final text;
  final textStyle;
  final enabled;
  final Future<void> Function(String) onEditItemName;
  final onDelete;

  const MoreOptionsEditableTextLabel(
      {required this.text,
      required this.textStyle,
      required this.enabled,
      required this.onEditItemName,
      required this.onDelete});

  @override
  _MoreOptionsEditableTextLabelState createState() => _MoreOptionsEditableTextLabelState(text);
}

class _MoreOptionsEditableTextLabelState extends State<MoreOptionsEditableTextLabel> {
  static const delete = "DELETE";
  static const rename = "RENAME";

  final TextEditingController _textEditingController;
  final _focusNode = new FocusNode();
  String currentText;
  bool _editing = false;
  bool _valid = false;
  bool _enabled = true;

  _MoreOptionsEditableTextLabelState(String text)
      : _textEditingController = new TextEditingController(text: text),
        currentText = text;

  @override
  void initState() {
    super.initState();
    _textEditingController.addListener(() {
      setState(() => _valid = _textEditingController.text.trim().isNotEmpty);
    });
  }

  void onEditItemName() async {
    setState(() => _enabled = false);
    final newText = _textEditingController.text;
    if (currentText != newText) {
      await widget.onEditItemName(_textEditingController.text);
      currentText = newText;
    }
    setState(() {
      _editing = false;
      _enabled = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    const _iconSize = 24.0;
    const _iconPadding = EdgeInsets.all(8.0);

    if (_editing) {
      return TextField(
        controller: _textEditingController,
        enabled: _enabled && widget.enabled,
        textCapitalization: TextCapitalization.sentences,
        style: widget.textStyle,
        focusNode: _focusNode,
        onSubmitted: (_) => onEditItemName(),
        decoration: InputDecoration(
          suffixIcon: IconButton(
            icon: Icon(Icons.check),
            iconSize: _iconSize,
            padding: _iconPadding,
            splashRadius: _iconSize,
            onPressed: _valid ? onEditItemName : null,
          ),
        ),
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(child: Text(widget.text, style: widget.textStyle)),
          PopupMenuButton(
            enabled: _enabled && widget.enabled,
            icon: Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case rename:
                  setState(() {
                    _textEditingController.selection =
                        TextSelection(baseOffset: 0, extentOffset: _textEditingController.text.length);
                    _valid = true;
                    _editing = true;
                    _focusNode.requestFocus();
                  });
                  break;
                case delete:
                  widget.onDelete();
                  break;
                default:
              }
            },
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                    child: Row(children: [
                      Icon(Icons.drive_file_rename_outline),
                      SizedBox(width: 10),
                      Text(AppLocalizations.of(context).itemRename)
                    ]),
                    value: rename),
                PopupMenuItem(
                    child: Row(children: [
                      Icon(Icons.delete),
                      SizedBox(width: 10),
                      Text(AppLocalizations.of(context).itemRemove)
                    ]),
                    value: delete)
              ];
            },
          )
        ],
      );
    }
  }
}
