import 'package:flutter/material.dart';

import 'multi_child_layout/multi_child_layout.dart';

typedef RelativeSizeRuleResult = ({double minSize, double maxSize})?;

abstract class RelativeSizeRule {
  RelativeSizeRuleResult getSize(double extent);

  static const none = _CustomRule(_none);
  static const exact = _CustomRule(_exact);
}

// ------------------------------------------------------------------------------------------------

class _CustomRule implements RelativeSizeRule {
  final RelativeSizeRuleResult Function(double extent) _callback;

  const _CustomRule(this._callback);

  @override
  RelativeSizeRuleResult? getSize(double extent) => _callback(extent);
}

RelativeSizeRuleResult _none(_) => null;

RelativeSizeRuleResult _exact(double size) => (maxSize: size, minSize: size);

// ------------------------------------------------------------------------------------------------

class RelativeSizeWidget extends StatelessWidget {
  final Widget child;
  final Widget relativeWidget;
  final RelativeSizeRule vertical;
  final RelativeSizeRule horizontal;

  const RelativeSizeWidget({
    super.key,
    required this.relativeWidget,
    required this.child,
    this.vertical = RelativeSizeRule.none,
    this.horizontal = RelativeSizeRule.none,
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
  final RelativeSizeRule vertical;
  final RelativeSizeRule horizontal;

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
