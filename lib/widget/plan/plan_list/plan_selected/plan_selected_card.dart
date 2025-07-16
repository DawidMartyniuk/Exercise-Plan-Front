import 'package:flutter/material.dart';
import 'package:work_plan_front/model/exercise_plan.dart';
import 'package:work_plan_front/widget/plan/plan_list/plan_selected_list.dart';

class PlanSelectedCard extends StatelessWidget {
  final VoidCallback? infoExercise;
  final NetworkImage exerciseGif;
  final String exerciseName;
  final Widget headerCellTextStep;
  final Widget headerCellTextKg;
  final Widget headerCellTextReps;
 final List<TableRow> exerciseRows;
  final String notes;
  

  const PlanSelectedCard({
    super.key,
    required this.infoExercise,
    required this.exerciseGif,
    required this.exerciseName,
    required this.headerCellTextStep,
    required this.headerCellTextKg,
    required this.headerCellTextReps,
    required this.notes,
    required this.exerciseRows,
    //List<ExerciseRow>? exerciseRows,
    });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(
        context,
      ).colorScheme.surface.withAlpha((0.9 * 255).toInt()),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    infoExercise?.call();
                  },
                  child: ClipOval(
                    child:
                        exerciseGif.url.isNotEmpty
                            ? Image.network(
                              exerciseGif.url,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            )
                            : Container(
                              width: 50,
                              height: 50,
                              color: Colors.grey[300],
                              alignment: Alignment.center,
                              child: const Text(
                                "brak",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    exerciseName,
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
             Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              child: TextField(
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface, // tekst wpisywany
                  fontSize: 16, // dopasuj do reszty tekstów
                ),
                decoration: InputDecoration(
                  hintText: "notes",
                  hintStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), // podpowiedź lekko jaśniejsza
                    fontSize: 16,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.all(8),
                ),
                minLines: 1,
                maxLines: 3,
                onChanged: (value) {
                  // obsługa notatki
                },
              ),
            ),
            Table(
              border: TableBorder.symmetric(
                inside: BorderSide.none,
                outside: BorderSide.none,
              ),
              columnWidths: const {
                0: FlexColumnWidth(1),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1),
                3: FlexColumnWidth(1),
              },
              children: [
                TableRow(
                  children: [
                    headerCellTextStep,
                    headerCellTextKg,
                    headerCellTextReps,
                    Container(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.1),
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.check,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                ...exerciseRows, // <-- używasz przekazanej listy TableRow
              ],
            ),
          ],
        ),
      ),
    );
  }
}
