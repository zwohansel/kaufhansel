import 'package:flutter/material.dart';

class TitleWidget extends StatelessWidget {
  final String _title;
  final String? _subTitle;

  TitleWidget(this._title, {String? subTitle}) : _subTitle = subTitle;

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = [];
    final subTitle = _subTitle;
    if (subTitle != null && subTitle.isNotEmpty) {
      children.add(Text(
        subTitle,
        style: Theme.of(context).primaryTextTheme.titleMedium?.apply(color: Colors.white70),
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
            size: Theme.of(context).primaryTextTheme.titleLarge?.fontSize,
          ),
          Flexible(child: Text(_title)),
        ]),
        ...children
      ],
    );
  }
}
