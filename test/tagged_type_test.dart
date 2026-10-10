import 'package:flutter_test/flutter_test.dart';
import 'package:mk_kit/mk_kit.dart';

void main() {
  test('same tagged type compares by value', () {
    expect(const _UserId('a'), const _UserId('a'));
    expect(const _UserId('a').hashCode, const _UserId('a').hashCode);
    expect(const _UserId('a'), isNot(const _UserId('b')));
  });

  test('different tagged types with the same value are not equal', () {
    const user = _UserId('a');
    const product = _ProductId('a');

    expect(user == product, isFalse);
    expect(user.hashCode, isNot(product.hashCode));
  });
}

class _UserId extends TaggedType<String> {
  const _UserId(super.value);
}

class _ProductId extends TaggedType<String> {
  const _ProductId(super.value);
}
