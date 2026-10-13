import 'package:example/baseline_demo/baseline_demo.dart';
import 'package:example/main.dart';
import 'package:example/reference_sized_box_demo/reference_sized_box_demo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('home page loads', (tester) async {
    await tester.pumpWidget(const MKKitExampleApp());
    await tester.pumpAndSettle();
    expect(find.text('mk-kit demo'), findsOneWidget);
  });

  testWidgets('baseline demo layouts', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: BaselineDemo()));
    await tester.pumpAndSettle();
    expect(find.text('Baseline Demo'), findsOneWidget);
    expect(find.text('Flutter Baseline'), findsOneWidget);
  });

  testWidgets('reference sized box demo layouts', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ReferenceSizedBoxDemo()));
    await tester.pumpAndSettle();
    expect(find.text('ReferenceSizedBox'), findsOneWidget);
    expect(find.text('child'), findsOneWidget);
    expect(find.text('reference'), findsOneWidget);
  });
}
