import 'package:flutter/material.dart';

import 'multi_child_layout/multi_child_layout.dart';

///
/// mktodo: add child aligning and positioning
///
abstract class SizedRelativeToWidgetRule {
  SizedRelativeToWidgetRuleGetSizeResult getSize(double extent);

  static const none = _CustomRule(_none);
  static const exact = _CustomRule(_exact);
}

typedef SizedRelativeToWidgetRuleGetSizeResult = ({double minSize, double maxSize})?;

// ------------------------------------------------------------------------------------------------

///
/// A widget that sizes its child relative to another widget's dimensions using
/// customizable sizing rules for both vertical and horizontal axes.
///
/// This widget uses a multi-child layout to position a reference widget (which
/// is not painted) and a child widget. The child's size constraints are calculated
/// based on the reference widget's dimensions and the specified sizing rules.
///
/// The sizing behavior is controlled by [SizedRelativeToWidgetRule] objects for both
/// [vertical] and [horizontal] dimensions. These rules can define minimum and
/// maximum size constraints that the child widget must respect.
///
/// ## Usage
///
/// ```dart
/// SizedRelativeToWidget(
///   relativeWidget: Container(width: 200, height: 100),
///   child: Container(color: Colors.blue),
///   horizontal: SizedRelativeToWidgetRule.exact, // Child width = relative widget width
///   vertical: SizedRelativeToWidgetRule.none,    // No vertical constraint
/// )
/// ```
///
/// ## Sizing Rules
///
/// - [SizedRelativeToWidgetRule.none]: No constraint applied (uses parent constraints)
/// - [SizedRelativeToWidgetRule.exact]: Child size equals the relative widget's size
///
/// You can also create custom rules by implementing [SizedRelativeToWidgetRule].
///
/// ## Important Notes
///
/// - The [relativeWidget] serves as a measurement reference and is not rendered
///   in the final layout
/// - The [child] is the widget that will be sized and positioned according to
///   the specified rules
/// - If no rule is specified for an axis, the child will use the parent's
///   constraints for that dimension
///
class SizedRelativeToWidget extends StatelessWidget {
  /// The widget whose dimensions will be used as a reference for sizing the [child].
  final Widget relativeWidget;

  /// The widget that will be sized according to the specified rules.
  final Widget child;

  /// The sizing rule to apply to the vertical (height) dimension.
  ///
  /// Defaults to [SizedRelativeToWidgetRule.none].
  final SizedRelativeToWidgetRule vertical;

  /// The sizing rule to apply to the horizontal (width) dimension.
  ///
  /// Defaults to [SizedRelativeToWidgetRule.none].
  final SizedRelativeToWidgetRule horizontal;

  const SizedRelativeToWidget({
    super.key,
    required this.relativeWidget,
    required this.child,
    this.vertical = SizedRelativeToWidgetRule.none,
    this.horizontal = SizedRelativeToWidgetRule.none,
  });

  @override
  Widget build(BuildContext context) {
    return MKMultiChildLayout<_LayoutID>(
      delegate: _Delegate(vertical: vertical, horizontal: horizontal),
      children: [
        MKLayoutId.keyed(id: _LayoutID.relative, key: const ValueKey(_LayoutID.relative), child: relativeWidget),
        MKLayoutId.keyed(id: _LayoutID.child, key: const ValueKey(_LayoutID.child), child: child),
      ],
    );
  }
}

enum _LayoutID { relative, child }

class _Delegate extends MKMultiChildLayoutDelegate<_LayoutID> {
  final SizedRelativeToWidgetRule vertical;
  final SizedRelativeToWidgetRule horizontal;

  const _Delegate({required this.vertical, required this.horizontal});

  @override
  Size performLayout(Map<_LayoutID, MKChildLayout> childLayouts, BoxConstraints constraints) {
    final relative = childLayouts[_LayoutID.relative]!;
    relative.layoutConstrained(constraints);
    relative.shouldPaint = false;
    final relSize = relative.size;

    final child = childLayouts[_LayoutID.child]!;
    final h = horizontal.getSize(relSize.width);
    final v = vertical.getSize(relSize.height);
    final childSize = child.layout(
      minWidth: h == null ? constraints.minWidth : h.minSize,
      maxWidth: h == null ? constraints.maxWidth : h.maxSize,
      minHeight: v == null ? constraints.minHeight : v.minSize,
      maxHeight: v == null ? constraints.maxHeight : v.maxSize,
    );
    child.setPosition(0, 0);

    return childSize;
  }

  @override
  bool shouldRelayout(covariant _Delegate oldDelegate) {
    return vertical != oldDelegate.vertical || horizontal != oldDelegate.horizontal;
  }
}

// ------------------------------------------------------------------------------------------------

class _CustomRule implements SizedRelativeToWidgetRule {
  final SizedRelativeToWidgetRuleGetSizeResult Function(double extent) _callback;

  const _CustomRule(this._callback);

  @override
  SizedRelativeToWidgetRuleGetSizeResult? getSize(double extent) => _callback(extent);
}

SizedRelativeToWidgetRuleGetSizeResult _none(_) => null;

SizedRelativeToWidgetRuleGetSizeResult _exact(double size) => (maxSize: size, minSize: size);
