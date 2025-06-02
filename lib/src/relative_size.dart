import 'package:flutter/material.dart';

import 'multi_child_layout/multi_child_layout.dart';

typedef ReferencedSizeRuleResult = ({double minSize, double maxSize})?;

abstract class ReferencedSizeRule {
  ReferencedSizeRuleResult getSize(double extent);

  static const none = _CustomRule(_none);
  static const exact = _CustomRule(_exact);
}

// ------------------------------------------------------------------------------------------------

class _CustomRule implements ReferencedSizeRule {
  final ReferencedSizeRuleResult Function(double extent) _callback;

  const _CustomRule(this._callback);

  @override
  ReferencedSizeRuleResult? getSize(double extent) => _callback(extent);
}

ReferencedSizeRuleResult _none(_) => null;

ReferencedSizeRuleResult _exact(double size) => (maxSize: size, minSize: size);

// ------------------------------------------------------------------------------------------------

class ReferencedSize extends StatelessWidget {
  final Widget child;
  final Widget referenceWidget;
  final ReferencedSizeRule vertical;
  final ReferencedSizeRule horizontal;

  const ReferencedSize({
    super.key,
    required this.referenceWidget,
    required this.child,
    this.vertical = ReferencedSizeRule.none,
    this.horizontal = ReferencedSizeRule.none,
  });

  @override
  Widget build(BuildContext context) {
    return MKMultiChildLayout<_LayoutID>(
      delegate: _Delegate(vertical: vertical, horizontal: horizontal),
      children: [
        MKLayoutId.keyed(id: _LayoutID.reference, key: const ValueKey(_LayoutID.reference), child: referenceWidget),
        MKLayoutId.keyed(id: _LayoutID.child, key: const ValueKey(_LayoutID.child), child: child),
      ],
    );
  }
}

enum _LayoutID { reference, child }

class _Delegate extends MKMultiChildLayoutDelegate<_LayoutID> {
  final ReferencedSizeRule vertical;
  final ReferencedSizeRule horizontal;

  const _Delegate({required this.vertical, required this.horizontal});

  @override
  Size performLayout(Map<_LayoutID, MKChildLayout> childLayouts, BoxConstraints constraints) {
    final reference = childLayouts[_LayoutID.reference]!;
    reference.layoutConstrained(constraints);
    reference.shouldPaint = false;
    final refSize = reference.size;

    final child = childLayouts[_LayoutID.child]!;
    final h = horizontal.getSize(refSize.width);
    final v = vertical.getSize(refSize.height);
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
