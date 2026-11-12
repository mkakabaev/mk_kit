import 'dart:math';

import 'package:flutter/rendering.dart';

import 'layout_parent_data.dart';

class ChildLayout<ID extends Object>(final RenderBox _child, final ChildLayoutParentData<ID> _parentData) {
  final EdgeInsets padding;
  var _laidOut = false;

  this : assert(_parentData.padding != null), padding = _parentData.padding ?? EdgeInsets.zero {
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

  Size layoutConstrained(
    BoxConstraints constraints, {
    bool includeVerticalPadding = true,
    bool includeHorizontalPadding = true,
  }) {
    final resolved = _constraintsForChild(
      minWidth: constraints.minWidth,
      maxWidth: constraints.maxWidth,
      minHeight: constraints.minHeight,
      maxHeight: constraints.maxHeight,
      includeHorizontalPadding: includeHorizontalPadding,
      includeVerticalPadding: includeVerticalPadding,
    );
    _laidOut = true;
    _child.layout(resolved, parentUsesSize: true);
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
    final constraints = _constraintsForChild(
      minWidth: minWidth,
      maxWidth: maxWidth,
      minHeight: minHeight,
      maxHeight: maxHeight,
      includeHorizontalPadding: includeHorizontalPadding,
      includeVerticalPadding: includeVerticalPadding,
    );
    _laidOut = true;
    _child.layout(constraints, parentUsesSize: true);
    return size;
  }

  BoxConstraints _constraintsForChild({
    required double minWidth,
    required double maxWidth,
    required double minHeight,
    required double maxHeight,
    required bool includeHorizontalPadding,
    required bool includeVerticalPadding,
  }) {
    var resolvedMinWidth = minWidth;
    var resolvedMaxWidth = maxWidth;
    var resolvedMinHeight = minHeight;
    var resolvedMaxHeight = maxHeight;

    if (includeHorizontalPadding) {
      resolvedMaxWidth = max(0.0, resolvedMaxWidth - padding.horizontal);
      resolvedMinWidth = min(max(0.0, resolvedMinWidth - padding.horizontal), resolvedMaxWidth);
    }
    if (includeVerticalPadding) {
      resolvedMaxHeight = max(0.0, resolvedMaxHeight - padding.vertical);
      resolvedMinHeight = min(max(0.0, resolvedMinHeight - padding.vertical), resolvedMaxHeight);
    }

    return BoxConstraints(
      minWidth: resolvedMinWidth,
      maxWidth: resolvedMaxWidth,
      minHeight: resolvedMinHeight,
      maxHeight: resolvedMaxHeight,
    );
  }
}
