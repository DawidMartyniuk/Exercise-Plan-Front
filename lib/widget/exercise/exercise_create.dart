import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/model/exercise.dart';
import 'package:work_plan_front/provider/exercise_provider.dart';
import 'package:work_plan_front/services/userExerciseService.dart';
import 'package:work_plan_front/utils/toast_untils.dart';
import 'package:work_plan_front/utils/token_storage.dart' as TokenStorage;
import 'package:work_plan_front/widget/exercise/widget/body_part_grid_item.dart';
import 'package:work_plan_front/widget/exercise/widget/body_prat_items.dart';
import 'package:work_plan_front/widget/exercise/widget/equipment_selected.dart';
import 'package:work_plan_front/widget/exercise/widget/list_item_exercise_create.dart';
import 'package:work_plan_front/widget/exercise/widget/muscle_part_grid_item.dart';
import 'package:work_plan_front/widget/plan/widget/custom_divider.dart';
import 'package:flutter/foundation.dart'; 
class ExerciseCreate extends ConsumerStatefulWidget {
  const ExerciseCreate({super.key});

  @override
  ConsumerState<ExerciseCreate> createState() {
    return _ExerciseCreateState();
  }
}

class _ExerciseCreateState extends ConsumerState<ExerciseCreate> {
  File? _exerciseImage;
  String? _exerciseImageBase64;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _nameExerciseController = TextEditingController();
  BodyPart? _selectedBodyPart;

  TargetMuscles? _selectedTargetMuscle;
  List<TargetMuscles> _selectedSecondaryMuscles = [];
  EquipmentList? _selectedEquipment;
  List<TextEditingController> _instructionControllers = [
    TextEditingController(),
  ];
  bool fieldsNotEmpty() {
    bool nameis = _nameExerciseController.text.isNotEmpty;
    final instructionsAre = _instructionControllers.every(
      (controller) =>
          controller.text.trim().isNotEmpty &&
          controller.text.trim().endsWith('.'),
    );
    bool bodyPartIs = _selectedBodyPart != null;
    bool targetMuscleIs = _selectedTargetMuscle != null;
    bool equipmentIs = _selectedEquipment != null;
    bool selectedSecondaryMusclesIs = _selectedSecondaryMuscles.isNotEmpty;

    return nameis &&
        instructionsAre &&
        bodyPartIs &&
        targetMuscleIs &&
        equipmentIs &&
        selectedSecondaryMusclesIs;
  }

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
    if (kIsWeb) {
      // WEB: wczytaj jako base64
      final bytes = await image.readAsBytes();
      setState(() {
        _exerciseImageBase64 = "data:image/png;base64,${base64Encode(bytes)}";
        _exerciseImage = null;
      });
    } else {
      // MOBILE: wczytaj jako File
      setState(() {
        _exerciseImage = File(image.path);
        _exerciseImageBase64 = null;
      });
    }
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

  void _muscleTargetSelected(TargetMuscles? muscle) {
    setState(() {
      if (_selectedTargetMuscle == muscle) {
        _selectedTargetMuscle = null;
      } else {
        _selectedTargetMuscle = muscle;
      }
    });
    Navigator.of(context).pop();
  }

