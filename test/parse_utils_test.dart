import 'package:flutter_test/flutter_test.dart';
import 'package:mk_kit/mk_kit.dart';

// ignore_for_file: avoid-dynamic

void main() {
  test('parseList accepts a JSON list when every element has the requested type', () {
    expect(ParseUtils.parseList<int>(<dynamic>[1, 2, 3]), [1, 2, 3]);
  });

  test('parseList rejects an element of the wrong type', () {
    expect(
      () => ParseUtils.parseList<int>(<dynamic>[1, 'x']),
      throwsA(isA<FormatException>().having((error) => error.message, 'message', contains('at index 1'))),
    );
  });

  test('parseInt and parseDouble describe the bound that failed', () {
    expect(
      () => ParseUtils.parseInt(1, minValue: 5),
      throwsA(
        isA<FormatException>().having((error) => error.message, 'message', contains('greater than or equal to 5')),
      ),
    );
    expect(
      () => ParseUtils.parseInt(10, maxValue: 5),
      throwsA(isA<FormatException>().having((error) => error.message, 'message', contains('less than or equal to 5'))),
    );
    expect(
      () => ParseUtils.parseDouble(1, minValue: 5),
      throwsA(
        isA<FormatException>().having((error) => error.message, 'message', contains('greater than or equal to 5')),
      ),
    );
    expect(
      () => ParseUtils.parseDouble(10, maxValue: 5),
      throwsA(isA<FormatException>().having((error) => error.message, 'message', contains('less than or equal to 5'))),
    );
  });
}
