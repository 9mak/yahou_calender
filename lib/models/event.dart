import 'package:uuid/uuid.dart';

enum RecurrenceType {
  none,
  daily,
  weekly,
  monthly,
  yearly
}

class Event {
  final String id;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final String? description;
  final bool isAllDay;
  final String? location;
  final int colorIndex;
  final RecurrenceType recurrenceType;
  final DateTime? recurrenceEndDate;
  final List<int>? weeklyDays; // 週次繰り返しの場合の曜日（1-7）
  final int? monthlyDay; // 月次繰り返しの場合の日付（1-31）

  Event({
    String? id,
    required this.title,
    required this.startTime,
    required this.endTime,
    this.description,
    this.isAllDay = false,
    this.location,
    this.colorIndex = 0,
    this.recurrenceType = RecurrenceType.none,
    this.recurrenceEndDate,
    this.weeklyDays,
    this.monthlyDay,
  }) : id = id ?? const Uuid().v4();

  Event copyWith({
    String? title,
    DateTime? startTime,
    DateTime? endTime,
    String? description,
    bool? isAllDay,
    String? location,
    int? colorIndex,
    RecurrenceType? recurrenceType,
    DateTime? recurrenceEndDate,
    List<int>? weeklyDays,
    int? monthlyDay,
  }) {
    return Event(
      id: id,
      title: title ?? this.title,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      description: description ?? this.description,
      isAllDay: isAllDay ?? this.isAllDay,
      location: location ?? this.location,
      colorIndex: colorIndex ?? this.colorIndex,
      recurrenceType: recurrenceType ?? this.recurrenceType,
      recurrenceEndDate: recurrenceEndDate ?? this.recurrenceEndDate,
      weeklyDays: weeklyDays ?? this.weeklyDays,
      monthlyDay: monthlyDay ?? this.monthlyDay,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'startTime': startTime.toIso8601String(),
    'endTime': endTime.toIso8601String(),
    'description': description,
    'isAllDay': isAllDay ? 1 : 0,
    'location': location,
    'colorIndex': colorIndex,
    'recurrenceType': recurrenceType.index,
    'recurrenceEndDate': recurrenceEndDate?.toIso8601String(),
    'weeklyDays': weeklyDays?.join(","),
    'monthlyDay': monthlyDay,
  };

  factory Event.fromJson(Map<String, dynamic> json) => Event(
    id: json['id'],
    title: json['title'],
    startTime: DateTime.parse(json['startTime']),
    endTime: DateTime.parse(json['endTime']),
    description: json['description'],
    isAllDay: json['isAllDay'] == 1,
    location: json['location'],
    colorIndex: json['colorIndex'],
    recurrenceType: RecurrenceType.values[json['recurrenceType'] ?? 0],
    recurrenceEndDate: json['recurrenceEndDate'] != null 
        ? DateTime.parse(json['recurrenceEndDate'])
        : null,
    weeklyDays: json['weeklyDays'] != null 
        ? json['weeklyDays'].split(",").map<int>((e) => int.parse(e)).toList()
        : null,
    monthlyDay: json['monthlyDay'],
  );

  List<DateTime> generateRecurrenceInstances(DateTime until) {
    if (recurrenceType == RecurrenceType.none) {
      return [startTime];
    }

    final List<DateTime> instances = [];
    DateTime current = startTime;
    final endDate = recurrenceEndDate ?? until;

    while (current.isBefore(endDate)) {
      instances.add(current);

      switch (recurrenceType) {
        case RecurrenceType.daily:
          current = current.add(const Duration(days: 1));
          break;
        case RecurrenceType.weekly:
          if (weeklyDays != null && weeklyDays!.isNotEmpty) {
            // 次の指定曜日を見つける
            var nextDay = current;
            do {
              nextDay = nextDay.add(const Duration(days: 1));
            } while (!weeklyDays!.contains(nextDay.weekday));
            current = nextDay;
          } else {
            current = current.add(const Duration(days: 7));
          }
          break;
        case RecurrenceType.monthly:
          if (monthlyDay != null) {
            // 指定された日付の次の月
            current = DateTime(
              current.year,
              current.month + 1,
              monthlyDay!,
              current.hour,
              current.minute,
            );
          } else {
            // 同じ日の次の月
            current = DateTime(
              current.year,
              current.month + 1,
              current.day,
              current.hour,
              current.minute,
            );
          }
          break;
        case RecurrenceType.yearly:
          current = DateTime(
            current.year + 1,
            current.month,
            current.day,
            current.hour,
            current.minute,
          );
          break;
        case RecurrenceType.none:
          break;
      }
    }

    return instances;
  }
}
