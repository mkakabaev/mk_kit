import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import './key_value+provider.dart';

class SecureStorageProvider implements KeyValueStorageProvider {
    final FlutterSecureStorage _backedStorage;

    SecureStorageProvider({
        String? accountName, // macOS only
    }): _backedStorage = FlutterSecureStorage(
            mOptions: MacOsOptions.defaultOptions.copyWith(accountName: accountName),
        );

    @override
    Future<dynamic> getValueForKey(String key) async {
        return await _backedStorage.read(key: key);
    }

    @override
    Future<void> removeValueForKey(String key) async {
        await _backedStorage.delete(key: key);
    }

    @override
    Future<void> setValueForKey(String key, dynamic value) async {
        String v;
        if (value is String) {
            v = value;
        } else if (value is num || value is bool) {
            v = '$value';
        } else {
            throw UnsupportedError('Unable to store value of type ${value.runtimeType}');
        }
        await _backedStorage.write(key: key, value: v);
    }

    @override
    Future<void> clear() async {
        await _backedStorage.deleteAll();
    }
}
