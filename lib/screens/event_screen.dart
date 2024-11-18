import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/event.dart';
import '../providers/event_provider.dart';

class EventScreen extends ConsumerStatefulWidget {
  final Event? event;
  
  const EventScreen({super.key, this.event});
  
  @override
  ConsumerState<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends ConsumerState<EventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay.now();
  bool _isAllDay = false;

  @override
  void initState() {
    super.initState();
    if (widget.event != null) {
      _titleController.text = widget.event!.title;
      _descriptionController.text = widget.event?.description ?? '';
      _locationController.text = widget.event?.location ?? '';
      _selectedDate = widget.event!.startTime;
      _startTime = TimeOfDay.fromDateTime(widget.event!.startTime);
      _endTime = TimeOfDay.fromDateTime(widget.event!.endTime);
      _isAllDay = widget.event!.isAllDay;
    } else {
      _endTime = TimeOfDay(
        hour: _startTime.hour + 1,
        minute: _startTime.minute,
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _saveEvent() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      final event = Event(
        id: widget.event?.id,
        title: _titleController.text,
        description: _descriptionController.text,
        startTime: DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          _startTime.hour,
          _startTime.minute,
        ),
        endTime: DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          _endTime.hour,
          _endTime.minute,
        ),
        isAllDay: _isAllDay,
        location: _locationController.text,
      );

      try {
        if (widget.event != null) {
          await ref.read(eventListProvider.notifier).updateEvent(event);
        } else {
          await ref.read(eventListProvider.notifier).addEvent(event);
        }
        
        if (!mounted) return;
        Navigator.of(context).pop();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('エラーが発生しました'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _deleteEvent() async {
    if (widget.event?.id == null) return;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('予定の削除'),
        content: const Text('この予定を削除してもよろしいですか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('削除'),
          ),
        ],
      ),
    );

    if (confirmed == null || !confirmed) return;

    try {
      await ref.read(eventListProvider.notifier).deleteEvent(widget.event!.id!);
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('削除中にエラーが発生しました'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = '年月日';
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event == null ? '新規予定' : '予定の編集'),
        actions: [
          if (widget.event != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteEvent,
              color: Colors.red,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'タイトル',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty == true ? 'タイトルを入力してください' : null,
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('終日'),
                value: _isAllDay,
                onChanged: (bool? value) {
                  setState(() {
                    _isAllDay = value ?? false;
                  });
                },
              ),
              ListTile(
                title: const Text('日付'),
                trailing: Text(dateStr),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (date != null) {
                    setState(() {
                      _selectedDate = date;
                    });
                  }
                },
              ),
              if (!_isAllDay) ...[
                ListTile(
                  title: const Text('開始時間'),
                  trailing: Text(_startTime.format(context)),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: _startTime,
                    );
                    if (time != null) {
                      setState(() {
                        _startTime = time;
                        if (time.hour > _endTime.hour ||
                            (time.hour == _endTime.hour && time.minute >= _endTime.minute)) {
                          _endTime = TimeOfDay(
                            hour: time.hour + 1,
                            minute: time.minute,
                          );
                        }
                      });
                    }
                  },
                ),
                ListTile(
                  title: const Text('終了時間'),
                  trailing: Text(_endTime.format(context)),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: _endTime,
                    );
                    if (time != null) {
                      final buildContext = context;
                      if (time.hour < _startTime.hour ||
                          (time.hour == _startTime.hour && time.minute <= _startTime.minute)) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(buildContext).showSnackBar(
                          const SnackBar(
                            content: Text('終了時間は開始時間よりも後に設定してください'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        return;
                      }
                      setState(() {
                        _endTime = time;
                      });
                    }
                  },
                ),
              ],
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'メモ',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: '場所',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveEvent,
        child: const Icon(Icons.save),
      ),
    );
  }
}
