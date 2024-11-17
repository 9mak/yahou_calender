import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/event_provider.dart';
import '../models/event.dart';

class CalendarView extends ConsumerStatefulWidget {
  const CalendarView({super.key});

  @override
  ConsumerState<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends ConsumerState<CalendarView> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
      ref.read(selectedDateProvider.notifier).state = selectedDay;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: TableCalendar<Event>(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        calendarFormat: _calendarFormat,
        onDaySelected: _onDaySelected,
        onFormatChanged: (format) {
          if (_calendarFormat != format) {
            setState(() {
              _calendarFormat = format;
            });
          }
        },
        eventLoader: (day) {
          return ref.read(eventListProvider.notifier).getEventsForDay(day);
        },
        calendarStyle: const CalendarStyle(
          outsideDaysVisible: false,
          markersMaxCount: 4,
          markerSize: 6,
          markerDecoration: BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.all(Radius.circular(4)),
          ),
          todayDecoration: BoxDecoration(
            color: Colors.blueAccent,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.all(Radius.circular(4)),
          ),
          markersAlignment: Alignment.bottomCenter,
          markerMargin: EdgeInsets.only(top: 4),
        ),
        headerStyle: HeaderStyle(
          titleCentered: true,
          formatButtonVisible: true,
          formatButtonShowsNext: false,
          formatButtonDecoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(12.0),
          ),
          formatButtonTextStyle: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
