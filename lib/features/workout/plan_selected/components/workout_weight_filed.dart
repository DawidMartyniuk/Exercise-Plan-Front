import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/features/workout/plan_selected/widget/weight_step_picker.dart';
import 'package:work_plan_front/features/workout/provider/weight_step_provider.dart';
import 'package:work_plan_front/model/exercise_plan.dart'; 
import 'package:work_plan_front/shared/utils/toast_untils.dart';

class WorkoutWeightField extends ConsumerStatefulWidget {
  // ✅ ZMIEŃ NA ConsumerStatefulWidget
  final ExerciseRow row;
  final String exerciseNumber;
  final Function(String) onWeightChanged;
  final bool isReadOnly;
  final String planId;

  const WorkoutWeightField({
    super.key,
    required this.row,
    required this.exerciseNumber,
    required this.onWeightChanged,
    required this.planId,
    this.isReadOnly = false,
  });

  @override
  ConsumerState<WorkoutWeightField> createState() => _WorkoutWeightFieldState();
}

class _WorkoutWeightFieldState extends ConsumerState<WorkoutWeightField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  String _lastKnownValue = "";
  double _sliderValue = 0.0;
  bool? _isSliderMode;
  double _weightStep = 1.0;

  @override
  void initState() {
    super.initState();
    _lastKnownValue = widget.row.colKg > 0 ? widget.row.colKg.toString() : "";
    _controller = TextEditingController(text: _lastKnownValue);
    _focusNode = FocusNode();
    _sliderValue = widget.row.colKg.toDouble();

    // ✅ USTAW KROK NA GLOBALNY JEŚLI ISTNIEJE
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final globalStep = ref.read(globalWeightStepProvider(widget.planId));
      print(
        "🔍 InitState - Global step: $globalStep, Local step: $_weightStep",
      ); // ✅ DEBUG
      if (globalStep != 1.0) {
        setState(() {
          _weightStep = globalStep;
        });
        print("✅ Updated local step to global: $_weightStep"); // ✅ DEBUG
      }
    });
  }
  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(WorkoutWeightField oldWidget) {
    super.didUpdateWidget(oldWidget);

    final newValue = widget.row.colKg > 0 ? widget.row.colKg.toString() : "";

    if (newValue != _lastKnownValue && newValue != _controller.text) {
      _lastKnownValue = newValue;
      _sliderValue = widget.row.colKg.toDouble();

      final selection = _controller.selection;
      _controller.text = newValue;

      if (selection.isValid && selection.start <= newValue.length) {
        _controller.selection = selection;
      }
    }

    // ✅ SPRAWDŹ GLOBALNY KROK I AKTUALIZUJ LOKALNY
    final globalStep = ref.read(globalWeightStepProvider(widget.planId));
    if (_weightStep != globalStep) {
      print(
        "🔄 Global step changed: $globalStep, updating local step from $_weightStep",
      ); // ✅ DEBUG
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _weightStep = globalStep;
          });
          print("✅ Local step updated to: $_weightStep"); // ✅ DEBUG
        }
      });
    }
  }

  void _incrementWeight() {
    print("➕ Increment with step: $_weightStep"); // ✅ DEBUG
    double currentValue = double.tryParse(_controller.text) ?? 0.0;
    double newValue = currentValue + _weightStep;

    setState(() {
      _controller.text = newValue.toStringAsFixed(2);
      _sliderValue = newValue;
    });

    widget.onWeightChanged(_controller.text);
  }

  void _decrementWeight() {
    print("➖ Decrement with step: $_weightStep"); // ✅ DEBUG
    double currentValue = double.tryParse(_controller.text) ?? 0.0;
    double newValue = (currentValue - _weightStep).clamp(0.0, double.infinity);

    setState(() {
      _controller.text = newValue.toStringAsFixed(2);
      _sliderValue = newValue;
    });

    widget.onWeightChanged(_controller.text);
  }

  // ✅ POKAŻ AKTUALNY KROK W INTERFEJSIE
  Widget _buildWeightStepIndicator() {
    return AnimatedOpacity(
      opacity: _weightStep != 1.0 ? 1.0 : 0.5,
      duration: const Duration(milliseconds: 300),
      child: Text(
        "↕${_weightStep}kg",
        style: TextStyle(
          fontSize: 8,
          color:
              _weightStep != 1.0
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const String hintText = "0 kg";
    _isSliderMode ??= false;

    // ✅ OBSERWUJ GLOBALNY KROK I AKTUALIZUJ LOKALNY
    ref.listen<double>(globalWeightStepProvider(widget.planId), (
      previous,
      next,
    ) {
      print("🎯 Global step listener: $previous -> $next"); // ✅ DEBUG
      if (mounted && _weightStep != next) {
        setState(() {
          _weightStep = next;
        });
        print("✅ Local step updated via listener: $_weightStep"); // ✅ DEBUG
      }
    });

    if (widget.isReadOnly) {
      return Container(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          _controller.text.isNotEmpty ? "${_controller.text} kg" : "0 kg",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(6.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ✅ PRZEŁĄCZNIK TRYBU Z INFORMACJĄ O KROKU
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _toggleSliderMode,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color:
                        (_isSliderMode == true)
                            ? Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.2)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        (_isSliderMode == true) ? Icons.tune : Icons.edit,
                        size: 14,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        (_isSliderMode == true) ? "Slider" : "Manual",
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                   
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          if (_isSliderMode == true) ...[
            // ✅ PRZYCISKI +/- - ZWIĘKSZ ROZMIARY
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: _decrementWeight,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.remove,
                      size: 18,
                      color: Colors.red,
                    ),
                  ),
                ),

                // ✅ WARTOŚĆ W ŚRODKU - ZWIĘKSZ ROZMIARY
                GestureDetector(
                  onDoubleTap: _showWeightStepPicker,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12, // ✅ ZWIĘKSZ Z 8 NA 12
                      vertical: 6, // ✅ ZWIĘKSZ Z 4 NA 6
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withAlpha((0.1 * 255).round()),
                      borderRadius: BorderRadius.circular(
                        10,
                      ), // ✅ ZWIĘKSZ Z 8 NA 10
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withAlpha((0.3 * 255).round()),
                        width: 1.5, // ✅ ZWIĘKSZ Z 1 NA 1.5
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _controller.text.isEmpty
                              ? "0 kg"
                              : "${_controller.text} kg",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13, // ✅ ZWIĘKSZ Z 12 NA 14
                          ),
                        ),
                        // ✅ POKAŻ AKTUALNY KROK - ZWIĘKSZ FONT
                       // _buildWeightStepIndicator(),
                      ],
                    ),
                  ),
                ),

                GestureDetector(
                  onTap: _incrementWeight,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
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

            const SizedBox(height: 6),
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
                value: _sliderValue.clamp(0.0, 200.0),
                min: 0.0,
                max: 200.0,
                divisions: (200 / _weightStep).round(),
                label:
                    "${((_sliderValue / _weightStep).round() * _weightStep).toStringAsFixed(2)} kg",
                onChanged: _updateFromSlider,
              ),
            ),
          ] else ...[
            TextField(
              controller: _controller,
              focusNode: _focusNode,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                  fontSize: 12,
                ),
                contentPadding: const EdgeInsets.all(4),
              ),
              onChanged: (value) {
                final doubleValue = double.tryParse(value) ?? 0.0;
                setState(() {
                  _sliderValue = doubleValue;
                });
                _lastKnownValue = value;
                widget.onWeightChanged(value);
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

  // ✅ RESZTA METOD (sprawdź czy masz wszystkie potrzebne metody)
  void _toggleSliderMode() {
    setState(() {
      _isSliderMode = !_isSliderMode!;
    });
  }

  void _updateFromSlider(double value) {
    final steppedValue = (value / _weightStep).round() * _weightStep;
    setState(() {
      _sliderValue = steppedValue;
      _controller.text = steppedValue.toStringAsFixed(2);
    });
    widget.onWeightChanged(_controller.text);
  }

  void _showWeightStepPicker() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    FocusManager.instance.primaryFocus?.unfocus();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: WeightStepPickerBottomSheet(
              currentStep: _weightStep,
              planId: widget.planId,
              onStepSelected: (newStep) {
                print("📝 Setting local step to: $newStep"); // ✅ DEBUG
                setState(() {
                  _weightStep = newStep;
                });

                Future.delayed(const Duration(milliseconds: 100), () {
                  SystemChannels.textInput.invokeMethod('TextInput.hide');
                  FocusManager.instance.primaryFocus?.unfocus();
                });

                ToastUtils.showInfoToast(
                  context: context,
                  message: 'Weight step set to ${newStep}kg for this field',
                );
              },
            ),
          ),
    ).whenComplete(() {
      Future.delayed(const Duration(milliseconds: 200), () {
        SystemChannels.textInput.invokeMethod('TextInput.hide');
        FocusManager.instance.primaryFocus?.unfocus();
      });
    });
  }

  
}
