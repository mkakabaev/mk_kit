import 'package:flutter_test/flutter_test.dart';
import 'package:mk_kit/mk_kit.dart';

void main() {
  group('Date', () {
    test('fromDateTime', () {
      final date = Date.fromDateTime(DateTime(2024, 3, 15));
      expect(date.year, 2024);
      expect(date.month, 3);
      expect(date.day, 15);
    });

    test('today', () {
      final today = DateTime.now();
      final date = Date.today();
      expect(date.year, today.year);
      expect(date.month, today.month);
      expect(date.day, today.day);
      expect(date, Date.fromDateTime(today));
    });

    test('addedMonths', () {
      final date = Date.fromDateTime(DateTime(2024, 3, 15));

      expect(date.addedMonths(1), Date.fromDateTime(DateTime(2024, 4, 15)));
      expect(date.addedMonths(-1), Date.fromDateTime(DateTime(2024, 2, 15)));
      expect(date.addedMonths(12), Date.fromDateTime(DateTime(2025, 3, 15)));
      expect(date.addedMonths(-12), Date.fromDateTime(DateTime(2023, 3, 15)));
      expect(date.addedMonths(13), Date.fromDateTime(DateTime(2025, 4, 15)));
      expect(date.addedMonths(-13), Date.fromDateTime(DateTime(2023, 2, 15)));
      expect(date.addedMonths(100), Date.fromDateTime(DateTime(2032, 7, 15)));
      expect(date.addedMonths(-100), Date.fromDateTime(DateTime(2015, 11, 15)));
      expect(date.addedMonths(921), Date.fromDateTime(DateTime(2100, 12, 15)));
      expect(date.addedMonths(-1490), Date.fromDateTime(DateTime(1900, 1, 15)));

      // Test month end handling
      final endOfMonth = Date.fromDateTime(DateTime(2024, 1, 31));
      expect(endOfMonth.addedMonths(1), Date.fromDateTime(DateTime(2024, 2, 29))); // Leap year
      expect(endOfMonth.addedMonths(13), Date.fromDateTime(DateTime(2025, 2, 28)));
      expect(endOfMonth.addedMonths(49), Date.fromDateTime(DateTime(2028, 2, 29)));
      expect(Date.fromDateTime(DateTime(2024, 3, 31)).addedMonths(-13), Date.fromDateTime(DateTime(2023, 2, 28)));
    });

    test('addedDays', () {
      final date = Date.fromDateTime(DateTime(2024, 3, 15));

      expect(date.addedDays(1), Date.fromDateTime(DateTime(2024, 3, 16)));
      expect(date.addedDays(-1), Date.fromDateTime(DateTime(2024, 3, 14)));
      expect(date.addedDays(30), Date.fromDateTime(DateTime(2024, 4, 14)));
      expect(date.addedDays(-30), Date.fromDateTime(DateTime(2024, 2, 14)));

      expect(date.addedDays(365), Date.fromDateTime(DateTime(2025, 3, 15)));
      expect(date.addedDays(-365), Date.fromDateTime(DateTime(2023, 3, 16))); // 2024 is a leap year
    });

    test('difference', () {
      final date1 = Date.fromDateTime(DateTime(2024, 3, 15));
      final date2 = Date.fromDateTime(DateTime(2024, 3, 20));
      final date3 = Date.fromDateTime(DateTime(2024, 2, 20));

      expect(date2.difference(date1), 5);
      expect(date1.difference(date2), -5);

      expect(date3.difference(date1), -24);
      expect(date1.difference(date3), 24);
    });

    test('differenceInMonths', () {
      final dec23 = Date.fromYMD(2023, 12, 31);
      final mar23 = Date.fromYMD(2023, 3, 15);
      final mar24 = Date.fromYMD(2024, 3, 15);
      final mar25 = Date.fromYMD(2025, 3, 15);
      final may24 = Date.fromYMD(2024, 5, 15);
      final jan24 = Date.fromYMD(2024, 1, 15);
      

      void expectDifferenceInMonths(Date a, Date b, int expected) {
        expect(a.differenceInMonths(b), expected);
        expect(b.differenceInMonths(a), -expected);
      }

      expectDifferenceInMonths(dec23, mar25, -15);
      expectDifferenceInMonths(may24, mar24, 2);
      expectDifferenceInMonths(jan24, mar24, -2);
      expectDifferenceInMonths(mar25, mar24, 12);
      expectDifferenceInMonths(mar23, mar24, -12);
      expectDifferenceInMonths(jan24, mar23, 10);
      expectDifferenceInMonths(mar24, mar24, 0);
      expectDifferenceInMonths(mar24, Date.fromYMD(2024, 3, 2), 0);
    });

    test('comparison', () {
      final date1 = Date.fromDateTime(DateTime(2024, 3, 15));
      final date2 = Date.fromDateTime(DateTime(2024, 3, 20));

      expect(date1 < date2, true);
      expect(date1 <= date2, true);
      expect(date2 > date1, true);
      expect(date2 >= date1, true);
      expect(date1.isBefore(date2), true);
      expect(date2.isAfter(date1), true);
    });

    test('firstOfMonth', () {
      final date = Date.fromDateTime(DateTime(2024, 3, 15));
      expect(date.firstOfMonth(), Date.fromDateTime(DateTime(2024, 3, 1)));
    });

    test('daysInMonth', () {
      expect(Date.fromDateTime(DateTime(2024, 2, 1)).daysInMonth, 29); // Leap year
      expect(Date.fromDateTime(DateTime(2023, 2, 1)).daysInMonth, 28); // Non-leap year
      expect(Date.fromDateTime(DateTime(2000, 2, 1)).daysInMonth, 29); // Divisible by 400
      expect(Date.fromDateTime(DateTime(1900, 2, 1)).daysInMonth, 28); // Century, not divisible by 400
      expect(Date.fromYMD(2100, 2, 1).daysInMonth, 28);
      expect(Date.fromDateTime(DateTime(2024, 4, 1)).daysInMonth, 30);
      expect(Date.fromDateTime(DateTime(2024, 5, 1)).daysInMonth, 31);
    });

    test('addedMonths clamps century non-leap February', () {
      expect(Date.fromYMD(1900, 1, 31).addedMonths(1), Date.fromYMD(1900, 2, 28));
      expect(Date.fromYMD(2000, 1, 31).addedMonths(1), Date.fromYMD(2000, 2, 29));
    });

    test('invalid date', () {
      expect(() => Date.fromInt(20240230), throwsFormatException); // Invalid day
      expect(() => Date.fromInt(20241301), throwsFormatException); // Invalid month
      expect(() => Date.fromInt(18990101), throwsFormatException); // Year too small
      expect(() => Date.fromInt(21010101), throwsFormatException); // Year too large
      expect(() => Date.fromYMD(1900, 2, 29), throwsFormatException);
      expect(() => Date.fromYMD(2100, 2, 29), throwsFormatException);
      expect(Date.fromYMD(2000, 2, 29), Date.fromInt(20000229));
    });
  });

  group('DateRange', () {
    test('contains', () {
      final range = DateRange(Date.fromDateTime(DateTime(2024, 3, 1)), Date.fromDateTime(DateTime(2024, 3, 15)));

      expect(range.contains(Date.fromDateTime(DateTime(2024, 3, 1))), true);
      expect(range.contains(Date.fromDateTime(DateTime(2024, 3, 10))), true);
      expect(range.contains(Date.fromDateTime(DateTime(2024, 3, 15))), true);
      expect(range.contains(Date.fromDateTime(DateTime(2024, 2, 29))), false);
      expect(range.contains(Date.fromDateTime(DateTime(2024, 3, 16))), false);
    });

    test('intersects', () {
      final range1 = DateRange(Date.fromDateTime(DateTime(2024, 3, 1)), Date.fromDateTime(DateTime(2024, 3, 15)));

      final range2 = DateRange(Date.fromDateTime(DateTime(2024, 3, 10)), Date.fromDateTime(DateTime(2024, 3, 20)));

      final range3 = DateRange(Date.fromDateTime(DateTime(2024, 3, 16)), Date.fromDateTime(DateTime(2024, 3, 20)));

      expect(range1.intersects(range2), true);
      expect(range2.intersects(range1), true);
      expect(range1.intersects(range3), false);
      expect(range3.intersects(range1), false);
    });

    test('invalid range', () {
      final start = Date.fromYMD(2024, 3, 15);
      final end = Date.fromYMD(2024, 3, 1);

      expect(() => DateRange(start, end), throwsArgumentError);
      expect(DateRange.fromDate(start), DateRange(start, start));
    });
  });
}
