abstract interface class KeyValueStorageProvider {
  Future<Object?> getValueForKey(String key);
  Future<void> removeValueForKey(String key);
  Future<void> setValueForKey(String key, Object value);

  /// Removes stored keys. Each implementation documents whether this deletes the whole store or only its own keys.
  Future<void> clear();
}