  void _openSelectedTargetMuscle() {
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder:
          (ctx) =>
              MusclePartGridItem(onMusclePartSelected: _muscleTargetSelected),
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

  Map<String, dynamic> toUserExerciseJson({required int userId}) {
    return {
      "external_id": DateTime.now().millisecondsSinceEpoch.toString(),
      "user_id": userId,
      "name": _nameExerciseController.text.trim(),
      //"gif_url": _exerciseImageBase64 ?? "",
      "target_muscles":
          _selectedTargetMuscle != null ? [_selectedTargetMuscle!.name] : [],
      "body_parts": _selectedBodyPart != null ? [_selectedBodyPart!.name] : [],
      "equipments":
          _selectedEquipment != null ? [_selectedEquipment!.name] : [],
      "secondary_muscles":
          _selectedSecondaryMuscles.map((e) => e.name).toList(),
      "instructions":
          _instructionControllers
              .map((c) => c.text.trim())
              .where((t) => t.isNotEmpty)
              .toList(),
    };
  }

  void saveExercise() async {
  if (!fieldsNotEmpty()) {
    ToastUtils.showValidationError(
      context,
      customMessage: "Uzupełnij poprawnie wszystkie pola.",
    );
    return;
  }
  final userId = await TokenStorage.getUserId();
  final exerciseData = toUserExerciseJson(userId: userId!);
  print(exerciseData);
  try {
    await userExerciseService().addUserExercise(
      exerciseData,
      imageFile: _exerciseImage,
      imageBase64: _exerciseImageBase64, // <-- DODAJ TO!
    );
    if (context.mounted) {
      ref.read(exerciseProvider.notifier).fetchExercises(forceRefresh: true);
    }
    ToastUtils.showSaveSuccess(
      context,
      itemName: _nameExerciseController.text.trim(),
    );
    Navigator.of(context).pop();
 } catch (e, st) {
  print("❌ Błąd podczas zapisu ćwiczenia: $e");
  print(st);
  ToastUtils.showErrorToast(
    context: context,
    title: "Błąd zapisu ćwiczenia",
    message: e.toString(),
  );
}
}

  @override
  Widget build(BuildContext context) {
    List<Widget> _buildInstructionFields() {
      return List.generate(_instructionControllers.length, (index) {
        final text = _instructionControllers[index].text;
        final endsWithDot = text.trim().endsWith(".");

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                fit: FlexFit.tight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _instructionControllers[index],
                      maxLines: null,
                      decoration: InputDecoration(
                        labelText: "Step ${index + 1}: ",
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
                      onChanged: (_) {
                        setState(() {}); // Odświeżenie stanu, jeśli potrzebne
                      },
                    ),
                    if (!endsWithDot && text.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2, left: 8),
                        child: Text(
                          'The instruction must end with a dot.',
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                  ],
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

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
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
                saveExercise();
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
                  child:CircleAvatar(
  radius: 56,
  backgroundColor: Theme.of(context).colorScheme.surface,
  backgroundImage: kIsWeb
      ? (_exerciseImageBase64 != null
          ? MemoryImage(
              base64Decode(
                _exerciseImageBase64!.split(',').last,
              ),
            )
          : null)
      : (_exerciseImage != null
          ? FileImage(_exerciseImage!)
          : (_exerciseImageBase64 != null
              ? MemoryImage(
                  base64Decode(
                    _exerciseImageBase64!.split(',').last,
                  ),
                )
              : null)),
  child: (_exerciseImage == null && _exerciseImageBase64 == null)
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
                openModelaToSelectedParet: _openSelectedTargetMuscle,
                selectedItem:
                    _selectedTargetMuscle?.displayNameTargetMuscle ??
                    'No selected target muscle',
                rowTitle: "Target Muscle :",
              ),
              CustomDivider(dashSpace: 0),
              ListItemExerciseCreate(
                openModelaToSelectedParet: _openSelectSecondaryMuscles,
                selectedItem:
                    _selectedSecondaryMuscles.isEmpty
                        ? 'No secondary muscles'
                        : _selectedSecondaryMuscles
                            .map((e) => e.displayNameTargetMuscle)
                            .join(', '),
                rowTitle: "Secondary Muscles :",
              ),
              CustomDivider(dashSpace: 0),

              ListItemExerciseCreate(
                openModelaToSelectedParet: _openSelectEquipment,
                selectedItem:
                    _selectedEquipment?.name ?? 'No selected equipment',
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
            ],
          ),
        ),
      ),
    );
  }
}

// extension on BuildContext {
//   read(AlwaysAliveRefreshable<ExerciseNotifier> notifier) {}
// }
