import 'package:flutter_test/flutter_test.dart';
import 'package:mk_kit/mk_kit.dart';

void main() {
  group('MKDate', () {
    test('fromDateTime', () {
      final date = MKDate.fromDateTime(DateTime(2024, 3, 15));
      expect(date.year, 2024);
      expect(date.month, 3);
      expect(date.day, 15);
    });

    test('today', () {
      final today = DateTime.now();
      final date = MKDate.today();
      expect(date.year, today.year);
      expect(date.month, today.month);
      expect(date.day, today.day);
      expect(date, today);
    });

    test('addedMonths', () {
      final date = MKDate.fromDateTime(DateTime(2024, 3, 15));

      expect(date.addedMonths(1), MKDate.fromDateTime(DateTime(2024, 4, 15)));
      expect(date.addedMonths(-1), MKDate.fromDateTime(DateTime(2024, 2, 15)));
      expect(date.addedMonths(12), MKDate.fromDateTime(DateTime(2025, 3, 15)));
      expect(date.addedMonths(-12), MKDate.fromDateTime(DateTime(2023, 3, 15)));

      // Test month end handling
      final endOfMonth = MKDate.fromDateTime(DateTime(2024, 1, 31));
      expect(endOfMonth.addedMonths(1), MKDate.fromDateTime(DateTime(2024, 2, 29))); // Leap year
    });

    test('addedDays', () {
      final date = MKDate.fromDateTime(DateTime(2024, 3, 15));

      expect(date.addedDays(1), MKDate.fromDateTime(DateTime(2024, 3, 16)));
      expect(date.addedDays(-1), MKDate.fromDateTime(DateTime(2024, 3, 14)));
      expect(date.addedDays(30), MKDate.fromDateTime(DateTime(2024, 4, 14)));
      expect(date.addedDays(-30), MKDate.fromDateTime(DateTime(2024, 2, 14)));

      expect(date.addedDays(365), MKDate.fromDateTime(DateTime(2025, 3, 15)));
      expect(date.addedDays(-365), MKDate.fromDateTime(DateTime(2023, 3, 16))); // 2024 is a leap year
    });

    test('difference', () {
      final date1 = MKDate.fromDateTime(DateTime(2024, 3, 15));
      final date2 = MKDate.fromDateTime(DateTime(2024, 3, 20));
      final date3 = MKDate.fromDateTime(DateTime(2024, 2, 20));

      expect(date2.difference(date1), 5);
      expect(date1.difference(date2), -5);
      
      expect(date3.difference(date1), -24);
      expect(date1.difference(date3), 24);
    });

    test('comparison', () {
      final date1 = MKDate.fromDateTime(DateTime(2024, 3, 15));
      final date2 = MKDate.fromDateTime(DateTime(2024, 3, 20));

      expect(date1 < date2, true);
      expect(date1 <= date2, true);
      expect(date2 > date1, true);
      expect(date2 >= date1, true);
      expect(date1.isBefore(date2), true);
      expect(date2.isAfter(date1), true);
    });

    test('firstOfMonth', () {
      final date = MKDate.fromDateTime(DateTime(2024, 3, 15));
      expect(date.firstOfMonth(), MKDate.fromDateTime(DateTime(2024, 3, 1)));
    });

    test('daysInMonth', () {
      expect(MKDate.fromDateTime(DateTime(2024, 2, 1)).daysInMonth, 29); // Leap year
      expect(MKDate.fromDateTime(DateTime(2023, 2, 1)).daysInMonth, 28); // Non-leap year
      expect(MKDate.fromDateTime(DateTime(2024, 4, 1)).daysInMonth, 30);
      expect(MKDate.fromDateTime(DateTime(2024, 5, 1)).daysInMonth, 31);
    });

    test('invalid date', () {
      expect(() => MKDate.fromInt(20240230), throwsFormatException); // Invalid day
      expect(() => MKDate.fromInt(20241301), throwsFormatException); // Invalid month
      expect(() => MKDate.fromInt(18990101), throwsFormatException); // Year too small
      expect(() => MKDate.fromInt(21010101), throwsFormatException); // Year too large
    });
  });

  group('MKDateRange', () {
    test('contains', () {
      final range = (start: MKDate.fromDateTime(DateTime(2024, 3, 1)), end: MKDate.fromDateTime(DateTime(2024, 3, 15)));

      expect(range.contains(MKDate.fromDateTime(DateTime(2024, 3, 1))), true);
      expect(range.contains(MKDate.fromDateTime(DateTime(2024, 3, 10))), true);
      expect(range.contains(MKDate.fromDateTime(DateTime(2024, 3, 15))), true);
      expect(range.contains(MKDate.fromDateTime(DateTime(2024, 2, 29))), false);
      expect(range.contains(MKDate.fromDateTime(DateTime(2024, 3, 16))), false);
    });

    test('intersects', () {
      final range1 = (
        start: MKDate.fromDateTime(DateTime(2024, 3, 1)),
        end: MKDate.fromDateTime(DateTime(2024, 3, 15)),
      );

      final range2 = (
        start: MKDate.fromDateTime(DateTime(2024, 3, 10)),
        end: MKDate.fromDateTime(DateTime(2024, 3, 20)),
      );

      final range3 = (
        start: MKDate.fromDateTime(DateTime(2024, 3, 16)),
        end: MKDate.fromDateTime(DateTime(2024, 3, 20)),
      );

      expect(range1.intersects(range2), true);
      expect(range2.intersects(range1), true);
      expect(range1.intersects(range3), false);
      expect(range3.intersects(range1), false);
    });
  });
}
