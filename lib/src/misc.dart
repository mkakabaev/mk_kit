import 'description_builder.dart';

///
/// Helper to pass nullable value to copyWith() method oif a class.
/// Works better than sentinels because it is type-safe.
///
/// ```
/// class MyClass {
///    final int? a;
///
///    MyClass({
///        required this.a,
///    });
///
///    MyClass copyWith({
///        CWValue<int>? a,
///    }) {
///        return MyClass(
///           a: CWValue.resolve(a, this.a),
///        );
///    }
/// }
/// ```
///
/// Starting Dart 3.3 implemented using 'extension type'
/// Due type unsafety of 'extension type' I had to use pseudo-typing record (T?, Type) to hold the value
/// Without it CWValue(null) is interpreted as null,
/// Instead (T?, Type) record (T?, String) can be used as well and even (T?,)
/// After all it gives type checking on CWValue(null)

extension type const CWValue<T extends Object>._((T?, Type) _value) implements Object {
  const CWValue(T? value) : this._((value, T));

  static T? resolve<T extends Object>(CWValue<T>? v, T? originalValue) => v == null ? originalValue : v._value.$1;

  T? get value => _value.$1; // ignore: avoid-renaming-representation-getters

  static CWValue<T>? diffOnly<T extends Object>(T? valueFrom, T? valueTo) {
    return valueFrom == valueTo ? null : CWValue(valueTo);
  }
}

/* old, pre-Dart 3.3 implementation
class CWValue<T extends Object> {
    final T? value;
    CWValue(this.value);

    static T? resolve<T extends Object>(CWValue<T>? v, T? originalValue) {
        return v == null ? originalValue : v.value;
    }

    static CWValue<T>? diffOnly<T extends Object>(T? valueFrom, T? valueTo) {
      return valueFrom == valueTo ? null : CWValue<T>(valueTo);
    }  
}
*/

///
/// A simple wrapper to hold (and change) value. Use to mimic 'out' function parameters in Dart:
/// an ability to change the value of a parameter inside a function by reference. Mostly
/// useless nowadays, can be replaced with a function that returns record with multiple values.
///
class ValueRef<T> {
  T value;
  ValueRef(this.value);
}

T safe<T>(Object? v, T defaultValue) {
  return v is T ? v : defaultValue;
}

T safeMapValue<T>(Object? map, String key, T defaultValue) {
  if (map is Map) {
    final v = map[key];
    if (v is T) {
      return v;
    }
  }
  return defaultValue;
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
///    extension type MyType(T id) { }///
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
    db.addValue(value, quote: value is String);
  }
}
