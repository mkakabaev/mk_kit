import 'package:flutter/painting.dart';

import 'description_builder.dart';

///
/// A simple wrapper to hold (and change) value. Use to mimic 'out' function parameters in Dart:
/// an ability to change the value of a parameter inside a function by reference. Mostly
/// useless nowadays, can be replaced with a function that returns record with multiple values.
///
class ValueRef<T> {
  T value;
  ValueRef(this.value);
}

// ------------------------------------------------------------------------------------------------

bool isEmpty(Object? value) {
  if (value == null) {
    return true;
  }

  if (value is String) {
    return value.isEmpty;
  }

  if (value is Iterable) {
    return value.isEmpty;
  }

  if (value is Map) {
    return value.isEmpty;
  }

  if (value is CanBeEmpty) {
    return value.isEmpty;
  }

  return false;
}

bool isNotEmpty(Object? value) => !isEmpty(value);

abstract interface class CanBeEmpty {
  bool get isEmpty;
  bool get isNotEmpty => !isEmpty;
}

// ------------------------------------------------------------------------------------------------

String? stringify(Object? value) {
  if (value == null) {
    return null;
  }

  if (value is String) {
    return value;
  }

  if (value is Enum) {
    return value.name;
  }

  return '$value';
}

// ------------------------------------------------------------------------------------------------

///
/// Tagged (or branded) type concept, similar to TypeScript's branded types.
///
/// In most cases it is better to use the new 'extension type' feature (Dart 3.3+)
/// ```
///    extension type MyType(T id) { }
/// ```
///
abstract class TaggedType<T extends Object> with DescriptionProvider {
  final T value;

  const TaggedType(this.value);

  @override
  int get hashCode => value.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is TaggedType) {
      assert(
        other.runtimeType == runtimeType,
        'An attempt to compare using different types: $runtimeType vs ${other.runtimeType}',
      );
      return other.value == value;
    }
    return false;
  }

  @override
  void configureDescription(DescriptionBuilder db) {
    db.addValue(value, isQuoted: value is String);
  }
}

extension MKEdgeInsets on EdgeInsets {
  EdgeInsets getScaled(double scale) => EdgeInsets.fromLTRB(
    (left * scale).roundToDouble(),
    (top * scale).roundToDouble(),
    (right * scale).roundToDouble(),
    (bottom * scale).roundToDouble(),
  );
}
