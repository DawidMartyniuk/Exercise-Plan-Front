import 'package:flutter/material.dart';
import 'package:work_plan_front/widget/plan/widget/reps_selected.dart';
import 'package:work_plan_front/widget/plan/widget/weight_selected.dart';

class BuildSetsTable extends StatelessWidget{
  final String exerciseId;
  final String exerciseName;
  final List<Map<String, String>> rows;
  final Map<String, List<TextEditingController>>? kgControllers ;
  final Map<String, List<TextEditingController>>? repControllers;

  const BuildSetsTable({
    Key? key,
    required this.exerciseId,
    required this.exerciseName,
    required this.rows,
    this.kgControllers,
    this.repControllers,
  }) : super(key: key);

   void _showWeightBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.5, 
      ),
      builder: (context) => const WeightSelected(),
    );
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

  @override
  Widget build(BuildContext context) {
    return Container( decoration: BoxDecoration(
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
                      print("Kg header clicked!"); // ✅ DEBUG LOG
                      _showWeightBottomSheet(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),

                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Weight",
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
                      print("Reps header clicked!"); // ✅ DEBUG LOG
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
                              fontSize: 20,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            textAlign: TextAlign.center,
                          ),
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
                border: i > 0 ? Border(
                  top: BorderSide(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  ),
                ) : null,
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
                  
                  // ✅ POLE KG Z ZABEZPIECZENIEM
                  Expanded(
                    child: TextField(
                      controller: (kgControllers?[exerciseId] != null && 
                                   i < kgControllers![exerciseId]!.length) 
                          ? kgControllers![exerciseId]![i] 
                          : null, // ✅ ZABEZPIECZENIE PRZED INDEX OUT OF RANGE
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // ✅ POLE POWTÓRZEŃ Z ZABEZPIECZENIEM
                  Expanded(
                    child: TextField(
                      controller: (repControllers?[exerciseId] != null && 
                                   i < repControllers![exerciseId]!.length) 
                          ? repControllers![exerciseId]![i] 
                          : null, // ✅ ZABEZPIECZENIE PRZED INDEX OUT OF RANGE
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        isDense: true,
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