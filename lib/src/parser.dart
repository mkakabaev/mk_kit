import './misc.dart';

class Parser {
  static const instance = Parser();

  const Parser();

  Map parseMap(
    Object? value, {
    String? tag,
    bool allowEmpty = true,
    Map Function()? defaultValue,
  }) {
    final effectiveValue = value ?? defaultValue?.call();
    if (effectiveValue is! Map) {
      throw MKFormatException("Wrong value '$effectiveValue': a map is expected", tag: tag);
    }

    if (!allowEmpty && effectiveValue.isEmpty) {
      throw MKFormatException("Wrong value '$value': a non-empty map is expected", tag: tag);
    }
    return effectiveValue;
  }

  List<T> parseArray<T>(
    Object? value, {
    String? tag,
    bool allowEmpty = true,
    List<T> Function()? defaultValue,
  }) {
    final effectiveValue = value ?? defaultValue?.call();

    if (effectiveValue is! List) {
      throw MKFormatException("Wrong value '$value': an array is expected", tag: tag);
    }

    if (!allowEmpty && effectiveValue.isEmpty) {
      throw MKFormatException("Wrong value '$value': a non-empty array is expected", tag: tag);
    }
    return effectiveValue as List<T>;
  }

  bool parseBool(Object? value, {String? tag, bool? defaultValue}) {
    bool? result;
    if (value is bool) {
      return value;
    }
    if (value is String) {
      const boolMap = {
        't': true,
        'true': true,
        '1': true,
        'f': false,
        'false': false,
        '0': false,
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

    throw MKFormatException("Wrong value '$value': a boolean is expected", tag: tag);
  }

  String parseString(
    Object? value, {
    String? tag,
    bool allowEmpty = true,
    bool allowInt = false,
    String? defaultValue,
  }) {
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
        throw MKFormatException("Wrong value '$value': a non-empty string is expected", tag: tag);
      }
      return result;
    }

    throw MKFormatException("Wrong value '$value': a string is expected", tag: tag);
  }

  int parseInt(
    Object? value, {
    String? tag,
    int? defaultValue,
    int? minValue,
    int? maxValue,
  }) {
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
      throw MKFormatException("Wrong value '$value': an integer is expected", tag: tag);
    }
    if (minValue != null && result < minValue) {
      throw MKFormatException('Wrong integer value $result: must be less than $minValue', tag: tag);
    }
    if (maxValue != null && result > maxValue) {
      throw MKFormatException('Wrong integer value $result: must be greater than $maxValue', tag: tag);
    }
    return result;
  }

  double parseDouble(
    Object? value, {
    String? tag,
    double? defaultValue,
    double? minValue,
    double? maxValue,
  }) {
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
      throw MKFormatException("Wrong value '$value': a double is expected", tag: tag);
    }
    if (minValue != null && result < minValue) {
      throw MKFormatException('Wrong double value $result: must be less than $minValue', tag: tag);
    }
    if (maxValue != null && result > maxValue) {
      throw MKFormatException('Wrong double value $result: must be greater than $maxValue', tag: tag);
    }
    return result;
  }
}

class MKFormatException extends FormatException {
  final List<String> tags;
  final String originalMessage;

  @override
  String get message {
    var s = originalMessage;
    final tag = tags.reversed.join('.');
    if (tag.isNotEmpty) {
      s += ' (tag: $tag)';
    }
    return s;
  }

  MKFormatException(String message, {String? tag}) : this._(message, tag == null ? [] : [tag]);

  MKFormatException._(this.originalMessage, this.tags) : super(originalMessage);

  factory MKFormatException.fromError(Object? error, {String? tag}) {
    if (error is MKFormatException) {
      if (tag != null) {
        return MKFormatException._(error.originalMessage, [...error.tags, tag]);
      }
      return error;
    }
    return MKFormatException('$error', tag: tag);
  }
}
