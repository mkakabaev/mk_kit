import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// An abstract delegate that computes the baseline position for a child widget.
///
/// Implementations of [MKBaselineDelegate] provide a way to determine the
/// baseline offset for a given child size. This is used by [MKBaseline] to
/// align its child according to a custom baseline logic.
abstract class MKBaselineDelegate {
  /// Returns the baseline offset (distance from the top) for the given [childSize].
  double computeBaseline(Size childSize);
}

class MKBaselineAlignmentDelegate implements MKBaselineDelegate {
  /// The alignment of the baseline, as a fraction of the child's height,
  ///
  /// A value of 0.0 means the baseline is at the bottom of the child,
  /// a value of 1.0 means the baseline is at the top of the child,
  /// and a value of 0.5 means the baseline is in the middle of the child.
  ///
  /// Can be negative to set the baseline below the child's bottom.
  /// Can be greater than 1.0 to set the baseline above the child's top.
  final double alignment;

  const MKBaselineAlignmentDelegate({required this.alignment});

  @override
  double computeBaseline(Size childSize) {
    return childSize.height * (1.0 - alignment);
  }
}

///
/// A widget that positions its child according to a custom baseline.
///
/// [MKBaseline] allows you to specify how the baseline of its child should be
/// calculated and aligned, using a [MKBaselineDelegate]. This is useful for
/// aligning widgets that do not natively support baselines, or for custom
/// baseline alignment scenarios (such as aligning shapes, icons, or custom
/// widgets with text).
///
/// The [delegate] determines the baseline offset for the child, which is used
/// for layout and alignment. Optionally, [debugDrawBaseline] can be set to true
/// to visually display the computed baseline for debugging purposes.
///
/// Example usage:
/// ```dart
/// MKBaseline(
///   delegate: MKBaselinePositionDelegate(position: 0.5),
///   debugDrawBaseline: true,
///   child: MyWidget(),
/// )
/// ```
////
class MKBaseline extends SingleChildRenderObjectWidget {
  final MKBaselineDelegate delegate;
  final bool debugDrawBaseline;

  const MKBaseline({super.key, super.child, required this.delegate, this.debugDrawBaseline = false});

  @override
  RenderObject createRenderObject(BuildContext context) =>
      RenderMKBaseline(delegate: delegate, debugDrawBaseline: debugDrawBaseline);

  @override
  void updateRenderObject(BuildContext context, RenderMKBaseline renderObject) {
    renderObject.delegate = delegate;
    renderObject.debugDrawBaseline = debugDrawBaseline;
  }
}

class RenderMKBaseline extends RenderShiftedBox {
  RenderMKBaseline({RenderBox? child, required MKBaselineDelegate delegate, required bool debugDrawBaseline})
    : _delegate = delegate,
      _debugDrawBaseline = debugDrawBaseline,
      super(child);

  bool _debugDrawBaseline;

  set debugDrawBaseline(bool value) {
    if (_debugDrawBaseline != value) {
      _debugDrawBaseline = value;
      markNeedsLayout();
    }
  }

  MKBaselineDelegate _delegate;

  set delegate(MKBaselineDelegate value) {
    if (_delegate != value) {
      _delegate = value;
      markNeedsLayout();
    }
  }

  @override
  double? computeDryBaseline(covariant BoxConstraints constraints, TextBaseline baseline) {
    final RenderBox? child = this.child;
    if (child == null) {
      return null;
    }
    final childSize = child.getDryLayout(constraints);
    return _delegate.computeBaseline(childSize);
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final RenderBox? child = this.child;
    if (child == null) {
      return constraints.smallest;
    }
    return child.getDryLayout(constraints);
  }

  @override
  void performLayout() {
    final RenderBox? child = this.child;
    if (child == null) {
      size = constraints.smallest;
      return;
    }

    child.layout(constraints, parentUsesSize: true);
    size = child.size;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final RenderBox? child = this.child;
    if (child != null) {
      context.paintChild(child, offset);
    }

    if (_debugDrawBaseline && kDebugMode) {
      final baseline = _delegate.computeBaseline(child?.size ?? Size.zero);
      context.canvas.drawLine(
        Offset(0, baseline) + offset,
        Offset(child?.size.width ?? 0, baseline) + offset,
        Paint()..color = Colors.orange,
      );
    }
  }

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    final RenderBox? child = this.child;
    if (child == null) {
      return super.computeDistanceToActualBaseline(baseline);
    }

    // ignore: avoid-passing-self-as-argument
    final childSize = child.getDryLayout(child.constraints);
    return _delegate.computeBaseline(childSize);
  }
}
