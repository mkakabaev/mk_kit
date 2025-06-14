extension type const MKDate._(int _value) implements Object {
  MKDate._fromYMD(int year, int month, int day) : _value = _ymd(year, month, day);

  factory MKDate.fromInt(int value) => _checkedDate(value);

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
