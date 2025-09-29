import 'package:flutter/material.dart';
import 'package:work_plan_front/model/exercise.dart';

class SecondaryMusclesSelector extends StatefulWidget {
  final List<BodyPart> selectedMuscles;
  final void Function(List<BodyPart>) onSelectionChanged;

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
  late List<BodyPart> _selected;

  @override
  void initState() {
    super.initState();
    _selected = List<BodyPart>.from(widget.selectedMuscles);
  }

  void _onItemTapped(BodyPart part) {
    setState(() {
      if (_selected.contains(part)) {
        _selected.remove(part);
      } else {
        _selected.add(part);
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
              itemCount: BodyPart.values.length,
              itemBuilder: (context, index) {
                final bodyPart = BodyPart.values[index];
                final isSelected = _selected.contains(bodyPart);
                return Card(
                  margin: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  child: ListTile(
                    leading: Image.asset(
                      'assets/muscles/${bodyPart.name}.png',
                      width: 40,
                      height: 40,
                    ),
                    title: Text(
                      bodyPart.displayNameBodyPart(),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    trailing: Checkbox(
                      value: isSelected,
                      onChanged: (checked) {
                        _onItemTapped(bodyPart);
                      },
                      checkColor: Theme.of(context).colorScheme.onPrimary,
                      activeColor: Theme.of(context).colorScheme.primary,
                      side: BorderSide(
                        color:
                            Theme.of(
                              context,
                            ).colorScheme.primary, // ramka checkboxa
                        width: 2,
                      ),
                    ),

                    onTap: () => _onItemTapped(bodyPart),
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
