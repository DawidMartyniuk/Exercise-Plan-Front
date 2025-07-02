import 'package:flutter/material.dart';

class DataPickerBottomSheet extends StatefulWidget {
  final int initialDay;
  final int initialMonth;
  final int initialYear;
  final void Function(int day, int month, int year) onDateSelected;

  const DataPickerBottomSheet({
    super.key,
    required this.initialDay,
    required this.initialMonth,
    required this.initialYear,
    required this.onDateSelected,
  });

  @override
  State<DataPickerBottomSheet> createState() => _DataPickerBottomSheetState();
}

class _DataPickerBottomSheetState extends State<DataPickerBottomSheet> {
  late int selectedDay;
  late int selectedMonth;
  late int selectedYear;

  final int minYear = 2000;
  final int maxYear = 2100;

  @override
  void initState() {
    super.initState();
    selectedDay = widget.initialDay;
    selectedMonth = widget.initialMonth;
    selectedYear = widget.initialYear;
  }

  int daysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  @override
  Widget build(BuildContext context) {
    int maxDay = daysInMonth(selectedYear, selectedMonth);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Wybierz datę',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 24),
      
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
                style: BorderStyle.none,
              ),
            ),
            child: Text(
              '${selectedDay.toString().padLeft(2, '0')}.${selectedMonth.toString().padLeft(2, '0')}.${selectedYear.toString()}',
              style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
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
                      selectedDay = index + 1;
                    });
                  },
                  childDelegate: ListWheelChildBuilderDelegate(
                    builder: (context, index) {
                      if (index < 0 || index >= maxDay) return null;
                      return Center(
                        child: Text(
                          (index + 1).toString().padLeft(2, '0'),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      );
                    },
                  ),
                  controller: FixedExtentScrollController(initialItem: selectedDay - 1),
                ),
              ),
              const SizedBox(width: 7),
              Text(
                '.',
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
                      selectedMonth = index + 1;
                     
                      if (selectedDay > daysInMonth(selectedYear, selectedMonth)) {
                        selectedDay = daysInMonth(selectedYear, selectedMonth);
                      }
                    });
                  },
                  childDelegate: ListWheelChildBuilderDelegate(
                    builder: (context, index) {
                      if (index < 0 || index > 11) return null;
                      return Center(
                        child: Text(
                          (index + 1).toString().padLeft(2, '0'),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      );
                    },
                  ),
                  controller: FixedExtentScrollController(initialItem: selectedMonth - 1),
                ),
              ),
              const SizedBox(width: 7),
              Text(
                '.',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(width: 7),
             
              SizedBox(
                width: 80,
                height: 120,
                child: ListWheelScrollView.useDelegate(
                  itemExtent: 40,
                  diameterRatio: 1.2,
                  physics: const FixedExtentScrollPhysics(),
                  onSelectedItemChanged: (index) {
                    setState(() {
                      selectedYear = minYear + index;
                    
                      if (selectedDay > daysInMonth(selectedYear, selectedMonth)) {
                        selectedDay = daysInMonth(selectedYear, selectedMonth);
                      }
                    });
                  },
                  childDelegate: ListWheelChildBuilderDelegate(
                    builder: (context, index) {
                      if (index < 0 || index > (maxYear - minYear)) return null;
                      return Center(
                        child: Text(
                          (minYear + index).toString(),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      );
                    },
                  ),
                  controller: FixedExtentScrollController(initialItem: selectedYear - minYear),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              widget.onDateSelected(selectedDay, selectedMonth, selectedYear);
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