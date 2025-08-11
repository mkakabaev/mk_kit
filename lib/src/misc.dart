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
/// A base class for implementing tagged (or branded) types in Dart, inspired by TypeScript's branded types.
///
/// Tagged types are used to create distinct types from primitive values (such as `String` or `int`)
/// to provide additional type safety and prevent accidental misuse or mixing of values that share the same underlying type.
/// For example, you might want to distinguish between a `UserId` and a `ProductId` even though both are represented as `String`.
///
/// Example usage:
/// ```dart
/// class UserId extends TaggedType<String> {
///   const UserId(super.value);
/// }
///
/// void fetchUser(UserId id) { ... }
/// ```
///
/// **Note:**
/// As of Dart 3.3, the new 'extension type' feature is generally preferred for this use case,
/// as it provides a more idiomatic and efficient way to create branded types:
/// ```dart
/// extension type UserId(String id) {}
/// ```
/// Use this class only if you need compatibility with older Dart versions or require additional
/// functionality provided by this base class (such as [DescriptionProvider]).
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

///
/// A lightweight wrapper for nullable objects to enable value-based equality and hashing.
///
/// This is particularly useful when you need to distinguish between `null` and non-null values
/// in equality comparisons or as map keys, such as in state management scenarios (e.g., [ValueState]).
///
/// mktodo: Could this be replaced with an extension type?
///
final class OptionalValue<T extends Object> {
  final T? value;

  const OptionalValue(this.value);

  @override
  int get hashCode => value.hashCode;

  @override
  bool operator ==(Object other) => other is OptionalValue<T> && other.value == value;
}
