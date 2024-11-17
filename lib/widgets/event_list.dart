import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/event_provider.dart';
import '../models/event.dart';
import 'package:intl/intl.dart';

class EventList extends ConsumerWidget {
  const EventList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final events = ref.watch(eventListProvider).where((event) {
      return ref.read(eventListProvider.notifier).getEventsForDay(selectedDate).contains(event);
    }).toList();

    if (events.isEmpty) {
      return const Center(
        child: Text('予定はありません'),
      );
    }

    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return EventCard(event: event);
      },
    );
  }
}

class EventCard extends StatelessWidget {
  final Event event;

  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat.Hm();
    
    return Card(
      child: ListTile(
        leading: Container(
          width: 4,
          height: 50,
          color: Colors.blue,
        ),
        title: Text(
          event.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          event.isAllDay 
              ? '終日'
              : '${timeFormat.format(event.startTime)} - ${timeFormat.format(event.endTime)}',
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // TODO: イベント詳細画面へ遷移
        },
      ),
    );
  }
}
