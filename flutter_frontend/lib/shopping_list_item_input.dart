import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:kaufhansel_client/generated/l10n.dart';
import 'package:kaufhansel_client/synced_shoppinglist.dart';
import 'package:kaufhansel_client/widgets/async_operation_icon_button.dart';
import 'package:kaufhansel_client/widgets/error_dialog.dart';
import 'package:provider/provider.dart';

class ShoppingListItemInput extends StatefulWidget {
  final ScrollController shoppingListScrollController;
  final String? category;
  final bool enabled;
  final void Function(String) onChange;

  ShoppingListItemInput({
    required this.shoppingListScrollController,
    required this.onChange,
    this.category,
    this.enabled = true,
  });

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
      widget.onChange(_newItemNameController.text.trim());
    });
  }

  @override
  void dispose() {
    _newItemNameController.dispose();
    _focus.dispose();
    super.dispose();
  }

  void addNewItemIfValid() async {
    if (_submitting) {
      return;
    }
    final name = _newItemNameController.value.text.trim();
    if (name.isNotEmpty) {
      await addNewItem(name);
    }
  }

  Future<void> addNewItem(String name) async {
    setState(() => _submitting = true);
    try {
      final shoppingList = Provider.of<SyncedShoppingList>(context, listen: false);
      await shoppingList.addNewItem(name, widget.category);
      _newItemNameController.clear();
      // Scroll to the new element after it has been added and rendered (at the end of this frame).
      SchedulerBinding.instance.addPostFrameCallback((_) {
        Future.delayed(
            Duration(milliseconds: 500),
            () => widget.shoppingListScrollController.animateTo(
                widget.shoppingListScrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut));
      });
    } on Exception catch (e) {
      developer.log("Could not add $name to list", error: e);
      showErrorDialogForException(context, e, altText: AppLocalizations.of(context).exceptionAddItemFailed(name));
    } finally {
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final addButton = AsyncOperationIconButton(
      icon: Icon(Icons.add),
      onPressed: widget.enabled && _nameValid ? addNewItemIfValid : null,
      loading: _submitting,
    );

    return Container(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 5, bottom: 5),
      child: Row(
        children: [
          Expanded(
            child: TextField(
                focusNode: _focus,
                autofocus: false,
                textCapitalization: TextCapitalization.sentences,
                style: TextStyle(fontFamilyFallback: ['NotoColorEmoji']),
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(12, 8, 12, 8),
                    border: OutlineInputBorder(),
                    hintText: AppLocalizations.of(context).createOrSearchHint,
                    suffixIcon: _buildClearButton()),
                controller: _newItemNameController,
                enabled: widget.enabled,
                onSubmitted: (_) {
                  addNewItemIfValid();
                  _focus.requestFocus();
                }),
          ),
          Container(child: addButton, margin: EdgeInsets.only(left: 6.0)),
        ],
      ),
    );
  }

  IconButton? _buildClearButton() {
    if (_focus.hasFocus || _focus.hasPrimaryFocus) {
      return IconButton(
        icon: Icon(Icons.clear, color: Colors.black, size: 20),
        splashRadius: 23,
        onPressed: () {
          _newItemNameController.clear();
          _focus.unfocus();
        },
      );
    }
    return null;
  }
}
