import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Link extends StatelessWidget {
  final _url;
  final _text;
  final _style;

  const Link(this._url, {String text, TextStyle style})
      : _text = text,
        _style = style;

  @override
  Widget build(BuildContext context) {
    final displayText = _text == null ? _url : _text;
    final displayStyle =
        _style == null ? Theme.of(context).textTheme.subtitle2.apply(decoration: TextDecoration.underline) : _style;
    return InkWell(
      child: Text(displayText, style: displayStyle),
      onTap: () => launch(_url),
    );
  }
}
