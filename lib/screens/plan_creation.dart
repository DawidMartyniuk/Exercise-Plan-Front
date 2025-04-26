import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/model/exercise.dart';
import 'package:work_plan_front/screens/exercises.dart';
import 'package:work_plan_front/widget/selected_exercise_list.dart';

class PlanCreation  extends ConsumerStatefulWidget{
  const PlanCreation({super.key});


  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
      return _StatePlanCreation();
  }
}
class _StatePlanCreation extends ConsumerState<PlanCreation>{

 List<Exercise> selectedExercise = [];
  Map<String, List<Map<String, String>>> Function()? _getTableData;
  
  var exerciseLenght = 0;
  late final Widget _exerciseList;  


  void addExercise() async{

  }

  void _saveTabelData() {
    if(_getTableData != null) {
      final tableData = _getTableData!();
      print("Table data: $tableData");
    } else {
      print("No table data available.");
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold( 
      appBar: AppBar(
        title: Text("log workout"),
        actions: [
          IconButton(
            onPressed: _saveTabelData,
            icon: const Icon(Icons.save),
          ),
        ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 24.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
              Expanded(
                child: selectedExercise.isEmpty 
              ? Center(
                child: Text( "No exercises added yet.", 
                style: Theme.of(context).textTheme.titleLarge!.copyWith( 
                  color: Theme.of(context).colorScheme.onSurface
                  ),),
              )
              : SelectedExerciseList(
                onGetTableData: (getterFunction) {
                  _getTableData = getterFunction;
                },
                exercises: selectedExercise,
                onDelete: (exercise) {
                  setState(() {
                    selectedExercise.remove(exercise);
                  });
                },
              ),
              ),
            Center(
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: TextButton(
                  onPressed: () async {
                    final newExercise = await Navigator.of(context).push<Exercise>(
                      MaterialPageRoute(builder: (ctx) => ExercisesScreen(),
                      ),
                    );
                    if(newExercise != null) {
                        print('Adding exercise: ${newExercise.name}');
                      setState(() {
                      selectedExercise.add(newExercise);
                    });
                    }
                  }, 
                  child: Text("Add Exercise"),
                  style: TextButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary.withAlpha((0.2 * 255).toInt()),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                  ),
                ),
              ),
            )
            
          ],
        ),
      )
    );
  }

}