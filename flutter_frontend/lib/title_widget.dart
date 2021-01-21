import 'package:flutter/material.dart';

class TitleWidget extends StatelessWidget {
  final String _subTitle;

  TitleWidget({String subTitle}) : _subTitle = subTitle;

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = [Text('Kaufhansel')];
    if (_subTitle != null && _subTitle.isNotEmpty) {
      children.add(Padding(
        child: Text(
          _subTitle,
          style: Theme.of(context).primaryTextTheme.subtitle1.apply(color: Colors.white70),
        ),
        padding: EdgeInsets.only(left: 10),
      ));
    }

    return Flex(
      direction: Axis.horizontal,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          Icons.shopping_cart_outlined,
          size: Theme.of(context).primaryTextTheme.headline6.fontSize,
        ),
        Flex(
          direction: Axis.horizontal,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.ideographic,
          children: children,
        )
      ],
    );
  }
}
