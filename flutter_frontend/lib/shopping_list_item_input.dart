import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:kaufhansel_client/async_operation_icon_button.dart';
import 'package:kaufhansel_client/model.dart';
import 'package:kaufhansel_client/rest_client.dart';
import 'package:provider/provider.dart';

class ShoppingListItemInput extends StatefulWidget {
  final ScrollController _shoppingListScrollController;
  final String _category;

  ShoppingListItemInput({@required ScrollController shoppingListScrollController, String category})
      : _shoppingListScrollController = shoppingListScrollController,
        _category = category;

  @override
  _ShoppingListItemInputState createState() => _ShoppingListItemInputState();
}

class _ShoppingListItemInputState extends State<ShoppingListItemInput> {
  final TextEditingController _newItemNameController = TextEditingController();
  final FocusNode _focus = FocusNode();
  bool _enabled = false;
  bool _submitting = false;

  _ShoppingListItemInputState();

  @override
  void initState() {
    super.initState();
    _newItemNameController.addListener(() => setState(() => _enabled = _newItemNameController.text.trim().isNotEmpty));
  }

  void addNewItemIfValid() {
    final name = _newItemNameController.value.text.trim();
    if (name.isNotEmpty) {
      setState(() => _submitting = true);
      addNewItem(name).whenComplete(() => setState(() => _submitting = false));
    } else {
      _focus.requestFocus();
    }
  }

  Future<void> addNewItem(String name) async {
    await Future.delayed(Duration(seconds: 5));

    final shoppingList = Provider.of<ShoppingListModel>(context);
    ShoppingListItem shoppingListItem =
        await RestClientWidget.of(context).createShoppingListItem(shoppingList.id, name, widget._category);
    shoppingList.addItem(shoppingListItem);
    _newItemNameController.clear();
    // Scroll to the new element after it has been added and rendered (at the end of this frame).
    // TODO: Does not work reliably (e.g. after hot reload)
    SchedulerBinding.instance.addPostFrameCallback((_) {
      widget._shoppingListScrollController.animateTo(widget._shoppingListScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    });
  }

  @override
  Widget build(BuildContext context) {
    final addButton = AsyncOperationIconButton(
      icon: Icon(Icons.add),
      onPressed: _enabled ? addNewItemIfValid : null,
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
                        hintText: "Das brauche ich noch..."),
                    controller: _newItemNameController,
                    enabled: !_submitting,
                    onSubmitted: (_) => addNewItemIfValid())),
            Container(child: addButton, margin: EdgeInsets.only(left: 6.0)),
          ],
        ));
  }
}
