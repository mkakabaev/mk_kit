import 'package:flutter_test/flutter_test.dart';
import 'package:mk_kit/mk_kit.dart';

class _FailingStorage implements KeyValueStorageProvider {
  @override
  Future<void> clear() async {}

  @override
  Future<Object?> getValueForKey(String key) async => null;

  @override
  Future<void> removeValueForKey(String key) async {}

  @override
  Future<void> setValueForKey(String key, Object value) async {
    throw StateError('disk');
  }
}

void main() {
  test('setJson round-trips a map', () async {
    final storage = KeyValueStorage(provider: MemoryKeyValueStorageProvider());
    await storage.setJson('user', {'name': 'a'});
    expect(await storage.getJsonMap('user'), {'name': 'a'});

    await storage.setJson('user', null);
    expect(await storage.getJsonMap('user'), isNull);
  });

  test('setJson reports a storage failure once', () async {
    final storage = KeyValueStorage(provider: _FailingStorage());
    await expectLater(
      storage.setJson('user', {'name': 'a'}),
      throwsA(
        isA<KeyValueStorageException>().having(
          (error) => error.toString(),
          'toString',
          allOf(contains('Failed to save'), isNot(contains('Failed to encode'))),
        ),
      ),
    );
  });
}
