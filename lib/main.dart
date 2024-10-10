import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yahou_calender/services/event_service.dart';
import 'package:yahou_calender/views/calendar_page.dart';

void main() {
  runApp(const MyApp());  // ここを修正
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});  // ここを修正

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => EventService(),
      child: MaterialApp(
        title: 'Yahoo!カレンダークローン',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const CalendarPage(),  // ここを修正
      ),
    );
  }
}