import 'package:flutter/material.dart';

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
                  child: Text(
                    "Kg",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    "Reps",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
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