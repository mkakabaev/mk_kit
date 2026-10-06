import 'package:flutter_test/flutter_test.dart';
import 'package:mk_kit/mk_kit.dart';

void main() {
  test('DisposeBag toString includes its name', () {
    final bag = DisposeBag(name: 'session');
    expect(bag.toString(), contains('session'));
    bag.dispose();
  });
}
