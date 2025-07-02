import 'package:flutter/material.dart';

class TimePickerBottomSheet extends StatefulWidget {
  final int initialHour;
  final int initialMinute;
  final void Function(int hour, int minute) onTimeSelected;

  const TimePickerBottomSheet({
    super.key,
    required this.initialHour,
    required this.initialMinute,
    required this.onTimeSelected,
  });

  @override
  State<TimePickerBottomSheet> createState() => _TimePickerBottomSheetState();
}

class _TimePickerBottomSheetState extends State<TimePickerBottomSheet> {
  late int selectedHour;
  late int selectedMinute;

  @override
  void initState() {
    super.initState();
    selectedHour = widget.initialHour;
    selectedMinute = widget.initialMinute;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Wybierz czas treningu',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 24),
          // Prostokątny kontener z czasem
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            child: Text(
              '${selectedHour.toString().padLeft(2, '0')}:${selectedMinute.toString().padLeft(2, '0')}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          const SizedBox(height: 24),
          // Pickery godzin i minut
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Godziny
              SizedBox(
                width: 80,
                height: 120,
                child: ListWheelScrollView.useDelegate(
                  itemExtent: 40,
                  diameterRatio: 1.2,
                  physics: const FixedExtentScrollPhysics(),
                  onSelectedItemChanged: (index) {
                    setState(() {
                      selectedHour = index + 1;
                    });
                  },
                  childDelegate: ListWheelChildBuilderDelegate(
                    builder: (context, index) {
                      if (index < 0 || index > 58) return null;
                      return Center(
                        child: Text(
                          (index + 1).toString().padLeft(2, '0'),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      );
                    },
                  ),
                  // domyślnie na 0 (czyli 1 godzina)
                  controller: FixedExtentScrollController(initialItem: selectedHour - 1),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                ':',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(width: 16),
              // Minuty
              SizedBox(
                width: 80,
                height: 120,
                child: ListWheelScrollView.useDelegate(
                  itemExtent: 40,
                  diameterRatio: 1.2,
                  physics: const FixedExtentScrollPhysics(),
                  onSelectedItemChanged: (index) {
                    setState(() {
                      selectedMinute = index + 1;
                    });
                  },
                  childDelegate: ListWheelChildBuilderDelegate(
                    builder: (context, index) {
                      if (index < 0 || index > 58) return null;
                      return Center(
                        child: Text(
                          (index + 1).toString().padLeft(2, '0'),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      );
                    },
                  ),
                  controller: FixedExtentScrollController(initialItem: selectedMinute - 1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              widget.onTimeSelected(selectedHour, selectedMinute);
              Navigator.pop(context);
            },
            child: const Text('Zatwierdź'),
          ),
        ],
      ),
    );
  }
}