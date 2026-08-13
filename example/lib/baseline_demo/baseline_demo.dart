import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:mk_kit/mk_kit.dart';

class BaselineDemo extends StatefulWidget {
  const BaselineDemo({super.key});

  @override
  State createState() => _BaselineDemoState();
}

class _BaselineDemoState extends State<BaselineDemo> {
  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(height: 2, fontSize: 30, leadingDistribution: TextLeadingDistribution.proportional);

    const circle = SizedBox(
      width: 20,
      height: 20,
      child: DecoratedBox(
        decoration: BoxDecoration(color: Colors.black, shape: BoxShape.circle),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Baseline Demo')),
      body: ListView(
        children: [
          for (final r in <double>[-1, 0, 0.5, 1, 2.0])
            _Row(
              title: 'Alignment($r)',
              child: MKBaseline(
                delegate: MKBaselineAlignmentDelegate(alignment: r),
                debugDrawBaseline: true,
                child: circle,
              ),
            ),

          const _Row(
            title: 'Text',
            child: Text("Hello", style: textStyle),
          ),

          // Not all widgets support baseline. For example, Icon()
          const _Row(
            title: 'Other',
            child: SizedBox(
              width: 20,
              height: 20,
              child: DecoratedBox(
                decoration: BoxDecoration(color: Colors.black, shape: BoxShape.circle),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String title;
  final Widget child;
  const _Row({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        spacing: 16,
        children: [
          Expanded(flex: 1, child: Text(title, style: const TextStyle(fontSize: 12))),
          Expanded(flex: 2, child: BaselineBox(child: child)),
        ],
      ),
    );
  }
}

///
/// Helper widget to visualize the baseline of a child
///
class BaselineBox extends SingleChildRenderObjectWidget {
  const BaselineBox({super.key, super.child});

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderBaselineBox();
  }

  @override
  void updateRenderObject(BuildContext context, RenderBaselineBox renderObject) {}
}

class RenderBaselineBox extends RenderShiftedBox {
  RenderBaselineBox({RenderBox? child}) : super(child);

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final RenderBox? child = this.child;
    if (child == null) {
      return constraints.smallest;
    }
    final childSize = child.getDryLayout(_innerConstraints(constraints));
    return constraints.constrain(Size(childSize.width, _topPadding + childSize.height + _bottomPadding));
  }

  final _topPadding = 20.0;
  final _bottomPadding = 20.0;

  BoxConstraints _innerConstraints(BoxConstraints constraints) {
    return constraints.deflate(EdgeInsets.only(top: _topPadding, bottom: _bottomPadding));
  }

  @override
  void performLayout() {
    final RenderBox? child = this.child;
    if (child == null) {
      size = constraints.smallest;
      return;
    }

    child.layout(_innerConstraints(constraints), parentUsesSize: true);
    final baseline = child.getDistanceToBaseline(TextBaseline.alphabetic) ?? child.size.height;

    size = constraints.constrain(
      Size(child.size.width, _topPadding + max(child.size.height, baseline) + _bottomPadding),
    );
    (child.parentData as BoxParentData).offset = Offset(0.0, _topPadding);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final child = this.child;

    {
      final paint = Paint()
        ..color = Colors.blue.withValues(alpha: 0.1)
        ..style = PaintingStyle.fill;
      context.canvas.drawRect(offset & size, paint);
    }

    if (child != null && child.hasSize) {
      final baseline = child.getDistanceToBaseline(TextBaseline.alphabetic) ?? 0;
      final paint = Paint()
        ..color = Colors.red.withValues(alpha: 0.5)
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;
      context.canvas.drawLine(
        offset + Offset(0, baseline + _topPadding),
        offset + Offset(size.width, baseline + _topPadding),
        paint,
      );
    }

    super.paint(context, offset);
  }
}
