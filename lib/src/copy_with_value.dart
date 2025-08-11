///
/// A type-safe helper for passing nullable values to a class's `copyWith()` method,
/// enabling explicit intent to set a field to `null` versus leaving it unchanged.
///
/// This approach is superior to using sentinel values (such as a special constant)
/// because it leverages the type system for safety and clarity.
///
/// # Motivation
/// In Dart, when you want to allow a field to be set to `null` via `copyWith`, you
/// can't distinguish between "no change" and "set to null" using just nullable parameters:
///
/// ```dart
/// class MyClass {
///   final int? a;
///
///   MyClass({required this.a});
///
///   // Problematic: can't distinguish between "no change" and "set to null"
///   MyClass copyWith({int? a}) {
///     return MyClass(a: a ?? this.a);
///   }
/// }
/// ```
///
/// With [CWValue], you can explicitly express intent:
///
/// ```dart
/// class MyClass {
///   final int? a;
///
///   MyClass({required this.a});
///
///   MyClass copyWith({CWValue<int>? a}) {
///     return MyClass(a: CWValue.resolve(a, this.a));
///   }
/// }
///
/// final x = MyClass(a: 42);
/// x.copyWith(); // a == 42 (no change)
/// x.copyWith(a: CWValue(null)); // a == null (explicitly set to null)
/// x.copyWith(a: CWValue(100)); // a == 100
/// ```
///
/// # Implementation Notes
/// - As of Dart 3.3, this is implemented using an `extension type` for efficiency and type safety.
/// - To avoid type unsafety with extension types and `null`, a pseudo-typed record `(T?, Type)` is used internally.
///   This ensures that `CWValue<T>(null)` is not confused with a plain `null`, and preserves type information.
/// - Alternative representations (such as `(T?, String)` or `(T?,)`) are possible, but `(T?, Type)` provides
///   robust type checking for `CWValue(null)`.
///
/// # See Also
/// - [CWValue.resolve] for resolving the value in `copyWith`.
/// - [CWValue.diffOnly] for creating a [CWValue] only if the value has changed.
///
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
