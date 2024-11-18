import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../services/calendar_sync_service.dart';
import '../providers/event_provider.dart';

class CalendarImportScreen extends ConsumerStatefulWidget {
  const CalendarImportScreen({super.key});

  @override
  ConsumerState<CalendarImportScreen> createState() => _CalendarImportScreenState();
}

class _CalendarImportScreenState extends ConsumerState<CalendarImportScreen> {
  bool _isLoading = false;
  String? _error;
  final _syncService = CalendarSyncService();

  Future<void> _importEvents() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final events = await _syncService.importFromGoogle();
      for (final event in events) {
        await ref.read(eventListProvider.notifier).addEvent(event);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('インポートが完了しました')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _importIcsFile() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['ics'],
      );

      if (result != null) {
        final events = await _syncService.importFromIcs(result.files.first);
        for (final event in events) {
          await ref.read(eventListProvider.notifier).addEvent(event);
        }

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ファイルのインポートが完了しました')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('カレンダーのインポート'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_error != null)
                    Card(
                      color: Colors.red[100],
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ),
                  ElevatedButton(
                    onPressed: _importEvents,
                    child: const Text('Googleカレンダーからインポート'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _importIcsFile,
                    child: const Text('ICSファイルからインポート'),
                  ),
                ],
              ),
            ),
    );
  }
}
