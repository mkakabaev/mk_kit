import 'key_value_storage_provider.dart';

class MemoryKeyValueStorageProvider implements KeyValueStorageProvider {
  final _data = <String, dynamic>{};

  @override
  Future<void> clear() async => _data.clear();

  @override
  Future getValueForKey(String key) async => _data[key];

  @override
  Future<void> removeValueForKey(String key) async => _data.remove(key);

  @override
  Future<void> setValueForKey(String key, Object? value) async => _data[key] = value;
}
