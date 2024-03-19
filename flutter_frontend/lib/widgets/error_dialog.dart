import 'package:flutter/material.dart';
import 'package:kaufhansel_client/generated/l10n.dart';
import 'package:kaufhansel_client/rest_client.dart';

Future<void> showErrorDialogForException(BuildContext context, Exception e, {String? altText}) {
  final localization = AppLocalizations.of(context);
  if (e is HttpResponseException && e.isUnauthenticated()) {
    return showErrorDialog(context, localization.exceptionUnAuthenticated, closeLabel: localization.willLoginAgain);
  }
  return showErrorDialog(context, altText ?? localization.exceptionUnknown(e));
}

Future<void> showErrorDialog(BuildContext context, String text, {String? closeLabel}) {
  final chosenCloseLabel = closeLabel ?? AppLocalizations.of(context).thatsJustHowItIs;
  return showCustomErrorDialog(context, Text(text, textAlign: TextAlign.center), chosenCloseLabel);
}

Future<void> showCustomErrorDialog(BuildContext context, Widget message, String closeLabel, {String? emoji}) {
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
