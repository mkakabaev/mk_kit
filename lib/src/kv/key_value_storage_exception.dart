typedef KVStorageValueMapper<R> = R? Function(Object? value);

class const KeyValueStorageException(final String message) implements Exception {
  @override
  String toString() => message;
}
