import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:url_launcher/url_launcher.dart';

class Link extends StatelessWidget {
  final String _url;
  final String _text;
  final TextStyle _style;
  final TextAlign _textAlign;
  final bool _selectable;
  final IconData _trailingIcon;

  const Link(this._url,
      {String text, TextStyle style, TextAlign textAlign, bool selectable = false, IconData trailingIcon})
      : _text = text,
        _style = style,
        _textAlign = textAlign,
        _selectable = selectable,
        _trailingIcon = trailingIcon;

  @override
  Widget build(BuildContext context) {
    final displayStyle =
        _style == null ? Theme.of(context).textTheme.subtitle2.apply(decoration: TextDecoration.underline) : _style;
    List<Widget> children = [
      _buildText(displayStyle),
    ];
    if (_trailingIcon != null) {
      children.add(Icon(_trailingIcon, size: displayStyle.fontSize));
    }

    return InkWell(
        mouseCursor: _selectable ? SystemMouseCursors.text : SystemMouseCursors.click,
        child: Wrap(crossAxisAlignment: WrapCrossAlignment.center, children: children),
        onTap: () => _selectable ? null : launch(_url));
  }

  Widget _buildText(TextStyle displayStyle) {
    final displayText = _text == null ? _url : _text;
    if (_selectable) {
      return SelectableText(displayText, style: displayStyle, textAlign: _textAlign, onTap: () => launch(_url));
    } else {
      return Text(displayText, style: displayStyle, textAlign: _textAlign);
    }
  }
}
