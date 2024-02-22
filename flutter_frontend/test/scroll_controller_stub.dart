import 'package:flutter/material.dart';
import 'package:flutter/src/gestures/drag.dart';
import 'package:flutter/src/rendering/viewport_offset.dart';

class ScrollControllerStub implements ScrollController {
  @override
  void addListener(VoidCallback listener) {}

  @override
  Future<void> animateTo(double offset, {Duration? duration, Curve? curve}) async {
    return;
  }

  @override
  void attach(ScrollPosition position) {}

  @override
  ScrollPosition createScrollPosition(ScrollPhysics physics, ScrollContext context, ScrollPosition? oldPosition) {
    throw UnimplementedError();
  }

  @override
  void debugFillDescription(List<String> description) {}

  @override
  String get debugLabel => throw UnimplementedError();

  @override
  void detach(ScrollPosition position) {}

  @override
  void dispose() {}

  @override
  bool get hasClients => throw UnimplementedError();

  @override
  bool get hasListeners => throw UnimplementedError();

  @override
  double get initialScrollOffset => throw UnimplementedError();

  @override
  void jumpTo(double value) {}

  @override
  bool get keepScrollOffset => throw UnimplementedError();

  @override
  void notifyListeners() {}

  @override
  double get offset => throw UnimplementedError();

  @override
  ScrollPosition get position => new ScrollPositionStub();

  @override
  Iterable<ScrollPosition> get positions => throw UnimplementedError();

  @override
  void removeListener(VoidCallback listener) {}

  @override
  // TODO: implement onAttach
  ScrollControllerCallback? get onAttach => throw UnimplementedError();

  @override
  // TODO: implement onDetach
  ScrollControllerCallback? get onDetach => throw UnimplementedError();
}

class ScrollPositionStub implements ScrollPosition {
  @override
  void absorb(ScrollPosition other) {}

  @override
  ScrollActivity get activity => throw UnimplementedError();

  @override
  void addListener(VoidCallback listener) {}

  @override
  bool get allowImplicitScrolling => throw UnimplementedError();

  @override
  Future<void> animateTo(double to, {Duration? duration, Curve? curve}) {
    throw UnimplementedError();
  }

  @override
  double applyBoundaryConditions(double value) {
    throw UnimplementedError();
  }

  @override
  bool applyContentDimensions(double minScrollExtent, double maxScrollExtent) {
    throw UnimplementedError();
  }

  @override
  void applyNewDimensions() {}

  @override
  bool applyViewportDimension(double viewportDimension) {
    throw UnimplementedError();
  }

  @override
  bool get atEdge => throw UnimplementedError();

  @override
  Axis get axis => throw UnimplementedError();

  @override
  AxisDirection get axisDirection => throw UnimplementedError();

  @override
  void beginActivity(ScrollActivity? newActivity) {}

  @override
  ScrollContext get context => throw UnimplementedError();

  @override
  ScrollMetrics copyWith(
      {double? minScrollExtent,
      double? maxScrollExtent,
      double? pixels,
      double? viewportDimension,
      AxisDirection? axisDirection,
      double? devicePixelRatio}) {
    throw UnimplementedError();
  }

  @override
  void correctBy(double correction) {}

  @override
  bool correctForNewDimensions(ScrollMetrics oldPosition, ScrollMetrics newPosition) {
    throw UnimplementedError();
  }

  @override
  void correctPixels(double value) {}

  @override
  void debugFillDescription(List<String> description) {}

  @override
  String get debugLabel => throw UnimplementedError();

  @override
  void didEndScroll() {}

  @override
  void didOverscrollBy(double value) {}

  @override
  void didStartScroll() {}

  @override
  void didUpdateScrollDirection(ScrollDirection direction) {}

  @override
  void didUpdateScrollPositionBy(double delta) {}

  @override
  void dispose() {}

  @override
  Drag drag(DragStartDetails details, VoidCallback dragCancelCallback) {
    throw UnimplementedError();
  }

  @override
  Future<void> ensureVisible(RenderObject object,
      {double alignment = 0.0,
      Duration duration = Duration.zero,
      Curve curve = Curves.ease,
      ScrollPositionAlignmentPolicy alignmentPolicy = ScrollPositionAlignmentPolicy.explicit,
      RenderObject? targetRenderObject}) {
    throw UnimplementedError();
  }

  @override
  double get extentAfter => throw UnimplementedError();

  @override
  double get extentBefore => throw UnimplementedError();

  @override
  double get extentInside => throw UnimplementedError();

  @override
  void forcePixels(double value) {}

  @override
  bool get hasContentDimensions => throw UnimplementedError();

  @override
  bool get hasListeners => throw UnimplementedError();

  @override
  bool get hasPixels => throw UnimplementedError();

  @override
  bool get hasViewportDimension => throw UnimplementedError();

  @override
  bool get haveDimensions => throw UnimplementedError();

  @override
  ScrollHoldController hold(VoidCallback holdCancelCallback) {
    throw UnimplementedError();
  }

  @override
  ValueNotifier<bool> get isScrollingNotifier => throw UnimplementedError();

  @override
  void jumpTo(double value) {}

  @override
  void jumpToWithoutSettling(double value) {}

  @override
  bool get keepScrollOffset => throw UnimplementedError();

  @override
  double get maxScrollExtent => 0;

  @override
  double get minScrollExtent => throw UnimplementedError();

  @override
  Future<void> moveTo(double to, {Duration? duration, Curve? curve, bool? clamp = true}) {
    throw UnimplementedError();
  }

  @override
  void notifyListeners() {}

  @override
  bool get outOfRange => throw UnimplementedError();

  @override
  ScrollPhysics get physics => throw UnimplementedError();

  @override
  double get pixels => throw UnimplementedError();

  @override
  void pointerScroll(double delta) {}

  @override
  bool recommendDeferredLoading(BuildContext context) {
    throw UnimplementedError();
  }

  @override
  void removeListener(VoidCallback listener) {}

  @override
  void restoreOffset(double offset, {bool initialRestore = false}) {}

  @override
  void restoreScrollOffset() {}

  @override
  void saveOffset() {}

  @override
  void saveScrollOffset() {}

  @override
  double setPixels(double newPixels) {
    throw UnimplementedError();
  }

  @override
  ScrollDirection get userScrollDirection => throw UnimplementedError();

  @override
  double get viewportDimension => throw UnimplementedError();

  @override
  // TODO: implement devicePixelRatio
  double get devicePixelRatio => throw UnimplementedError();

  @override
  void didUpdateScrollMetrics() {
    // TODO: implement didUpdateScrollMetrics
  }

  @override
  // TODO: implement extentTotal
  double get extentTotal => throw UnimplementedError();
}
