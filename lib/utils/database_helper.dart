import 'package:flutter/foundation.dart';
import '../models/event.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  
  DatabaseHelper._init();

  Future<List<Event>> getAllEvents() async {
    // テスト用のダミーデータを返す（Web対応）
    return [
      Event(
        id: '1',
        title: 'テストイベント1',
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(hours: 2)),
        description: 'テストの説明1',
        isAllDay: false,
      ),
      Event(
        id: '2',
        title: 'テストイベント2',
        startTime: DateTime.now().add(const Duration(days: 1)),
        endTime: DateTime.now().add(const Duration(days: 1, hours: 1)),
        description: 'テストの説明2',
        isAllDay: true,
      ),
    ];
  }

  Future<void> saveEvent(Event event) async {
    // Webでは実際のデータベース操作は行わない
    debugPrint('Event saved: ');
  }

  Future<void> updateEvent(Event event) async {
    // Webでは実際のデータベース操作は行わない
    debugPrint('Event updated: ');
  }

  Future<void> deleteEvent(String id) async {
    // Webでは実際のデータベース操作は行わない
    debugPrint('Event deleted: ');
  }
}
