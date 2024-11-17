import 'package:flutter/material.dart';
import '../models/event.dart';

class RecurrencePicker extends StatefulWidget {
  final RecurrenceType initialValue;
  final DateTime startDate;
  final Function(RecurrenceType type, DateTime? endDate, List<int>? weeklyDays, int? monthlyDay) onChanged;

  const RecurrencePicker({
    super.key,
    required this.initialValue,
    required this.startDate,
    required this.onChanged,
  });

  @override
  State<RecurrencePicker> createState() => _RecurrencePickerState();
}

class _RecurrencePickerState extends State<RecurrencePicker> {
  late RecurrenceType _selectedType;
  DateTime? _endDate;
  List<int>? _weeklyDays;
  int? _monthlyDay;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialValue;
  }

  List<Widget> _buildRecurrenceOptions() {
    final List<Widget> options = [
      RadioListTile<RecurrenceType>(
        title: const Text('繰り返しなし'),
        value: RecurrenceType.none,
        groupValue: _selectedType,
        onChanged: _updateRecurrenceType,
      ),
      RadioListTile<RecurrenceType>(
        title: const Text('毎日'),
        value: RecurrenceType.daily,
        groupValue: _selectedType,
        onChanged: _updateRecurrenceType,
      ),
      RadioListTile<RecurrenceType>(
        title: const Text('毎週'),
        value: RecurrenceType.weekly,
        groupValue: _selectedType,
        onChanged: _updateRecurrenceType,
      ),
      if (_selectedType == RecurrenceType.weekly)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Wrap(
            spacing: 8.0,
            children: [
              for (int i = 1; i <= 7; i++)
                FilterChip(
                  label: Text(_getWeekdayShortName(i)),
                  selected: _weeklyDays?.contains(i) ?? false,
                  onSelected: (selected) {
                    setState(() {
                      _weeklyDays ??= [];
                      if (selected) {
                        _weeklyDays!.add(i);
                      } else {
                        _weeklyDays!.remove(i);
                      }
                      widget.onChanged(_selectedType, _endDate, _weeklyDays, _monthlyDay);
                    });
                  },
                ),
            ],
          ),
        ),
      RadioListTile<RecurrenceType>(
        title: const Text('毎月'),
        value: RecurrenceType.monthly,
        groupValue: _selectedType,
        onChanged: _updateRecurrenceType,
      ),
      if (_selectedType == RecurrenceType.monthly)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: DropdownButton<int>(
            value: _monthlyDay ?? widget.startDate.day,
            items: List.generate(31, (index) => index + 1).map((day) {
              return DropdownMenuItem(
                value: day,
                child: Text('$day日'),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _monthlyDay = value;
                widget.onChanged(_selectedType, _endDate, _weeklyDays, _monthlyDay);
              });
            },
          ),
        ),
      RadioListTile<RecurrenceType>(
        title: const Text('毎年'),
        value: RecurrenceType.yearly,
        groupValue: _selectedType,
        onChanged: _updateRecurrenceType,
      ),
    ];

    if (_selectedType != RecurrenceType.none) {
      options.add(
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Text('終了日: '),
              TextButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _endDate ?? DateTime.now().add(const Duration(days: 365)),
                    firstDate: widget.startDate,
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) {
                    setState(() {
                      _endDate = picked;
                      widget.onChanged(_selectedType, _endDate, _weeklyDays, _monthlyDay);
                    });
                  }
                },
                child: Text(_endDate != null
                    ? '${_endDate!.year}年${_endDate!.month}月${_endDate!.day}日'
                    : '選択してください'),
              ),
            ],
          ),
        ),
      );
    }

    return options;
  }

  void _updateRecurrenceType(RecurrenceType? value) {
    if (value != null) {
      setState(() {
        _selectedType = value;
        if (value == RecurrenceType.none) {
          _endDate = null;
          _weeklyDays = null;
          _monthlyDay = null;
        }
        widget.onChanged(_selectedType, _endDate, _weeklyDays, _monthlyDay);
      });
    }
  }

  String _getWeekdayShortName(int weekday) {
    switch (weekday) {
      case 1: return '月';
      case 2: return '火';
      case 3: return '水';
      case 4: return '木';
      case 5: return '金';
      case 6: return '土';
      case 7: return '日';
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _buildRecurrenceOptions(),
    );
  }
}
