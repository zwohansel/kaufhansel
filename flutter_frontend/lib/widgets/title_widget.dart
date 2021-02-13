import 'package:flutter/material.dart';

class TitleWidget extends StatelessWidget {
  final String _title;
  final String _subTitle;

  TitleWidget(this._title, {String subTitle}) : _subTitle = subTitle;

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = [];
    if (_subTitle != null && _subTitle.isNotEmpty) {
      children.add(Text(
        _subTitle,
        style: Theme.of(context).primaryTextTheme.subtitle1.apply(color: Colors.white70),
      ));
    }

    return Wrap(
      direction: Axis.horizontal,
      crossAxisAlignment: WrapCrossAlignment.end,
      spacing: 10.0,
      children: [
        Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: Theme.of(context).primaryTextTheme.headline6.fontSize,
          ),
          Flexible(child: Text(_title)),
        ]),
        ...children
      ],
    );
  }
}
