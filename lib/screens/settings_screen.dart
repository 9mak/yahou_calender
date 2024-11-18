import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);
final notificationEnabledProvider = StateProvider<bool>((ref) => true);
final calendarViewProvider = StateProvider<CalendarViewType>((ref) => CalendarViewType.month);

enum CalendarViewType { month, week, day }

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final notificationEnabled = ref.watch(notificationEnabledProvider);
    final calendarView = ref.watch(calendarViewProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.color_lens),
            title: const Text('テーマ'),
            subtitle: Text(
              themeMode == ThemeMode.system
                  ? 'システム設定に従う'
                  : themeMode == ThemeMode.light
                      ? 'ライトモード'
                      : 'ダークモード',
            ),
            onTap: () => _showThemeDialog(context, ref),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.notifications),
            title: const Text('通知'),
            subtitle: const Text('イベントの通知を有効にする'),
            value: notificationEnabled,
            onChanged: (value) {
              ref.read(notificationEnabledProvider.notifier).state = value;
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('表示設定'),
            subtitle: Text(
              calendarView == CalendarViewType.month
                  ? '月表示'
                  : calendarView == CalendarViewType.week
                      ? '週表示'
                      : '日表示',
            ),
            onTap: () => _showViewDialog(context, ref),
          ),
        ],
      ),
    );
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('テーマ設定'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('システム設定に従う'),
              value: ThemeMode.system,
              groupValue: ref.read(themeProvider),
              onChanged: (value) {
                ref.read(themeProvider.notifier).state = value!;
                Navigator.pop(context);
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('ライトモード'),
              value: ThemeMode.light,
              groupValue: ref.read(themeProvider),
              onChanged: (value) {
                ref.read(themeProvider.notifier).state = value!;
                Navigator.pop(context);
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('ダークモード'),
              value: ThemeMode.dark,
              groupValue: ref.read(themeProvider),
              onChanged: (value) {
                ref.read(themeProvider.notifier).state = value!;
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showViewDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('表示設定'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<CalendarViewType>(
              title: const Text('月表示'),
              value: CalendarViewType.month,
              groupValue: ref.read(calendarViewProvider),
              onChanged: (value) {
                ref.read(calendarViewProvider.notifier).state = value!;
                Navigator.pop(context);
              },
            ),
            RadioListTile<CalendarViewType>(
              title: const Text('週表示'),
              value: CalendarViewType.week,
              groupValue: ref.read(calendarViewProvider),
              onChanged: (value) {
                ref.read(calendarViewProvider.notifier).state = value!;
                Navigator.pop(context);
              },
            ),
            RadioListTile<CalendarViewType>(
              title: const Text('日表示'),
              value: CalendarViewType.day,
              groupValue: ref.read(calendarViewProvider),
              onChanged: (value) {
                ref.read(calendarViewProvider.notifier).state = value!;
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
