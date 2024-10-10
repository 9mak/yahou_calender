import 'package:flutter/material.dart';
import 'package:yahou_calender/models/event.dart';
import 'package:yahou_calender/models/recurrence_rule.dart';
import 'package:yahou_calender/widgets/recurrence_form.dart';

class EventForm extends StatefulWidget {
  final Event? event;
  final DateTime selectedDate;
  final Function(Event) onSave;

  const EventForm({
    super.key,
    this.event,
    required this.selectedDate,
    required this.onSave,
  });

  @override
  State<EventForm> createState() => _EventFormState();
}

class _EventFormState extends State<EventForm> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _startTime;
  late DateTime _endTime;
  late Color _color;
  RecurrenceRule? _recurrenceRule;
  DateTime? _reminderTime;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event?.title ?? '');
    _descriptionController = TextEditingController(text: widget.event?.description ?? '');
    _startTime = widget.event?.startTime ?? widget.selectedDate.add(const Duration(hours: 9));
    _endTime = widget.event?.endTime ?? widget.selectedDate.add(const Duration(hours: 10));
    _color = widget.event?.color ?? Colors.blue;
    _recurrenceRule = widget.event?.recurrenceRule;
    _reminderTime = widget.event?.reminderTime;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'タイトル'),
          ),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(labelText: '説明'),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _selectDateTime(context, isStartTime: true),
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: '開始時間'),
                    child: Text(_formatDateTime(_startTime)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: InkWell(
                  onTap: () => _selectDateTime(context, isStartTime: false),
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: '終了時間'),
                    child: Text(_formatDateTime(_endTime)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('カラー: '),
              InkWell(
                onTap: _selectColor,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: _color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: _selectRecurrence,
            child: InputDecorator(
              decoration: const InputDecoration(labelText: '繰り返し'),
              child: Text(_recurrenceRule?.toReadableString() ?? '繰り返しなし'),
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () => _selectDateTime(context, isReminder: true),
            child: InputDecorator(
              decoration: const InputDecoration(labelText: 'リマインダー'),
              child: Text(_reminderTime != null ? _formatDateTime(_reminderTime!) : 'リマインダーなし'),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _saveEvent,
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

    void _selectDateTime(BuildContext context, {bool isStartTime = false, bool isReminder = false}) async {
      final initialDate = isReminder ? _startTime : (isStartTime ? _startTime : _endTime);
      final pickedDate = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );
      if (pickedDate != null && mounted) {
        final pickedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(initialDate),
        );
        if (pickedTime != null && mounted) {
          setState(() {
            final newDateTime = DateTime(
              pickedDate.year,
              pickedDate.month,
              pickedDate.day,
              pickedTime.hour,
              pickedTime.minute,
            );
            if (isReminder) {
              _reminderTime = newDateTime;
            } else if (isStartTime) {
              _startTime = newDateTime;
            } else {
              _endTime = newDateTime;
            }
          });
        }
      }
    }
  }

  void _selectColor() async {
    final pickedColor = await showDialog<Color>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('カラーを選択'),
        children: Colors.primaries.map((color) {
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(context, color),
            child: Container(
              width: 24,
              height: 24,
              color: color,
            ),
          );
        }).toList(),
      ),
    );
    if (pickedColor != null) {
      setState(() {
        _color = pickedColor;
      });
    }
  }

  void _selectRecurrence() async {
    final result = await showDialog<RecurrenceRule?>(
      context: context,
      builder: (context) => Dialog(
        child: RecurrenceForm(initialRule: _recurrenceRule),
      ),
    );
    if (result != null) {
      setState(() {
        _recurrenceRule = result;
      });
    }
  }

  void _saveEvent() {
    final newEvent = Event(
      id: widget.event?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text,
      description: _descriptionController.text,
      startTime: _startTime,
      endTime: _endTime,
      color: _color,
      recurrenceRule: _recurrenceRule,
      reminderTime: _reminderTime,
    );
    widget.onSave(newEvent);
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}/${dateTime.month}/${dateTime.day} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}