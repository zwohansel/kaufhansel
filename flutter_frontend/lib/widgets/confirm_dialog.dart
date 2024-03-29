import 'package:flutter/material.dart';
import 'package:kaufhansel_client/generated/l10n.dart';

Future<bool?> showConfirmDialog(BuildContext context, String text,
    {String? title,
    String? confirmBtnLabel,
    String? cancelBtnLabel,
    Color? confirmBtnColor,
    Color? confirmBtnFontColor,
    bool hideCancelBtn = false}) {
  final displayTitle = title == null ? AppLocalizations.of(context).important : title;
  final displayConfirmBtnLabel = confirmBtnLabel == null ? AppLocalizations.of(context).ok : confirmBtnLabel;
  final displayCancelBtnLabel = cancelBtnLabel == null ? AppLocalizations.of(context).cancel : cancelBtnLabel;

  return showDialog<bool>(
    barrierDismissible: false,
    context: context,
    builder: (context) => _ConfirmationDialog(
      displayTitle,
      text,
      displayConfirmBtnLabel,
      confirmBtnColor ?? Colors.red,
      confirmBtnFontColor ?? Colors.white,
      displayCancelBtnLabel,
      hideCancelBtn,
    ),
  );
}

class _ConfirmationDialog extends StatelessWidget {
  final String _title;
  final String _text;
  final String _confirmBtnLabel;
  final Color _confirmBtnColor;
  final Color _confirmBtnFontColor;
  final String _cancelBtnLabel;
  final bool _hideCancelBtn;

  const _ConfirmationDialog(this._title, this._text, this._confirmBtnLabel, this._confirmBtnColor,
      this._confirmBtnFontColor, this._cancelBtnLabel, this._hideCancelBtn);

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
      buttonRow.add(SizedBox(width: 10, height: 10));
    }
    buttonRow.add(
      ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: _confirmBtnColor),
        onPressed: () => Navigator.pop(context, true),
        child: Text(_confirmBtnLabel, style: TextStyle(color: _confirmBtnFontColor)),
      ),
    );

    return SimpleDialog(title: Text(_title), children: [
      Padding(
          padding: EdgeInsets.only(left: 24, right: 24, top: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_text),
              SizedBox(height: 20),
              IntrinsicHeight(
                child: Flex(
                  direction: MediaQuery.of(context).size.width > 400 ? Axis.horizontal : Axis.vertical,
                  mainAxisAlignment: _hideCancelBtn ? MainAxisAlignment.center : MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: buttonRow,
                ),
              )
            ],
          ))
    ]);
  }
}
