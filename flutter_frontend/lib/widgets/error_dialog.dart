import 'package:flutter/material.dart';

Future<void> showErrorDialog(BuildContext context, String text) {
  return showCustomErrorDialog(context, Text(text, textAlign: TextAlign.center));
}

Future<void> showCustomErrorDialog(BuildContext context, Widget child,
    {String closeLabel = "Ist dann halt schon so..."}) {
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
