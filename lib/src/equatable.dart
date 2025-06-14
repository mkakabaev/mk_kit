import 'package:flutter/foundation.dart';

import 'package:collection/collection.dart';

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
class EQValue<T> with EquatableProps {
  final T value;

  const EQValue(this.value);

  @override
  List<Object?> get equatableProps => [value];
}

