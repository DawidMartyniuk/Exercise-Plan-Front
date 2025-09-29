import 'package:flutter/material.dart';
import 'package:work_plan_front/model/exercise.dart';

class EquipmentSelected extends StatelessWidget {
  final void Function(EquipmentList?) onEquipmentSelected;
  final EquipmentList? selectedEquipment;

  const EquipmentSelected({
    super.key,
    required this.onEquipmentSelected,
    this.selectedEquipment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Select Equipment',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: EquipmentList.values.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  // Opcja "All"
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ListTile(
                      leading: Icon(Icons.all_inclusive, size: 40),
                      title: const Text(
                        'All',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      trailing: const Icon(Icons.arrow_forward),
                      onTap: () {
                        onEquipmentSelected(null);
                        Navigator.of(context).pop();
                      },
                    ),
                  );
                }
                final equipment = EquipmentList.values[index - 1];
               // final equipmentName = equipment.name.replaceAll('_', '-'); // dla plików z myślnikiem
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    leading:Image.asset(
                      'equipments/${equipment.name}.png',
                      width: 40,
                      height: 40,
                    ),
                    title: Text(
                      equipment.name.replaceAll('_', '-'), // dokładnie jak nazwa pliku
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    trailing: Icon(Icons.arrow_forward,
                        color: selectedEquipment == equipment
                            ? Theme.of(context).colorScheme.primary
                            : null),
                    onTap: () {
                      onEquipmentSelected(equipment);
                      Navigator.of(context).pop();
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