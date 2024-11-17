import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/calendar_view.dart';
import '../widgets/event_list.dart';
import '../providers/event_provider.dart';
import '../models/event.dart';
import 'event_screen.dart';
import 'settings_screen.dart';
import 'calendar_import_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('カレンダー'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CalendarImportScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: EventSearchDelegate(ref),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: const Column(
        children: [
          CalendarView(),
          Expanded(
            child: EventList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
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

class EventSearchDelegate extends SearchDelegate {
  final WidgetRef ref;

  EventSearchDelegate(this.ref);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = "";
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final events = ref.read(eventListProvider);
    final searchResults = events.where((event) {
      return event.title.toLowerCase().contains(query.toLowerCase()) ||
             (event.description?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
             (event.location?.toLowerCase().contains(query.toLowerCase()) ?? false);
    }).toList();

    return ListView.builder(
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final event = searchResults[index];
        return ListTile(
          title: Text(event.title),
          subtitle: Text(event.description ?? ""),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => EventScreen(event: event),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildResults(context);
  }
}
