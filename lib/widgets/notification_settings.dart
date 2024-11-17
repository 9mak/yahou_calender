import 'package:flutter/material.dart';

class NotificationSettings extends StatefulWidget {
  final List<Duration> selectedReminders;
  final Function(List<Duration>) onChanged;

  const NotificationSettings({
    super.key,
    required this.selectedReminders,
    required this.onChanged,
  });

  @override
  State<NotificationSettings> createState() => _NotificationSettingsState();
}

class _NotificationSettingsState extends State<NotificationSettings> {
  late List<Duration> _selectedReminders;

  @override
  void initState() {
    super.initState();
    _selectedReminders = List.from(widget.selectedReminders);
  }

  static const Map<String, Duration> _availableReminders = {
    '5分前': Duration(minutes: 5),
    '10分前': Duration(minutes: 10),
    '30分前': Duration(minutes: 30),
    '1時間前': Duration(hours: 1),
    '2時間前': Duration(hours: 2),
    '1日前': Duration(days: 1),
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            '通知設定',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...(_availableReminders.entries.map((entry) {
          final isSelected = _selectedReminders.contains(entry.value);
          return CheckboxListTile(
            title: Text(entry.key),
            value: isSelected,
            onChanged: (bool? value) {
              setState(() {
                if (value ?? false) {
                  _selectedReminders.add(entry.value);
                } else {
                  _selectedReminders.remove(entry.value);
                }
                widget.onChanged(_selectedReminders);
              });
            },
          );
        })),
      ],
    );
  }
}
