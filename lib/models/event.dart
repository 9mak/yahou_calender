// lib/models/event.dart

import 'package:flutter/material.dart';
import 'package:yahou_calender/models/recurrence_rule.dart';

class Event {
  final String id;
  String title;
  String description;
  DateTime startTime;
  DateTime endTime;
  Color color;
  RecurrenceRule? recurrenceRule;
  DateTime? reminderTime;

  Event({
    required this.id,
    required this.title,
    this.description = '',
    required this.startTime,
    required this.endTime,
    this.color = Colors.blue,
    this.recurrenceRule,
    this.reminderTime,
  });

  bool get isMultiDay => !isSameDay(startTime, endTime);

  List<Event> splitMultiDayEvent() {
    if (!isMultiDay) return [this];

    List<Event> splitEvents = [];
    DateTime currentStart = startTime;
    int dayCount = 0;

    while (currentStart.isBefore(endTime)) {
      DateTime currentEnd = DateTime(currentStart.year, currentStart.month, currentStart.day, 23, 59, 59);
      if (currentEnd.isAfter(endTime)) currentEnd = endTime;

      splitEvents.add(Event(
        id: '$id-$dayCount',
        title: title,
        description: description,
        startTime: currentStart,
        endTime: currentEnd,
        color: color,
        recurrenceRule: dayCount == 0 ? recurrenceRule : null,
        reminderTime: dayCount == 0 ? reminderTime : null,
      ));

      currentStart = DateTime(currentStart.year, currentStart.month, currentStart.day + 1);
      dayCount++;
    }

    return splitEvents;
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'color': color.value,
      'recurrenceRule': recurrenceRule?.toMap(),
      'reminderTime': reminderTime?.toIso8601String(),
    };
  }

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      startTime: DateTime.parse(map['startTime']),
      endTime: DateTime.parse(map['endTime']),
      color: Color(map['color']),
      recurrenceRule: map['recurrenceRule'] != null
          ? RecurrenceRule.fromMap(map['recurrenceRule'])
          : null,
      reminderTime: map['reminderTime'] != null
          ? DateTime.parse(map['reminderTime'])
          : null,
    );
  }
}