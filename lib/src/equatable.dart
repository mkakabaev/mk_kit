import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

mixin EquatableProps {
  @protected
  final equatableProps = <Object?>[];

  static final Function _equals = const DeepCollectionEquality().equals;
  static final Function _hash = const DeepCollectionEquality().equals;

  @override
  int get hashCode {
    return _hash(equatableProps);
  }

  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType == runtimeType) {
      return _equals(other.equatableProps, equatableProps);
    }
    return false;
  }
}
