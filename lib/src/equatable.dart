import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

const _equality = DeepCollectionEquality();

mixin EquatableProps {
    @protected
    final equatableProps = <Object?>[];

    @override
    int get hashCode {
        return _equality.hash(equatableProps);
    }

    @override
    bool operator ==(Object other) {
        if (identical(this, other)) {
            return true;
        }
        if (other is EquatableProps) {
            return other.runtimeType == runtimeType && _equality.equals(other.equatableProps, equatableProps);
        }
        return false;
    }
}

class EquatableObject with EquatableProps {
    EquatableObject(Iterable<Object?> equatableProps) {
        this.equatableProps.addAll(equatableProps);
    }
}
