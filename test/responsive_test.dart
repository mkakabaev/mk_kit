import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mk_kit/mk_kit.dart';

void main() {
  testWidgets('Responsive.of throws when there is no ancestor', (tester) async {
    await tester.pumpWidget(
      Builder(
        builder: (context) {
          Responsive.of(context);
          return const SizedBox();
        },
      ),
    );

    expect(tester.takeException(), isA<FlutterError>());
  });
}
