import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:work_plan_front/model/exercise.dart';
import 'package:work_plan_front/widget/exercise/widget/body_part_grid_item.dart';
import 'package:work_plan_front/widget/exercise/widget/body_prat_items.dart';
import 'package:work_plan_front/widget/exercise/widget/equipment_selected.dart';
import 'package:work_plan_front/widget/exercise/widget/list_item_exercise_create.dart';
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
  BodyPart? _selectedBodyPart;
  List<BodyPart> _selectedSecondaryMuscles = [];
  EquipmentList? _selectedEquipment;
  List<TextEditingController> _instructionControllers = [
    TextEditingController(),
  ];

  @override
  void initState() {
    super.initState();
    _instructionControllers = [TextEditingController()];
  }

  @override
  void dispose() {
    //  // ...existing dispose logic...
    for (final c in _instructionControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addInstructionField() {
    setState(() {
      _instructionControllers.add(TextEditingController());
    });
  }

  void _removeInstructionField(int index) {
    setState(() {
      if (_instructionControllers.length > 1) {
        _instructionControllers[index].dispose();
        _instructionControllers.removeAt(index);
      }
    });
  }

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

  String selectedBodyPart() {
    String bodyPart = "Chest";
    return bodyPart;
  }

  void _bodyPartSelected(BodyPart? bodyPart) {
    setState(() {
      if (_selectedBodyPart == bodyPart) {
        _selectedBodyPart = null;
      } else {
        _selectedBodyPart = bodyPart;
      }
    });
    Navigator.of(context).pop();
  }

  void _openSelectBodyPart() {
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (ctx) => BodyPartSelected(onBodyPartSelected: _bodyPartSelected),
    );
  }

  void _openSelectSecondaryMuscles() {
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder:
          (ctx) => SecondaryMusclesSelector(
            selectedMuscles: _selectedSecondaryMuscles,
            onSelectionChanged: (selected) {
              setState(() {
                _selectedSecondaryMuscles = selected;
              });
            },
          ),
    );
  }

  void _openSelectEquipment() {
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder:
          (ctx) => EquipmentSelected(
            selectedEquipment: _selectedEquipment,
            onEquipmentSelected: (equipment) {
              setState(() {
                _selectedEquipment = equipment;
              });
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _buildInstructionFields() {
      return List.generate(_instructionControllers.length, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SizedBox(
              //   width: 60,
              //   child: Text(
              //     "Step ${index + 1}:",
              //     style: Theme.of(context).textTheme.bodyMedium,
              //     overflow: TextOverflow.ellipsis,
              //     maxLines: 1,
              //   ),
              // ),
              // const SizedBox(width: 8),
              Flexible(
                fit: FlexFit.tight,
                child: TextFormField(
                  controller: _instructionControllers[index],
                  maxLines: null,
                  decoration: InputDecoration(
                    labelText: "Step ${index + 1}: ", // <-- label zamiast hint
                    labelStyle: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 18,
                    ),
                    border: UnderlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: Icon(Icons.delete_outline),
                tooltip: "Remove step",
                color: const Color.fromARGB(255, 228, 115, 107),
                onPressed:
                    _instructionControllers.length > 1
                        ? () => _removeInstructionField(index)
                        : null,
              ),
            ],
          ),
        );
      });
    }

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
      body: SingleChildScrollView(
        child: Column(
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
                  backgroundColor:
                      Theme.of(context).colorScheme.surfaceContainer,
                  backgroundImage:
                      _exerciseImage != null
                          ? FileImage(_exerciseImage!)
                          : null,
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
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: 'Exercise Name',
                  border: UnderlineInputBorder(borderSide: BorderSide()),
                  labelStyle: TextStyle(),
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 20),
            CustomDivider(dashSpace: 0),
            ListItemExerciseCreate(
              openModelaToSelectedParet: _openSelectBodyPart,
              selectedItem:
                  _selectedBodyPart?.displayNameBodyPart() ??
                  'No selected body part',
              rowTitle: "Body Part :",
            ),
            CustomDivider(dashSpace: 0),
            ListItemExerciseCreate(
              openModelaToSelectedParet: _openSelectSecondaryMuscles,
              selectedItem:
                  _selectedSecondaryMuscles.isEmpty
                      ? 'No secondary muscles'
                      : _selectedSecondaryMuscles
                          .map((e) => e.displayNameBodyPart())
                          .join(', '),
              rowTitle: "Secondary Muscles :",
            ),
            CustomDivider(dashSpace: 0),
            ListItemExerciseCreate(
              openModelaToSelectedParet: _openSelectEquipment,
              selectedItem: _selectedEquipment?.name ?? 'No selected equipment',
              rowTitle: "Equipment :",
            ),
            CustomDivider(dashSpace: 0),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "Instructions :",
                      textAlign: TextAlign.center,

                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add),
                    tooltip: "Add step",
                    onPressed: _addInstructionField,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ),
            ..._buildInstructionFields(),
            //  ListView.builder(
            //   shrinkWrap: true,
            //   physics: NeverScrollableScrollPhysics(),
            //   itemCount: _instructionControllers.length,
            //   itemBuilder: (context, index) {
            //     return Padding(
            //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            //       child: Row(
            //         crossAxisAlignment: CrossAxisAlignment.start,
            //         children: [
            //           Text(
            //             "Step ${index + 1}:",
            //             style: Theme.of(context).textTheme.bodyMedium,
            //           ),
            //           SizedBox(width: 8),
            //           Expanded(
            //             child: TextFormField(
            //               controller: _instructionControllers[index],
            //               maxLines: null,
            //               decoration: InputDecoration(
            //                 hintText: "Describe this step...",
            //                 border: OutlineInputBorder(),
            //               ),
            //             ),
            //           ),
            //           IconButton(
            //             icon: Icon(Icons.delete_outline),
            //             tooltip: "Remove step",
            //             onPressed: _instructionControllers.length > 1
            //                 ? () => _removeInstructionField(index)
            //                 : null,
            //           ),
            //         ],
            //       ),
            //     );
            //   },
            // ),
          ],
        ),
      ),
    );
  }
}
