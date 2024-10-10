// lib/models/recurrence_rule.dart

enum RecurrenceFrequency { daily, weekly, monthly, yearly }

class RecurrenceRule {
  final RecurrenceFrequency frequency;
  final int interval;
  final DateTime? until;
  final int? count;
  final List<int>? byWeekday;
  final List<int>? byMonthDay;
  final List<int>? byMonth;

  RecurrenceRule({
    required this.frequency,
    this.interval = 1,
    this.until,
    this.count,
    this.byWeekday,
    this.byMonthDay,
    this.byMonth,
  });

  String toReadableString() {
    String result = '';
    switch (frequency) {
      case RecurrenceFrequency.daily:
        result = '毎日';
        break;
      case RecurrenceFrequency.weekly:
        result = '毎週';
        break;
      case RecurrenceFrequency.monthly:
        result = '毎月';
        break;
      case RecurrenceFrequency.yearly:
        result = '毎年';
        break;
    }

    if (interval > 1) {
      result += ' $interval回ごと';
    }

    if (byWeekday != null && byWeekday!.isNotEmpty) {
      result += ' (${_weekdaysToString(byWeekday!)})';
    }

    if (byMonthDay != null && byMonthDay!.isNotEmpty) {
      result += ' (${byMonthDay!.join(', ')}日)';
    }

    if (byMonth != null && byMonth!.isNotEmpty) {
      result += ' (${_monthsToString(byMonth!)})';
    }

    if (until != null) {
      result += ' ${until!.year}年${until!.month}月${until!.day}日まで';
    } else if (count != null) {
      result += ' $count回';
    }

    return result;
  }

  List<DateTime> getOccurrences(DateTime start, DateTime end) {
    List<DateTime> occurrences = [];
    DateTime current = start;

    while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
      if (_isValidOccurrence(current)) {
        occurrences.add(current);
      }

      switch (frequency) {
        case RecurrenceFrequency.daily:
          current = current.add(Duration(days: interval));
          break;
        case RecurrenceFrequency.weekly:
          current = current.add(Duration(days: 7 * interval));
          break;
        case RecurrenceFrequency.monthly:
          current = DateTime(current.year, current.month + interval, current.day);
          break;
        case RecurrenceFrequency.yearly:
          current = DateTime(current.year + interval, current.month, current.day);
          break;
      }

      if (until != null && current.isAfter(until!)) break;
      if (count != null && occurrences.length >= count!) break;
    }

    return occurrences;
  }

  bool _isValidOccurrence(DateTime date) {
    if (byWeekday != null && !byWeekday!.contains(date.weekday)) return false;
    if (byMonthDay != null && !byMonthDay!.contains(date.day)) return false;
    if (byMonth != null && !byMonth!.contains(date.month)) return false;
    return true;
  }

  String _weekdaysToString(List<int> weekdays) {
    const weekdayNames = ['月', '火', '水', '木', '金', '土', '日'];
    return weekdays.map((day) => weekdayNames[day - 1]).join(', ');
  }

  String _monthsToString(List<int> months) {
    return months.map((month) => '$month月').join(', ');
  }
}

Map<String, dynamic> toMap() {
  return {
    'frequency': frequency.index,
    'interval': interval,
    'until': until?.toIso8601String(),
    'count': count,
    'byWeekday': byWeekday,
    'byMonthDay': byMonthDay,
    'byMonth': byMonth,
  };
}

static RecurrenceRule fromMap(Map<String, dynamic> map) {
  return RecurrenceRule(
    frequency: RecurrenceFrequency.values[map['frequency']],
    interval: map['interval'],
    until: map['until'] != null ? DateTime.parse(map['until']) : null,
    count: map['count'],
    byWeekday: List<int>.from(map['byWeekday'] ?? []),
    byMonthDay: List<int>.from(map['byMonthDay'] ?? []),
    byMonth: List<int>.from(map['byMonth'] ?? []),
  );
}