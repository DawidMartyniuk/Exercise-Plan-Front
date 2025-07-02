import 'package:flutter/material.dart';

class TimeIntervalPickerBottomSheet extends StatefulWidget {
  final int initialHourFrom;
  final int initialMinuteFrom;
  final int initialHourTo;
  final int initialMinuteTo;
  final void Function(int hourFrom, int minuteFrom, int hourTo, int minuteTo) onTimeIntervalSelected;

  const TimeIntervalPickerBottomSheet({
    super.key,
    required this.initialHourFrom,
    required this.initialMinuteFrom,
    required this.initialHourTo,
    required this.initialMinuteTo,
    required this.onTimeIntervalSelected,
  });

  @override
  State<TimeIntervalPickerBottomSheet> createState() => _TimeIntervalPickerBottomSheetState();
}

class _TimeIntervalPickerBottomSheetState extends State<TimeIntervalPickerBottomSheet> {
  late int selectedHourFrom;
  late int selectedMinuteFrom;
  late int selectedHourTo;
  late int selectedMinuteTo;

  @override
  void initState() {
    super.initState();
    selectedHourFrom = widget.initialHourFrom;
    selectedMinuteFrom = widget.initialMinuteFrom;
    selectedHourTo = widget.initialHourTo;
    selectedMinuteTo = widget.initialMinuteTo;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Wybierz przedział czasu',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                    style: BorderStyle.none,
                  ),
                ),
                child: Text(
                  '${selectedHourFrom.toString().padLeft(2, '0')}:${selectedMinuteFrom.toString().padLeft(2, '0')}',
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.arrow_forward, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                    style: BorderStyle.none,
                  ),
                ),
                child: Text(
                  '${selectedHourTo.toString().padLeft(2, '0')}:${selectedMinuteTo.toString().padLeft(2, '0')}',
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 60,
                height: 120,
                child: ListWheelScrollView.useDelegate(
                  itemExtent: 40,
                  diameterRatio: 1.2,
                  physics: const FixedExtentScrollPhysics(),
                  onSelectedItemChanged: (index) {
                    setState(() {
                      selectedHourFrom = index + 1;
                    });
                  },
                  childDelegate: ListWheelChildBuilderDelegate(
                    builder: (context, index) {
                      if (index < 0 || index > 23) return null;
                      return Center(
                        child: Text(
                          (index + 1).toString().padLeft(2, '0'),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      );
                    },
                  ),
                  controller: FixedExtentScrollController(initialItem: selectedHourFrom - 1),
                ),
              ),
              const SizedBox(width: 7),
              Text(
                ':',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(width: 7),
              SizedBox(
                width: 60,
                height: 120,
                child: ListWheelScrollView.useDelegate(
                  itemExtent: 40,
                  diameterRatio: 1.2,
                  physics: const FixedExtentScrollPhysics(),
                  onSelectedItemChanged: (index) {
                    setState(() {
                      selectedMinuteFrom = index;
                    });
                  },
                  childDelegate: ListWheelChildBuilderDelegate(
                    builder: (context, index) {
                      if (index < 0 || index > 59) return null;
                      return Center(
                        child: Text(
                          index.toString().padLeft(2, '0'),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      );
                    },
                  ),
                  controller: FixedExtentScrollController(initialItem: selectedMinuteFrom),
                ),
              ),
              const SizedBox(width: 24),
              SizedBox(
                width: 60,
                height: 120,
                child: ListWheelScrollView.useDelegate(
                  itemExtent: 40,
                  diameterRatio: 1.2,
                  physics: const FixedExtentScrollPhysics(),
                  onSelectedItemChanged: (index) {
                    setState(() {
                      selectedHourTo = index + 1;
                    });
                  },
                  childDelegate: ListWheelChildBuilderDelegate(
                    builder: (context, index) {
                      if (index < 0 || index > 23) return null;
                      return Center(
                        child: Text(
                          (index + 1).toString().padLeft(2, '0'),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      );
                    },
                  ),
                  controller: FixedExtentScrollController(initialItem: selectedHourTo - 1),
                ),
              ),
              const SizedBox(width: 7),
              Text(
                ':',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(width: 7),
              SizedBox(
                width: 60,
                height: 120,
                child: ListWheelScrollView.useDelegate(
                  itemExtent: 40,
                  diameterRatio: 1.2,
                  physics: const FixedExtentScrollPhysics(),
                  onSelectedItemChanged: (index) {
                    setState(() {
                      selectedMinuteTo = index;
                    });
                  },
                  childDelegate: ListWheelChildBuilderDelegate(
                    builder: (context, index) {
                      if (index < 0 || index > 59) return null;
                      return Center(
                        child: Text(
                          index.toString().padLeft(2, '0'),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      );
                    },
                  ),
                  controller: FixedExtentScrollController(initialItem: selectedMinuteTo),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              widget.onTimeIntervalSelected(
                selectedHourFrom,
                selectedMinuteFrom,
                selectedHourTo,
                selectedMinuteTo,
              );
              Navigator.pop(context);
            },
            child: Text(
              'Zatwierdź',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}