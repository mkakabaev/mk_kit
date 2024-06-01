import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class MKMultiChildLayout<ID extends Object, DATA extends Object> extends MultiChildRenderObjectWidget {
  final MKMultiChildLayoutDelegate<ID, DATA> delegate;

  const MKMultiChildLayout({
    super.key,
    required this.delegate,
    required List<MKLayoutId<ID, DATA>> super.children,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderLayout<ID, DATA>(
      delegate: delegate,
    );
  }

  @override
  // ..Comment to make analyzer happy..
  // ignore: consistent-update-render-object
  void updateRenderObject(BuildContext context, RenderObject renderObject) {
    (renderObject as _RenderLayout).setDelegate(delegate);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('delegate', delegate));
  }
}

abstract class MKMultiChildLayoutDelegate<ID extends Object, DATA extends Object> {
  Size performLayout(Map<ID, MKChildLayout<ID, DATA>> children, BoxConstraints constraints);
  bool shouldRelayout(covariant MKMultiChildLayoutDelegate<ID, DATA> oldDelegate) => false;
}

class MKLayoutId<ID extends Object, DATA extends Object>
    extends ParentDataWidget<MKMultiChildLayoutParentData<ID, DATA>> {
  final ID id;
  final EdgeInsets padding;
  final DATA? data;

  const MKLayoutId({
    required this.id,
    required super.child,
    this.padding = EdgeInsets.zero,
    this.data,
    super.key,
  });

  @override
  void applyParentData(RenderObject renderObject) {
    final parentData = renderObject.parentData;
    if (parentData is! MKMultiChildLayoutParentData<ID, DATA>) {
      assert(false);
      return;
    }

    var needsLayout = false;

    if (parentData.layoutId != id) {
      parentData.layoutId = id;
      needsLayout = true;
    }

    if (parentData.padding != padding) {
      parentData.padding = padding;
      needsLayout = true;
    }

    if (parentData.data != data) {
      parentData.data = data;
      needsLayout = true;
    }

    if (needsLayout) {
      final targetParent = renderObject.parent;
      if (targetParent is RenderObject) {
        targetParent.markNeedsLayout();
      }
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => MKMultiChildLayout<ID, DATA>;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('id', id));
    properties.add(DiagnosticsProperty<DATA>('data', data));
    properties.add(DiagnosticsProperty<EdgeInsetsGeometry>('padding', padding));
  }
}

class MKChildLayout<ID extends Object, DATA extends Object> {
  final RenderBox _child;
  final MKMultiChildLayoutParentData<ID, DATA> _parentData;
  var _layedOut = false;

  final EdgeInsets padding;
  final DATA? data;

  MKChildLayout(RenderBox child, MKMultiChildLayoutParentData<ID, DATA> parentData)
      : assert(parentData.padding != null),
        _child = child,
        _parentData = parentData,
        padding = parentData.padding ?? EdgeInsets.zero,
        data = parentData.data;

  void setPosition(double x, double y) => _parentData.offset = Offset(x + padding.left, y + padding.top);

  void setPositionRight(double rightOffset, double y) {
    _parentData.offset = Offset(rightOffset - _child.size.width - padding.right, y + padding.top);
  }

  Size get size => _child.size + Offset(padding.horizontal, padding.vertical);

  Size get childSize => _child.size;

  Size layout({
    double maxWidth = double.infinity,
    double maxHeight = double.infinity,
    double minWidth = 0,
    double minHeight = 0,
    bool includeVerticalPadding = true,
    bool includeHorizontalPadding = true,
  }) {
    _layedOut = true;
    final constraints = BoxConstraints(
      minHeight: minHeight,
      minWidth: minWidth,
      maxHeight: includeVerticalPadding ? max(0, maxHeight - padding.vertical) : maxHeight,
      maxWidth: includeHorizontalPadding ? max(0, maxWidth - padding.horizontal) : maxWidth,
    );
    _child.layout(
      constraints,
      parentUsesSize: true,
    );
    return size;
  }
}

class MKMultiChildLayoutParentData<ID extends Object, DATA extends Object> extends ContainerBoxParentData<RenderBox> {
  ID? layoutId;
  EdgeInsets? padding;
  DATA? data;
}

class _RenderLayout<ID extends Object, DATA extends Object> extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, MKMultiChildLayoutParentData<ID, DATA>>,
        RenderBoxContainerDefaultsMixin<RenderBox, MKMultiChildLayoutParentData<ID, DATA>> {
  MKMultiChildLayoutDelegate<ID, DATA> delegate;

  _RenderLayout({
    required this.delegate,
  });

  void setDelegate(MKMultiChildLayoutDelegate<ID, DATA> newDelegate) {
    if (this.delegate.shouldRelayout(newDelegate)) {
      this.delegate = newDelegate;
      markNeedsLayout();
    } else {
      this.delegate = newDelegate;
    }
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! MKMultiChildLayoutParentData<ID, DATA>) {
      // ..Comment to make analyzer happy..
      // ignore: avoid-mutating-parameters
      child.parentData = MKMultiChildLayoutParentData<ID, DATA>();
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    // context.pushClipRect(
    //   true, offset, Rect.fromLTWH(0, 0, size.width, size.height),
    //   (context, offset) {
    defaultPaint(context, offset);
    //     },
    // );
  }

  @override
  void performLayout() {
    // Fill the layout map
    final childMap = <ID, MKChildLayout<ID, DATA>>{};
    {
      var child = firstChild;
      while (child != null) {
        final childParentData = child.parentData;
        if (childParentData is MKMultiChildLayoutParentData<ID, DATA>) {
          final layoutId = childParentData.layoutId;

          if (layoutId == null) {
            assert(
              false,
              'MKLayoutId widget wrapper must have a non-null id. Please check generic param ID and DATA types.',
            );
          } else {
            assert(() {
              if (childMap.containsKey(layoutId)) {
                throw FlutterError.fromParts([
                  ErrorSummary('Duplicated layout identifier $layoutId found.'),
                  ErrorDescription(
                    'All MKLayoutId widget wrapper identifiers for a MKMultiChildLayout(delegate: $delegate) instance must be unique',
                  ),
                ]);
              }
              return true;
            }());
            childMap[layoutId] = MKChildLayout<ID, DATA>(child, childParentData);
          }
        } else {
          assert(false);
          break;
        }
        child = childAfter(child);
      }
    }
    // Perform layout
    final calculatedSize = delegate.performLayout(childMap, constraints);

    // Checking for missed layouts
    // MKTODO: remove this check? Allow to skip some layouts?
    assert(() {
      // ..Comment to make analyzer happy..
      // ignore: avoid-accessing-other-classes-private-members
      final missedLayouts = childMap.keys.where((key) => childMap[key]?._layedOut == false);
      if (missedLayouts.isNotEmpty) {
        throw FlutterError.fromParts([
          ErrorSummary('Inconsistent MKMultiChildLayout children layout.'),
          ErrorDescription(
            'Few widgets have not been laid out while running $delegate.performLayout(). Their identifiers are:\n',
          ),
          ...missedLayouts.map((e) => ErrorDescription('- $e\n')),
        ]);
      }
      return true;
    }());

    // constraint to the calculated size
    size = constraints.constrain(calculatedSize);
  }
}
