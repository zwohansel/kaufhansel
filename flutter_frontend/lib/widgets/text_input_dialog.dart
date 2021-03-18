import 'package:flutter/material.dart';
import 'package:kaufhansel_client/generated/l10n.dart';

import 'error_dialog.dart';

Future<String> showTextInputDialog(BuildContext context,
    {@required String title,
    String hintText,
    String confirmBtnLabel,
    String cancelBtnLabel,
    Future<void> Function(String value) onConfirm}) {
  final displayConfirmBtnLabel = confirmBtnLabel ?? AppLocalizations.of(context).ok;
  final displayCancelBtnLabel = cancelBtnLabel ?? AppLocalizations.of(context).cancel;
  return showDialog<String>(
    barrierDismissible: false,
    context: context,
    builder: (context) => _TextInputDialog(title, hintText, displayConfirmBtnLabel, displayCancelBtnLabel, onConfirm),
  );
}

class _TextInputDialog extends StatefulWidget {
  final String title;
  final String hintText;
  final String confirmBtnLabel;
  final String cancelBtnLabel;
  final Future<void> Function(String value) onConfirm;

  const _TextInputDialog(this.title, this.hintText, this.confirmBtnLabel, this.cancelBtnLabel, this.onConfirm);

  @override
  _CreateTextInputDialogState createState() => _CreateTextInputDialogState();
}

class _CreateTextInputDialogState extends State<_TextInputDialog> {
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
    return SimpleDialog(title: Text(widget.title), children: [
      _buildProgressBar(),
      Padding(
        padding: EdgeInsets.only(left: 24, right: 24),
        child: Column(
          children: [
            TextField(
              focusNode: _textInputFocusNode,
              onSubmitted: (_) {
                if (_isListNameValid) {
                  Navigator.pop(context, _textController.text);
                } else {
                  _textInputFocusNode.requestFocus();
                }
              },
              controller: _textController,
              enabled: !_loading,
              textCapitalization: TextCapitalization.sentences,
              style: TextStyle(fontFamilyFallback: ['NotoColorEmoji']),
              decoration: InputDecoration(hintText: widget.hintText),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: OutlinedButton(
                    child: Text(widget.cancelBtnLabel),
                    onPressed: _loading ? null : () => Navigator.pop(context),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                    child: ElevatedButton(
                        onPressed: (_isListNameValid && !_loading) ? _onConfirmPressed : null,
                        child: Text(widget.confirmBtnLabel)))
              ],
            )
          ],
        ),
      )
    ]);
  }

  Widget _buildProgressBar() {
    if (_loading) {
      return LinearProgressIndicator(minHeight: 5);
    } else {
      return SizedBox(height: 5);
    }
  }

  void _onConfirmPressed() async {
    setState(() => _loading = true);
    try {
      if (widget.onConfirm != null) {
        await widget.onConfirm(_textController.text.trim());
      }
      Navigator.pop(context, _textController.text);
    } catch (e) {
      showErrorDialog(context, AppLocalizations.of(context).exceptionGeneralTryAgainLater);
    } finally {
      setState(() => _loading = false);
    }
  }
}
