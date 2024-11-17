import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/event.dart';
import '../providers/event_provider.dart';
import '../utils/notification_helper.dart';

class EventScreen extends ConsumerStatefulWidget {
  final Event? event;
  
  const EventScreen({super.key, this.event});

  @override
  ConsumerState<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends ConsumerState<EventScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late DateTime _startDate;
  late DateTime _endDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late bool _isAllDay;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event?.title ?? "");
    _startDate = widget.event?.startTime ?? DateTime.now();
    _endDate = widget.event?.endTime ?? DateTime.now().add(const Duration(hours: 1));
    _startTime = TimeOfDay.fromDateTime(widget.event?.startTime ?? DateTime.now());
    _endTime = TimeOfDay.fromDateTime(widget.event?.endTime ?? DateTime.now().add(const Duration(hours: 1)));
    _isAllDay = widget.event?.isAllDay ?? false;
    _descriptionController = TextEditingController(text: widget.event?.description ?? "");
    _locationController = TextEditingController(text: widget.event?.location ?? "");
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            _startTime.hour,
            _startTime.minute,
          );
        } else {
          _endDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            _endTime.hour,
            _endTime.minute,
          );
        }
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    TimeOfDay initialTime = isStart ? _startTime : _endTime;
    int initialHour = initialTime.hour;
    int initialMinute = (initialTime.minute ~/ 5) * 5;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('時刻を選択'),
              content: SizedBox(
                height: 200,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 時の選択
                    SizedBox(
                      width: 60,
                      child: ListWheelScrollView.useDelegate(
                        itemExtent: 40,
                        perspective: 0.005,
                        diameterRatio: 1.1,
                        physics: const FixedExtentScrollPhysics(),
                        controller: FixedExtentScrollController(initialItem: initialHour),
                        onSelectedItemChanged: (index) {
                          setDialogState(() => initialHour = index);
                        },
                        childDelegate: ListWheelChildBuilderDelegate(
                          childCount: 24,
                          builder: (context, index) {
                            return Center(
                              child: Text(
                                index.toString().padLeft(2, '0'),
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: initialHour == index ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(':', style: TextStyle(fontSize: 20)),
                    ),
                    // 分の選択
                    SizedBox(
                      width: 60,
                      child: ListWheelScrollView.useDelegate(
                        itemExtent: 40,
                        perspective: 0.005,
                        diameterRatio: 1.1,
                        physics: const FixedExtentScrollPhysics(),
                        controller: FixedExtentScrollController(initialItem: initialMinute ~/ 5),
                        onSelectedItemChanged: (index) {
                          setDialogState(() => initialMinute = index * 5);
                        },
                        childDelegate: ListWheelChildBuilderDelegate(
                          childCount: 12,
                          builder: (context, index) {
                            return Center(
                              child: Text(
                                (index * 5).toString().padLeft(2, '0'),
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: initialMinute == index * 5 ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('キャンセル'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      final selectedTime = TimeOfDay(hour: initialHour, minute: initialMinute);
                      if (isStart) {
                        _startTime = selectedTime;
                        _startDate = DateTime(
                          _startDate.year,
                          _startDate.month,
                          _startDate.day,
                          selectedTime.hour,
                          selectedTime.minute,
                        );
                      } else {
                        _endTime = selectedTime;
                        _endDate = DateTime(
                          _endDate.year,
                          _endDate.month,
                          _endDate.day,
                          selectedTime.hour,
                          selectedTime.minute,
                        );
                      }
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final startDateTime = _isAllDay
          ? DateTime(_startDate.year, _startDate.month, _startDate.day)
          : DateTime(
              _startDate.year,
              _startDate.month,
              _startDate.day,
              _startTime.hour,
              _startTime.minute,
            );
      
      final endDateTime = _isAllDay
          ? DateTime(_endDate.year, _endDate.month, _endDate.day, 23, 59, 59)
          : DateTime(
              _endDate.year,
              _endDate.month,
              _endDate.day,
              _endTime.hour,
              _endTime.minute,
            );

      if (endDateTime.isBefore(startDateTime)) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('終了日時は開始日時より後に設定してください')),
        );
        return;
      }

      final event = Event(
        id: widget.event?.id,
        title: _titleController.text,
        startTime: startDateTime,
        endTime: endDateTime,
        isAllDay: _isAllDay,
        description: _descriptionController.text,
        location: _locationController.text,
      );

      if (widget.event != null) {
        await ref.read(eventListProvider.notifier).updateEvent(event);
      } else {
        await ref.read(eventListProvider.notifier).addEvent(event);
      }

      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('予定を保存しました')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('エラーが発生しました: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event == null ? "予定の追加" : "予定の編集"),
        actions: [
          if (widget.event != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                final bool? confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("予定の削除"),
                    content: const Text("この予定を削除してもよろしいですか？"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text("キャンセル"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text("削除"),
                      ),
                    ],
                  ),
                );

                if (confirm == true && mounted) {
                  await ref.read(eventListProvider.notifier).deleteEvent(widget.event!.id);
                  if (!mounted) return;
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('予定を削除しました')),
                  );
                }
              },
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: "タイトル",
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "タイトルを入力してください";
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text("終日"),
              value: _isAllDay,
              onChanged: (value) {
                setState(() {
                  _isAllDay = value;
                });
              },
            ),
            Card(
              child: Column(
                children: [
                  ListTile(
                    title: const Text("開始日"),
                    subtitle: Text(
                      "${_startDate.year}年${_startDate.month}月${_startDate.day}日",
                    ),
                    trailing: TextButton(
                      onPressed: () => _selectDate(context, true),
                      child: const Text("変更"),
                    ),
                  ),
                  if (!_isAllDay)
                    ListTile(
                      title: const Text("開始時刻"),
                      subtitle: Text(
                        "${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}",
                      ),
                      trailing: TextButton(
                        onPressed: () => _selectTime(context, true),
                        child: const Text("変更"),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  ListTile(
                    title: const Text("終了日"),
                    subtitle: Text(
                      "${_endDate.year}年${_endDate.month}月${_endDate.day}日",
                    ),
                    trailing: TextButton(
                      onPressed: () => _selectDate(context, false),
                      child: const Text("変更"),
                    ),
                  ),
                  if (!_isAllDay)
                    ListTile(
                      title: const Text("終了時刻"),
                      subtitle: Text(
                        "${_endTime.hour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')}",
                      ),
                      trailing: TextButton(
                        onPressed: () => _selectTime(context, false),
                        child: const Text("変更"),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: "場所",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: "メモ",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveEvent,
        label: const Text("保存"),
        icon: const Icon(Icons.save),
      ),
    );
  }
}
