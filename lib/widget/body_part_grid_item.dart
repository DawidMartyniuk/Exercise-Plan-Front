import 'package:flutter/material.dart';
import 'package:work_plan_front/model/exercise.dart';
import 'package:work_plan_front/widget/body_part_grid_item.dart';

class BodyPartSelected extends StatefulWidget {
  const BodyPartSelected({
    super.key,
    required this.onBodyPartSelected,
  });

  final void Function(BodyPart) onBodyPartSelected;

  @override
  State<BodyPartSelected> createState() => _BodyPartSelectedState();
}

class _BodyPartSelectedState extends State<BodyPartSelected> {
  @override
  Widget build(BuildContext context) {
    return Container(
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
                final bodyPart = BodyPart.values[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text(
                      bodyPart.name, // Wyświetl nazwę BodyPart
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