import 'package:flutter/material.dart';

class AsyncOperationIconButton extends StatelessWidget {
  final Icon _icon;
  final bool _loading;
  final VoidCallback _onPressed;

  const AsyncOperationIconButton({@required Icon icon, @required bool loading, @required VoidCallback onPressed})
      : _icon = icon,
        _loading = loading,
        _onPressed = onPressed;

  @override
  Widget build(BuildContext context) {
    final iconSize = _icon.size != null ? _icon.size : 24.0;
    return SizedBox(child: _buildButton(iconSize), width: iconSize * 2, height: iconSize * 2);
  }

  Widget _buildButton(double iconSize) {
    if (_loading) {
      return Center(
          child: SizedBox(
        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
        width: iconSize,
        height: iconSize,
      ));
    }

    return Center(
      child: IconButton(
        splashRadius: 23,
        icon: _icon,
        onPressed: _onPressed != null ? _onPressed : null,
      ),
    );
  }
}
