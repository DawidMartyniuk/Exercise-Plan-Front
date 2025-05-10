import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/model/exercise_plan.dart';
import 'package:work_plan_front/provider/ExercisePlanNotifier.dart';
import 'package:work_plan_front/screens/plan_creation.dart';
import 'package:work_plan_front/widget/plan_card_item.dart';

class PlanScreen extends ConsumerStatefulWidget {
  const PlanScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _PlanScreenState();
  }
}

void openPlanCreation(BuildContext context) {
  Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (ctx) => PlanCreation()));
}

class _PlanScreenState extends ConsumerState<PlanScreen> {

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(exercisePlanProvider.notifier).fetchExercisePlans();
    });
  }

  @override
  Widget build(BuildContext context) {
    final exercisePlans = ref.watch(exercisePlanProvider);

    void showPlanBottomSheet(BuildContext context, ExerciseTable plan) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => SizedBox(
          height: MediaQuery.of(ctx).size.height * 0.98, // prawie cały ekran
          child: PlanCardItem(
            plan: plan,
            onStartWorkout: () {
              Navigator.of(ctx).pop();
            },
          ),
        ),
      );
    }
  
    return Scaffold(
      appBar: AppBar(title: const Text('Plan')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              textAlign: TextAlign.left,
              "Start Now",
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () {},
                icon: Icon(Icons.add),
                style: TextButton.styleFrom(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primary.withAlpha((0.2 * 255).toInt()),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                ),
                label: Text(
                  "Start Empty Workout",
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              textAlign: TextAlign.left,
              "Create plan",
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () => openPlanCreation(context),

                icon: Icon(Icons.add),
                style: TextButton.styleFrom(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primary.withAlpha((0.2 * 255).toInt()),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                ),
                label: Text(
                  "Create exercise plann",
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Text(
                textAlign: TextAlign.left,
                "Your plans",
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            Expanded(
              child:
                  exercisePlans.isEmpty
          ? Center(child: Text("No plans available."))
          : ListView.builder(
              itemCount: exercisePlans.length,
              itemBuilder: (context, index) {
                final exercise = exercisePlans[index];
                return Card(
                  color: Theme.of(context).colorScheme.primary.withAlpha((0.1 * 255).toInt()), // Dodaje kolor tła
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
                    child: Column( 
                      //
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                exercise.exercise_table,
                                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                            IconButton(
                              onPressed: () {}, 
                              icon: Icon(
                                Icons.more_horiz,
                                color: Theme.of(context).colorScheme.onSurface,size: 20,),
                              alignment: Alignment.centerRight,
                            ),
                          ],
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                          exercise.rows.map((row) => row.exercise_name).join(", "),
                          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withAlpha((0.5 * 255).toInt()),
                          ),
                          textAlign: TextAlign.left,
                          ),
                      
                        ),
                        SizedBox(height: 12),                
                          SizedBox(
                            width: double.infinity,
                            child: TextButton(
                              style: TextButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25.0),
                              ),
                              ),
                              onPressed: () {
                                showPlanBottomSheet(context, exercise);
                                }, 
                              child: Text(
                                "Start workout",
                                style: Theme.of(context).textTheme.labelLarge!.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  )

                );
              },
            ),
            ),
          ],
        ),
      ),
    );
  }
}
