import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yahou_calender/services/event_service.dart';
import 'package:yahou_calender/views/event_detail_page.dart';

class EventList extends StatelessWidget {
  final DateTime selectedDate;

  const EventList({
    super.key,  // ここを変更
    required this.selectedDate,
  });

  @override
  Widget build(BuildContext context) {
    final eventService = Provider.of<EventService>(context);
    final events = eventService.getEventsForDay(selectedDate);

    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return ListTile(
          title: Text(event.title),
          subtitle: Text('${_formatTime(event.startTime)} - ${_formatTime(event.endTime)}'),
          leading: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: event.color,
              shape: BoxShape.circle,
            ),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EventDetailPage(
                  event: event,
                  selectedDate: selectedDate,
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}