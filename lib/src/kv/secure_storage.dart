import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import './key_value+provider.dart';

// ------------------------------------------------------------------------------------------------

class SecureStorageProvider implements KeyValueStorageProvider {
    final _backedStorage = const FlutterSecureStorage();

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
        await _backedStorage.write(key: key, value: value is String ? value : "$value");
    }

    @override
    Future<void> clear() async {
        await _backedStorage.deleteAll();
    }
}
