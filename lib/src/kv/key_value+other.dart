typedef KVStorageValueMapper<R> = R? Function(Object? value);

class KeyValueStorageException implements Exception {
  final String message;

  const KeyValueStorageException(this.message);

  @override
  String toString() => message;
}
