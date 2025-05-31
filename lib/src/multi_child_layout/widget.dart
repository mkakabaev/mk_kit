import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'child_layout.dart';
import 'delegate.dart';
import 'layout_id.dart';
import 'parent_data.dart';

///
/// Extended version of [CustomMultiChildLayout] that allows to layout children
///
class MKMultiChildLayout<ID extends Object> extends MultiChildRenderObjectWidget {
  final MKMultiChildLayoutDelegate<ID> delegate;
  final bool isOpaqueToHits;
  final bool shouldClip;

  const MKMultiChildLayout({
    super.key,
    required this.delegate,
    this.isOpaqueToHits = false,
    this.shouldClip = false,
    required List<MKLayoutId<ID>> super.children,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderLayout<ID>(delegate: delegate, isOpaqueToHits: isOpaqueToHits, shouldClip: shouldClip);
  }

  @override
  // ..a comment to make analyzer happy..
  // ignore: consistent-update-render-object
  void updateRenderObject(BuildContext context, RenderObject renderObject) {
    (renderObject as _RenderLayout).setDelegate(delegate, isOpaqueToHits, shouldClip);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('delegate', delegate));
  }
}

class _RenderLayout<ID extends Object> extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, MKMultiChildLayoutParentData<ID>>,
        RenderBoxContainerDefaultsMixin<RenderBox, MKMultiChildLayoutParentData<ID>> {
  MKMultiChildLayoutDelegate<ID> delegate;
  bool isOpaqueToHits;
  bool shouldClip;

  _RenderLayout({required this.delegate, required this.isOpaqueToHits, required this.shouldClip});

  void setDelegate(MKMultiChildLayoutDelegate<ID> newDelegate, bool isOpaqueToHits, bool shouldClip) {
    if (this.isOpaqueToHits != isOpaqueToHits ||
        this.shouldClip != shouldClip ||
        this.delegate.shouldRelayout(newDelegate)) {
      markNeedsLayout();
    }
    this.delegate = newDelegate;
    this.isOpaqueToHits = isOpaqueToHits;
    this.shouldClip = shouldClip;
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! MKMultiChildLayoutParentData<ID>) {
      // ..a comment to make analyzer happy..
      // ignore: avoid-mutating-parameters
      child.parentData = MKMultiChildLayoutParentData<ID>();
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  bool hitTestSelf(Offset position) => isOpaqueToHits;

  @override
  void paint(PaintingContext context, Offset offset) {
    if (shouldClip) {
      context.pushClipRect(needsCompositing, offset, Rect.fromLTWH(0, 0, size.width, size.height), (context, offset) {
        _defaultPaint(context, offset);
      });
    } else {
      _defaultPaint(context, offset);
    }
  }

  void _defaultPaint(PaintingContext context, Offset offset) {
    var child = firstChild;
    while (child != null) {
      final childParentData = child.parentData as MKMultiChildLayoutParentData<ID>;
      if (childParentData.shouldPaint) {
        context.paintChild(child, childParentData.offset + offset);
      }
      child = childParentData.nextSibling;
    }
  }

  @override
  void performLayout() {
    // Fill the layout map
    final childMap = <ID, MKChildLayout<ID>>{};
    {
      var child = firstChild;
      while (child != null) {
        final childParentData = child.parentData;
        if (childParentData is MKMultiChildLayoutParentData<ID>) {
          final layoutId = childParentData.layoutId;
          if (layoutId == null) {
            assert(
              false,
              'MKLayoutId widget wrapper must have a non-null id. '
              'Please check generic param ID type.',
            );
          } else {
            assert(() {
              if (childMap.containsKey(layoutId)) {
                throw FlutterError.fromParts([
                  ErrorSummary('Duplicated layout identifier $layoutId found.'),
                  ErrorDescription(
                    'All MKLayoutId widget wrapper identifiers for '
                    'a MKMultiChildLayout(delegate: $delegate) instance must be unique',
                  ),
                ]);
              }
              return true;
            }());
            childMap[layoutId] = MKChildLayout<ID>(child, childParentData);
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
    size = constraints.constrain(calculatedSize);

    // Checking for missed layouts
    // MKTODO: remove this check? Allow to skip some layouts?
    assert(() {
      // ..Comment to make analyzer happy..
      // ignore: avoid-accessing-other-classes-private-members
      final missedLayouts = childMap.keys.where((key) => childMap[key]?.laidOut == false);
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

  // See notes on [RenderBox.computeDistanceToActualBaseline] for
  // possible strategies to handle this case.
  // For now it iw enough to use the first child's baseline.
  // Later move the logic to the delegate!!
  @override
  double? computeDistanceToActualBaseline(TextBaseline baselineType) {
    var child = firstChild;
    while (child != null) {
      final childParentData = child.parentData as MKMultiChildLayoutParentData<ID>;
      assert(childParentData.layoutId != null);
      if (childParentData.layoutId != null) {
        final result = child.getDistanceToActualBaseline(baselineType);
        if (result != null) {
          return result + childParentData.offset.dy;
        }
      }
      child = childParentData.nextSibling;
    }

    return super.computeDistanceToActualBaseline(baselineType);
  }
}
