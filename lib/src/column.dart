import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import './multi_child_layout.dart';
import './spacer.dart';

@immutable
class MKColumn extends StatelessWidget {
  final List<Widget> children;

  const MKColumn({
    super.key,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: MKMultiChildLayout<int, _Data>(
            delegate: _LayoutDelegate(
              viewportHeight: constraints.maxHeight,
            ),
            children: children.mapIndexed((index, child) {
              if (child is MKSpacer) {
                return MKLayoutId(
                  id: index,
                  data: _Data(
                    height: child.height,
                    minHeight: child.minHeight,
                    isExpandable: child.isExpandable,
                  ),
                  child: child.child ?? const SizedBox(),
                );
              }
              return MKLayoutId<int, _Data>(
                id: index,
                child: child,
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

@immutable
class _Data {
  final double height;
  final double minHeight;
  final bool isExpandable;
  const _Data({
    required this.height,
    required this.minHeight,
    required this.isExpandable,
  });
}

class _LayoutInfo {
  final MKChildLayout<int, _Data> child;
  double height = 0.0;
  double minHeight = 0.0;
  bool isHandled = false;
  _LayoutInfo(this.child);
}

@immutable
class _LayoutDelegate implements MKMultiChildLayoutDelegate<int, _Data> {
  final double viewportHeight;

  const _LayoutDelegate({
    required this.viewportHeight,
  });

  @override
  Size performLayout(Map<int, MKChildLayout<int, _Data>> children, BoxConstraints constraints) {
    // If we has at least one expandable item then all non-expandable spacers
    // will have minimum height (i.e. they can be considered as regular 'fixed-size' elements)
    final hasExpandable = children.values.firstWhereOrNull((e) => e.data?.isExpandable == true) != null;

    // Enumerate items, layout fixed ones and collect spacers (expandable and not)
    final allLayouts = <_LayoutInfo>[];
    final spacers = <_LayoutInfo>[];
    var fixedHeight = 0.0;
    var spacerHeight = 0.0;
    children.forEach((index, child) {
      final data = child.data;
      final layout = _LayoutInfo(child);
      allLayouts.add(layout);

      // Regular widget, not a spacer. Layout Immediately,
      if (data == null) {
        final sz = child.layout(maxWidth: constraints.maxWidth);
        layout.height = sz.height;
        fixedHeight += sz.height;
        return;
      }

      // Spacer. Consider it as a regular widget with a fixed height (and layout)
      if (hasExpandable && !data.isExpandable) {
        final sz = child.layout(
          maxWidth: constraints.maxWidth,
          minHeight: data.minHeight,
          maxHeight: data.minHeight,
        );
        layout.height = sz.height;
        fixedHeight += sz.height;
        return;
      }

      // Spacer with adjustable (later) height. Just collect it for now.
      assert(hasExpandable ^ !data.isExpandable, 'assertion_20230601_501183');
      if (hasExpandable) {
        layout.height = max(1, data.height) * viewportHeight;
      } else {
        layout.height = data.height;
      }
      layout.minHeight = data.minHeight;
      spacerHeight += layout.height;
      spacers.add(layout);
    });

    // Calculate adjusting (if needed) for spacer heights to fit the viewport.
    // for expandable spacers we can can scale in any direction (up and down),
    // for non-expandable spacers we can only scale down.
    if (spacerHeight > 0) {
      var viewportSpacerHeight = viewportHeight - fixedHeight;
      var hasUnhandled = spacers.isNotEmpty;
      if (spacerHeight > viewportSpacerHeight && hasUnhandled) {
        while (spacerHeight > viewportSpacerHeight && hasUnhandled) {
          hasUnhandled = false;
          final scale = viewportSpacerHeight / spacerHeight;
          for (final layout in spacers) {
            if (layout.isHandled) {
              continue;
            }
            final newHeight = (layout.height * scale).floorToDouble(); // round down
            if (newHeight <= layout.minHeight) {
              spacerHeight -= layout.height;
              layout.height = layout.minHeight;
              viewportSpacerHeight -= layout.height;
              layout.isHandled = true;
            } else {
              spacerHeight -= layout.height - newHeight;
              layout.height = newHeight;
              hasUnhandled = true;
            }
          }
        }

        // Now we can have some space left (because we rounded down). Distribute it between all spacers
        var index = 0;
        while (spacerHeight < viewportSpacerHeight) {
          spacers[index].height += 1;
          spacerHeight += 1;
          index = (index + 1) % spacers.length;
        }
      }
    }

    // Layout spacers finally
    for (final layout in spacers) {
      layout.child.layout(
        maxWidth: constraints.maxWidth,
        minHeight: layout.height,
        maxHeight: layout.height,
      );
    }

    var contentHeight = 0.0;
    for (final layout in allLayouts) {
      layout.child.setPosition(0, contentHeight);
      contentHeight += layout.height;
    }

    return Size(constraints.maxWidth, max(contentHeight, viewportHeight));
  }

  @override
  bool shouldRelayout(_LayoutDelegate oldDelegate) {
    return viewportHeight != oldDelegate.viewportHeight;
  }
}
