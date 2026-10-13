import 'package:flutter/widgets.dart';

import 'multi_child_layout/delegate.dart';
import 'multi_child_layout/layout.dart';
import 'multi_child_layout/layout_id.dart';
import 'multi_child_layout/widget.dart';

///
/// Describes how one axis of [ReferenceSizedBox] is sized from the
/// reference widget's laid-out extent on that axis.
///
/// [none] leaves the axis to the incoming parent constraints. [exact] uses the
/// reference extent as both the minimum and the maximum. [custom] takes a
/// callback with the same contract as [getSize].
///
/// The returned range is clamped into the incoming parent constraints: a range
/// above the parent max shrinks to that max, and a range below the parent
/// minimum expands to that minimum.
///
/// mktodo: add child aligning and positioning
///
abstract class ReferenceSize {
  const ReferenceSize();

  /// Returns the min and max for this axis, or null to leave it to the parent.
  ///
  /// [extent] is the reference widget's size on this axis after it has been
  /// laid out with the incoming parent constraints.
  ReferenceSizeResult getSize(double extent);

  static ReferenceSizeResult _none(_) => null;
  static ReferenceSizeResult _exact(double size) => (maxSize: size, minSize: size);

  /// No extra constraint. The child uses the incoming parent constraints.
  static const none = ReferenceSize.custom(_none);

  /// Child extent matches the reference widget's laid-out extent on this axis.
  static const exact = ReferenceSize.custom(_exact);

  /// A rule that computes the min and max from the reference extent.
  ///
  /// Return null to leave that axis to the parent constraints. `minSize` must
  /// be finite and zero or greater, and `maxSize` must be at least `minSize`.
  const factory ReferenceSize.custom(ReferenceSizeCallback callback) = _CustomRule;
}

typedef ReferenceSizeResult = ({double minSize, double maxSize})?;
typedef ReferenceSizeCallback = ReferenceSizeResult Function(double extent);

// ------------------------------------------------------------------------------------------------

///
/// A widget that sizes its child from a reference widget's laid-out size.
///
/// The [reference] is laid out with the incoming constraints and is not painted.
/// [width] and [height] turn that laid-out size into constraints for [child].
///
/// ## Usage
///
/// ```dart
/// ReferenceSizedBox(
///   reference: SizedBox(width: 200, height: 100),
///   child: ColoredBox(color: Color(0xFF1565C0)),
///   width: ReferenceSize.exact, // Child width = reference laid-out width
///   height: ReferenceSize.none, // No height constraint
/// )
/// ```
///
/// ## Sizing Rules
///
/// - [ReferenceSize.none]: No extra constraint. The child uses the incoming parent constraints.
/// - [ReferenceSize.exact]: Child extent matches the reference widget's laid-out extent on that axis.
/// - [ReferenceSize.custom]: A callback returns the min and max for that axis, or null to leave it to the parent.
///
/// A custom rule can also be a class that implements [ReferenceSize].
///
/// ## Important Notes
///
/// - The [reference] is measured with the same incoming constraints and is not painted.
///   [ReferenceSize.exact] copies that laid-out size, so a reference larger than
///   the parent is measured at the parent's maximum.
/// - The [child] is sized from those rules and positioned at the top left.
/// - If no rule is specified for an axis, the child uses the parent's constraints for that dimension.
/// - A rule's min and max are clamped into the incoming parent constraints. A range larger than
///   the parent max shrinks to that max, and a range smaller than the parent minimum expands
///   to that minimum. The child and this widget are the same size.
///
class ReferenceSizedBox extends StatelessWidget {
  /// The widget whose dimensions will be used as a reference for sizing the [child].
  final Widget reference;

  /// The widget that will be sized according to the specified rules.
  final Widget child;

  /// The sizing rule to apply to the width.
  ///
  /// Defaults to [ReferenceSize.none].
  final ReferenceSize width;

  /// The sizing rule to apply to the height.
  ///
  /// Defaults to [ReferenceSize.none].
  final ReferenceSize height;

  const ReferenceSizedBox({
    super.key,
    required this.reference,
    required this.child,
    this.width = ReferenceSize.none,
    this.height = ReferenceSize.none,
  });

  @override
  Widget build(BuildContext context) {
    return CustomChildLayout<_LayoutID>(
      delegate: _Delegate(width: width, height: height),
      children: [
        ChildLayoutId.keyed(id: _LayoutID.relative, key: const ValueKey(_LayoutID.relative), child: reference),
        ChildLayoutId.keyed(id: _LayoutID.child, key: const ValueKey(_LayoutID.child), child: child),
      ],
    );
  }
}

enum _LayoutID { relative, child }

class _Delegate extends ChildLayoutDelegate<_LayoutID> {
  final ReferenceSize width;
  final ReferenceSize height;

  const _Delegate({required this.width, required this.height});

  @override
  Size performLayout(Map<_LayoutID, ChildLayout> childLayouts, BoxConstraints constraints) {
    final relative = childLayouts[_LayoutID.relative]!;
    relative.layoutConstrained(constraints);
    relative.shouldPaint = false;
    final relSize = relative.size;

    final child = childLayouts[_LayoutID.child]!;
    final tightened = _childConstraints(
      constraints,
      width: width.getSize(relSize.width),
      height: height.getSize(relSize.height),
    );
    final childSize = child.layout(
      minWidth: tightened.minWidth,
      maxWidth: tightened.maxWidth,
      minHeight: tightened.minHeight,
      maxHeight: tightened.maxHeight,
    );
    child.setPosition(0, 0);

    return childSize;
  }

  @override
  bool shouldRelayout(covariant _Delegate oldDelegate) {
    return width != oldDelegate.width || height != oldDelegate.height;
  }

  BoxConstraints _childConstraints(
    BoxConstraints constraints, {
    required ReferenceSizeResult? width,
    required ReferenceSizeResult? height,
  }) {
    _checkExtent(width, 'width');
    _checkExtent(height, 'height');
    return BoxConstraints(
      minWidth: width?.minSize ?? 0,
      maxWidth: width?.maxSize ?? double.infinity,
      minHeight: height?.minSize ?? 0,
      maxHeight: height?.maxSize ?? double.infinity,
    ).enforce(constraints);
  }

  void _checkExtent(ReferenceSizeResult? extent, String axis) {
    if (extent == null) {
      return;
    }
    final minSize = extent.minSize;
    final maxSize = extent.maxSize;
    if (minSize.isFinite && minSize >= 0 && !maxSize.isNaN && maxSize >= minSize) {
      return;
    }
    throw FlutterError.fromParts([
      ErrorSummary('ReferenceSize returned an invalid $axis extent.'),
      ErrorDescription(
        'minSize is $minSize and maxSize is $maxSize. '
        'minSize must be finite and greater than or equal to zero, '
        'and maxSize must be greater than or equal to minSize.',
      ),
    ]);
  }
}

// ------------------------------------------------------------------------------------------------

class _CustomRule implements ReferenceSize {
  final ReferenceSizeCallback _callback;

  const _CustomRule(this._callback);

  @override
  ReferenceSizeResult getSize(double extent) => _callback(extent);
}
