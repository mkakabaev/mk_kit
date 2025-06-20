import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'multi_child_layout.dart';
import 'multi_child_layout_parent_data.dart';

///
/// Similar to [LayoutId] but with additional padding and data properties.
///
class MKLayoutId<ID extends Object> extends ParentDataWidget<MKMultiChildLayoutParentData<ID>> {
  final ID id;
  final EdgeInsets padding;

  // Any external data to be passed to the layout.
  final Object? data;

  const MKLayoutId.keyed({
    required this.id,
    required super.child,
    this.padding = EdgeInsets.zero,
    this.data,
    super.key,
  });

  MKLayoutId({required this.id, required super.child, this.padding = EdgeInsets.zero, this.data})
    : super(key: ValueKey(id));

  @override
  void applyParentData(RenderObject renderObject) {
    final parentData = renderObject.parentData;
    if (parentData is! MKMultiChildLayoutParentData<ID>) {
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
  Type get debugTypicalAncestorWidgetClass => MKMultiChildLayout;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('id', id));
    properties.add(DiagnosticsProperty('data', data));
    properties.add(DiagnosticsProperty<EdgeInsetsGeometry>('padding', padding));
  }
}
