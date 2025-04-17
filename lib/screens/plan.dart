import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/screens/plan_creation.dart';

class PlanScreen extends ConsumerStatefulWidget {
  const PlanScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _PlanScreenState();
  }
}
  void openPlanCreation(BuildContext context){
    Navigator.of(context).push(MaterialPageRoute(builder: (ctx) =>PlanCreation() ),);
  } 

class _PlanScreenState extends ConsumerState<PlanScreen> {
  @override
  Widget build(BuildContext context) {
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
                style:
                 TextButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary.withAlpha((0.2 * 255).toInt()),
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
            SizedBox(height: 20,),
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
                style:
                 TextButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary.withAlpha((0.2 * 255).toInt()),
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
          ],
        ),
      ),
    );
  }
}
