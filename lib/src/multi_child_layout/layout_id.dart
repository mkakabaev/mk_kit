import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'layout_parent_data.dart';
import 'widget.dart';

///
/// Similar to [LayoutId] but with additional padding and data properties.
///
class ChildLayoutId<ID extends Object> extends ParentDataWidget<ChildLayoutParentData<ID>> {
  final ID id;
  final EdgeInsets padding;

  // Any external data to be passed to the layout.
  final Object? data;

  const ChildLayoutId.keyed({
    required this.id,
    required super.child,
    this.padding = EdgeInsets.zero,
    this.data,
    super.key,
  });

  ChildLayoutId({required this.id, required super.child, this.padding = EdgeInsets.zero, this.data})
    : super(key: ValueKey(id));

  @override
  void applyParentData(RenderObject renderObject) {
    final parentData = renderObject.parentData;
    if (parentData is! ChildLayoutParentData<ID>) {
      assert(false);
      return;
    }

    if (parentData.layoutId != id || parentData.padding != padding || parentData.data != data) {
      parentData.layoutId = id;
      parentData.padding = padding;
      parentData.data = data;

      final targetParent = renderObject.parent;
      if (targetParent is RenderObject) {
        targetParent.markNeedsLayout();
      }
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => CustomChildLayout;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('id', id));
    properties.add(DiagnosticsProperty('data', data));
    properties.add(DiagnosticsProperty<EdgeInsetsGeometry>('padding', padding));
  }
}
