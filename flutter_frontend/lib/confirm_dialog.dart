import 'package:flutter/material.dart';

Future<bool> showConfirmDialog(BuildContext context, String text,
    {String title = "Achtung!",
    String confirmBtnLabel = "Ok",
    Color confirmBtnColor = Colors.red,
    String cancelBtnLabel = "Abbrechen"}) {
  return showDialog<bool>(
    barrierDismissible: false,
    context: context,
    builder: (context) => _ConfirmationDialog(title, text, confirmBtnLabel, confirmBtnColor, cancelBtnLabel),
  );
}

class _ConfirmationDialog extends StatelessWidget {
  final String _title;
  final String _text;
  final String _confirmBtnLabel;
  final Color _confirmBtnColor;
  final String _cancelBtnLabel;

  const _ConfirmationDialog(
      this._title, this._text, this._confirmBtnLabel, this._confirmBtnColor, this._cancelBtnLabel);

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(title: Text(_title), children: [
      Padding(
          padding: EdgeInsets.only(left: 24, right: 24, top: 12),
          child: Column(
            children: [
              Text(_text),
              SizedBox(height: 20),
              Flex(
                direction: Axis.horizontal,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      child:
                          OutlinedButton(child: Text(_cancelBtnLabel), onPressed: () => Navigator.pop(context, false))),
                  SizedBox(width: 10),
                  Expanded(
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(primary: _confirmBtnColor),
                          onPressed: () => Navigator.pop(context, true),
                          child: Text(_confirmBtnLabel)))
                ],
              )
            ],
          ))
    ]);
  }
}
