import 'package:shared_preferences/shared_preferences.dart';
import './key_value+provider.dart';

// ------------------------------------------------------------------------------------------------

class PreferencesStorageProvider implements KeyValueStorageProvider {
    SharedPreferences? _backedStorage;

    Future<SharedPreferences> _getInstance() async {
        return _backedStorage ??= await SharedPreferences.getInstance();
    }

    @override
    Future<Object?> getValueForKey(String key) async {
        final bs = _backedStorage ?? await _getInstance();
        return bs.get(key);
    }

    @override
    Future<void> removeValueForKey(String key) async {
        final bs = _backedStorage ?? await _getInstance();
        await bs.remove(key);
    }

    @override
    Future<void> setValueForKey(String key, Object? value) async {
        final bs = _backedStorage ?? await _getInstance();
        if (value is String) {
            await bs.setString(key, value);
            return;
        }
        if (value is int) {
            await bs.setInt(key, value);
            return;
        }
        if (value is bool) {
            await bs.setBool(key, value);
            return;
        }
        if (value is double) {
            await bs.setDouble(key, value);
            return;
        }
        throw UnsupportedError('Unable to store value of type ${value.runtimeType}');
    }

    @override
    Future<void> clear() async {
        final bs = _backedStorage ?? await _getInstance();
        await bs.clear();
    }
}
