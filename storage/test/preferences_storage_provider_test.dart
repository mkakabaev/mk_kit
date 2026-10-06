import 'package:flutter_test/flutter_test.dart';
import 'package:mk_kit_storage/mk_kit_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('clear removes only keys with the provider prefix', () async {
    TestWidgetsFlutterBinding.ensureInitialized();

    const keyPrefix = 'a_prefix.';
    SharedPreferences.setMockInitialValues({'other': 'keep', '${keyPrefix}mine': 'drop'});

    final provider = PreferencesStorageProvider(keyPrefix: keyPrefix);
    await provider.setValueForKey('added', 'x');
    expect(await provider.getValueForKey('added'), 'x');
    expect(await provider.getValueForKey('mine'), 'drop');

    await provider.clear();

    expect(await provider.getValueForKey('added'), isNull);
    expect(await provider.getValueForKey('mine'), isNull);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('other'), 'keep');
  });
}
