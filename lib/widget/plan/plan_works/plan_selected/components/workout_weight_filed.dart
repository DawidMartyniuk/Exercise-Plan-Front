import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/model/exercise_plan.dart';
import 'package:work_plan_front/provider/weight_type_provider.dart';

class WorkoutWeightField extends StatefulWidget {
  final ExerciseRow row;
  final String exerciseNumber;
  final Function(String) onWeightChanged;
  final bool isReadOnly;

  const WorkoutWeightField({
    super.key,
    required this.row,
    required this.exerciseNumber,
    required this.onWeightChanged,
    this.isReadOnly = false,
  });

  @override
  State<WorkoutWeightField> createState() => _WorkoutWeightFieldState();
}

class _WorkoutWeightFieldState extends State<WorkoutWeightField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  String _lastKnownValue = "";

  @override
  void initState() {
    super.initState();
    _lastKnownValue = widget.row.colKg > 0 ? widget.row.colKg.toString() : "";
    _controller = TextEditingController(text: _lastKnownValue);
    _focusNode = FocusNode();
    
    print("🏋️ WorkoutWeightField initState: initialValue='$_lastKnownValue'");
  }

  @override
  void didUpdateWidget(WorkoutWeightField oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // ✅ AKTUALIZUJ KONTROLER TYLKO JEŚLI WARTOŚĆ ZMIENIŁA SIĘ ZEWNĘTRZNIE
    final newValue = widget.row.colKg > 0 ? widget.row.colKg.toString() : "";
    
    // ✅ SPRAWDŹ CZY TO ZEWNĘTRZNA ZMIANA (NIE OD UŻYTKOWNIKA)
    if (newValue != _lastKnownValue && newValue != _controller.text) {
      print("🏋️ External update detected: '$_lastKnownValue' -> '$newValue'");
      _lastKnownValue = newValue;
      
      // ✅ ZACHOWAJ POZYCJĘ KURSORA JEŚLI TO MOŻLIWE
      final selection = _controller.selection;
      _controller.text = newValue;
      
      if (selection.isValid && selection.start <= newValue.length) {
        _controller.selection = selection;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String hintText = "0 kg";
    
    print("🏋️ WorkoutWeightField build: controller.text='${_controller.text}', colKg=${widget.row.colKg}");

    if (widget.isReadOnly) {
      return Container(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          _controller.text.isNotEmpty ? "${_controller.text} kg" : "0 kg",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }
    
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _controller, // ✅ TRWAŁY KONTROLER
        focusNode: _focusNode,    // ✅ TRWAŁY FOCUS NODE
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          border: InputBorder.none,
          hintStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: (value) {
          _lastKnownValue = value; // ✅ ŚLEDŹ ZMIANY
          print("🏋️ Weight changed to: '$value' (backspace/delete working!)");
          widget.onWeightChanged(value);
        },
        // ✅ OBSŁUŻ TAP - ZAZNACZ CAŁY TEKST
        onTap: () {
          if (_controller.text.isNotEmpty) {
            _controller.selection = TextSelection(
              baseOffset: 0, 
              extentOffset: _controller.text.length,
            );
            print("🏋️ Text selected: '${_controller.text}'");
          }
        },
      ),
    );
  }
}