import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/model/reps_type.dart';
import 'package:work_plan_front/provider/reps_type_provider.dart';
import 'package:work_plan_front/features/plan_creation/widgets/reps_field.dart';
import 'package:work_plan_front/shared/widget/plan/reps_selected.dart';
import 'package:work_plan_front/shared/widget/plan/weight_selected.dart';
import 'package:work_plan_front/provider/weight_type_provider.dart';
import 'package:work_plan_front/model/weight_type.dart';

class BuildSetsTable extends ConsumerStatefulWidget {
  final String exerciseId;
  final String exerciseName;
  final List<Map<String, String>> rows;
  final Map<String, List<TextEditingController>>? kgControllers;
  final Map<String, List<TextEditingController>>? repMinControllers;
  final Map<String, List<TextEditingController>>? repMaxControllers;
  final String repsType;
  final Function(String exerciseId, int setIndex, String field, dynamic value)?
  onUpdateRowValue;

  const BuildSetsTable({
    super.key,
    required this.exerciseId,
    required this.exerciseName,
    required this.rows,
    required this.repsType,
    this.kgControllers,
    this.repMinControllers,
    this.repMaxControllers,
    this.onUpdateRowValue,
  });

  @override
  ConsumerState<BuildSetsTable> createState() => _BuildSetsTableState();
}

