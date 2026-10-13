import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mk_kit/mk_kit.dart';

class SecureStorageProvider implements KeyValueStorageProvider {
  /// Prepended to every key. The default is empty, so keys are stored unchanged.
  ///
  /// An empty prefix makes [clear] delete every key in [FlutterSecureStorage].
  /// A non-empty prefix stores keys as `keyPrefix + key` and makes [clear] delete only keys that start with it.
  final String keyPrefix;
  final FlutterSecureStorage _backedStorage;

  SecureStorageProvider({
    this.keyPrefix = '',
    String? accountName, // macOS only
  }) : _backedStorage = FlutterSecureStorage(mOptions: MacOsOptions(accountName: accountName));

  String _storageKey(String key) => '$keyPrefix$key';

  @override
  Future<Object?> getValueForKey(String key) {
    return _backedStorage.read(key: _storageKey(key));
  }

  @override
  Future<void> removeValueForKey(String key) async {
    await _backedStorage.delete(key: _storageKey(key));
  }

  @override
  Future<void> setValueForKey(String key, Object? value) async {
    String v;
    if (value is String) {
      v = value;
    } else if (value is num || value is bool) {
      v = '$value';
    } else {
      throw UnsupportedError('Unable to store value of type ${value.runtimeType}');
    }
    await _backedStorage.write(key: _storageKey(key), value: v);
  }

  /// Deletes every secure-storage key when [keyPrefix] is empty.
  /// Otherwise deletes only keys that start with [keyPrefix].
  @override
  Future<void> clear() async {
    if (keyPrefix.isEmpty) {
      await _backedStorage.deleteAll();
      return;
    }
    final all = await _backedStorage.readAll();
    for (final key in all.keys) {
      if (key.startsWith(keyPrefix)) {
        await _backedStorage.delete(key: key);
      }
    }
  }
}
