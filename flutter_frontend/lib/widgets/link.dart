import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Link extends StatelessWidget {
  final String _url;
  final String _text;
  final TextStyle _style;
  final TextAlign _textAlign;

  const Link(this._url, {String text, TextStyle style, TextAlign textAlign})
      : _text = text,
        _style = style,
        _textAlign = textAlign;

  @override
  Widget build(BuildContext context) {
    final displayText = _text == null ? _url : _text;
    final displayStyle =
        _style == null ? Theme.of(context).textTheme.subtitle2.apply(decoration: TextDecoration.underline) : _style;
    return InkWell(
      child: Text(
        displayText,
        style: displayStyle,
        textAlign: _textAlign,
      ),
      onTap: () => launch(_url),
    );
  }
}
