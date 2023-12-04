import './description.dart';

class CWValue<T extends Object> {
  final T? value;
  CWValue(this.value);

  static T? resolve<T extends Object>(CWValue<T>? v, T? originalValue) {
    return v == null ? originalValue : v.value;
  }
}

class ValueRef<T> {
    T value;
    ValueRef(this.value);
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

///  Returns a new list with the elements of [items] flattened.
/// 
///  If [toElement] is specified, then it is used to transform each element of
///  [items] to an element of type [T]. If [toElement] is not specified, then
///  each element of [items] must be assignable to [T].
/// 
/// ```dart
/// void f() {
///   final list = [
///     "String",
///     1,
///     null,
///     [2, 2],
///     [
///       3,
///       "Another String",
///       3,
///       3,
///       [4, 4, 4, 4]
///     ],
///     [4, 4, 4, 4]
///   ];
///
///   final flattened = flatList<int>(list, (v) => int.tryParse("$v")); 
///   final flattenedNullable = flatList<int?>(list, (v) => int.tryParse("$v")); 
///   print(flattened);         // [1, 2, 2, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4]
///   print(flattenedNullable); // [null, 1, null, 2, 2, 3, null, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4]
/// }
///
/// ``` 
List<T> flatList<T>(Iterable<dynamic>? items, [T? Function(dynamic)? toElement]) {
  final result = <T>[];
  _flatList(items, toElement, result);
  return result;
}

void _flatList<T>(Iterable<dynamic>? items, T? Function(dynamic)? toElement, List<T> result) {
  if (items == null) {
    return;
  }

  if (toElement == null) {
    for (final item in items) {
      if (item is T) {
        result.add(item);
        continue;
      }
      if (item == null) {
        continue;
      }
      if (item is Iterable) {
        _flatList(item, null, result);
        continue;
      }
      assert(false, "flatList(): An object of type <$T> is expected: <$item> is not one");
    }
    return;
  }

  for (final item in items) {
    if (item is Iterable) {
      _flatList(item, toElement, result);
      continue;
    }
    final transformed = toElement(item);
    if (transformed is T) {
      result.add(transformed);
      continue;
    }
  }
}
