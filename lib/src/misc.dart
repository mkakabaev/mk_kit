import 'package:mk_kit/mk_kit.dart';

class CWValue<T extends Object> {
  final T? value;
  CWValue(this.value);

  static T? resolve<T extends Object>(CWValue<T>? v, T? originalValue) {
    return v == null ? originalValue : v.value;
  }
}

T safe<T>(dynamic v, T defaultValue) {
  return v is T ? v : defaultValue;
}

T safeMapValue<T>(dynamic map, String key, T defaultValue) {
  if (map is Map) {
    final v = map[key];
    if (v is T) {
      return v;
    }
  }
  return defaultValue;
}

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

abstract class CanBeEmpty {
  bool get isEmpty;
  bool get isNotEmpty => !isEmpty;
}

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

///
/// Tagged (or branded) type concept, similar to TypeScript's branded types.
///
abstract class TaggedType<T extends Object> with DescriptionProvider {
  final T value;

  const TaggedType(this.value);

  @override
  int get hashCode => value.hashCode;

  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType == runtimeType) {
      return other.value == value;
    }
    return false;
  }

  @override
  void configureDescription(DescriptionBuilder db) {
    db.addValue(value, quote: T is String);
  }
}
