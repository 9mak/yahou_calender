import 'package:flutter/material.dart';

class TimePickerSpinner extends StatefulWidget {
  final TimeOfDay time;
  final ValueChanged<TimeOfDay> onTimeChanged;

  const TimePickerSpinner({
    Key? key,
    required this.time,
    required this.onTimeChanged,
  }) : super(key: key);

  @override
  State<TimePickerSpinner> createState() => _TimePickerSpinnerState();
}

class _TimePickerSpinnerState extends State<TimePickerSpinner> {
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;

  @override
  void initState() {
    super.initState();
    _hourController = FixedExtentScrollController(initialItem: widget.time.hour);
    _minuteController = FixedExtentScrollController(initialItem: widget.time.minute ~/ 5);
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            'Žž‚ð‘I‘ð',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 70,
                  height: 200,
                  child: ListWheelScrollView.useDelegate(
                    controller: _hourController,
                    itemExtent: 50,
                    perspective: 0.005,
                    diameterRatio: 1.1,
                    physics: const FixedExtentScrollPhysics(),
                    onSelectedItemChanged: (int index) {
                      widget.onTimeChanged(
                        TimeOfDay(
                          hour: index,
                          minute: widget.time.minute,
                        ),
                      );
                    },
                    childDelegate: ListWheelChildBuilderDelegate(
                      childCount: 24,
                      builder: (context, index) {
                        return Container(
                          height: 50,
                          alignment: Alignment.center,
                          child: Text(
                            index.toString().padLeft(2, '0'),
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: _hourController.selectedItem == index
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    ':',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                Container(
                  width: 70,
                  height: 200,
                  child: ListWheelScrollView.useDelegate(
                    controller: _minuteController,
                    itemExtent: 50,
                    perspective: 0.005,
                    diameterRatio: 1.1,
                    physics: const FixedExtentScrollPhysics(),
                    onSelectedItemChanged: (int index) {
                      widget.onTimeChanged(
                        TimeOfDay(
                          hour: widget.time.hour,
                          minute: index * 5,
                        ),
                      );
                    },
                    childDelegate: ListWheelChildBuilderDelegate(
                      childCount: 12,
                      builder: (context, index) {
                        return Container(
                          height: 50,
                          alignment: Alignment.center,
                          child: Text(
                            (index * 5).toString().padLeft(2, '0'),
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: _minuteController.selectedItem == index
                                  ? FontWeight.bold
                                  : FontWeight.normal,
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
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('ƒLƒƒƒ“ƒZƒ‹'),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(
                    TimeOfDay(
                      hour: _hourController.selectedItem,
                      minute: _minuteController.selectedItem * 5,
                    ),
                  );
                },
                child: const Text('Š®—¹'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
