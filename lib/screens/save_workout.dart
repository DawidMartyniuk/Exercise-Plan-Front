import 'package:flutter/material.dart';
import 'package:work_plan_front/widget/CustomDivider.dart';

class SaveWorkout extends StatefulWidget {
  const SaveWorkout({Key? key}) : super(key: key);

  @override
  _SaveWorkoutState createState() => _SaveWorkoutState();
}

class _SaveWorkoutState extends State<SaveWorkout> {
  void verticalLine() {
    const Divider(
      color: Colors.black,
      thickness: 2,
      height: 1,
      indent: 26,
      endIndent: 26,
    );
  }

  void openDetails(){
    showModalBottomSheet(
      context: context,
      builder: (context) => 
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Details about the workout will be displayed here.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
            child: Text('Save'),
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Trening zapisany!')));
              Navigator.pop(context);
            },
          ),
        ],
        centerTitle: true,
        title: Text(
          'Zapisz trening',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            shadowColor: Theme.of(
              context,
            ).colorScheme.primary.withAlpha((0.9 * 255).toInt()),
            color: Theme.of(
              context,
            ).colorScheme.primary.withAlpha((0.3 * 255).toInt()),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 26,
                    vertical: 40,
                  ),
                  child: Text(
                    'Tytuł treningu',
                    style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    //style: Theme.of(context).textTheme.headline6,
                  ),
                ),
                CustomDivider(indent: 5, endIndent: 5, color: Colors.black),
               // SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        Text(
                          textAlign: TextAlign.left,
                          'Kiedy:',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall!.copyWith(
                            color: Theme.of(context).colorScheme.onSurface
                                .withAlpha((0.9 * 255).toInt()),
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          '${DateTime.now().toLocal()}',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium!.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 20),
                    Column(
                      children: [
                        Text(
                           textAlign: TextAlign.left,
                          'Czas trwania:',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall!.copyWith(
                            color: Theme.of(context).colorScheme.onSurface
                                .withAlpha((0.9 * 255).toInt()),
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Czas: 00:00:00',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium!.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                CustomDivider(indent: 5, endIndent: 5, color: Colors.black),
                //SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        Text(
                           textAlign: TextAlign.left,
                          "Ilość kilogramów:",
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall!.copyWith(
                            color: Theme.of(context).colorScheme.onSurface
                                .withAlpha((0.9 * 255).toInt()),
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "0 kg", // ilość kilogramów w całości
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium!.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        // Tutaj można dodać logikę do wyświetlenia informacji o ćwiczeniu
                        openDetails();
                      },
                      child: Column(
                        children: [
                          Text(
                             textAlign: TextAlign.left,
                            "Ilość powtórzeń:",
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall!.copyWith(
                              color: Theme.of(context).colorScheme.onSurface
                                  .withAlpha((0.9 * 255).toInt()),
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "0 powtórzeń", // ilość powtórzeń w całości
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium!.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                 CustomDivider(indent: 5, endIndent: 5, color: Colors.black),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
