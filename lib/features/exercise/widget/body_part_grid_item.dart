import 'package:flutter/material.dart';
import 'package:work_plan_front/model/exercise.dart';

class BodyPartSelected extends StatefulWidget {
  const BodyPartSelected({
    super.key,
    required this.onBodyPartSelected,
  });

  final void Function(BodyPart?) onBodyPartSelected;

  @override
  State<BodyPartSelected> createState() => _BodyPartSelectedState();
}

class _BodyPartSelectedState extends State<BodyPartSelected> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Select Body Part',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: BodyPart.values.length,
              itemBuilder: (context, index) {
                  if (index == 0) {
                  // Opcja "All"
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ListTile(
                      leading: Image.asset(
                      'assets/bodyParts/all.png', 
                      width: 40,
                      height: 40,
                    ),
                      title: const Text(
                        'All',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      trailing: const Icon(Icons.arrow_forward),
                      onTap: () {
                        widget.onBodyPartSelected(null); // Ustawienie na null
                      },
                    ),
                  );
                }
                final bodyPart = BodyPart.values[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    leading: Image.asset(
                      'assets/bodyParts/${bodyPart.name}.png', 
                      width: 40,
                      height: 40,
                    ),
                    title: Text(
                      bodyPart.displayNameBodyPart(), // Wyświetl nazwę BodyPart
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () {
                      widget.onBodyPartSelected(bodyPart); // Wywołaj callback
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