class _BuildSetsTableState extends ConsumerState<BuildSetsTable> {
  void _showWeightBottomSheet(BuildContext context) {
    // POBIERZ AKTUALNĄ JEDNOSTKĘ DLA TEGO ĆWICZENIA
    final oldWeightType = ref.read(
      exerciseWeightTypeProvider(widget.exerciseId),
    );

    showModalBottomSheet<WeightType>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).size.height * 0.4,
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      // PRZEKAŻ EXERCISE ID I NAZWĘ
      builder:
          (context) => WeightSelected(
            exerciseId: widget.exerciseId,
            exerciseName: widget.exerciseName,
          ),
    ).then((selectedWeightType) {
      if (selectedWeightType != null && selectedWeightType != oldWeightType) {
        print(
          "Converting weights for ${widget.exerciseName} from $oldWeightType to $selectedWeightType",
        );
        _convertWeightValues(selectedWeightType, oldWeightType);
      }
    });
  }

  void _showRepsBottomSheet(BuildContext context) {
    // POBIERZ AKTUALNY RODZAJ POWTÓRZEŃ DLA TEGO ĆWICZENIA
    final oldRepsType = ref.read(exerciseRepsTypeProvider(widget.exerciseId));

    showModalBottomSheet<RepsType>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).size.height * 0.4,
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      builder:
          (context) => RepsSelected(
            exerciseId: widget.exerciseId,
            exerciseName: widget.exerciseName,
          ),
    ).then((selectedRepsType) {
      if (selectedRepsType != null && selectedRepsType != oldRepsType) {
        print(
          "Reps type changed for ${widget.exerciseName} from $oldRepsType to $selectedRepsType",
        );

        // ✅ SETSTATE WYWOŁUJE PRZEBUDOWANIE WIDGETU
        setState(() {
          _covertRepsValues(selectedRepsType, oldRepsType);
        });

        // ✅ AKTUALIZUJ DANE W PARENT WIDGET
        if (widget.onUpdateRowValue != null) {
          for (int i = 0; i < widget.rows.length; i++) {
            widget.onUpdateRowValue!(
              widget.exerciseId,
              i,
              "repsType",
              selectedRepsType.toDbString(),
            );
          }
        }
      }
    });
  }

  // KONWERSJA WARTOŚCI DLA TEGO KONKRETNEGO ĆWICZENIA
  void _convertWeightValues(
    WeightType newWeightType,
    WeightType oldWeightType,
  ) {
    if (widget.kgControllers?[widget.exerciseId] == null) return;

    print(
      "🔄 Converting weights for exercise ${widget.exerciseId} (${widget.exerciseName}):",
    );
    print("  From: $oldWeightType -> To: $newWeightType");

    for (int i = 0; i < widget.kgControllers![widget.exerciseId]!.length; i++) {
      final controller = widget.kgControllers![widget.exerciseId]![i];
      if (controller.text.isNotEmpty) {
        final currentValue = double.tryParse(controller.text) ?? 0.0;
        if (currentValue > 0) {
          final convertedValue = oldWeightType.convertTo(
            currentValue,
            newWeightType,
          );
          controller.text = convertedValue.toStringAsFixed(1);
          print(
            "    Set ${i + 1}: $currentValue ${oldWeightType.displayName} -> $convertedValue ${newWeightType.displayName}",
          );
        }
      }
    }

    // ✅ WYMUSI PRZEBUDOWANIE WIDGETU Z NOWYMI WARTOŚCIAMI
    setState(() {});
  }

  void _covertRepsValues(RepsType newRepsType, RepsType oldRepsType) {
    if (widget.repMinControllers?[widget.exerciseId] == null ||
        widget.repMaxControllers?[widget.exerciseId] == null) {
      return;
    }

    print(
      "🔄 Converting reps for exercise ${widget.exerciseId} (${widget.exerciseName}):",
    );
    print("  From: $oldRepsType -> To: $newRepsType");

    for (
      int i = 0;
      i < widget.repMinControllers![widget.exerciseId]!.length;
      i++
    ) {
      final repController = widget.repMinControllers![widget.exerciseId]![i];
      final repMaxController = widget.repMaxControllers![widget.exerciseId]![i];

      if (newRepsType == RepsType.range && oldRepsType == RepsType.single) {
        if (repController.text.isNotEmpty) {
          final currentValue = repController.text;
          repMaxController.text = currentValue;
          print(
            "    Set ${i + 1}: $currentValue seconds → $currentValue-$currentValue reps",
          );
        }
      } else if (newRepsType == RepsType.single &&
          oldRepsType == RepsType.range) {
        if (repController.text.isNotEmpty) {
          final miniValue = repController.text;
          repMaxController.text = "";
          print(
            "    Set ${i + 1}: $miniValue-${repMaxController.text} reps → $miniValue seconds",
          );
        }
      }
    }

    // ✅ WYMUSI PRZEBUDOWANIE WIDGETU Z NOWYMI WARTOŚCIAMI
    // Nie trzeba wywołać setState() tutaj, bo już jest wywołane w _showRepsBottomSheet
  }

  @override
  Widget build(BuildContext context) {
    // POBIERZ JEDNOSTKĘ WAGI DLA TEGO KONKRETNEGO ĆWICZENIA
    final currentWeightType = ref.watch(
      exerciseWeightTypeProvider(widget.exerciseId),
    );
    // ✅ POBIERZ AKTUALNY TYP POWTÓRZEŃ Z PROVIDERA
    final currentRepsType = ref.watch(
      exerciseRepsTypeProvider(widget.exerciseId),
    );

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Header tabeli
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 40,
                  child: Text(
                    "Set",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      print(
                        "Weight header clicked for exercise: ${widget.exerciseId} (${widget.exerciseName})!",
                      );
                      _showWeightBottomSheet(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 4,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Weight (${currentWeightType.displayName})",
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_drop_down,
                            color: Theme.of(context).colorScheme.primary,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      print("Reps header clicked!");
                      _showRepsBottomSheet(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 4,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Reps",
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_drop_down,
                            color: Theme.of(context).colorScheme.primary,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Wiersze tabeli
          for (int i = 0; i < widget.rows.length; i++)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                border:
                    i > 0
                        ? Border(
                          top: BorderSide(
                            color: Theme.of(
                              context,
                            ).colorScheme.outline.withOpacity(0.2),
                          ),
                        )
                        : null,
              ),
              child: Row(
                children: [
                  // Numer setu
                  SizedBox(
                    width: 40,
                    child: Text(
                      "${i + 1}",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 8),

                  // ✅ POLE WAGI Z PLACEHOLDER JEDNOSTKI DLA TEGO ĆWICZENIA
                  Expanded(
                    child: TextField(
                      controller:
                          (widget.kgControllers?[widget.exerciseId] != null &&
                                  i <
                                      widget
                                          .kgControllers![widget.exerciseId]!
                                          .length)
                              ? widget.kgControllers![widget.exerciseId]![i]
                              : null,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 4,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        isDense: true,
                        hintText: "0 ${currentWeightType.displayName}",
                        hintStyle: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.5),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // ✅ POLE POWTÓRZEŃ - UŻYJ AKTUALNEGO TYPU Z PROVIDERA
                  RepsField(
                    setIndex: i,
                    exerciseId: widget.exerciseId,
                    repControllers: widget.repMinControllers,
                    repMaxControllers: widget.repMaxControllers,
                    repsType:
                        currentRepsType.toDbString(), // ✅ UŻYJ AKTUALNEGO TYPU
                    ref: ref,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
