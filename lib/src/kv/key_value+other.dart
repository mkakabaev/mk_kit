typedef KVStorageValueMapper<R> = R? Function(dynamic);

class KeyValueStorageException implements Exception {
    final String message;

    KeyValueStorageException(this.message);

    @override
    String toString() => message;
}
