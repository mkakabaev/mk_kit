abstract interface class KeyValueStorageProvider {
  Future getValueForKey(String key);
  Future<void> removeValueForKey(String key);
  Future<void> setValueForKey(String key, Object value);
  Future<void> clear();
}
