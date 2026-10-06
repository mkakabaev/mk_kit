import 'package:flutter_test/flutter_test.dart';
import 'package:mk_kit/mk_kit.dart';

class UserId extends TaggedType<String> {
  const UserId(super.value);
}

class ProductId extends TaggedType<String> {
  const ProductId(super.value);
}

void main() {
  test('same tagged type compares by value', () {
    expect(const UserId('a'), const UserId('a'));
    expect(const UserId('a').hashCode, const UserId('a').hashCode);
    expect(const UserId('a'), isNot(const UserId('b')));
  });

  test('different tagged types with the same value are not equal', () {
    const user = UserId('a');
    const product = ProductId('a');

    expect(user == product, isFalse);
    expect(user.hashCode, isNot(product.hashCode));
  });
}
