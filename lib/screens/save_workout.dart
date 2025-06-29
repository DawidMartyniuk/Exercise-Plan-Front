import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:work_plan_front/widget/CustomDivider.dart';

class SaveWorkout extends StatefulWidget {
 const SaveWorkout ({super.key});

  @override
  _SaveWorkoutState createState() => _SaveWorkoutState();
}

class _SaveWorkoutState extends State<SaveWorkout> {
   File? _selectedImage;
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40),
            ),
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
                  padding: const EdgeInsets.only(top: 20, left: 26, right: 26),
                  child: Row(
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
                          // TODO: obsługa zmiany godziny w przyszłości
                        },
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
                            onTap: () {},
                            child: Text(
                              '1 h 10 min',
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
                      Column( children: [

                      ],
                      ),
                ], 
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
