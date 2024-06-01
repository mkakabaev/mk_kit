import 'dart:convert';

import '../description.dart';
import '../parser.dart';
import './key_value+other.dart';
import './key_value+provider.dart';

typedef KeyValueStorageErrorHandler = void Function(KeyValueStorageException error, StackTrace stackTrace);

class KeyValueStorage with DescriptionProvider {
  final KeyValueStorageProvider provider;
  final Parser parser;
  KeyValueStorageErrorHandler? onError;

  KeyValueStorage({required this.provider, this.parser = Parser.instance, this.onError});

  void _onError(String message, Object error, StackTrace stackTrace) {
    final e = KeyValueStorageException('$this: $message: $error');
    final onError = this.onError;
    if (onError == null) {
      throw e;
    }

    onError(e, stackTrace);
  }

  Future<void> removeValueForKey(String key) async {
    try {
      await provider.removeValueForKey(key);
    } catch (e, stack) {
      _onError("Failed to remove value for key '$key'", e, stack);
    }
  }

  Future<void> setValue(String key, Object? value) async {
    try {
      if (key.isEmpty) {
        throw ArgumentError('Empty key passed');
      }
      if (value == null) {
        await provider.removeValueForKey(key);
      } else {
        await provider.setValueForKey(key, value);
      }
    } catch (e, stack) {
      _onError("Failed to save value at key '$key'", e, stack);
    }
  }

  Future<R?> getValue<R>(String key, KVStorageValueMapper<R> mapper) async {
    try {
      if (key.isEmpty) {
        throw ArgumentError('Empty key passed');
      }
      final value = await provider.getValueForKey(key);
      if (value == null) {
        return null;
      }
      return mapper(value);
    } catch (e, stack) {
      _onError('Failed to restore value for key $key as $R', e, stack);
      return null;
    }
  }

  Future<int?> getInt(String key) => getValue(key, (value) => parser.parseInt(value));
  Future<void> setInt(String key, int? value) => setValue(key, value);

  Future<bool?> getBool(String key) => getValue(key, (value) => parser.parseBool(value));
  Future<void> setBool(String key, bool? value) => setValue(key, value);

  Future<String?> getString(String key) => getValue(key, (value) => parser.parseString(value));
  Future<void> setString(String key, String? value) => setValue(key, value);

  /// Most common way to organize json objects. This way we move all possible typecasting errors into parsing
  Future<Map<String, dynamic>?> getJsonMap(String key) => getValue(
        key,
        (value) {
          final s = Parser.instance.parseString(value);
          final result = jsonDecode(s);
          return Parser.instance.parseMap(result) as Map<String, dynamic>?;
        },
      );

  Future<Object?> getJson(String key) => getValue(
        key,
        (value) {
          return jsonDecode(Parser.instance.parseString(value));
        },
      );

  Future<void> setJson(String key, Object? value) async {
    try {
      if (value == null) {
        await setValue(key, value); // this will remove the key
      } else {
        await setString(key, jsonEncode(value));
      }
    } catch (e, stack) {
      _onError("Failed to encode value to JSON for key '$key'", e, stack);
    }
  }

  Future<void> clear() async {
    try {
      await provider.clear();
    } catch (e, stack) {
      _onError('Failed to clean', e, stack);
    }
  }

  @override
  void configureDescription(DescriptionBuilder db) {
    db.addValue('${provider.runtimeType}');
  }
}
