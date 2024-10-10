// lib/services/event_service.dart

import 'package:flutter/foundation.dart';
import 'package:yahou_calender/models/event.dart';

class EventService extends ChangeNotifier {
  final List<Event> _events = [];

  List<Event> get events => _events;

  void addEvent(Event event) {
    _events.addAll(event.splitMultiDayEvent());
    notifyListeners();
  }

  void updateEvent(Event updatedEvent) {
    _events.removeWhere((e) => e.id.startsWith(updatedEvent.id));
    _events.addAll(updatedEvent.splitMultiDayEvent());
    notifyListeners();
  }

  void deleteEvent(Event event) {
    _events.removeWhere((e) => e.id.startsWith(event.id));
    notifyListeners();
  }

  List<Event> getEventsForDay(DateTime day) {
    return _events.where((event) {
      if (event.isMultiDay) {
        return day.isAfter(event.startTime.subtract(const Duration(days: 1))) &&
               day.isBefore(event.endTime.add(const Duration(days: 1)));
      }
      if (event.recurrenceRule != null) {
        return event.recurrenceRule!.getOccurrences(
          event.startTime,
          day.add(const Duration(days: 1)),
        ).any((occurrence) => isSameDay(occurrence, day));
      }
      return isSameDay(event.startTime, day);
    }).toList();
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }
}