import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'delegate.dart';
import 'layout.dart';
import 'layout_id.dart';
import 'layout_parent_data.dart';

///
/// Extended version of [CustomMultiChildLayout] that allows to layout children
///
class const CustomChildLayout<ID extends Object>({
  super.key,
  required final ChildLayoutDelegate<ID> delegate,
  final bool isOpaqueToHits = false,
  final bool shouldClip = false,
  required List<ChildLayoutId<ID>> super.children,
}) extends MultiChildRenderObjectWidget {
  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderLayout<ID>(delegate: delegate, isOpaqueToHits: isOpaqueToHits, shouldClip: shouldClip);
  }

  @override
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

class _RenderLayout<ID extends Object>({
  required var ChildLayoutDelegate<ID> delegate,
  required var bool isOpaqueToHits,
  required var bool shouldClip,
}) extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, ChildLayoutParentData<ID>>,
        RenderBoxContainerDefaultsMixin<RenderBox, ChildLayoutParentData<ID>> {
  void setDelegate(ChildLayoutDelegate<ID> delegate, bool isOpaqueToHits, bool shouldClip) {
    final oldDelegate = this.delegate;
    if (isOpaqueToHits != this.isOpaqueToHits ||
        shouldClip != this.shouldClip ||
        delegate.runtimeType != oldDelegate.runtimeType ||
        delegate.shouldRelayout(oldDelegate)) {
      markNeedsLayout();
    }
    this.delegate = delegate;
    this.isOpaqueToHits = isOpaqueToHits;
    this.shouldClip = shouldClip;
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! ChildLayoutParentData<ID>) {
      child.parentData = ChildLayoutParentData<ID>();
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    // similar to defaultHitTestChildren(result, position: position) but respects the shouldPaint flag
    var child = lastChild;
    while (child != null) {
      // ignore: avoid-non-null-assertion
      final parentData = child.parentData! as ChildLayoutParentData<ID>;
      if (parentData.shouldPaint) {
        final hit = result.addWithPaintOffset(
          offset: parentData.offset,
          position: position,
          // ignore: avoid-non-null-assertion
          hitTest: (result, transformed) => child!.hitTest(result, position: transformed),
        );
        if (hit) {
          return true;
        }
      }
      child = parentData.previousSibling;
    }
    return false;
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
      final childParentData = child.parentData as ChildLayoutParentData<ID>;
      if (childParentData.shouldPaint) {
        context.paintChild(child, childParentData.offset + offset);
      }
      child = childParentData.nextSibling;
    }
  }

  @override
  void visitChildrenForSemantics(RenderObjectVisitor visitor) {
    var child = firstChild;
    while (child != null) {
      final childParentData = child.parentData as ChildLayoutParentData<ID>;
      if (childParentData.shouldPaint) {
        visitor(child);
      }
      child = childParentData.nextSibling;
    }
  }

  @override
  void performLayout() {
    final paintBeforeLayout = <RenderBox, bool>{};
    var child = firstChild;
    while (child != null) {
      final childParentData = child.parentData as ChildLayoutParentData<ID>;
      paintBeforeLayout[child] = childParentData.shouldPaint;
      child = childAfter(child);
    }

    // Fill the layout map
    final childMap = <ID, ChildLayout<ID>>{};
    {
      var child = firstChild;
      while (child != null) {
        final childParentData = child.parentData;
        if (childParentData is ChildLayoutParentData<ID>) {
          final layoutId = childParentData.layoutId;
          if (layoutId == null) {
            assert(
              false,
              'ChildLayoutId widget wrapper must have a non-null id. '
              'Please check generic param ID type.',
            );
          } else {
            assert(() {
              if (childMap.containsKey(layoutId)) {
                throw FlutterError.fromParts([
                  ErrorSummary('Duplicated layout identifier $layoutId found.'),
                  ErrorDescription(
                    'All ChildLayoutId widget wrapper identifiers for '
                    'a CustomChildLayout(delegate: $delegate) instance must be unique',
                  ),
                ]);
              }
              return true;
            }());
            childMap[layoutId] = ChildLayout<ID>(child, childParentData);
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
      final missedLayouts = childMap.keys.where((key) => childMap[key]?.laidOut == false);
      if (missedLayouts.isNotEmpty) {
        throw FlutterError.fromParts([
          ErrorSummary('Inconsistent CustomChildLayout children layout.'),
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

    child = firstChild;
    while (child != null) {
      final childParentData = child.parentData as ChildLayoutParentData<ID>;
      if (paintBeforeLayout[child] != childParentData.shouldPaint) {
        markNeedsSemanticsUpdate();
        break;
      }
      child = childAfter(child);
    }
  }

  // Uses the first painted child that has a baseline.
  // Children with shouldPaint == false are measurement-only and must not contribute.
  // Later move the logic to the delegate!!
  @override
  double? computeDistanceToActualBaseline(TextBaseline baselineType) {
    var child = firstChild;
    while (child != null) {
      final childParentData = child.parentData as ChildLayoutParentData<ID>;
      assert(childParentData.layoutId != null);
      if (childParentData.shouldPaint && childParentData.layoutId != null) {
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
