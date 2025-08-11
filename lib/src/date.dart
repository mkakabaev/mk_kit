///
/// [MKDate] is a compact, immutable value type representing a calendar date (year, month, day) without any time or timezone information.
///
/// It is implemented as an extension type over a single integer in the format `yyyymmdd` (e.g., 20240601 for June 1, 2024),
/// providing efficient storage, comparison, and serialization.
///
/// # Features
/// - **Type-safe**: Only valid dates can be constructed (invalid dates throw).
/// - **Immutable**: All instances are deeply immutable.
/// - **Efficient**: Backed by a single integer for fast equality, hashing, and storage.
/// - **No Time/Timezone**: Represents only the date part, not time-of-day or timezone.
/// - **Conversions**: Easily convert to/from [DateTime], and extract year/month/day components.
/// - **Date Arithmetic**: Supports adding months, getting first/last day of month, etc.
///
/// # Example
/// ```dart
/// final date = MKDate.fromYMD(2024, 6, 1);
/// print(date.year); // 2024
/// print(date.month); // 6
/// print(date.day); // 1
/// print(date.toUtcDateTime()); // 2024-06-01 00:00:00.000Z
/// ```
///
/// # Use Cases
/// - Value objects for business logic (e.g., birthdays, due dates, etc.)
/// - Keys in maps or sets
/// - Serialization to/from database or network
///
extension type const MKDate._(int _value) implements Object {
  // 'Unchecked' constructor for internal use only
  MKDate._fromYMD(int year, int month, int day) : _value = _ymd(year, month, day);

  const MKDate.fromIntUnchecked(int ymd) : _value = ymd;

  factory MKDate.fromYMD(int year, int month, int day) => _checkedDate(_ymd(year, month, day));

  factory MKDate.fromInt(int ymd) => _checkedDate(ymd);

  factory MKDate.fromDateTime(DateTime dateTime) => MKDate._fromYMD(dateTime.year, dateTime.month, dateTime.day);

  factory MKDate.today() => MKDate.fromDateTime(DateTime.now());

  int get yearMonth => _value ~/ 100;

  int get year => _value ~/ 10000;

  int get month => (_value % 10000) ~/ 100;

  int get day => _value % 100;

  DateTime toUtcDateTime() => DateTime.utc(year, month, day);

  DateTime toLocalDateTime() => DateTime(year, month, day);

  MKDate firstOfMonth() => MKDate._fromYMD(year, month, 1);

  MKDate lastOfMonth() {
    final year = this.year;
    final month = this.month;
    return MKDate._fromYMD(year, month, _daysInMonth(year, month));
  }

  int get daysInMonth => _daysInMonth(year, month);

  MKDate addedMonths(int monthCount) {
    if (monthCount == 0) {
      return this;
    }

    var newMonth = month + monthCount;
    var newYear = year;

    while (newMonth > 12) {
      newMonth -= 12;
      newYear += 1;
    }
    while (newMonth < 1) {
      newMonth += 12;
      newYear -= 1;
    }

    final daysInMonth = _daysInMonth(newYear, newMonth);
    final newDay = day > daysInMonth ? daysInMonth : day;

    return MKDate._fromYMD(newYear, newMonth, newDay);
  }

  MKDate addedDays(int days) {
    if (days == 0) {
      return this;
    }

    var finalDay = day + days;
    var month = this.month;
    var year = this.year;

    if (days > 0) {
      while (true) {
        final daysInMonth = _daysInMonth(year, month);
        if (finalDay <= daysInMonth) {
          break;
        }
        finalDay -= daysInMonth;
        if (month == 12) {
          month = 1;
          year += 1;
        } else {
          month += 1;
        }
      }
    } else {
      while (true) {
        if (finalDay > 0) {
          break;
        }
        if (month == 1) {
          month = 12;
          year -= 1;
        } else {
          month -= 1;
        }
        finalDay += _daysInMonth(year, month);
      }
    }

    return MKDate._fromYMD(year, month, finalDay);
  }

  int difference(MKDate other) {
    // small optimization
    if (yearMonth == other.yearMonth) {
      return day - other.day;
    }
    return toUtcDateTime().difference(other.toUtcDateTime()).inDays;
  }

  int differenceInMonths(MKDate other) {
    return (year - other.year) * 12 + (month - other.month);
  }

  int compareTo(MKDate other) => _value.compareTo(other._value);

  bool isAfter(MKDate other) => _value > other._value;

  bool isBefore(MKDate other) => _value < other._value;

  bool isSameDay(MKDate other) => _value == other._value;

  bool operator <=(MKDate other) => _value <= other._value;

  bool operator <(MKDate other) => _value < other._value;

  bool operator >=(MKDate other) => _value >= other._value;

  bool operator >(MKDate other) => _value > other._value;
}

// ------------------------------------------------------------------------------------------------

@pragma("vm:prefer-inline")
int _ymd(int year, int month, int day) => year * 10000 + month * 100 + day;

int _daysInMonth(int year, int month) {
  assert(month >= 1 && month <= 12, 'assertion_20230603_504967');
  const days = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
  if (month == 2) {
    return year % 4 == 0 ? 29 : 28;
  }
  // ignore: avoid-unsafe-collection-methods
  return days[month - 1];
}

MKDate _checkedDate(int value) {
  final result = MKDate._(value);
  final year = result.year;
  if (year >= 1900 && year <= 2100) {
    final month = result.month;
    if (month >= 1 && month <= 12) {
      final day = result.day;
      if (day >= 1 && day <= _daysInMonth(year, month)) {
        return result;
      }
    }
  }
  throw FormatException('Invalid date value: $value');
}

// ------------------------------------------------------------------------------------------------

typedef MKDateRange = ({MKDate start, MKDate end});

extension MKDateRangeExt on MKDateRange {
  bool contains(MKDate date) => start <= date && date <= end;

  bool intersects(MKDateRange other) => start <= other.end && end >= other.start;

  bool get isSingleDay => start == end;

  int get length => end.difference(start) + 1;
}
