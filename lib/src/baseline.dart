import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Computes the baseline that [BaselineBox] reports for its child.
///
/// [computeBaseline] returns the distance from the top of the child to that
/// baseline. [childBaseline] is the child's own baseline for the requested
/// [TextBaseline], or null when the child has none. A delegate may use that
/// value or ignore it.
abstract interface class BaselineBoxDelegate() {
  /// Returns the baseline offset (distance from the top) for the given [childSize].
  ///
  /// [childBaseline] is the distance from the top of the child to the child's
  /// own baseline, or null if the child has no baseline.
  double computeBaseline(Size childSize, double? childBaseline);
}

/// Reports a baseline at a fraction of the child's height.
///
/// The child's own baseline is ignored.
class const FractionalBaselineDelegate({
  /// The alignment of the baseline, as a fraction of the child's height,
  ///
  /// A value of 0.0 means the baseline is at the bottom of the child,
  /// a value of 1.0 means the baseline is at the top of the child,
  /// and a value of 0.5 means the baseline is in the middle of the child.
  ///
  /// Can be negative to set the baseline below the child's bottom.
  /// Can be greater than 1.0 to set the baseline above the child's top.
  required final double alignment,
  final bool respectChildBaseline = true,
}) implements BaselineBoxDelegate {
  @override
  double computeBaseline(Size childSize, double? baseline) {
    var result = childSize.height * (1.0 - alignment);

    if (respectChildBaseline && baseline != null) {
      result -= childSize.height - baseline;
    }

    return result;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is FractionalBaselineDelegate && other.alignment == alignment;
  }

  @override
  int get hashCode => alignment.hashCode;
}

/// Overrides the baseline of its child.
///
/// [BaselineBox] reports the baseline from [delegate] instead of the child's own.
/// The child is laid out and painted in place. Ancestors that align on a baseline,
/// such as a [Row] with [CrossAxisAlignment.baseline], use that reported value.
/// This replaces a baseline the child already has, and supplies one for widgets
/// that have none, such as shapes and icons.
///
/// The delegate is given the child's own baseline for the requested
/// [TextBaseline], or null when the child has none, and may use that value or
/// ignore it. [FractionalBaselineDelegate] ignores it, so alphabetic and
/// ideographic stay the same offset.
///
/// Set [debugDrawBaseline] to draw the reported alphabetic baseline in debug builds.
///
/// ```dart
/// BaselineBox(
///   delegate: FractionalBaselineDelegate(alignment: 0.5),
///   debugDrawBaseline: true,
///   child: MyWidget(),
/// )
/// ```
class const BaselineBox({
  super.key,
  super.child,
  required final BaselineBoxDelegate delegate,
  final bool debugDrawBaseline = false,
}) extends SingleChildRenderObjectWidget {
  @override
  RenderObject createRenderObject(BuildContext context) =>
      RenderBaselineBox(delegate: delegate, debugDrawBaseline: debugDrawBaseline);

  @override
  void updateRenderObject(BuildContext context, RenderBaselineBox renderObject) {
    renderObject.delegate = delegate;
    renderObject.debugDrawBaseline = debugDrawBaseline;
  }
}

class RenderBaselineBox({
  RenderBox? child,
  required var BaselineBoxDelegate _delegate,
  required var bool _debugDrawBaseline,
}) extends RenderShiftedBox {
  this : super(child);

  set debugDrawBaseline(bool value) {
    if (_debugDrawBaseline != value) {
      _debugDrawBaseline = value;
      markNeedsPaint();
    }
  }

  set delegate(BaselineBoxDelegate value) {
    if (_delegate != value) {
      _delegate = value;
      markNeedsLayout();
    }
  }

  @override
  double? computeDryBaseline(covariant BoxConstraints constraints, TextBaseline baseline) {
    final child = this.child;
    if (child == null) {
      return null;
    }
    final childSize = child.getDryLayout(constraints);
    final childBaseline = child.getDryBaseline(constraints, baseline);
    return _delegate.computeBaseline(childSize, childBaseline);
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final child = this.child;
    if (child == null) {
      return constraints.smallest;
    }
    return child.getDryLayout(constraints);
  }

  @override
  void performLayout() {
    final child = this.child;
    if (child == null) {
      size = constraints.smallest;
      return;
    }

    child.layout(constraints, parentUsesSize: true);
    size = child.size;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    super.paint(context, offset);

    final child = this.child;
    if (!_debugDrawBaseline || !kDebugMode || child == null) {
      return;
    }

    final childBaseline = child.getDistanceToBaseline(TextBaseline.alphabetic, onlyReal: true);
    final baseline = _delegate.computeBaseline(child.size, childBaseline);
    context.canvas.drawLine(
      offset + Offset(0, baseline),
      offset + Offset(size.width, baseline),
      Paint()..color = const Color(0xFFFF9800),
    );
  }

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    final child = this.child;
    if (child == null) {
      return null;
    }

    final childBaseline = child.getDistanceToActualBaseline(baseline);
    return _delegate.computeBaseline(child.size, childBaseline);
  }
}
