import 'package:flutter/material.dart';
import 'package:work_plan_front/model/exercise.dart';

class BodyPartInfoBottomSheet extends StatelessWidget {
  final Map<BodyPart?, int> exercisesCount;
  final String title;
  //final Map<BodyPart, int> bodyPartsInfo;

  const BodyPartInfoBottomSheet({
    super.key,
    required this.exercisesCount,
    required this.title,
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
              'Partie ciała i liczba ćwiczeń',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: BodyPart.values.length,
              itemBuilder: (context, index) {
               // if (index == 0 ) {
                  
                  // return Card(
                  //   margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  //   child: ListTile(
                  //     leading: Image.asset(
                  //       'assets/muscles/all.png',
                  //       width: 40,
                  //       height: 40,
                  //     ),
                  //     title: const Text(
                  //       'all',
                  //       style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  //     ),
                  //     trailing: Row(
                  //       mainAxisSize: MainAxisSize.min,
                  //       children: [
                  //         Text(
                  //           '${exercisesCount[null] ?? 0}',
                  //           style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  //         ),
                  //         const SizedBox(width: 8),
                  //         const Icon(Icons.info_outline),
                  //       ],
                  //     ),
                  //   ),
                  // );
                //}
                final bodyPart = BodyPart.values[index];
                if ((exercisesCount[bodyPart] ?? 0) == 0) {
                  return const SizedBox.shrink();
                }
                var card = Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                    Text(
                      '${exercisesCount[bodyPart] ?? 0}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.info_outline),
                    ],
                  ),
                  ),
                );
                return card;
              },
            ),
          ),
        ],
      ),
    );
  }
}