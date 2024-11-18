import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/event_provider.dart';
import '../screens/settings_screen.dart';

class CalendarView extends ConsumerWidget {
  const CalendarView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final calendarViewType = ref.watch(calendarViewProvider);
    final events = ref.watch(eventListProvider);

    CalendarFormat getCalendarFormat() {
      switch (calendarViewType) {
        case CalendarViewType.month:
          return CalendarFormat.month;
        case CalendarViewType.week:
          return CalendarFormat.week;
        case CalendarViewType.day:
          return CalendarFormat.week; // tableCalendarには日表示がないため、週表示で代用
      }
    }

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: selectedDate,
        calendarFormat: getCalendarFormat(),
        selectedDayPredicate: (day) => isSameDay(selectedDate, day),
        onDaySelected: (selectedDay, focusedDay) {
          ref.read(selectedDateProvider.notifier).state = selectedDay;
        },
        eventLoader: (day) {
          return ref.read(eventListProvider.notifier).getEventsForDay(day);
        },
        calendarStyle: const CalendarStyle(
          todayDecoration: BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: Colors.deepPurple,
            shape: BoxShape.circle,
          ),
          markerDecoration: BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
          ),
        ),
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
        ),
      ),
    );
  }
}
