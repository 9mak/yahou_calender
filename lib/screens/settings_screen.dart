import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/preferences_helper.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.system) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    state = await PreferencesHelper.loadThemeMode();
  }

  Future<void> setTheme(ThemeMode mode) async {
    await PreferencesHelper.saveThemeMode(mode);
    state = mode;
  }
}

final startWeekdayProvider = StateNotifierProvider<StartWeekdayNotifier, int>((ref) {
  return StartWeekdayNotifier();
});

class StartWeekdayNotifier extends StateNotifier<int> {
  StartWeekdayNotifier() : super(DateTime.monday) {
    _loadStartWeekday();
  }

  Future<void> _loadStartWeekday() async {
    state = await PreferencesHelper.loadStartWeekday();
  }

  Future<void> setStartWeekday(int weekday) async {
    await PreferencesHelper.saveStartWeekday(weekday);
    state = weekday;
  }
}

final defaultViewProvider = StateNotifierProvider<DefaultViewNotifier, String>((ref) {
  return DefaultViewNotifier();
});

class DefaultViewNotifier extends StateNotifier<String> {
  DefaultViewNotifier() : super("月") {
    _loadDefaultView();
  }

  Future<void> _loadDefaultView() async {
    state = await PreferencesHelper.loadDefaultView();
  }

  Future<void> setDefaultView(String view) async {
    await PreferencesHelper.saveDefaultView(view);
    state = view;
  }
}

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final startWeekday = ref.watch(startWeekdayProvider);
    final defaultView = ref.watch(defaultViewProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('テーマ設定'),
            subtitle: Text(
              switch (themeMode) {
                ThemeMode.system => 'システム設定に従う',
                ThemeMode.light => 'ライトモード',
                ThemeMode.dark => 'ダークモード',
              }
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => SimpleDialog(
                  title: const Text('テーマ設定'),
                  children: [
                    RadioListTile(
                      title: const Text('システム設定に従う'),
                      value: ThemeMode.system,
                      groupValue: themeMode,
                      onChanged: (value) {
                        ref.read(themeProvider.notifier).setTheme(value!);
                        Navigator.pop(context);
                      },
                    ),
                    RadioListTile(
                      title: const Text('ライトモード'),
                      value: ThemeMode.light,
                      groupValue: themeMode,
                      onChanged: (value) {
                        ref.read(themeProvider.notifier).setTheme(value!);
                        Navigator.pop(context);
                      },
                    ),
                    RadioListTile(
                      title: const Text('ダークモード'),
                      value: ThemeMode.dark,
                      groupValue: themeMode,
                      onChanged: (value) {
                        ref.read(themeProvider.notifier).setTheme(value!);
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          ListTile(
            title: const Text('週の開始曜日'),
            subtitle: Text(
              switch (startWeekday) {
                DateTime.monday => '月曜日',
                DateTime.sunday => '日曜日',
                _ => '月曜日',
              }
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => SimpleDialog(
                  title: const Text('週の開始曜日'),
                  children: [
                    RadioListTile(
                      title: const Text('月曜日'),
                      value: DateTime.monday,
                      groupValue: startWeekday,
                      onChanged: (value) {
                        ref.read(startWeekdayProvider.notifier).setStartWeekday(value!);
                        Navigator.pop(context);
                      },
                    ),
                    RadioListTile(
                      title: const Text('日曜日'),
                      value: DateTime.sunday,
                      groupValue: startWeekday,
                      onChanged: (value) {
                        ref.read(startWeekdayProvider.notifier).setStartWeekday(value!);
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          ListTile(
            title: const Text('デフォルト表示'),
            subtitle: Text(defaultView),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => SimpleDialog(
                  title: const Text('デフォルト表示'),
                  children: [
                    RadioListTile(
                      title: const Text('月表示'),
                      value: "月",
                      groupValue: defaultView,
                      onChanged: (value) {
                        ref.read(defaultViewProvider.notifier).setDefaultView(value!);
                        Navigator.pop(context);
                      },
                    ),
                    RadioListTile(
                      title: const Text('週表示'),
                      value: "週",
                      groupValue: defaultView,
                      onChanged: (value) {
                        ref.read(defaultViewProvider.notifier).setDefaultView(value!);
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('バージョン情報'),
            subtitle: const Text('1.0.0'),
          ),
        ],
      ),
    );
  }
}
