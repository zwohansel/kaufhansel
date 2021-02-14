import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Future<void> showErrorDialog(BuildContext context, String text) {
  final closeLabel = AppLocalizations.of(context).thatsJustHowItIs;
  return showCustomErrorDialog(context, Text(text, textAlign: TextAlign.center), closeLabel);
}

Future<void> showCustomErrorDialog(BuildContext context, Widget message, String closeLabel, {String emoji}) {
  String displayEmoji;
  if (emoji == null || emoji.isEmpty) {
    displayEmoji = "🤷‍♂️";
  } else {
    displayEmoji = emoji;
  }
  return showDialog(
      context: context,
      builder: (context) => AlertDialog(
          title: Center(
              child: Text(displayEmoji, style: TextStyle(fontFamilyFallback: ["NotoColorEmoji"], fontSize: 100))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              message,
              SizedBox(height: 24, width: 24),
              Center(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: Text(closeLabel)))
            ],
          )));
}
