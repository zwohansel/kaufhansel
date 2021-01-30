import 'package:flutter/material.dart';

class EditableTextLabel extends StatefulWidget {
  final String _initialText;
  final Future<bool> Function(String) _onSubmit;
  final TextStyle _textStyle;

  const EditableTextLabel(
      {@required String text, @required void Function(String) onSubmit, @required TextStyle textStyle})
      : _initialText = text,
        _onSubmit = onSubmit,
        _textStyle = textStyle;

  @override
  _EditableTextLabelState createState() => _EditableTextLabelState(_initialText);
}

class _EditableTextLabelState extends State<EditableTextLabel> {
  final TextEditingController _textEditingController;
  final _focusNode = new FocusNode();
  String currentText;
  bool _editing = false;
  bool _valid = false;
  bool _loading = false;

  _EditableTextLabelState(String text)
      : _textEditingController = new TextEditingController(text: text),
        currentText = text;

  @override
  void initState() {
    super.initState();
    _textEditingController.addListener(() {
      setState(() => _valid = _textEditingController.text.trim().isNotEmpty);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Flexible(
            child: Text(
          _textEditingController.text,
          overflow: TextOverflow.ellipsis,
          style: widget._textStyle,
        )),
        CircularProgressIndicator()
      ]);
    }
    if (_editing) {
      return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Flexible(
            child: TextField(
          controller: _textEditingController,
          textCapitalization: TextCapitalization.sentences,
          style: widget._textStyle,
          focusNode: _focusNode,
          onSubmitted: (_) => _submit(),
          decoration: InputDecoration(
              suffixIcon: IconButton(
            icon: Icon(Icons.check),
            onPressed: _valid ? _submit : null,
          )),
        )),
      ]);
    } else {
      return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Flexible(
            child: Text(
          _textEditingController.text,
          overflow: TextOverflow.ellipsis,
          style: widget._textStyle,
        )),
        IconButton(
            icon: Icon(Icons.drive_file_rename_outline),
            onPressed: _loading
                ? null
                : () => setState(() {
                      //_textEditingController.text = widget._text;
                      _textEditingController.selection =
                          TextSelection(baseOffset: 0, extentOffset: _textEditingController.text.length);
                      _valid = true;
                      _editing = true;
                      _focusNode.requestFocus();
                    }))
      ]);
    }
  }

  void _submit() async {
    if (_valid) {
      setState(() => _loading = true);
      final newText = _textEditingController.text.trim();
      if (newText == currentText) {
        setState(() => _loading = false);
        setState(() => _editing = false);
        return;
      }

      if (await widget._onSubmit(newText)) {
        currentText = newText;
        setState(() => _loading = false);
        setState(() => _editing = false);
      } else {
        _focusNode.requestFocus();
      }
    } else {
      _focusNode.requestFocus();
    }
  }
}
