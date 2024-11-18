enum RecurrenceType {
  none,
  daily,
  weekly,
  monthly,
  yearly,
}

class Recurrence {
  final RecurrenceType type;
  final int interval;
  final DateTime? until;
  final List<int>? weekDays;
  final List<int>? monthDays;

  const Recurrence({
    this.type = RecurrenceType.none,
    this.interval = 1,
    this.until,
    this.weekDays,
    this.monthDays,
  });
}
