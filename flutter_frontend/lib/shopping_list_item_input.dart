import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:kaufhansel_client/model.dart';
import 'package:kaufhansel_client/rest_client.dart';
import 'package:kaufhansel_client/widgets/async_operation_icon_button.dart';
import 'package:kaufhansel_client/widgets/error_dialog.dart';
import 'package:provider/provider.dart';

class ShoppingListItemInput extends StatefulWidget {
  final ScrollController _shoppingListScrollController;
  final String _category;
  final bool _enabled;

  ShoppingListItemInput({@required ScrollController shoppingListScrollController, String category, bool enabled = true})
      : _shoppingListScrollController = shoppingListScrollController,
        _category = category,
        _enabled = enabled;

  @override
  _ShoppingListItemInputState createState() => _ShoppingListItemInputState();
}

class _ShoppingListItemInputState extends State<ShoppingListItemInput> {
  final TextEditingController _newItemNameController = TextEditingController();
  final FocusNode _focus = FocusNode();
  bool _nameValid = false;
  bool _submitting = false;

  _ShoppingListItemInputState();

  @override
  void initState() {
    super.initState();
    _newItemNameController.addListener(() {
      setState(() => _nameValid = _newItemNameController.text.trim().isNotEmpty);
    });
  }

  @override
  void dispose() {
    _newItemNameController.dispose();
    _focus.dispose();
    super.dispose();
  }

  void addNewItemIfValid() {
    final name = _newItemNameController.value.text.trim();
    if (name.isNotEmpty) {
      addNewItem(name);
    } else {
      _focus.requestFocus();
    }
  }

  Future<void> addNewItem(String name) async {
    setState(() => _submitting = true);
    try {
      final shoppingList = Provider.of<ShoppingList>(context, listen: false);
      // category CATEGORY_ALL is virtual, do not add it to items
      final category = widget._category == CATEGORY_ALL ? null : widget._category;
      ShoppingListItem shoppingListItem =
          await RestClientWidget.of(context).createShoppingListItem(shoppingList.id, name, category);
      shoppingList.addItem(shoppingListItem);
      _newItemNameController.clear();
      // Scroll to the new element after it has been added and rendered (at the end of this frame).
      // TODO: Does not work reliably (e.g. after hot reload)
      SchedulerBinding.instance.addPostFrameCallback((_) {
        widget._shoppingListScrollController.animateTo(widget._shoppingListScrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      });
    } on Exception catch (e) {
      developer.log("Could not add $name to list.", error: e);
      showErrorDialog(context, AppLocalizations.of(context).exceptionAddItemFailed(name));
    } finally {
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final addButton = AsyncOperationIconButton(
      icon: Icon(Icons.add),
      onPressed: widget._enabled && _nameValid ? addNewItemIfValid : null,
      loading: _submitting,
    );

    return Container(
        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
        child: Row(
          children: [
            Expanded(
                child: TextField(
                    focusNode: _focus,
                    textCapitalization: TextCapitalization.sentences,
                    style: TextStyle(fontFamilyFallback: ['NotoColorEmoji']),
                    decoration: InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.fromLTRB(12, 8, 12, 8),
                        border: OutlineInputBorder(),
                        hintText: AppLocalizations.of(context).shoppingListNeededHint),
                    controller: _newItemNameController,
                    enabled: !_submitting && widget._enabled,
                    onSubmitted: (_) => addNewItemIfValid())),
            Container(child: addButton, margin: EdgeInsets.only(left: 6.0)),
          ],
        ));
  }
}
