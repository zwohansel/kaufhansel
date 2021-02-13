import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Future<void> showErrorDialog(BuildContext context, String text) {
  final closeLabel = AppLocalizations.of(context).thatsJustHowItIs;
  return showCustomErrorDialog(context, Text(text, textAlign: TextAlign.center), closeLabel);
}

Future<void> showCustomErrorDialog(BuildContext context, Widget child, String closeLabel) {
  return showDialog(
      context: context,
      builder: (context) => AlertDialog(
          title: Center(
              child: Text(
            "🤷‍♂️",
            style: TextStyle(fontFamilyFallback: ["NotoColorEmoji"], fontSize: 100),
          )),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              child,
              SizedBox(height: 24, width: 24),
              Center(child: TextButton(onPressed: () => Navigator.pop(context), child: Text(closeLabel)))
            ],
          )));
}
