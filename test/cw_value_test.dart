import 'package:flutter_test/flutter_test.dart';
import 'package:mk_kit/mk_kit.dart';

void main() {
  test(
    'CWValue',
    () {
      expect(CWValue.resolve(null, 10), 10);
      expect(CWValue.resolve(const CWValue(20), 10), 20);
      expect(CWValue.resolve(const CWValue(20), null as int?), 20);
      expect(CWValue.resolve(const CWValue(null as int?), 100), null);

      // ignore: avoid-misused-test-matchers
      expect(CWValue.diffOnly(10, 10), null);
      expect(CWValue.diffOnly(null as int?, 10), const CWValue(10));
      expect(CWValue.diffOnly(10, null as int?), const CWValue<int>(null));
      expect(CWValue.diffOnly(10, 20), const CWValue(20));
      expect(CWValue.diffOnly(20, 10), const CWValue(10));
      expect(CWValue.diffOnly(100, null as int?), const CWValue<int>(null));

      return true;
    },
  );
}
