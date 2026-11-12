import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:mk_kit/mk_kit.dart';

void main() {
  testWidgets('tight child constraints stay valid after padding', (tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: SizedBox(
            width: 100,
            height: 40,
            child: CustomChildLayout<String>(
              delegate: const _TightDelegate(),
              children: [
                ChildLayoutId(
                  id: 'child',
                  padding: const EdgeInsets.all(8),
                  child: const SizedBox.expand(key: Key('padded')),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byKey(const Key('padded'))), const Size(84, 24));
  });

  testWidgets('unpainted child is omitted from semantics and baseline', (tester) async {
    final semantics = tester.ensureSemantics();
    const childStyle = TextStyle(fontSize: 14);
    double? layoutBaseline;
    double? textBaseline;

    try {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Column(
            children: [
              _BaselineProbe(
                onBaseline: (value) => layoutBaseline = value,
                child: CustomChildLayout<String>(
                  delegate: const _HideReferenceDelegate(),
                  children: [
                    ChildLayoutId(
                      id: 'reference',
                      child: const Text('reference', style: TextStyle(fontSize: 40)),
                    ),
                    ChildLayoutId(
                      id: 'child',
                      child: const Text('child', style: childStyle),
                    ),
                  ],
                ),
              ),
              _BaselineProbe(
                onBaseline: (value) => textBaseline = value,
                child: const Text('child', style: childStyle),
              ),
            ],
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.bySemanticsLabel('reference'), findsNothing);
      expect(find.bySemanticsLabel('child'), findsWidgets);
      expect(layoutBaseline, isNotNull);
      expect(layoutBaseline, textBaseline);
    } finally {
      semantics.dispose();
    }
  });
}

class const _TightDelegate() extends ChildLayoutDelegate<String> {
  @override
  Size performLayout(Map<String, ChildLayout<String>> children, BoxConstraints constraints) {
    final child = children['child']!;
    child.layout(
      minWidth: constraints.maxWidth,
      maxWidth: constraints.maxWidth,
      minHeight: constraints.maxHeight,
      maxHeight: constraints.maxHeight,
    );
    child.setPosition(0, 0);
    return Size(constraints.maxWidth, constraints.maxHeight);
  }
}

class const _HideReferenceDelegate() extends ChildLayoutDelegate<String> {
  @override
  Size performLayout(Map<String, ChildLayout<String>> children, BoxConstraints constraints) {
    final reference = children['reference']!;
    reference.layout(maxWidth: constraints.maxWidth, maxHeight: constraints.maxHeight);
    reference.shouldPaint = false;

    final child = children['child']!;
    final childSize = child.layout(maxWidth: constraints.maxWidth, maxHeight: constraints.maxHeight);
    child.setPosition(0, 0);
    return childSize;
  }
}

class const _BaselineProbe({required final ValueChanged<double?> onBaseline, required super.child})
    extends SingleChildRenderObjectWidget {
  @override
  RenderObject createRenderObject(BuildContext context) => _RenderBaselineProbe(onBaseline);

  @override
  void updateRenderObject(BuildContext context, _RenderBaselineProbe renderObject) {
    renderObject.onBaseline = onBaseline;
  }
}

class _RenderBaselineProbe(var ValueChanged<double?> onBaseline) extends RenderProxyBox {
  @override
  void performLayout() {
    final child = this.child;
    if (child == null) {
      assert(false, 'assertion_20261013_362698');
      return;
    }
    child.layout(constraints, parentUsesSize: true);
    size = child.size;
    onBaseline(child.getDistanceToBaseline(TextBaseline.alphabetic));
  }
}
