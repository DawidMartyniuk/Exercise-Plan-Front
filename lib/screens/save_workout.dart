import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:work_plan_front/widget/save_workout/CustomDivider.dart';
import 'package:work_plan_front/widget/save_workout/time_picker_bottom_sheet.dart';

class SaveWorkout extends StatefulWidget {
 const SaveWorkout ({super.key});

  @override
  _SaveWorkoutState createState() => _SaveWorkoutState();
}

class _SaveWorkoutState extends State<SaveWorkout> {
   File? _selectedImage;
  int minutesSelected = 30;
  int hoursSelected = 1;

  

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
      onTimeSelected: (hour, minute) {
        setState(() {
          hoursSelected = hour;
          minutesSelected = minute;
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
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min, // <-- to jest ważne!
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20, left: 26, right: 26),
                  child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start, // <-- dodane
                  children: [
                    Flexible(
                    child: TextField(
                      controller: TextEditingController(
                      text: 'Tytuł treningu',
                      ),
                      style: Theme.of(
                      context,
                      ).textTheme.headlineLarge!.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.left,
                      decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    ),
                    SizedBox(width: 20),
                    Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Icon(
                      Icons.edit,
                      color: Theme.of(context).colorScheme.onSurface,
                      size: 30,
                    ),
                    ),
                  ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 26),
                  child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    GestureDetector(
                    onTap: () {
                      // TODO: obsługa zmiany daty w przyszłości
                     
                    },
                    child: Text(
                      "${DateTime.now().day.toString().padLeft(2, '0')}.${DateTime.now().month.toString().padLeft(2, '0')}.${DateTime.now().year}",
                      style: Theme.of(
                      context,
                      ).textTheme.bodyLarge!.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                      ),
                    ),
                    ),
                    const SizedBox(width: 32),
                    GestureDetector(
                    onTap: () {
                     
                    },
                    child: Container(
                      child: Text(
                        "16:20 - 17:30",
                        style: Theme.of(
                        context,
                        ).textTheme.bodyLarge!.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ),
                  ],
                  ),
                ),
                CustomDivider(dashWidth: 12, dashSpace: 4, indent: 5, endIndent: 5, color: Colors.black),
                //SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                  // Kolumna 1: czas
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
                      Icon(
                      Icons.fitness_center,
                      size: 50,
                      color: Theme.of(context).colorScheme.onSurface,
                      ),
                      SizedBox(height: 10),
                      GestureDetector(
                      onTap: () {},
                      child: Text(
                        '120 kg',
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
                    children: [
                      Icon(
                      Icons.repeat,
                      size: 50,
                      color: Theme.of(context).colorScheme.onSurface,
                      ),
                      SizedBox(height: 10),
                      GestureDetector(
                      onTap: () {},
                      child: Text(
                        '12',
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
                          
                          controller: TextEditingController(
                          
                           // text: 'Tutaj możesz dodać szczegóły dotyczące treningu.',
                          ),
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
