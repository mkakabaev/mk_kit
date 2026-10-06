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
            child: MKMultiChildLayout<String>(
              delegate: const _TightDelegate(),
              children: [
                MKLayoutId(
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
}

class _TightDelegate extends MKMultiChildLayoutDelegate<String> {
  const _TightDelegate();

  @override
  Size performLayout(Map<String, MKChildLayout<String>> children, BoxConstraints constraints) {
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
