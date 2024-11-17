import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/event.dart';
import '../utils/database_helper.dart';

final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

final eventListProvider = StateNotifierProvider<EventNotifier, List<Event>>((ref) {
  return EventNotifier();
});

class EventNotifier extends StateNotifier<List<Event>> {
  EventNotifier() : super([]) {
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final events = await DatabaseHelper.getAllEvents();
    state = events;
  }

  Future<void> addEvent(Event event) async {
    await DatabaseHelper.insert(event);
    final events = await DatabaseHelper.getAllEvents();
    state = events;
  }

  Future<void> updateEvent(Event updatedEvent) async {
    await DatabaseHelper.update(updatedEvent);
    final events = await DatabaseHelper.getAllEvents();
    state = events;
  }

  Future<void> deleteEvent(String id) async {
    await DatabaseHelper.delete(id);
    final events = await DatabaseHelper.getAllEvents();
    state = events;
  }

  List<Event> getEventsForDay(DateTime day) {
    return state.where((event) {
      final startDate = DateTime(event.startTime.year, event.startTime.month, event.startTime.day);
      final endDate = DateTime(event.endTime.year, event.endTime.month, event.endTime.day);
      final targetDate = DateTime(day.year, day.month, day.day);
      
      return (targetDate.isAtSameMomentAs(startDate) || targetDate.isAfter(startDate)) &&
             (targetDate.isAtSameMomentAs(endDate) || targetDate.isBefore(endDate));
    }).toList();
  }
}

final eventColorProvider = StateProvider<List<MaterialColor>>((ref) {
  return [
    Colors.blue,
    Colors.green,
    Colors.red,
    Colors.orange,
    Colors.purple,
    Colors.teal,
  ];
});
