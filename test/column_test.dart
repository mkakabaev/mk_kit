import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mk_kit/mk_kit.dart';

void main() {
  testWidgets('expandable spacer in an unbounded column keeps a finite height', (tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: Column(
          children: [
            SpacerColumn(children: [Text('a'), ColumnSpacer(height: 20, minHeight: 8, isExpandable: true)]),
          ],
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(SpacerColumn)).height.isFinite, isTrue);
  });
}
