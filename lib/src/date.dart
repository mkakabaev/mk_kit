// ignore_for_file: prefer-static-class

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
  factory MKDate.fromInt(int ymd) {
    _validateYMD(ymd);
    return ._(ymd);
  }

  factory MKDate.fromYMD(int year, int month, int day) {
    _validateDateComponents(year, month, day);
    return ._(_ymd(year, month, day));
  }

  factory MKDate.fromDateTime(DateTime dateTime) => .fromYMD(dateTime.year, dateTime.month, dateTime.day);

  factory MKDate.today() => .fromDateTime(DateTime.now());

  int get yearMonth => _value ~/ 100;

  int get year => _value ~/ 10000;

  int get month => (_value % 10000) ~/ 100;

  int get day => _value % 100;

  DateTime toUtcDateTime() => DateTime.utc(year, month, day);

  DateTime toLocalDateTime() => DateTime(year, month, day);

  MKDate firstOfMonth() => .fromYMD(year, month, 1);

  MKDate lastOfMonth() {
    final year = this.year;
    final month = this.month;
    return .fromYMD(year, month, _daysInMonth(year, month));
  }

  int get daysInMonth => _daysInMonth(year, month);

  MKDate addedMonths(int monthCount) {
    if (monthCount == 0) {
      return this;
    }

    final zeroBased = (month - 1) + monthCount;
    final monthIndex = zeroBased % 12;
    final newYear = year + (zeroBased - monthIndex) ~/ 12;
    final newMonth = monthIndex + 1;

    final daysInMonth = _daysInMonth(newYear, newMonth);
    final newDay = day > daysInMonth ? daysInMonth : day;

    return .fromYMD(newYear, newMonth, newDay);
  }

  @pragma("vm:prefer-inline")
  MKDate get nextMonth => addedMonths(1);

  @pragma("vm:prefer-inline")
  MKDate get previousMonth => addedMonths(-1);

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

    return .fromYMD(year, month, finalDay);
  }

  @pragma("vm:prefer-inline")
  MKDate get next => addedDays(1);

  @pragma("vm:prefer-inline")
  MKDate get previous => addedDays(-1);

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

@pragma("vm:prefer-inline")
bool _isLeapYear(int year) => year % 4 == 0 && (year % 100 != 0 || year % 400 == 0);

@pragma("vm:prefer-inline")
int _year(int ymd) => ymd ~/ 10000;

@pragma("vm:prefer-inline")
int _month(int ymd) => (ymd % 10000) ~/ 100;

@pragma("vm:prefer-inline")
int _day(int ymd) => ymd % 100;

int _daysInMonth(int year, int month) {
  if (month < 1 || month > 12) {
    throw FormatException('Invalid month: $month');
  }
  const days = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
  if (month == 2 && _isLeapYear(year)) {
    return 29;
  }
  return days[month - 1];
}

void _validateDateComponents(int year, int month, int day) {
  if (year >= 1900 && year <= 2100) {
    if (month >= 1 && month <= 12) {
      if (day >= 1 && day <= _daysInMonth(year, month)) {
        return;
      }
    }
  }
  throw FormatException('Invalid date value: $year-$month-$day');
}

@pragma("vm:prefer-inline")
void _validateYMD(int ymd) {
  _validateDateComponents(_year(ymd), _month(ymd), _day(ymd));
}

// ------------------------------------------------------------------------------------------------

typedef MKDateRange = ({MKDate start, MKDate end});

extension MKDateRangeExt on MKDateRange {
  static MKDateRange fromDate(MKDate date) => (start: date, end: date);

  bool contains(MKDate date) => start <= date && date <= end;

  bool intersects(MKDateRange other) => start <= other.end && end >= other.start;

  MKDateRange? intersection(MKDateRange other) {
    if (start > other.end || end < other.start) {
      return null;
    }
    return (start: start < other.start ? other.start : start, end: end > other.end ? other.end : end);
  }

  Iterable<MKDate> get iterable sync* {
    var temp = start;
    while (temp <= end) {
      yield temp;
      temp = temp.next;
    }
  }

  static MKDateRange? union(MKDateRange? r1, MKDateRange? r2) {
    if (r1 == null) {
      return r2;
    }
    if (r2 == null) {
      return r1;
    }

    return (start: r1.start < r2.start ? r1.start : r2.start, end: r1.end > r2.end ? r1.end : r2.end);
  }

  bool get isSingleDay => start == end;

  int get length => end.difference(start) + 1;
}
