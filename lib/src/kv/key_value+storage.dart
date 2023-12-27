import 'dart:convert';

import '../description.dart';
import '../parser.dart';
import './key_value+other.dart';
import './key_value+provider.dart';

class KeyValueStorage with DescriptionProvider {
    final KeyValueStorageProvider provider;
    final Parser parser;
    final void Function(KeyValueStorageException error, StackTrace stackTrace)? onError;

    KeyValueStorage({required this.provider, this.parser = Parser.instance, this.onError});

    void _onError(String message, Object error, StackTrace stackTrace) {
        final e = KeyValueStorageException('$this: $message: $error');
        final onError = this.onError;
        if (onError != null) {
            onError(e, stackTrace);
        } else {
            throw e;
        }
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
                throw 'Empty key passed';
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
                throw 'Empty key passed';
            }
            final value = await provider.getValueForKey(key);
            if (value == null) {
                return null;
            }
            return mapper(value!);
        } catch (e, stack) {
            _onError('Failed to restore value for key $key as $R', e, stack);
            return null;
        }
    }

    Future<int?> getInt(String key) => getValue<int>(key, (value) => parser.parseInt(value));
    Future<void> setInt(String key, int? value) => setValue(key, value);

    Future<bool?> getBool(String key) => getValue<bool>(key, (value) => parser.parseBool(value));
    Future<void> setBool(String key, bool? value) => setValue(key, value);

    Future<String?> getString(String key) => getValue<String>(key, (value) => parser.parseString(value));
    Future<void> setString(String key, String? value) => setValue(key, value);

    Future<Object?> getJson(String key) => getValue<dynamic>(key, (value) => jsonDecode(value));
    Future<void> setJson(String key, Object? value) async {
        try {
            if (value != null) {
                await setString(key, jsonEncode(value));
            } else {
                await setValue(key, value); // this will remove the key
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
