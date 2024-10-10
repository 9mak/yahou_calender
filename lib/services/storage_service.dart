// lib/services/storage_service.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yahou_calender/models/event.dart';

class StorageService {
  static const String _eventsKey = 'events';

  Future<void> saveEvents(List<Event> events) async {
    final prefs = await SharedPreferences.getInstance();
    final String eventsJson = jsonEncode(
      events.map((e) => e.toMap()).toList(),
    );
    await prefs.setString(_eventsKey, eventsJson);
  }

  Future<List<Event>> loadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final String? eventsJson = prefs.getString(_eventsKey);
    if (eventsJson == null) {
      return [];
    }
    final List<dynamic> eventsList = jsonDecode(eventsJson);
    return eventsList.map((e) => Event.fromMap(e)).toList();
  }

  Future<void> clearEvents() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_eventsKey);
  }
}