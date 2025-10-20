import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:work_plan_front/model/training_session.dart';
import 'package:work_plan_front/model/weight_type.dart';
import 'package:work_plan_front/provider/exercise_plan_notifier.dart';
import 'package:work_plan_front/provider/training_serssion_notifer.dart';
import 'package:work_plan_front/provider/current_workout_plan_provider.dart';
import 'package:work_plan_front/features/workout/save_wokrout/components/save_workrout_header.dart';
import 'package:work_plan_front/features/workout/save_wokrout/components/save_workout_action_buttons.dart';
import 'package:work_plan_front/features/workout/save_wokrout/components/save_workout_image_and_description.dart';
import 'package:work_plan_front/features/workout/save_wokrout/components/save_workout_stats_row.dart';
import 'package:work_plan_front/screens/tabs.dart';
import 'package:work_plan_front/shared/utils/exercise_untils.dart';
import 'package:work_plan_front/shared/widget/common/keyboard_dismisser.dart';
import 'package:work_plan_front/shared/utils/workout_utils.dart';
import 'package:work_plan_front/shared/utils/toast_untils.dart'; // ✅ DODAJ IMPORT TOAST
import 'package:work_plan_front/shared/widget/common/custom_divider.dart';
import 'package:work_plan_front/features/workout/save_wokrout/save_workout_bottom_sheet/body_part_botton_sheet.dart';
import 'package:work_plan_front/features/workout/save_wokrout/save_workout_bottom_sheet/data_picker_bottom_sheet.dart';
import 'package:work_plan_front/features/workout/save_wokrout/save_workout_bottom_sheet/reps_info_bottom_sheet.dart';
import 'package:work_plan_front/features/workout/save_wokrout/save_workout_bottom_sheet/time_interval_picker_bottom_sheet.dart';
import 'package:work_plan_front/features/workout/save_wokrout/save_workout_bottom_sheet/time_picker_bottom_sheet.dart';
import 'package:work_plan_front/shared/widget/common/info_bottom.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/provider/workout_plan_state_provider.dart';
import 'package:work_plan_front/features/workout/save_wokrout/save_workout_bottom_sheet/workout_list_botton_sheet.dart';
import 'package:work_plan_front/services/trainingSessions.dart';

class SaveWorkout extends ConsumerStatefulWidget {
  final int allTime;
  final int allReps;
  final double allWeight;
  final int startHour;
  final int startMinute;
  final VoidCallback? onEndWorkout;
  final String planName;

  const SaveWorkout({
    super.key,
    required this.allTime,
    required this.allReps,
    required this.allWeight,
    required this.startHour,
    required this.startMinute,
    required this.onEndWorkout,
    required this.planName,
  });

  @override
  _SaveWorkoutState createState() => _SaveWorkoutState();
}

class _SaveWorkoutState extends ConsumerState<SaveWorkout> {

  //TODO: nie działa: lista wykonanych ćwiczeń oraz inne szczegulowe dane
  File? _selectedImage;

  int get allTime => widget.allTime;
  int get allReps => widget.allReps;
  double get allWeight => widget.allWeight;

  int minutesSelected = 0;
  int hoursSelected = 0;
  int secondsSelected = 0;
  int weightSelected = 120;
  int daySelected = DateTime.now().day;
  int monthSelected = DateTime.now().month;
  int yearSelected = DateTime.now().year;
  int hourFrom = 0;
  int minuteFrom = 0;
  int hourTo = DateTime.now().hour;
  int minuteTo = DateTime.now().minute;

  late final TextEditingController TitleController;

  final TextEditingController descriptionController = TextEditingController();

  @override
  void dispose() {
    TitleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    TitleController = TextEditingController(text: widget.planName);
    secondsSelected = allTime % 60;
    minutesSelected = (allTime ~/ 60) % 60;
    hoursSelected = allTime ~/ 3600;
    weightSelected = allWeight.toInt();

    hourFrom = widget.startHour;
    minuteFrom = widget.startMinute;

    print("czas: $allTime, powtórzenia: $allReps, ciężar: $allWeight");
  }

