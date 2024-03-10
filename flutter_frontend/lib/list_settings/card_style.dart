import 'package:flutter/material.dart';

TextStyle? getCardSubtitleStyle(BuildContext context) {
  final theme = Theme.of(context);
  return theme.textTheme.bodyMedium?.apply(color: theme.textTheme.bodySmall?.color);
}

TextStyle? getCardHeadlineStyle(BuildContext context) {
  return Theme.of(context).textTheme.titleLarge;
}
