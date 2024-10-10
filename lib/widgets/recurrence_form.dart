// lib/widgets/recurrence_form.dart

import 'package:flutter/material.dart';
import 'package:yahou_calender/models/recurrence_rule.dart';

class RecurrenceForm extends StatefulWidget {
  final RecurrenceRule? initialRule;

  const RecurrenceForm({super.key, this.initialRule});

  @override
  State<RecurrenceForm> createState() => _RecurrenceFormState();
}

class _RecurrenceFormState extends State<RecurrenceForm> {
  late RecurrenceFrequency _frequency;
  late int _interval;
  DateTime? _until;
  int? _count;

  @override
  void initState() {
    super.initState();
    _frequency = widget.initialRule?.frequency ?? RecurrenceFrequency.daily;
    _interval = widget.initialRule?.interval ?? 1;
    _until = widget.initialRule?.until;
    _count = widget.initialRule?.count;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<RecurrenceFrequency>(
            value: _frequency,
            onChanged: (value) {
              setState(() {
                _frequency = value!;
              });
            },
            items: RecurrenceFrequency.values.map((frequency) {
              return DropdownMenuItem(
                value: frequency,
                child: Text(_getFrequencyText(frequency)),
              );
            }).toList(),
            decoration: const InputDecoration(labelText: '繰り返し'),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: _interval.toString(),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: '間隔'),
                  onChanged: (value) {
                    setState(() {
                      _interval = int.tryParse(value) ?? 1;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _until != null ? 'until' : (_count != null ? 'count' : 'forever'),
                  onChanged: (value) {
                    setState(() {
                      if (value == 'until') {
                        _until = DateTime.now().add(const Duration(days: 30));
                        _count = null;
                      } else if (value == 'count') {
                        _count = 10;
                        _until = null;
                      } else {
                        _until = null;
                        _count = null;
                      }
                    });
                  },
                  items: const [
                    DropdownMenuItem(value: 'forever', child: Text('無期限')),
                    DropdownMenuItem(value: 'until', child: Text('終了日')),
                    DropdownMenuItem(value: 'count', child: Text('回数')),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_until != null)
            InkWell(
              onTap: _selectUntilDate,
              child: InputDecorator(
                decoration: const InputDecoration(labelText: '終了日'),
                child: Text(_until != null ? '${_until!.year}/${_until!.month}/${_until!.day}' : ''),
              ),
            ),
          if (_count != null)
            TextFormField(
              initialValue: _count.toString(),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: '繰り返し回数'),
              onChanged: (value) {
                setState(() {
                  _count = int.tryParse(value);
                });
              },
            ),
          const SizedBox(height: 32),
          ElevatedButton(
            child: const Text('保存'),
            onPressed: () {
              Navigator.of(context).pop(RecurrenceRule(
                frequency: _frequency,
                interval: _interval,
                until: _until,
                count: _count,
              ));
            },
          ),
        ],
      ),
    );
  }

  void _selectUntilDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _until ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        _until = pickedDate;
      });
    }
  }

  String _getFrequencyText(RecurrenceFrequency frequency) {
    switch (frequency) {
      case RecurrenceFrequency.daily:
        return '毎日';
      case RecurrenceFrequency.weekly:
        return '毎週';
      case RecurrenceFrequency.monthly:
        return '毎月';
      case RecurrenceFrequency.yearly:
        return '毎年';
    }
  }
}