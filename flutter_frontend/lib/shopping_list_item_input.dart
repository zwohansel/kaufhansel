import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:kaufhansel_client/model.dart';
import 'package:kaufhansel_client/rest_client.dart';
import 'package:provider/provider.dart';

class ShoppingListItemInput extends StatefulWidget {
  final String shoppingListId;
  final ScrollController shoppingListScrollController;

  ShoppingListItemInput({@required this.shoppingListScrollController, @required this.shoppingListId});

  @override
  _ShoppingListItemInputState createState() => _ShoppingListItemInputState();
}

class _ShoppingListItemInputState extends State<ShoppingListItemInput> {
  TextEditingController _newItemNameController;
  bool _enabled = false;
  bool _submitting = false;
  FocusNode _focus = FocusNode();

  _ShoppingListItemInputState();

  @override
  void initState() {
    super.initState();
    _newItemNameController = TextEditingController();
    _newItemNameController.addListener(() => setState(() => _enabled = _newItemNameController.text.isNotEmpty));
  }

  void addNewItem() async {
    final name = _newItemNameController.value.text;

    if (name.isNotEmpty) {
      setState(() {
        _submitting = true;
      });
      ShoppingListItem shoppingListItem =
          await RestClientWidget.of(context).createShoppingListItem(widget.shoppingListId, name);
      Provider.of<ShoppingListModel>(context).addItem(shoppingListItem);
      _newItemNameController.clear();
      // Scroll to the new element after it has been added and rendered (at the end of this frame).
      // TODO: Does not work reliably (e.g. after hot reload)
      SchedulerBinding.instance.addPostFrameCallback((_) {
        widget.shoppingListScrollController.animateTo(widget.shoppingListScrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      });
      setState(() {
        _submitting = false;
      });
    }
    _focus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final addButton = _submitting
        ? Center(
            child: SizedBox(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
                width: 20,
                height: 20))
        : Center(
            child: IconButton(
              splashRadius: 23,
              icon: Icon(Icons.add),
              onPressed: _enabled ? addNewItem : null,
            ),
          );

    return Container(
        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
        child: Row(
          children: [
            Expanded(
                child: TextField(
                    focusNode: _focus,
                    style: TextStyle(fontFamilyFallback: ['NotoColorEmoji']),
                    decoration: InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.fromLTRB(12, 8, 12, 8),
                        border: OutlineInputBorder(),
                        hintText: "New Item"),
                    controller: _newItemNameController,
                    enabled: !_submitting,
                    onSubmitted: (_) => addNewItem())),
            Container(child: SizedBox(child: addButton, width: 40, height: 40), margin: EdgeInsets.only(left: 6.0)),
          ],
        ));
  }
}
