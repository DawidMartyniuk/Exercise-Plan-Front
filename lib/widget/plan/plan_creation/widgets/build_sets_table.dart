import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/widget/plan/widget/reps_selected.dart';
import 'package:work_plan_front/widget/plan/widget/weight_selected.dart';
import 'package:work_plan_front/provider/weight_type_provider.dart';
import 'package:work_plan_front/model/weight_type.dart';

class BuildSetsTable extends ConsumerWidget {
  final String exerciseId;
  final String exerciseName;
  final List<Map<String, String>> rows;
  final Map<String, List<TextEditingController>>? kgControllers;
  final Map<String, List<TextEditingController>>? repControllers;

  const BuildSetsTable({
    Key? key,
    required this.exerciseId,
    required this.exerciseName,
    required this.rows,
    this.kgControllers,
    this.repControllers,
  }) : super(key: key);

  void _showWeightBottomSheet(BuildContext context, WidgetRef ref) {
    // ✅ POBIERZ AKTUALNĄ JEDNOSTKĘ DLA TEGO ĆWICZENIA
    final oldWeightType = ref.read(exerciseWeightTypeProvider(exerciseId));
    
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
      // ✅ PRZEKAŻ EXERCISE ID I NAZWĘ
      builder: (context) => WeightSelected(
        exerciseId: exerciseId,
        exerciseName: exerciseName,
      ),
    ).then((selectedWeightType) {
      if (selectedWeightType != null && selectedWeightType != oldWeightType) {
        print("Converting weights for $exerciseName from $oldWeightType to $selectedWeightType");
        _convertWeightValues(selectedWeightType, oldWeightType);
      }
    });
  }

  void _showRepsBottomSheet(BuildContext context) {
    showModalBottomSheet(
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
      builder: (context) => const RepsSelected(),
    );
  }

  // ✅ KONWERSJA WARTOŚCI DLA TEGO KONKRETNEGO ĆWICZENIA
  void _convertWeightValues(WeightType newWeightType, WeightType oldWeightType) {
    if (kgControllers?[exerciseId] == null) return;
    
    print("🔄 Converting weights for exercise $exerciseId ($exerciseName):");
    print("  From: $oldWeightType -> To: $newWeightType");
    
    for (int i = 0; i < kgControllers![exerciseId]!.length; i++) {
      final controller = kgControllers![exerciseId]![i];
      if (controller.text.isNotEmpty) {
        final currentValue = double.tryParse(controller.text) ?? 0.0;
        if (currentValue > 0) {
          final convertedValue = oldWeightType.convertTo(currentValue, newWeightType);
          controller.text = convertedValue.toStringAsFixed(1);
          print("    Set ${i + 1}: $currentValue ${oldWeightType.displayName} -> $convertedValue ${newWeightType.displayName}");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ POBIERZ JEDNOSTKĘ WAGI DLA TEGO KONKRETNEGO ĆWICZENIA
    final currentWeightType = ref.watch(exerciseWeightTypeProvider(exerciseId));
    
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
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      print("Weight header clicked for exercise: $exerciseId ($exerciseName)!");
                      _showWeightBottomSheet(context, ref);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            // ✅ JEDNOSTKA SPECYFICZNA DLA TEGO ĆWICZENIA
                            "Weight (${currentWeightType.displayName})",
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      print("Reps header clicked!");
                      _showRepsBottomSheet(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Reps",
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
          for (int i = 0; i < rows.length; i++)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                border: i > 0
                    ? Border(
                        top: BorderSide(
                          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
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
                  const SizedBox(width: 16),

                  // ✅ POLE WAGI Z PLACEHOLDER JEDNOSTKI DLA TEGO ĆWICZENIA
                  Expanded(
                    child: TextField(
                      controller: (kgControllers?[exerciseId] != null &&
                                  i < kgControllers![exerciseId]!.length)
                          ? kgControllers![exerciseId]![i]
                          : null,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        isDense: true,
                        // ✅ PLACEHOLDER Z JEDNOSTKĄ SPECYFICZNĄ DLA TEGO ĆWICZENIA
                        hintText: "0 ${currentWeightType.displayName}",
                        hintStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // ✅ POLE POWTÓRZEŃ
                  Expanded(
                    child: TextField(
                      controller: (repControllers?[exerciseId] != null &&
                                  i < repControllers![exerciseId]!.length)
                          ? repControllers![exerciseId]![i]
                          : null,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        isDense: true,
                        hintText: "0 reps",
                        hintStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}