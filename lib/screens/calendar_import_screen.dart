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

  Future<void> _importFromGoogle() async {
    setState(() => _isLoading = true);
    try {
      final events = await CalendarSyncService.importGoogleCalendar();
      for (final event in events) {
        await ref.read(eventListProvider.notifier).addEvent(event);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Googleカレンダーからインポートしました')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('エラーが発生しました: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _importFromICS() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['ics'],
      );

      if (result != null) {
        setState(() => _isLoading = true);
        final fileContent = String.fromCharCodes(result.files.first.bytes!);
        final events = await CalendarSyncService.importICSFile(fileContent);
        
        for (final event in events) {
          await ref.read(eventListProvider.notifier).addEvent(event);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ICSファイルからインポートしました')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('エラーが発生しました: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('カレンダーのインポート'),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _importFromGoogle,
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('Googleカレンダーからインポート'),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _importFromICS,
                  icon: const Icon(Icons.file_upload),
                  label: const Text('ICSファイルからインポート'),
                ),
              ],
            ),
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
