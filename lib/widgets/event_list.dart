import 'package:flutter/material.dart';
import '../models/event.dart';

class EventList extends StatelessWidget {
  final List<Event> events;
  
  const EventList({super.key, this.events = const []});

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return const Center(
        child: Text('予定はありません'),
      );
    }

    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: ListTile(
            leading: Icon(
              event.isAllDay ? Icons.calendar_today : Icons.access_time,
              color: Colors.blue,
            ),
            title: Text(event.title),
            subtitle: event.description != null ? Text(event.description!) : null,
          ),
        );
      },
    );
  }
}
