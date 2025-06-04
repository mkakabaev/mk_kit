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