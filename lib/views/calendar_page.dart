import 'package:flutter/material.dart';
import 'package:yahou_calender/widgets/calendar_widget.dart';
import 'package:yahou_calender/widgets/event_list.dart';
import 'package:yahou_calender/views/event_detail_page.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});  // ここを修正

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yahoo!カレンダークローン'),
      ),
      body: Column(
        children: [
          CalendarWidget(
            selectedDate: _selectedDate,
            onDateSelected: (date) {
              setState(() {
                _selectedDate = date;
              });
            },
          ),
          Expanded(
            child: EventList(
              selectedDate: _selectedDate,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventDetailPage(
                event: null,
                selectedDate: _selectedDate,
              ),
            ),
          );
        },
      ),
    );
  }
}