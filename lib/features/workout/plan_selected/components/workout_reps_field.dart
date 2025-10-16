import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/model/exercise_plan.dart';
import 'package:work_plan_front/model/reps_type.dart';
import 'package:work_plan_front/provider/reps_type_provider.dart';

class WorkoutRepsField extends ConsumerStatefulWidget {
  final ExerciseRow row;
  final String exerciseNumber;
  final Function(String) onRepChanged;
  final String Function(String, int) getOriginalRange;
  final bool isReadOnly;

  const WorkoutRepsField({
    super.key,
    required this.row,
    required this.exerciseNumber,
    required this.onRepChanged,
    required this.getOriginalRange,
    this.isReadOnly = false,
  });

  @override
  ConsumerState<WorkoutRepsField> createState() => _WorkoutRepsFieldState();
}

class _WorkoutRepsFieldState extends ConsumerState<WorkoutRepsField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    final repsType = ref.read(exerciseRepsTypeProvider(widget.exerciseNumber));
    
    String initialValue = "";
    
    if (repsType == RepsType.range) {
      // ✅ DLA RANGE - POKAŻ WARTOŚĆ TYLKO JEŚLI UŻYTKOWNIK WPROWADZIŁ
      if (widget.row.isUserModified && widget.row.colRepMin > 0) {
        initialValue = widget.row.colRepMin.toString();
      } else if (widget.row.isChecked && widget.row.colRepMin > 0) {
        // ✅ ZAZNACZONE ALE BRAK MODYFIKACJI - POKAŻ ŚREDNIĄ
        initialValue = widget.row.colRepMin.toString();
      }
      // ✅ W PRZECIWNYM RAZIE ZOSTAW PUSTE - HINT POKAŻE ZAKRES
    } else {
      // ✅ SINGLE/SECONDS
      initialValue = widget.row.colRepMin > 0 ? widget.row.colRepMin.toString() : "";
    }
    
    _controller = TextEditingController(text: initialValue);
    //print("🔍 WorkoutRepsField init: '$initialValue', isUserModified=${widget.row.isUserModified}");
  }

  @override
  void didUpdateWidget(WorkoutRepsField oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    final repsType = ref.read(exerciseRepsTypeProvider(widget.exerciseNumber));
    String newValue = "";
    
    if (repsType == RepsType.range) {
      if (widget.row.isUserModified && widget.row.colRepMin > 0) {
        newValue = widget.row.colRepMin.toString();
      } else if (widget.row.isChecked && widget.row.colRepMin > 0) {
        newValue = widget.row.colRepMin.toString();
      }
    } else {
      newValue = widget.row.colRepMin > 0 ? widget.row.colRepMin.toString() : "";
    }
    
    if (newValue != _controller.text) {
      _controller.text = newValue;
    //  print("🔍 WorkoutRepsField update: '$newValue'");
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repsType = ref.watch(exerciseRepsTypeProvider(widget.exerciseNumber));
    
    String hintText = "";
    
    if (repsType == RepsType.range) {
      //  DLA RANGE - POKAŻ PRZEDZIAŁ W HINT JEŚLI POLE PUSTE
      if (_controller.text.isEmpty) {
        hintText = widget.getOriginalRange(widget.exerciseNumber, widget.row.colStep);
      }
    } else if (repsType == RepsType.single) {
      hintText = "0 reps";
    } else {
      hintText = "0";
    }

   // print("🔍 WorkoutRepsField build: controller='${_controller.text}', hint='$hintText', repsType=$repsType");

    // ✅ READ ONLY MODE
    if (widget.isReadOnly) {
      String displayText = _controller.text.isNotEmpty ? _controller.text : hintText;
      
      return Container(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          displayText,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }
    
    // ✅ EDITABLE MODE
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          border: InputBorder.none,
          hintStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            fontSize: 12,
          ),
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: (value) {
          print("🔍 Reps changed: '$value'");
          widget.onRepChanged(value);
        },
        // ✅ ZAZNACZ CAŁY TEKST PRZY KLIKNIĘCIU
        onTap: () {
          if (_controller.text.isNotEmpty) {
            _controller.selection = TextSelection(
              baseOffset: 0,
              extentOffset: _controller.text.length,
            );
          }
        },
      ),
    );
  }
}