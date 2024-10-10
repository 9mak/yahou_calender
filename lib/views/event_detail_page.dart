// lib/views/event_detail_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yahou_calender/models/event.dart';
import 'package:yahou_calender/services/event_service.dart';
import 'package:yahou_calender/widgets/event_form.dart';

class EventDetailPage extends StatelessWidget {
  final Event? event;
  final DateTime selectedDate;

  const EventDetailPage({
    super.key,  // ここを変更
    this.event,
    required this.selectedDate,
  });

  @override
  Widget build(BuildContext context) {
    final eventService = Provider.of<EventService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(event == null ? 'イベントの追加' : 'イベントの編集'),
        actions: [
          if (event != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('イベントの削除'),
                    content: const Text('このイベントを削除してもよろしいですか？'),
                    actions: [
                      TextButton(
                        child: const Text('キャンセル'),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      TextButton(
                        child: const Text('削除'),
                        onPressed: () {
                          eventService.deleteEvent(event!);
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: EventForm(
        event: event,
        selectedDate: selectedDate,
        onSave: (Event newEvent) {
          if (event == null) {
            eventService.addEvent(newEvent);
          } else {
            eventService.updateEvent(newEvent);
          }
          Navigator.of(context).pop();
        },
      ),
    );
  }
}