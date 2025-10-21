import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
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
  double _sliderValue = 0;
  bool _isSliderMode = false;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _initializeController() {
    final repsType = ref.read(exerciseRepsTypeProvider(widget.exerciseNumber));

    String initialValue = "";

    if (repsType == RepsType.range) {
      if (widget.row.isUserModified && widget.row.colRepMin > 0) {
        initialValue = widget.row.colRepMin.toString();
      } else if (widget.row.isChecked && widget.row.colRepMin > 0) {
        initialValue = widget.row.colRepMin.toString();
      }
    } else {
      initialValue =
          widget.row.colRepMin > 0 ? widget.row.colRepMin.toString() : "";
    }

    _controller = TextEditingController(text: initialValue);
    _sliderValue = widget.row.colRepMin.toDouble();
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
      newValue =
          widget.row.colRepMin > 0 ? widget.row.colRepMin.toString() : "";
    }

    if (newValue != _controller.text) {
      _controller.text = newValue;
      _sliderValue = widget.row.colRepMin.toDouble();
    }
  }

  //aktualizacja z suwaka
  void _updateFromSlider(double value) {
    final intValue = value.round();
    setState(() {
      _sliderValue = value;
      _controller.text = intValue.toString();
    });
    widget.onRepChanged(intValue.toString());
  }

  // pzyciski
  void _incrementReps() {
    int incrementRepsValue = 1;
    final currentValue = int.tryParse(_controller.text) ?? 0;
    final newValue = (currentValue + incrementRepsValue).clamp(1, 100);
    setState(() {
      _controller.text = newValue.toString();
      _sliderValue = newValue.toDouble();
    });
    widget.onRepChanged(_controller.text);
  }

  void _decrementReps() {
    int incrementRepsValue = 1;
    final currentValue = int.tryParse(_controller.text) ?? 0;
    final newValue = (currentValue - incrementRepsValue).clamp(1, 100);
    setState(() {
      _controller.text = newValue.toString();
      _sliderValue = newValue.toDouble();
    });
    widget.onRepChanged(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final repsType = ref.watch(exerciseRepsTypeProvider(widget.exerciseNumber));

    String hintText = "";
    if (repsType == RepsType.range) {
      if (_controller.text.isEmpty) {
        hintText = widget.getOriginalRange(
          widget.exerciseNumber,
          widget.row.colStep,
        );
      }
    } else if (repsType == RepsType.single) {
      hintText = "0 reps";
    } else {
      hintText = "0";
    }

    // ✅ READ ONLY MODE - ZWIĘKSZ FONT
    if (widget.isReadOnly) {
      String displayText =
          _controller.text.isNotEmpty ? _controller.text : hintText;

      return Container(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          displayText,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 14, // ✅ ZWIĘKSZ FONT
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(6.0), // ✅ ZWIĘKSZ Z 4 NA 6
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ✅ PRZEŁĄCZNIK TRYBU - ZWIĘKSZ ROZMIARY
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => setState(() => _isSliderMode = !_isSliderMode),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10, // ✅ ZWIĘKSZ Z 8 NA 10
                    vertical: 3, // ✅ ZWIĘKSZ Z 2 NA 3
                  ),
                  decoration: BoxDecoration(
                    color:
                        _isSliderMode
                            ? Theme.of(
                              context,
                            ).colorScheme.primary.withAlpha((0.2 * 255).round())
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isSliderMode ? Icons.tune : Icons.edit,
                        size: 14, 
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        _isSliderMode ? "Slider" : "Manual",
                        style: TextStyle(
                          fontSize: 11, // ✅ ZWIĘKSZ Z 10 NA 11
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6), // ✅ ZWIĘKSZ Z 4 NA 6

          if (_isSliderMode) ...[
            // ✅ PRZYCISKI +/- - ZWIĘKSZ ROZMIARY
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: _decrementReps,
                  child: Container(
                    width: 28, // ✅ ZWIĘKSZ Z 24 NA 28
                    height: 28, // ✅ ZWIĘKSZ Z 24 NA 28
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.error.withAlpha((0.1 * 255).round()),
                      borderRadius: BorderRadius.circular(
                        14,
                      ), // ✅ DOPASUJ DO NOWEGO ROZMIARU
                    ),
                    child: Icon(
                      Icons.remove,
                      size: 18, // ✅ ZWIĘKSZ Z 16 NA 18
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),

                // ✅ WARTOŚĆ W ŚRODKU - ZWIĘKSZ ROZMIARY
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6, 
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withAlpha((0.1 * 255).round()),
                    borderRadius: BorderRadius.circular(
                      10,
                    ), // ✅ ZWIĘKSZ Z 8 NA 10
                  ),
                  child: Text(
                    _controller.text.isEmpty ? "0" : _controller.text,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 14, // ✅ ZWIĘKSZ Z 12 NA 14
                    ),
                  ),
                ),

                GestureDetector(
                  onTap: _incrementReps,
                  child: Container(
                    width: 28, 
                    height: 28, 
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withAlpha((0.1 * 255).round()),
                      borderRadius: BorderRadius.circular(
                        14,
                      ), // ✅ DOPASUJ DO NOWEGO ROZMIARU
                    ),
                    child: Icon(
                      Icons.add,
                      size: 18, 
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6), // ✅ ZWIĘKSZ Z 4 NA 6
            // ✅ SLIDER - ZWIĘKSZ ROZMIARY
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 5, // ✅ ZWIĘKSZ Z 4 NA 5
                thumbShape: const RoundSliderThumbShape(
                  enabledThumbRadius: 10, // ✅ ZWIĘKSZ Z 8 NA 10
                ),
                overlayShape: const RoundSliderOverlayShape(
                  overlayRadius: 15, // ✅ ZWIĘKSZ Z 12 NA 15
                ),
                activeTrackColor: Theme.of(context).colorScheme.primary,
                inactiveTrackColor: Theme.of(
                  context,
                ).colorScheme.outline.withOpacity(0.3),
                thumbColor: Theme.of(context).colorScheme.primary,
              ),
              child: Slider(
                value: _sliderValue.clamp(1, 50),
                min: 1,
                max: 50,
                divisions: 49,
                onChanged: _updateFromSlider,
              ),
            ),
          ] else ...[
            // ✅ MANUAL MODE - ZWIĘKSZ FONT
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 20, // ✅ ZWIĘKSZ Z 12 NA 14
                fontWeight: FontWeight.w500, // ✅ DODAJ WAGI CZCIONKI
              ),
              decoration: InputDecoration(
                hintText: hintText,
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                  fontSize: 20, 
                ),
              ),
              onChanged: (value) {
                final intValue = int.tryParse(value) ?? 0;
                setState(() {
                  _sliderValue = intValue.toDouble();
                });
                widget.onRepChanged(value);
              },
              onTap: () {
                if (_controller.text.isNotEmpty) {
                  _controller.selection = TextSelection(
                    baseOffset: 0,
                    extentOffset: _controller.text.length,
                  );
                }
              },
            ),
          ],
        ],
      ),
    );
  }
}
