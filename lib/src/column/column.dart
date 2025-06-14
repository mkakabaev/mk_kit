import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:collection/collection.dart';

import '../multi_child_layout/multi_child_layout.dart';

import 'column_spacer.dart';

// cSpell: words Diagnosticable trackpad

@immutable
class MKColumn extends StatelessWidget {
  final List<Widget> children;

  const MKColumn({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        return ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(
            dragDevices: {
              PointerDeviceKind.touch,
              PointerDeviceKind.mouse,
              PointerDeviceKind.stylus,
              PointerDeviceKind.invertedStylus,
              PointerDeviceKind.trackpad,
            },
          ),
          child: SingleChildScrollView(
            child: MKMultiChildLayout<int>(
              delegate: _LayoutDelegate(viewportHeight: constraints.maxHeight),
              // Does not worth to optimize these little lists
              children: children.mapIndexed((index, child) {
                if (child is MKColumnSpacer) {
                  return MKLayoutId(
                    id: index,
                    data: _Data(height: child.height, minHeight: child.minHeight, isExpandable: child.isExpandable),
                    child: child.child ?? const SizedBox(),
                  );
                }
                return MKLayoutId(id: index, child: child);
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}

@immutable
class _Data with Diagnosticable {
  final double height;
  final double minHeight;
  final bool isExpandable;
  const _Data({required this.height, required this.minHeight, required this.isExpandable});

  @override
  String toStringShort() => '_MKColumnData';

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('height', height));
    properties.add(DoubleProperty('minHeight', minHeight));
    properties.add(DiagnosticsProperty<bool>('expandable', isExpandable));
  }
}

class _LayoutInfo {
  final MKChildLayout<int> child;
  double height = 0.0;
  double minHeight = 0.0;
  bool isHandled = false;
  _LayoutInfo(this.child);
}

@immutable
class _LayoutDelegate with Diagnosticable implements MKMultiChildLayoutDelegate<int> {
  final double viewportHeight;

  const _LayoutDelegate({required this.viewportHeight});

  @override
  Size performLayout(Map<int, MKChildLayout<int>> children, BoxConstraints constraints) {
    // If we have at least one expandable item then all non-expandable spacers have
    // minimum height (i.e. they can be considered as regular 'fixed-size' elements)
    final expandableEnvironment =
        children.values.firstWhereOrNull((e) => (e.data as _Data?)?.isExpandable == true) != null;

    // Enumerate items, layout fixed ones and collect spacers (expandable and not)
    final allLayouts = <_LayoutInfo>[];
    final spacerLayouts = <_LayoutInfo>[];
    var fixedHeight = 0.0;
    var spacerHeight = 0.0;
    children.forEach((index, child) {
      final layout = _LayoutInfo(child);
      allLayouts.add(layout);

      // Regular widget (not a spacer). Layout immediately,
      final data = child.data;
      if (data == null) {
        final sz = child.layout(maxWidth: constraints.maxWidth);
        layout.height = sz.height;
        fixedHeight += sz.height;
        return;
      }

      final _Data(:minHeight, :isExpandable, :height) = data as _Data;

      // Non-expandable spacer in expandable environment (there are expandable spacers in the column).
      // Consider it as a regular widget with a fixed height (and layout).
      // Min height is used have because we are in expandable environment and have to be compacted
      if (expandableEnvironment && !isExpandable) {
        final sz = child.layout(maxWidth: constraints.maxWidth, minHeight: minHeight, maxHeight: minHeight);
        layout.height = sz.height;
        fixedHeight += sz.height;
        return;
      }

      // Starting from here we have only expandable spacers OR only non-expandable spacers
      // in non-expandable environment.
      assert(expandableEnvironment ^ !isExpandable, 'assertion_20230601_501183');

      // Spacer with adjustable (later) height. Just collect it for now.
      if (expandableEnvironment) {
        layout.height = max(1, height) * viewportHeight;
      } else {
        layout.height = height;
      }
      layout.minHeight = minHeight;
      spacerHeight += layout.height;
      spacerLayouts.add(layout);
    });

    // Calculate adjusting (if needed) for spacer heights to fit the viewport.
    // for expandable spacers we can can scale in any direction (up and down),
    // for non-expandable spacers we can only scale down.
    if (spacerHeight > 0) {
      var viewportSpacerHeight = viewportHeight - fixedHeight;
      var hasUnhandled = spacerLayouts.isNotEmpty;
      if (spacerHeight > viewportSpacerHeight && hasUnhandled) {
        while (spacerHeight > viewportSpacerHeight && hasUnhandled) {
          hasUnhandled = false;
          final scale = viewportSpacerHeight / spacerHeight;
          for (final layout in spacerLayouts) {
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

        // Now we may have some space left (because we rounded down). Distribute it between all spacers
        var index = 0;
        while (spacerHeight < viewportSpacerHeight) {
          spacerLayouts.elementAtOrNull(index)?.height += 1;
          spacerHeight += 1;
          index = (index + 1) % spacerLayouts.length;
        }
      }
    }

    // Layout spacers finally
    for (final layout in spacerLayouts) {
      final _ = layout.child.layout(maxWidth: constraints.maxWidth, minHeight: layout.height, maxHeight: layout.height);
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

  @override
  String toStringShort() => '_MKColumnLayoutDelegate';

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('viewportHeight', viewportHeight));
  }
}
