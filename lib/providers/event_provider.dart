import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/event.dart';
import '../utils/database_helper.dart';

final eventListProvider = StateNotifierProvider<EventNotifier, List<Event>>((ref) {
  return EventNotifier();
});

final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

final selectedDayEventsProvider = Provider<List<Event>>((ref) {
  final selectedDate = ref.watch(selectedDateProvider);
  return ref.watch(eventListProvider.notifier).getEventsForDay(selectedDate);
});

class EventNotifier extends StateNotifier<List<Event>> {
  final _db = DatabaseHelper.instance;
  final _uuid = const Uuid();

  EventNotifier() : super([]) {
    loadEvents();
  }

  Future<void> loadEvents() async {
    try {
      final events = await _db.getAllEvents();
      state = events;
    } catch (e) {
      state = [];
    }
  }

  Future<void> addEvent(Event event) async {
    final newEvent = Event(
      id: _uuid.v4(),
      title: event.title,
      description: event.description,
      startTime: event.startTime,
      endTime: event.endTime,
      isAllDay: event.isAllDay,
      location: event.location,
    );

    await _db.saveEvent(newEvent);
    state = [...state, newEvent];
  }

  Future<void> updateEvent(Event event) async {
    await _db.updateEvent(event);
    state = state.map((e) => e.id == event.id ? event : e).toList();
  }

  Future<void> deleteEvent(String id) async {
    await _db.deleteEvent(id);
    state = state.where((e) => e.id != id).toList();
  }

  List<Event> getEventsForDay(DateTime day) {
    return state.where((event) {
      final start = DateTime(event.startTime.year, event.startTime.month, event.startTime.day);
      final end = DateTime(event.endTime.year, event.endTime.month, event.endTime.day);
      final target = DateTime(day.year, day.month, day.day);
      
      return target.isAtSameMomentAs(start) ||
             target.isAtSameMomentAs(end) ||
             (target.isAfter(start) && target.isBefore(end));
    }).toList();
  }
}
