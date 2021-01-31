import 'package:flutter/material.dart';

class EditableTextLabel extends StatefulWidget {
  final String _initialText;
  final Future<bool> Function(String) _onSubmit;
  final TextStyle _textStyle;
  final bool _enabled;

  const EditableTextLabel(
      {@required String text,
      @required Future<bool> Function(String) onSubmit,
      @required TextStyle textStyle,
      bool enabled = true})
      : _initialText = text,
        _onSubmit = onSubmit,
        _textStyle = textStyle,
        _enabled = enabled;

  @override
  _EditableTextLabelState createState() => _EditableTextLabelState(_initialText);
}

const _iconSize = 24.0;
const _iconPadding = EdgeInsets.all(8.0);

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
    return SizedBox(
      height: 48,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: _buildRow(context),
      ),
    );
  }

  List<Widget> _buildRow(BuildContext context) {
    if (_loading) {
      return [
        Flexible(
          child: Text(
            _textEditingController.text,
            overflow: TextOverflow.ellipsis,
            style: widget._textStyle,
          ),
        ),
        Padding(
          padding: _iconPadding,
          child: SizedBox(
            height: _iconSize,
            width: _iconSize,
            child: CircularProgressIndicator(),
          ),
        )
      ];
    }
    if (_editing) {
      return [
        Flexible(
          child: TextField(
            controller: _textEditingController,
            enabled: widget._enabled,
            textCapitalization: TextCapitalization.sentences,
            style: widget._textStyle,
            focusNode: _focusNode,
            onSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              suffixIcon: IconButton(
                icon: Icon(Icons.check),
                iconSize: _iconSize,
                padding: _iconPadding,
                splashRadius: _iconSize,
                onPressed: _valid ? _submit : null,
              ),
            ),
          ),
        ),
      ];
    } else {
      return [
        Flexible(
          child: Text(
            _textEditingController.text,
            overflow: TextOverflow.ellipsis,
            style: widget._textStyle,
          ),
        ),
        _buildEditIcon(),
      ];
    }
  }

  Widget _buildEditIcon() {
    if (!widget._enabled) {
      return Container();
    }
    return IconButton(
        icon: Icon(Icons.drive_file_rename_outline),
        iconSize: _iconSize,
        padding: _iconPadding,
        splashRadius: _iconSize,
        onPressed: _loading
            ? null
            : () => setState(() {
                  //_textEditingController.text = widget._text;
                  _textEditingController.selection =
                      TextSelection(baseOffset: 0, extentOffset: _textEditingController.text.length);
                  _valid = true;
                  _editing = true;
                  _focusNode.requestFocus();
                }));
  }

  void _submit() async {
    if (!_valid) {
      _focusNode.requestFocus();
      return;
    }
    try {
      setState(() => _loading = true);
      final newText = _textEditingController.text.trim();
      if (newText == currentText) {
        setState(() => _editing = false);
        return;
      }

      if (await widget._onSubmit(newText)) {
        currentText = newText;
        setState(() => _editing = false);
      } else {
        _focusNode.requestFocus();
      }
    } finally {
      setState(() => _loading = false);
    }
  }
}
