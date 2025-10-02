import 'package:flutter/material.dart';
import 'package:work_plan_front/model/exercise.dart';

class SecondaryMusclesSelector extends StatefulWidget {
  final List<TargetMuscles> selectedMuscles;
  final void Function(List<TargetMuscles>) onSelectionChanged;

  const SecondaryMusclesSelector({
    super.key,
    required this.selectedMuscles,
    required this.onSelectionChanged,
  });

  @override
  State<SecondaryMusclesSelector> createState() =>
      _SecondaryMusclesSelectorState();
}

class _SecondaryMusclesSelectorState extends State<SecondaryMusclesSelector> {
  late List<TargetMuscles> _selected;

  @override
  void initState() {
    super.initState();
    _selected = List<TargetMuscles>.from(widget.selectedMuscles);
  }

  void _onItemTapped(TargetMuscles muscle) {
    setState(() {
      if (_selected.contains(muscle)) {
        _selected.remove(muscle);
      } else {
        _selected.add(muscle);
      }
      widget.onSelectionChanged(_selected);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Select Secondary Muscles',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: TargetMuscles.values.length,
              itemBuilder: (context, index) {
                final muscle = TargetMuscles.values[index];
                final isSelected = _selected.contains(muscle);
                return Card(
                  margin: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  child: ListTile(
                    leading: Image.asset(
                      'muscles/${muscle.name}.png',
                      width: 40,
                      height: 40,
                    ),
                    title: Text(
                      muscle.displayNameTargetMuscle,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    trailing: Checkbox(
                      value: isSelected,
                      onChanged: (checked) {
                        _onItemTapped(muscle);
                      },
                      checkColor: Theme.of(context).colorScheme.onPrimary,
                      activeColor: Theme.of(context).colorScheme.primary,
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    onTap: () => _onItemTapped(muscle),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
