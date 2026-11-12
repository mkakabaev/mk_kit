import 'package:flutter/widgets.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:mk_kit/mk_kit.dart';

void main() {
  testWidgets('exact child matches a reference that fits', (tester) async {
    await tester.pumpWidget(
      const _Host(
        constraints: BoxConstraints(maxWidth: 200, maxHeight: 80),
        child: ReferenceSizedBox(
          key: Key('sized'),
          reference: SizedBox(width: 48, height: 24),
          width: ReferenceSize.exact,
          height: ReferenceSize.exact,
          child: SizedBox.expand(key: Key('child')),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byKey(const Key('child'))), const Size(48, 24));
    expect(tester.getSize(find.byKey(const Key('sized'))), const Size(48, 24));
    expect(tester.getTopLeft(find.byKey(const Key('child'))), tester.getTopLeft(find.byKey(const Key('sized'))));
  });

  testWidgets('a rule larger than the parent is tightened to the parent max', (tester) async {
    await tester.pumpWidget(
      _Host(
        constraints: const BoxConstraints(maxWidth: 100, maxHeight: 50),
        child: ReferenceSizedBox(
          key: const Key('sized'),
          reference: const SizedBox(width: 40, height: 20),
          width: ReferenceSize.custom((_) => (minSize: 200, maxSize: 200)),
          height: ReferenceSize.custom((_) => (minSize: 80, maxSize: 80)),
          child: const SizedBox.expand(key: Key('child')),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byKey(const Key('child'))), const Size(100, 50));
    expect(tester.getSize(find.byKey(const Key('sized'))), const Size(100, 50));
  });

  testWidgets('a rule smaller than the parent minimum fills the widget', (tester) async {
    await tester.pumpWidget(
      _Host(
        constraints: const BoxConstraints(minWidth: 80, maxWidth: 120, minHeight: 40, maxHeight: 60),
        child: ReferenceSizedBox(
          key: const Key('sized'),
          reference: const SizedBox.shrink(),
          width: ReferenceSize.custom((_) => (minSize: 20, maxSize: 20)),
          height: ReferenceSize.custom((_) => (minSize: 10, maxSize: 10)),
          child: const SizedBox.expand(key: Key('child')),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byKey(const Key('child'))), const Size(80, 40));
    expect(tester.getSize(find.byKey(const Key('sized'))), const Size(80, 40));
    expect(tester.getTopLeft(find.byKey(const Key('child'))), tester.getTopLeft(find.byKey(const Key('sized'))));
  });

  testWidgets('an overlapping rule keeps the shared range', (tester) async {
    const constraints = BoxConstraints(minWidth: 40, maxWidth: 100, minHeight: 30, maxHeight: 70);
    const horizontal = _RangeRule(minSize: 10, maxSize: 90);
    const vertical = _RangeRule(minSize: 10, maxSize: 50);

    await tester.pumpWidget(
      const _Host(
        constraints: constraints,
        child: ReferenceSizedBox(
          reference: SizedBox.shrink(),
          width: horizontal,
          height: vertical,
          child: SizedBox.expand(key: Key('expanded')),
        ),
      ),
    );
    expect(tester.getSize(find.byKey(const Key('expanded'))), const Size(90, 50));

    await tester.pumpWidget(
      const _Host(
        constraints: constraints,
        child: ReferenceSizedBox(
          reference: SizedBox.shrink(),
          width: horizontal,
          height: vertical,
          child: SizedBox.shrink(key: Key('shrunk')),
        ),
      ),
    );
    expect(tester.getSize(find.byKey(const Key('shrunk'))), const Size(40, 30));
  });

  testWidgets('an invalid rule names the axis and both sizes', (tester) async {
    final errors = <FlutterErrorDetails>[];
    final previousOnError = FlutterError.onError;
    FlutterError.onError = errors.add;
    try {
      await tester.pumpWidget(
        _Host(
          constraints: const BoxConstraints(maxWidth: 100, maxHeight: 50),
          child: ReferenceSizedBox(
            reference: const SizedBox(width: 40, height: 20),
            width: ReferenceSize.custom((_) => (minSize: 5, maxSize: 1)),
            child: const SizedBox.expand(),
          ),
        ),
      );
    } finally {
      FlutterError.onError = previousOnError;
    }

    expect(errors.length, greaterThan(0));
    expect(
      errors.first.exception.toString(),
      allOf(contains('invalid width extent'), contains('5.0'), contains('1.0')),
    );
  });
}

class const _Host({required final BoxConstraints constraints, required final Widget child}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Center(
        child: ConstrainedBox(constraints: constraints, child: child),
      ),
    );
  }
}

class const _RangeRule({required final double minSize, required final double maxSize}) implements ReferenceSize {
  @override
  ReferenceSizeResult getSize(double extent) => (minSize: minSize, maxSize: maxSize);
}
