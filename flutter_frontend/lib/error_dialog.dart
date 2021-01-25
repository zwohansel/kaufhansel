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
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(text, textAlign: TextAlign.center),
              SizedBox(height: 24, width: 24),
              Center(
                  child: TextButton(onPressed: () => Navigator.pop(context), child: Text("Ist dann halt schon so...")))
            ],
          )));
}
