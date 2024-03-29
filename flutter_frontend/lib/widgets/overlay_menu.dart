import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

// Overlay menu inspired by https://github.com/shubham030/simple_account_menu

class OverlayMenuButton extends StatefulWidget {
  final GlobalKey _overlayKey = LabeledGlobalKey("de.zwohansel.kaufhansel.customOverlayWidget");

  final Widget _button;
  final Widget? _buttonOpen;
  final Widget _child;
  final double _heightOffset;
  final double _widthOffset;

  OverlayMenuButton(
      {required Widget button,
      required Widget child,
      Widget? buttonOpen,
      double heightOffset = 0,
      double widthOffset = 0})
      : _button = button,
        _child = child,
        _buttonOpen = buttonOpen,
        _heightOffset = heightOffset,
        _widthOffset = widthOffset;

  @override
  _OverlayMenuButtonState createState() => _OverlayMenuButtonState();
}

class _OverlayMenuButtonState extends State<OverlayMenuButton> {
  late OverlayEntry _overlayEntry;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _overlayEntry = OverlayEntry(
      builder: (_) => _OverlayMenu(
        child: widget._child,
        overlayKey: widget._overlayKey,
        onBarrierClicked: _closeMenu,
        heightOffset: widget._heightOffset,
        widthOffset: widget._widthOffset,
      ),
    );
  }

  @override
  void didUpdateWidget(covariant OverlayMenuButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The overlay entry builder does notice that its input values (e.g. the child) has
    // changed and does not rebuild the _OverlayMenu. Therefore we have to trigger the rebuild manually.
    // However; We can not do that directly since we are already in the build phase.
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _overlayEntry.markNeedsBuild();
    });
  }

  @override
  Widget build(_) {
    return IconButton(
        key: widget._overlayKey,
        icon: _buildButton(),
        splashRadius: 23,
        onPressed: () {
          if (_isOpen) {
            _closeMenu();
          } else {
            _openMenu();
          }
        });
  }

  Widget _buildButton() {
    final buttonOpen = widget._buttonOpen;
    if (buttonOpen != null && _isOpen) {
      return buttonOpen;
    } else {
      return widget._button;
    }
  }

  void _openMenu() {
    Overlay.of(context).insert(_overlayEntry);
    setState(() => _isOpen = !_isOpen);
  }

  void _closeMenu() {
    _overlayEntry.remove();
    setState(() => _isOpen = !_isOpen);
  }
}

class _OverlayMenu extends StatelessWidget {
  final Widget _child;
  final GlobalKey _overlayKey;
  final VoidCallback _onBarrierClicked;
  final double heightOffset;
  final double widthOffset;

  _OverlayMenu(
      {required Widget child,
      required GlobalKey overlayKey,
      required VoidCallback onBarrierClicked,
      double heightOffset = 0,
      double widthOffset = 0})
      : _child = child,
        _overlayKey = overlayKey,
        _onBarrierClicked = onBarrierClicked,
        heightOffset = heightOffset,
        widthOffset = widthOffset;

  @override
  Widget build(context) {
    final double padding = 12.0;
    final double borderRadius = 4.0;
    RenderObject? renderObject = _overlayKey.currentContext?.findRenderObject();
    RenderBox? renderBox = renderObject as RenderBox?;
    Size buttonSize = renderBox?.size ?? Size(0, 0);
    Offset buttonPosition = renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;
    double calculatedWidthOffset = (widthOffset != 0) ? (widthOffset + 2 * padding + 2 * borderRadius) : 0;

    final theme = Theme.of(context);
    return Stack(children: [
      GestureDetector(
        onTap: _onBarrierClicked,
        child: Container(color: Colors.transparent),
      ),
      Positioned(
        top: buttonPosition.dy + buttonSize.height + heightOffset,
        left: buttonPosition.dx + buttonSize.width - calculatedWidthOffset,
        child: Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 3,
                  blurRadius: 4,
                  offset: Offset(0, 3),
                )
              ],
              border: Border.all(color: Colors.grey),
              color: Colors.white,
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            child: Theme(
              data: theme.copyWith(iconTheme: theme.iconTheme.copyWith(color: Colors.white)),
              child: Padding(
                padding: EdgeInsets.all(padding),
                child: _child,
              ),
            ),
          ),
        ),
      ),
    ]);
  }
}
