import 'package:flutter/foundation.dart';
import '../models/event.dart';

class CalendarSyncService {
  Future<List<Event>> importFromGoogle() async {
    if (kIsWeb) {
      // Web用の実装（現段階ではダミーデータを返す）
      return [
        Event(
          title: 'テストイベント',
          startTime: DateTime.now(),
          endTime: DateTime.now().add(const Duration(hours: 1)),
          description: 'Google Calendar からインポートしたテストイベント',
        ),
      ];
    }
    throw UnimplementedError('このプラットフォームではGoogle Calendar同期がサポートされていません');
  }

  Future<List<Event>> importFromIcs(dynamic file) async {
    // ICSファイルのパース処理（現段階ではダミーデータを返す）
    return [
      Event(
        title: 'ICSテストイベント',
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(hours: 1)),
        description: 'ICSファイルからインポートしたテストイベント',
      ),
    ];
  }
}
