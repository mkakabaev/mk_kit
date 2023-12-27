import './misc.dart';

class Parser {
    static const instance = Parser();

    const Parser();

    Map parseMap(
        dynamic value, {
        String? tag,
        bool allowEmpty = true,
        Map Function()? defaultValue,
    }) {
        if (value == null) {
            if (defaultValue != null) {
                value = defaultValue();
            }
        }

        if (value is! Map) {
            throw MKFormatException("Wrong value '$value': a map is expected", tag: tag);
        }

        if (!allowEmpty && value.isEmpty) {
            throw MKFormatException("Wrong value '$value': a non-empty map is expected", tag: tag);
        }
        return value;
    }

    List<T> parseArray<T>(
        dynamic value, {
        String? tag,
        bool allowEmpty = true,
        List<T> Function()? defaultValue,
    }) {
        if (value == null) {
            if (defaultValue != null) {
                value = defaultValue();
            }
        }

        if (value is! List) {
            throw MKFormatException("Wrong value '$value': an array is expected", tag: tag);
        }

        if (!allowEmpty && value.isEmpty) {
            throw MKFormatException("Wrong value '$value': a non-empty array is expected", tag: tag);
        }
        return value as List<T>;
    }

    bool parseBool(dynamic value, {String? tag, bool? defaultValue}) {
        bool? result;
        if (value is bool) {
            return value;
        }
        if (value is String) {
            const boolMap = <String, bool>{
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
        dynamic value, {
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
        dynamic value, {
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
        dynamic value, {
        String? tag,
        double? defaultValue,
        double? minValue,
        double? maxValue,
    }) {
        double? result;
        if (value == null) {
            result = defaultValue;
        } else if (value is double) {
            result = value;
        } else if (value is int) {
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

    MKFormatException._(this.originalMessage, this.tags) : super(originalMessage);

    MKFormatException(String message, {String? tag}) : this._(message, tag == null ? [] : [tag]);

    factory MKFormatException.fromError(dynamic error, {String? tag}) {
        if (error is MKFormatException) {
            if (tag != null) {
                return MKFormatException._(error.originalMessage, [...error.tags, tag]);
            }
            return error;
        }
        return MKFormatException('$error', tag: tag);
    }
}
