import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/calendar_view.dart';
import '../widgets/event_list.dart';
import '../providers/event_provider.dart';
import 'calendar_import_screen.dart';
import 'settings_screen.dart';
import 'event_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('カレンダー'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'import':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CalendarImportScreen(),
                    ),
                  );
                  break;
                case 'settings':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                  break;
              }
            },
            itemBuilder: (BuildContext context) => const <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'import',
                child: Text('カレンダーのインポート'),
              ),
              PopupMenuItem<String>(
                value: 'settings',
                child: Text('設定'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          const CalendarView(),
          Expanded(
            child: EventList(
              events: ref.watch(selectedDayEventsProvider),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const EventScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
