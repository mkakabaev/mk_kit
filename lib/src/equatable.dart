import 'package:flutter/foundation.dart';

import 'package:collection/collection.dart';

///
/// A lightweight internal mixin for implementing value-based equality and hashCode in Dart classes,
/// similar to the functionality provided by the `equatable` package, but without introducing an external dependency.
///
/// To use, mix this into your class and override [equatableProps] to return a list of the properties
/// that should be used for equality and hash code calculations. This enables deep equality for collections
/// and nested objects, making it suitable for use in immutable data classes, state objects, and value types.
///
/// Example:
/// ```dart
/// class MyData with EquatableProps {
///   final int id;
///   final String name;
///   final List<int> values;
///
///   MyData(this.id, this.name, this.values);
///
///   @override
///   List<Object?> get equatableProps => [id, name, values];
/// }
/// ```
///
/// This mixin is intended for internal use within the library to avoid a dependency on the `equatable` package.
///
mixin EquatableProps {
  @protected
  List<Object?> get equatableProps;

  @override
  int get hashCode {
    return _kEquality.hash(equatableProps);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is EquatableProps) {
      return other.runtimeType == runtimeType && _kEquality.equals(other.equatableProps, equatableProps);
    }
    return false;
  }
}

const _kEquality = DeepCollectionEquality();

///
/// A helper wrapper that enables deep equality for objects (including collections) when used in Dart records or as map keys.
///
/// This is especially useful when you want to compare records or objects containing collections (like lists, sets, or maps)
/// by value rather than by reference. For example, when using selectors or caching mechanisms that depend on value equality,
/// wrapping a collection in [EQValue] ensures that equality checks and hash codes are based on the contents of the collection,
/// not just its identity.
///
/// Example:
/// ```dart
/// final a = EQValue([1, 2, 3]);
/// final b = EQValue([1, 2, 3]);
/// print(a == b); // true
/// ```
///
/// This is similar in spirit to the `Equatable` package, but can be used as a lightweight wrapper for individual values
/// or collections, especially inside records or as map keys.
///
final class EQValue<T> with EquatableProps {
  final T value;

  const EQValue(this.value);

  @override
  List<Object?> get equatableProps => [value];
}
