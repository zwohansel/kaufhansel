import 'package:flutter/material.dart';

void showErrorDialog(BuildContext context, String text) {
  showDialog(
      context: context,
      builder: (context) => AlertDialog(
          title: Center(
              child: Text(
            "🤷‍♂️",
            style: TextStyle(fontFamilyFallback: ["NotoColorEmoji"], fontSize: 100),
          )),
          content: Text(text, textAlign: TextAlign.center)));
}
