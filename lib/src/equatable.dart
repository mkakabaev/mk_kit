import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

mixin EquatableProps {
  @protected
  final equatableProps = <Object?>[];

  static const _kEquality = DeepCollectionEquality();

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

class EquatableObject with EquatableProps {
  EquatableObject(Iterable<Object?> equatableProps) {
    this.equatableProps.addAll(equatableProps);
  }
}