  void verticalLine() {
    const Divider(
      color: Colors.black,
      thickness: 2,
      height: 1,
      indent: 26,
      endIndent: 26,
    );
  }

  void openDetails() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Details about the workout will be displayed here.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
    );
  }

  void _tahePicture() async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 600,
    );

    if (pickedImage == null) {
      return;
    }
    setState(() {
      _selectedImage = File(pickedImage.path);
    });
  }

  void _showTimePickerSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => TimePickerBottomSheet(
            initialHour: hoursSelected,
            initialMinute: minutesSelected,
            initialSecond: secondsSelected,
            onTimeSelected: (hour, minute, second) {
              setState(() {
                hoursSelected = hour;
                minutesSelected = minute;
                secondsSelected = second; // Reset seconds to 0
              });
            },
          ),
    );
  }

  void _showWeightInfoSheet() {
    showDialog(context: context, builder: (context) => 
    InfoBottomSheet(
      textInfo: "Weight is the total weight lifted during the workout.",
    ));
  }

  void _showBodyPartExercisePickerSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => BodyPartInfoBottomSheet(
            title: 'Body Part count exercises',
            info: "weight",
          ),
    );
  }

  void _showBodyPartRepsPickerSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => BodyPartInfoBottomSheet(
            title: 'Body Part count reps',
            info: "reps",
          ),
    );
  }

  void _showRepsInfoSheet() {
    showDialog(context: context, builder: (context) => RepsInfoBottomSheet());
  }

  void _showDataPickerSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => DataPickerBottomSheet(
            initialDay: daySelected,
            initialMonth: monthSelected,
            initialYear: yearSelected,
            onDateSelected: (day, month, year) {
              setState(() {
                daySelected = day;
                monthSelected = month;
                yearSelected = year;
              });
            },
          ),
    );
  }

  void _showTimeIntervalPickerSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => TimeIntervalPickerBottomSheet(
            initialHourFrom: hourFrom,
            initialMinuteFrom: minuteFrom,
            initialHourTo: hourTo,
            initialMinuteTo: minuteTo,
            onTimeIntervalSelected: (hourFrom, minuteFrom, hourTo, minuteTo) {
              setState(() {
                this.hourFrom = hourFrom;
                this.minuteFrom = minuteFrom;
                this.hourTo = hourTo;
                this.minuteTo = minuteTo;
              });
            },
          ),
    );
  }

  void onWorkoutSelected(String workout) {
    print("Wybrano: $workout");
  }

  void _showWrokoutListPickerSheet() {
    final currentWorkout = ref.watch(currentWorkoutPlanProvider);
    final performedExercises = getPerformedExercises(currentWorkout);

    for (final ex in performedExercises) {
      print(
        'Partia: ${ex.bodyPart}, ćwiczenie: ${ex.name}, liczba serii: ${ex.sets.length}',
      );
    }
    showModalBottomSheet(
      context: context,
      builder: (context) => WorkoutListBottonSheet(),
    );
  }
  void syncPlanWithProvider() {
  final currentWorkout = ref.read(currentWorkoutPlanProvider);
  final plan = currentWorkout?.plan;
  if (plan == null) return;

  final planId = plan.id;
  final savedRows = ref.read(workoutPlanStateProvider).getRows(planId);

  for (final rowData in plan.rows) {
    for (final row in rowData.data) {
      try {
        // ✅ POPRAWKA: Dodaj try-catch
        final match = savedRows.firstWhere(
          (e) =>
              e.colStep == row.colStep &&
              e.exerciseNumber == rowData.exercise_number,
        );
        
        row.colKg = match.colKg;
        row.colRepMin = match.colRepMin;
        row.colRepMax = match.colRepMax;
        row.isChecked = match.isChecked;
        row.isFailure = match.isFailure;
        row.rowColor = row.isChecked
            ? (row.isFailure
                ? const Color.fromARGB(255, 12, 107, 15)
                : const Color.fromARGB(255, 103, 189, 106))
            : Colors.transparent;
      } catch (e) {
        // ✅ Jeśli nie znajdzie elementu, po prostu pomiń
        print("🔍 Nie znaleziono zapisanego stanu dla row: colStep=${row.colStep}, exerciseNumber=${rowData.exercise_number}");
        // Wartości pozostają niezmienione
      }
    }
  }
}

  void saveWorkoutPlan() async {
  syncPlanWithProvider();
  final currentWorkout = ref.read(currentWorkoutPlanProvider);
  final performedExercises = getPerformedExercises(currentWorkout);

  print("🔍 currentWorkout?.plan?.id: ${currentWorkout?.plan?.id}");
  print("🔍 currentWorkout?.plan?.exercise_table: '${currentWorkout?.plan?.exercise_table}'");
  
  String imageBase64 = '';
  if (_selectedImage != null) {
    final bytes = await _selectedImage!.readAsBytes();
    imageBase64 = base64Encode(bytes);
  }
  
  final completedExercises = performedExercises.map((ex) {
    final exerciseId = ex.id;
    return CompletedExercise(
      exerciseId: exerciseId,
      notes: ex.notes,
      sets: ex.sets.asMap().entries.map((entry) {
        final set = entry.value;
        print('SAVE: set.step=${set.step}, isFailure=${set.isFailure}');
        return CompletedSet(
          colStep: set.step, 
          actualKg: set.kg,
          actualReps: set.colRepMin,
          weightType: WeightType.kg,
          completed: set.isChecked,
          toFailure: set.isFailure,
        );
      }).toList(),
    );
  }).toList();

  final exerciseTableName = currentWorkout?.plan?.exercise_table ?? '';
  print("🔍 exerciseTableName: '$exerciseTableName'");
  
  final finalExerciseTableName = exerciseTableName.isEmpty 
      ? 'Workout Session' 
      : exerciseTableName;

  print("🔍 finalExerciseTableName: '$finalExerciseTableName'");

  final trainingSession = TrainingSession(
    exerciseTableId: currentWorkout?.plan?.id ?? 0,
    exercise_table_name: finalExerciseTableName,
    startedAt: DateTime(
      yearSelected,
      monthSelected,
      daySelected,
      hourFrom,
      minuteFrom,
    ),
    duration: allTime,
    completed: true,
    totalWeight: allWeight,
    description: descriptionController.text,
    imageBase64: imageBase64,
    exercises: completedExercises, 
  );
  
  final json = trainingSession.toJson();
  print('🔍 Wysyłam JSON: ${jsonEncode(json)}');
  print('🔍 exercise_table_name w JSON: "${json['exercise_table_name']}"');

  final TrainingSessionService _trainingService = TrainingSessionService();

  try {
     //final success = await ApiService.saveCompletedWorkout(workoutData);
    final status = await _trainingService.saveTrainingSession(trainingSession);
    
    if (status == 200 || status == 201) {
      ref.read(trainingSessionAsyncProvider.notifier).addSession(trainingSession);

      //  ZAMIEŃ SNACKBAR NA TOAST
      if (mounted) {
        ToastUtils.showSaveSuccess(
          context,
          itemName: 'Workout'
        );
      }
      
      //  ZAKOŃCZ TRENING I PRZEJDŹ DO PLANÓW
     // await _endWorkoutAndNavigateToPlans();
       await _endWorkoutAfterSave();
      
    } else {
      // ZAMIEŃ SNACKBAR NA TOAST ERROR
      if (mounted) {
        ToastUtils.showErrorToast(
          context: context,
          title: "Save Failed",
          message: "Failed to save workout. Please try again.",
        );
      }
    }
  } catch (e) {
    // ZAMIEŃ SNACKBAR NA TOAST ERROR
    if (mounted) {
      ToastUtils.showErrorToast(
        context: context,
        title: "Save Failed",
        message: "Error saving workout: $e",
      );
    }
  }
}

