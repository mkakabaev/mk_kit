import 'package:flutter_test/flutter_test.dart';
import 'package:mk_kit/src/equatable.dart';

class TestEquatable with EquatableProps {
  final String name;
  final int age;
  final List<Object> tags;

  TestEquatable(this.name, this.age, this.tags);

  @override
  List<Object?> get equatableProps => [name, age, tags];
}

void main() {
  group('EquatableProps', () {
    test('identical objects are equal', () {
      final obj1 = TestEquatable('John', 30, [
        'tag1',
        'tag2',
        {
          "keyPlain": "value",
          "keyList": [1, 2, 3],
          "keyMap": {
            "keyPlain": "value",
            "keyList": [1, 2,  { "keyPlain": "value", "keyList": [1, 2, 3] }],
          },
          "keySet": {"A", "B", "C"},
        },
      ]);
      final obj2 = TestEquatable('John', 30, [
        'tag1',
        'tag2',
        {
          "keyPlain": "value",
          "keyList": [1, 2, 3],
          "keyMap": {
            "keyPlain": "value",
            "keyList": [1, 2,  { "keyPlain": "value", "keyList": [1, 2, 3] }],
          },
          "keySet": {"A", "B", "C"},
        },
      ]);
      expect(obj1, equals(obj2));
      expect(obj1.hashCode, equals(obj2.hashCode));
    });

    test('different objects are not equal', () {
      final obj1 = TestEquatable('John', 30, ['tag1', 'tag2']);
      final obj2 = TestEquatable('Jane', 30, ['tag1', 'tag2']);
      expect(obj1, isNot(equals(obj2)));
      expect(obj1.hashCode, isNot(equals(obj2.hashCode)));
    });

    test('different types are not equal', () {
      final obj1 = TestEquatable('John', 30, ['tag1', 'tag2']);
      final obj2 = Object();
      expect(obj1, isNot(equals(obj2)));
    });
  });

  group('EQValue', () {
    test('identical values are equal', () {
      final value1 = EQValue('test');
      final value2 = EQValue('test');
      expect(value1, equals(value2));
      expect(value1.hashCode, equals(value2.hashCode));
    });

    test('different values are not equal', () {
      final value1 = EQValue('test1');
      final value2 = EQValue('test2');
      expect(value1, isNot(equals(value2)));
      expect(value1.hashCode, isNot(equals(value2.hashCode)));
    });

    test('can hold and compare complex objects', () {
      final value1 = EQValue(TestEquatable('John', 30, ['tag1', 'tag2']));
      final value2 = EQValue(TestEquatable('John', 30, ['tag1', 'tag2']));
      final value3 = EQValue(TestEquatable('Jane', 30, ['tag1', 'tag2']));

      expect(value1, equals(value2));
      expect(value1, isNot(equals(value3)));
    });
  });
}
