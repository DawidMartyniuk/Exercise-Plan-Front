import 'package:flutter/material.dart';
import 'package:work_plan_front/model/exercise.dart';


class MusclePartGridItem extends StatefulWidget {
  const MusclePartGridItem({
    super.key,
    required this.onMusclePartSelected,
  });

  final void Function(TargetMuscles?) onMusclePartSelected;

  @override
  State<MusclePartGridItem> createState() => _MusclePartGridItemState();
}

class _MusclePartGridItemState extends State<MusclePartGridItem> {
  //targetMuscles? _selectedMusclePart;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Selcted Target Muscle',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child:  ListView.builder(
              itemCount: TargetMuscles.values.length,
              itemBuilder: (context, index) {
                  if (index == 0) {
                  // Opcja "All"
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ListTile(
                      leading: Image.asset(
                      'assets/muscles/all.png', 
                      width: 40,
                      height: 40,
                    ),
                      title: const Text(
                        'All',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      trailing: const Icon(Icons.arrow_forward),
                      onTap: () {
                        widget.onMusclePartSelected(null); // Ustawienie na null
                      },
                    ),
                  );
                }
                final muscle = TargetMuscles.values[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    leading: Image.asset(
                      'assets/muscles/${muscle.name}.png',
                      width: 40,
                      height: 40,
                    ),
                    title: Text(
                      muscle.displayNameTargetMuscle, // Wyświetl nazwę BodyPart
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () {
                      widget.onMusclePartSelected(muscle); // Wywołaj callback
                    },
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