Future<void> _endWorkoutAfterSave() async {
  try {
    print("🔚 Kończenie treningu po zapisie...");
    
    //  ZAKOŃCZ TRENING GLOBALNIE (z workout_utils.dart)
    await endWorkoutGlobal(context: context, ref: ref,showConfirmationDialog: false);
    
    //  WYWOŁAJ CALLBACK KOŃCA TRENINGU (JEŚLI ISTNIEJE)
    if (widget.onEndWorkout != null) {
      widget.onEndWorkout!();
    }
    
    print("✅ Trening zakończony po zapisie");
    
    //  PRZEJDŹ DO EKRANU PLANÓW (TAB INDEX 2)
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => TabsScreen(selectedPageIndex: 2), // INDEX 2 = PLANY
        ),
        (route) => false, //  USUŃ WSZYSTKIE POPRZEDNIE ROUTE
      );
    }
   
  } catch (e) {
    print("❌ Błąd podczas kończenia treningu: $e");
    
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }
}

  @override
  Widget build(BuildContext context) {
    Widget imageContent = TextButton.icon(
      onPressed: () {
        _tahePicture();
      },
      icon: Icon(
        Icons.add_a_photo,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      label: Text(
        'Add Image',
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
    return KeyboardDismisser(
      child: Scaffold(
        appBar: AppBar(
          actions: [
  
            SizedBox(width: 3),
      
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 98, 204, 107),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () => saveWorkoutPlan(),
      
              child: Text(
                'Save',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            SizedBox(width: 4),
          ],
          centerTitle: true,
          title: Text(
            'Zapisz trening',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          ),
          backgroundColor: Theme.of(context).colorScheme.surface,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: SizedBox(
               height: MediaQuery.of(context).size.height - 
                 MediaQuery.of(context).padding.top - 
                 kToolbarHeight - 
                 32, // 16 padding top + 16 padding bottom
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                   // mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SaveWorkoutHeader(
                        controller: TitleController,
                        hourFrom: hourFrom,
                        minuteFrom: minuteFrom,
                        onDateTap: _showDataPickerSheet,
                        onTimeTap: _showTimeIntervalPickerSheet,
                      ),
                      CustomDivider(
                        dashWidth: 12,
                        dashSpace: 4,
                        indent: 5,
                        endIndent: 5,
                        color: Colors.black,
                      ),
                      SaveWorkoutStatsRow(
                        hoursSelected: hoursSelected,
                        minutesSelected: minutesSelected,
                        weightSelected: weightSelected,
                        allReps: allReps,
                        showTimePickerSheet: _showTimePickerSheet,
                        showWeightInfoSheet: _showWeightInfoSheet,
                        showBodyPartExercisePickerSheet:
                            _showBodyPartExercisePickerSheet,
                        showBodyPartRepsPickerSheet: _showBodyPartRepsPickerSheet,
                        showRepsInfoSheet: _showRepsInfoSheet,
                      ),
                      CustomDivider(
                        dashWidth: 12,
                        dashSpace: 4,
                        indent: 5,
                        endIndent: 5,
                        color: Colors.black,
                      ),
                     
                      Expanded(
                        child: SaveWorkoutImageAndDescription(
                          selectedImage: _selectedImage,
                          onImagePick: _tahePicture,
                          descriptionController: descriptionController,
                        ),
                      ),
                      CustomDivider(
                        dashWidth: 12,
                        dashSpace: 4,
                        indent: 5,
                        endIndent: 5,
                        color: Colors.black,
                      ),
                      SaveWorkoutActionButtons(
                        onWorkoutList: _showWrokoutListPickerSheet,
                        
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}