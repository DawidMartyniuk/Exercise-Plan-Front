import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:work_plan_front/widget/plan/widget/custom_divider.dart';

class ExerciseCreate extends StatefulWidget {
  const ExerciseCreate({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ExerciseCreateState();
  }
}

class _ExerciseCreateState extends State<ExerciseCreate> {
  File? _exerciseImage;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _nameExerciseController = TextEditingController();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 512,
      maxWidth: 512,
      imageQuality: 80,
    );
    if (image != null) {
      setState(() {
        _exerciseImage = File(image.path);
      });
    }
  }
   String selectedBodyPart(){
    String bodyPart =  "Chest";
    return bodyPart;
   }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text('Create Exercise'),
        actions: [
          TextButton(
            child: Text(
              'Save',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: 16,
              ),
            ),
            onPressed: () {
              // TODO: Implement save functionality
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 32),
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 3,
                ),
              ),
              child: CircleAvatar(
                radius: 56,
                backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
                backgroundImage:
                    _exerciseImage != null ? FileImage(_exerciseImage!) : null,
                child:
                    _exerciseImage == null
                        ? Icon(
                          Icons.camera_alt,
                          size: 40,
                          color: Theme.of(context).colorScheme.primary,
                        )
                        : null,
              ),
            ),
          ),
          const SizedBox(height: 30),
          Padding(
            padding: EdgeInsets.all(16),
            child: TextFormField(
              controller: _nameExerciseController,
              keyboardType: TextInputType.text,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              decoration: InputDecoration(
              
                hintText:
                    'Exercise Name',
                border: UnderlineInputBorder(
                  borderSide: BorderSide(
                    //color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                labelStyle: TextStyle(
                  //color: Theme.of(context).colorScheme.onSurface,
                ),
                hintStyle: TextStyle(
                  //color: Theme.of(context).colorScheme.onSurface,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          CustomDivider(dashSpace: 0),
          Padding(
             padding: const EdgeInsets.symmetric(horizontal: 26),
            child: Row(
              children: [
                Text("Body Part :"),
                SizedBox(width: 10),
                Text(selectedBodyPart()),
                Icon(Icons.arrow_right),
              ],
            ),
          ),
          CustomDivider(dashSpace: 0),
        ],
      ),
    );
  }
}
