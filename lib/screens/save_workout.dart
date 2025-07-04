import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:work_plan_front/model/exercise.dart';
import 'package:work_plan_front/screens/save_workout/save_wokrout_header.dart';
import 'package:work_plan_front/widget/save_workout/CustomDivider.dart';
import 'package:work_plan_front/widget/save_workout/save_workout_bottom_sheet/body_part_botton_sheet.dart';
import 'package:work_plan_front/widget/save_workout/save_workout_bottom_sheet/data_picker_bottom_sheet.dart';
import 'package:work_plan_front/widget/save_workout/save_workout_bottom_sheet/reps_info_bottom_sheet.dart';
import 'package:work_plan_front/widget/save_workout/save_workout_bottom_sheet/time_interval_picker_bottom_sheet.dart';
import 'package:work_plan_front/widget/save_workout/save_workout_bottom_sheet/time_picker_bottom_sheet.dart';
import 'package:work_plan_front/widget/save_workout/save_workout_bottom_sheet/weight_info_bottom_sheet.dart';

class SaveWorkout extends StatefulWidget {
  final int allTime;
  final int allReps;
  final int allWeight;
  final int startHour;
  final int startMinute;
  final VoidCallback? onEndWorkout;
  final String planName;
 

 const SaveWorkout ({
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

class _SaveWorkoutState extends State<SaveWorkout> {
  File? _selectedImage;

  int get allTime => widget.allTime;
  int get allReps => widget.allReps;
  int get allWeight => widget.allWeight;
  
  int minutesSelected = 0;
  int hoursSelected = 0;
  int secondsSelected = 0;
  int weightSelected = 120; 
  int daySelected = DateTime.now().day;
  int monthSelected = DateTime.now().month;
  int yearSelected = DateTime.now().year;
  int hourFrom = 0;
  int minuteFrom = 0;
  int hourTo = DateTime.now().hour; // Zakładamy, że trening trwa co najmniej godzinę
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
    TitleController = TextEditingController(text: widget.planName); // <-- inicjalizacja z planName
    secondsSelected = allTime % 60;
    minutesSelected = (allTime ~/ 60) % 60;
    hoursSelected = allTime ~/ 3600;
    weightSelected = allWeight;

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
    final pickedImage =
        await imagePicker.pickImage(source: ImageSource.gallery, maxWidth: 600);
    
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
    builder: (context) => TimePickerBottomSheet(
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
  showDialog(context: context, builder: 
  (context) => WeightInfoBottomSheet(
  ));
}
void _showBodyPartExercisePickerSheet() {
  showModalBottomSheet(
    context: context,
    builder: (context) => BodyPartInfoBottomSheet(    
      title: 'Body Part count exercises',
      exercisesCount: {BodyPart.chest : 2}, 
      // tutaj możesz przekazać mapę z liczbą ćwiczeń dla każdej partii,
      // np. {BodyPart.chest: 2}
    ),
  );
}
void _showBodyPartRepsPickerSheet() {
  showModalBottomSheet(
    context: context,
    builder: (context) => BodyPartInfoBottomSheet(    
      title: 'Body Part count reps',
      exercisesCount: {BodyPart.chest : 6}, 
      // tutaj możesz przekazać mapę z liczbą ćwiczeń dla każdej partii,
      // np. {BodyPart.chest: 2}
    ),
  );
}
void _showRepsInfoSheet() {
  showDialog(
    context: context,
    builder: (context) => RepsInfoBottomSheet(),
  );
}
void _showDataPickerSheet(){
  showModalBottomSheet(
    context: context,
    builder:(context) => DataPickerBottomSheet(
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
    builder: (context) => TimeIntervalPickerBottomSheet(
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

  @override
  Widget build(BuildContext context) {
    Widget imageContent = TextButton.icon(
      onPressed: () {
          _tahePicture();
      },
      icon: Icon(Icons.add_a_photo, color: Theme.of(context).colorScheme.onSurface),
       label: Text(
        'Add Image',
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
        ),
    ),
    );
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon:Icon(Icons.settings),
            onPressed: (){

            }, 
            ),
           SizedBox(width: 3),
       
          ElevatedButton(
              child: Text(
                'Save',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Trening zapisany!')));
                Navigator.pop(context);
              },
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
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40),
            ),
            child: 
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min, // <-- to jest ważne!
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              SaveWorkoutHeader(
              controller: TitleController,
              hourFrom: hourFrom,
              minuteFrom: minuteFrom,
              onDateTap: _showDataPickerSheet,
              onTimeTap: _showTimeIntervalPickerSheet
            ),
                CustomDivider(dashWidth: 12, dashSpace: 4, indent: 5, endIndent: 5, color: Colors.black),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [

                  Expanded(
                    child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                      icon: Icon(
                        Icons.timer_sharp,
                        size: 50,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      onPressed: () {},
                      ),
                      SizedBox(height: 10),
                      GestureDetector(
                      onTap: 
                       _showTimePickerSheet,
                      child: Text(
                        ' ${hoursSelected} h ${minutesSelected} min',
                        style: Theme.of(
                        context,
                        ).textTheme.bodyLarge!.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      ),
                    ],
                    ),
                  ),
                  // Kolumna 2: ciężar
                  Expanded(
                    child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap:_showBodyPartExercisePickerSheet,
                        child: Icon(
                        Icons.fitness_center,
                        size: 50,
                        color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 10),
                      GestureDetector(
                      onTap: _showWeightInfoSheet,
                      child: Text(
                        '${weightSelected} kg',
                        style: Theme.of(
                        context,
                        ).textTheme.bodyLarge!.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      ),
                    ],
                    ),
                  ),
                  // Kolumna 3: powtórzenia
                  Expanded(
                    child: Column(
                    mainAxisSize: MainAxisSize.min,
                    //_showBodyPartRepsPickerSheet
                    children: [
                      GestureDetector(
                        onTap: _showBodyPartRepsPickerSheet,
                        child: Icon(
                        Icons.repeat,
                        size: 50,
                        color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 10),
                      GestureDetector(
                      onTap: _showRepsInfoSheet,
                      child: Text(
                        '${allReps} ',
                        style: Theme.of(
                        context,
                        ).textTheme.bodyLarge!.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      ),
                    ],
                    ),
                  ),
                  ],
                ),
                CustomDivider(dashWidth: 12, dashSpace: 4,indent: 5, endIndent: 5, color: Colors.black),
                Row(  
                  crossAxisAlignment: CrossAxisAlignment.start, // <-- dodane
                  children: [
                    Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 10),
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: const Color.fromARGB(255, 75, 65, 65),
                      ),
                      child: _selectedImage != null
                        ? Image.file(
                          _selectedImage!,
                          fit: BoxFit.cover,
                        )
                        : imageContent,
                    ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column( 
                      crossAxisAlignment: CrossAxisAlignment.start, // <-- dodane
                      children: [
                        Text(
                        'Opis',
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        ),
                        SizedBox(height: 10),
                        TextField(
                          controller: descriptionController,
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.left,
                          maxLines: 5,
                          decoration: InputDecoration(
                            hint: Text("Tutaj możesz dodać szczegóły dotyczące treningu."),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                      ),
                    ),
                ], 
                ),
                CustomDivider(dashWidth: 12, dashSpace: 4, indent: 5, endIndent: 5, color: Colors.black),
               Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          // TODO: Dodaj akcję po kliknięciu całego kontenera (Workout List)
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Theme.of(context).colorScheme.primary.withAlpha(150),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "Workout List",
                                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios_sharp,
                                color: Theme.of(context).colorScheme.onSurface,
                                size: 24,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
               SizedBox(height: 16),
               Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          // TODO: Dodaj akcję po kliknięciu całego kontenera (Discard Workout)
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Theme.of(context).colorScheme.primary.withAlpha(150),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "Discard Workout",
                                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                      color: Colors.red,
                                    ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios_sharp,
                                color: Theme.of(context).colorScheme.onSurface,
                                size: 24,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                  ],
                ),
              ),
            ),
          ),
        ),
      );
    
  }
}
