import 'dart:math';

import 'package:flutter/rendering.dart';

import 'multi_child_layout_parent_data.dart';

class MKChildLayout<ID extends Object> {
  final RenderBox _child;
  final MKMultiChildLayoutParentData<ID> _parentData;
  final EdgeInsets padding;
  var _laidOut = false;

  MKChildLayout(RenderBox child, MKMultiChildLayoutParentData<ID> parentData)
    : assert(parentData.padding != null),
      _child = child,
      _parentData = parentData,
      padding = parentData.padding ?? EdgeInsets.zero {
    _parentData.shouldPaint = true;
  }

  bool get shouldPaint => _parentData.shouldPaint;

  set shouldPaint(bool value) => _parentData.shouldPaint = value;

  void setPosition(double x, double y) => _parentData.offset = Offset(x + padding.left, y + padding.top);

  void setPositionRight(double rightOffset, double y) {
    _parentData.offset = Offset(rightOffset - _child.size.width - padding.right, y + padding.top);
  }

  Size get childSize => _child.size;

  Size get size {
    final s = _child.size;
    return Size(s.width + padding.horizontal, s.height + padding.vertical);
  }

  bool get laidOut => _laidOut;

  Object? get data => _parentData.data;

  void layoutTight(double width, double height) {
    layout(maxWidth: width, maxHeight: height, minWidth: width, minHeight: height);
  }

  Size layoutConstrained(BoxConstraints constraints, {
    bool includeVerticalPadding = true,
    bool includeHorizontalPadding = true,
  }) {
    if (includeVerticalPadding || includeHorizontalPadding) {
        constraints = constraints.copyWith(
          maxWidth: max(0, constraints.maxWidth - padding.horizontal),
          maxHeight: max(0, constraints.maxHeight - padding.vertical),
        );
    }

    _laidOut = true;
    _child.layout(constraints, parentUsesSize: true);
    return size;
  }

  Size layout({
    double maxWidth = double.infinity,
    double maxHeight = double.infinity,
    double minWidth = 0,
    double minHeight = 0,
    bool includeVerticalPadding = true,
    bool includeHorizontalPadding = true,
  }) {
    final constraints = BoxConstraints(
      minHeight: minHeight,
      minWidth: minWidth,
      maxHeight: includeVerticalPadding ? max(0, maxHeight - padding.vertical) : maxHeight,
      maxWidth: includeHorizontalPadding ? max(0, maxWidth - padding.horizontal) : maxWidth,
    );
    _laidOut = true;
    _child.layout(constraints, parentUsesSize: true);
    return size;
  }
}
