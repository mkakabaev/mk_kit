import './misc.dart';

abstract final class ParseUtils {
  static Map parseMap(Object? value, {bool allowEmpty = true, Map Function()? defaultValue}) {
    final effectiveValue = value ?? defaultValue?.call();
    if (effectiveValue is! Map) {
      throw FormatException("Wrong value '$effectiveValue': a map is expected");
    }

    if (!allowEmpty && effectiveValue.isEmpty) {
      throw FormatException("Wrong value '$value': a non-empty map is expected");
    }
    return effectiveValue;
  }

  static List<T> parseList<T>(Object? value, {bool allowEmpty = true, List<T> Function()? defaultValue}) {
    final effectiveValue = value ?? defaultValue?.call();

    if (effectiveValue is! List) {
      throw FormatException("Wrong value '$value': an array is expected");
    }

    if (!allowEmpty && effectiveValue.isEmpty) {
      throw FormatException("Wrong value '$value': a non-empty array is expected");
    }
    return effectiveValue as List<T>;
  }

  static bool parseBool(Object? value, {bool? defaultValue}) {
    bool? result;
    if (value is bool) {
      return value;
    }
    if (value is String) {
      const boolMap = {
        '0': false,
        '1': true,
        'F': false,
        'False': false,
        'T': true,
        'True': true,
        'f': false,
        'false': false,
        't': true,
        'true': true,
      };
      result = boolMap[value.toLowerCase()];
    } else if (value is int) {
      switch (value) {
        case 0:
          result = false;

        case 1:
          result = true;
      }
    } else if (value == null) {
      result = defaultValue;
    }

    if (result != null) {
      return result;
    }

    throw FormatException("Wrong value '$value': a boolean value is expected");
  }

  static String parseString(Object? value, {bool allowEmpty = true, bool allowInt = false, String? defaultValue}) {
    String? result;
    if (value is String) {
      result = value;
    } else if (allowInt && value is int) {
      result = value.toString();
    } else if (value == null) {
      result = defaultValue;
    }

    if (result != null) {
      if (!allowEmpty && isEmpty(result)) {
        throw FormatException("Wrong value '$value': a non-empty string is expected");
      }
      return result;
    }

    throw FormatException("Wrong value '$value': a string is expected");
  }

  static int parseInt(Object? value, {int? defaultValue, int? minValue, int? maxValue}) {
    int? result;
    if (value == null) {
      result = defaultValue;
    } else if (value is int) {
      result = value;
    }
    if (value is String) {
      result = int.tryParse(value);
    }
    if (result == null) {
      throw FormatException("Wrong value '$value': an integer is expected");
    }
    if (minValue != null && result < minValue) {
      throw FormatException('Wrong integer value $result: must be less than $minValue');
    }
    if (maxValue != null && result > maxValue) {
      throw FormatException('Wrong integer value $result: must be greater than $maxValue');
    }
    return result;
  }

  static double parseDouble(Object? value, {double? defaultValue, double? minValue, double? maxValue}) {
    double? result;
    if (value == null) {
      result = defaultValue;
    } else if (value is num) {
      result = value.toDouble();
    }
    if (value is String) {
      result = double.tryParse(value);
    }
    if (result == null) {
      throw FormatException("Wrong value '$value': a double is expected");
    }
    if (minValue != null && result < minValue) {
      throw FormatException('Wrong double value $result: must be less than $minValue');
    }
    if (maxValue != null && result > maxValue) {
      throw FormatException('Wrong double value $result: must be greater than $maxValue');
    }
    return result;
  }
}
