import 'package:flutter/foundation.dart';

import 'package:collection/collection.dart';

/// @docImport 'value_state';

///
/// Outdated. Use standard `equatable` package instead.
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
/// Helper wrapper to make object equatable in records. Useful for selectors to wrap collections.
///
final class EQValue<T> with EquatableProps {
  final T value;

  const EQValue(this.value);

  @override
  List<Object?> get equatableProps => [value];
}

///
/// Helper wrapper to work with nullable objects. Use case: [ValueState]
///
/// mktodo: Could it be replaced with extension type?
///
final class OptionalValue<T extends Object> {
  final T? value;

  const OptionalValue(this.value);

  @override
  int get hashCode => value.hashCode;

  @override
  bool operator ==(Object other) => other is OptionalValue<T> && other.value == value;
}
