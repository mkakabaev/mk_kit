import 'package:mk_kit/mk_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesStorageProvider({
  /// Prepended to every key. The default is empty, so keys are stored unchanged.
  ///
  /// An empty prefix makes [clear] delete every key in [SharedPreferences].
  /// A non-empty prefix stores keys as `keyPrefix + key` and makes [clear] delete only keys that start with it.
  final String keyPrefix = '',
}) implements KeyValueStorageProvider {
  SharedPreferences? _backedStorage;

  String _storageKey(String key) => '$keyPrefix$key';

  Future<SharedPreferences> _getInstance() async {
    return _backedStorage ??= await SharedPreferences.getInstance();
  }

  @override
  Future<Object?> getValueForKey(String key) async {
    final bs = _backedStorage ?? await _getInstance();
    return bs.get(_storageKey(key));
  }

  @override
  Future<void> removeValueForKey(String key) async {
    final bs = _backedStorage ?? await _getInstance();
    final _ = await bs.remove(_storageKey(key));
  }

  @override
  Future<void> setValueForKey(String key, Object? value) async {
    final bs = _backedStorage ?? await _getInstance();
    final storageKey = _storageKey(key);
    if (value is String) {
      final _ = await bs.setString(storageKey, value);
      return;
    }
    if (value is int) {
      final _ = await bs.setInt(storageKey, value);
      return;
    }
    if (value is bool) {
      final _ = await bs.setBool(storageKey, value);
      return;
    }
    if (value is double) {
      final _ = await bs.setDouble(storageKey, value);
      return;
    }
    throw UnsupportedError('Unable to store value of type ${value.runtimeType}');
  }

  /// Deletes every [SharedPreferences] key when [keyPrefix] is empty.
  /// Otherwise deletes only keys that start with [keyPrefix].
  @override
  Future<void> clear() async {
    final bs = _backedStorage ?? await _getInstance();
    if (keyPrefix.isEmpty) {
      final _ = await bs.clear();
      return;
    }
    final keys = bs.getKeys().where((key) => key.startsWith(keyPrefix)).toList();
    for (final key in keys) {
      final _ = await bs.remove(key);
    }
  }
}
