import 'package:flutter/material.dart';

Future<bool> showConfirmDialog(BuildContext context, String text,
    {String title = "Achtung!",
    String confirmBtnLabel = "Ok",
    Color confirmBtnColor = Colors.red,
    String cancelBtnLabel = "Abbrechen",
    bool hideCancelBtn = false}) {
  return showDialog<bool>(
    barrierDismissible: false,
    context: context,
    builder: (context) =>
        _ConfirmationDialog(title, text, confirmBtnLabel, confirmBtnColor, cancelBtnLabel, hideCancelBtn),
  );
}

class _ConfirmationDialog extends StatelessWidget {
  final String _title;
  final String _text;
  final String _confirmBtnLabel;
  final Color _confirmBtnColor;
  final String _cancelBtnLabel;
  final bool _hideCancelBtn;

  const _ConfirmationDialog(
      this._title, this._text, this._confirmBtnLabel, this._confirmBtnColor, this._cancelBtnLabel, this._hideCancelBtn);

  @override
  Widget build(BuildContext context) {
    List<Widget> buttonRow = [];
    if (!_hideCancelBtn) {
      buttonRow.add(
        Expanded(
          child: OutlinedButton(
            child: Text(_cancelBtnLabel),
            onPressed: () => Navigator.pop(context, false),
          ),
        ),
      );
      buttonRow.add(SizedBox(width: 10));
    }
    buttonRow.add(
      ElevatedButton(
        style: ElevatedButton.styleFrom(primary: _confirmBtnColor),
        onPressed: () => Navigator.pop(context, true),
        child: Text(_confirmBtnLabel),
      ),
    );

    return SimpleDialog(title: Text(_title), children: [
      Padding(
          padding: EdgeInsets.only(left: 24, right: 24, top: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_text),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: _hideCancelBtn ? MainAxisAlignment.center : MainAxisAlignment.spaceBetween,
                children: buttonRow,
              )
            ],
          ))
    ]);
  }
}
