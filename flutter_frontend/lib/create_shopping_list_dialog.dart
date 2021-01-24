import 'package:flutter/material.dart';

import 'error_dialog.dart';

class CreateShoppingListDialog extends StatefulWidget {
  final Future<void> Function(String) _onCreateShoppingList;

  const CreateShoppingListDialog(this._onCreateShoppingList);

  @override
  _CreateShoppingListDialogState createState() => _CreateShoppingListDialogState();
}

class _CreateShoppingListDialogState extends State<CreateShoppingListDialog> {
  final TextEditingController _textController = new TextEditingController();
  final FocusNode _textInputFocusNode = new FocusNode();

  bool _isListNameValid = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(() {
      setState(() {
        _isListNameValid = _textController.text.trim().isNotEmpty;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(title: Text("Neue Liste anlegen"), children: [
      _buildProgressBar(),
      Padding(
          padding: EdgeInsets.only(left: 24, right: 24),
          child: Column(
            children: [
              TextField(
                focusNode: _textInputFocusNode,
                onSubmitted: (_) {
                  if (_isListNameValid) {
                    _onCreateShoppingListPressed();
                  } else {
                    _textInputFocusNode.requestFocus();
                  }
                },
                controller: _textController,
                enabled: !_loading,
                textCapitalization: TextCapitalization.sentences,
                style: TextStyle(fontFamilyFallback: ['NotoColorEmoji']),
                decoration: InputDecoration(hintText: "Gib einen Namen ein"),
              ),
              SizedBox(height: 20),
              Flex(
                direction: Axis.horizontal,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      child: OutlinedButton(
                          child: Text("Abbrechen"), onPressed: _loading ? null : () => Navigator.pop(context))),
                  SizedBox(width: 10),
                  Expanded(
                      child: ElevatedButton(
                          onPressed: (_isListNameValid && !_loading) ? _onCreateShoppingListPressed : null,
                          child: Text("Anlegen")))
                ],
              )
            ],
          ))
    ]);
  }

  Widget _buildProgressBar() {
    if (_loading) {
      return LinearProgressIndicator(minHeight: 5);
    } else {
      return SizedBox(height: 5);
    }
  }

  void _onCreateShoppingListPressed() async {
    setState(() => _loading = true);

    try {
      await widget._onCreateShoppingList(_textController.text.trim());
      Navigator.pop(context);
    } catch (e) {
      showErrorDialog(context, "Ist der Speicher voll oder hast du einen Fehler beim Anlegen der Liste gemacht?");
    } finally {
      setState(() => _loading = false);
    }
  }
}
