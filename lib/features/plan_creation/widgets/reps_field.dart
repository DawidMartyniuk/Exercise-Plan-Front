import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/model/reps_type.dart';
import 'package:work_plan_front/provider/reps_type_provider.dart';

  //   final Map<String, List<TextEditingController>>? repControllers;
  //  final Map<String, List<TextEditingController>>? repMaxControllers;

class RepsField extends StatelessWidget {
  //final TextEditingController controller;
  final String repsType;
  final int setIndex;
  final WidgetRef ref;
  final String exerciseId;
  final Map<String, List<TextEditingController>>? repControllers;
  final Map<String, List<TextEditingController>>? repMaxControllers;

  const RepsField({
    super.key,
    //required this.controller,
 required this.repsType,
    required this.setIndex,
    required this.exerciseId,
    required this.repControllers,
    required this.repMaxControllers,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
  final currentRepsType = repsType == "range" ? RepsType.range : RepsType.single;
  
    if (currentRepsType == RepsType.single) {
      // ✅ POJEDYNCZE POLE DLA SECONDS
      return Expanded(
        child: TextField(
          controller: (repControllers?[exerciseId] != null &&
                      setIndex < repControllers![exerciseId]!.length)
              ? repControllers![exerciseId]![setIndex]
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
            hintText: "0 sec",
            hintStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              fontSize: 12,
            ),
          ),
        ),
      );
    }
   else {
      // ✅ DWIE POLA DLA RANGE (MIN - MAX)
      return Expanded(
        child: Row(
          children: [
            // Pole MIN
            Expanded(
              child: TextField(
                controller: (repControllers?[exerciseId] != null &&
                            setIndex < repControllers![exerciseId]!.length)
                    ? repControllers![exerciseId]![setIndex]
                    : null,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  isDense: true,
                  hintText: "0",
                  hintStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            
            // Separator "-"
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                "−",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            
            // Pole MAX
            Expanded(
              child: TextField(
                controller: (repMaxControllers?[exerciseId] != null &&
                            setIndex < repMaxControllers![exerciseId]!.length)
                    ? repMaxControllers![exerciseId]![setIndex]
                    : null,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  isDense: true,
                  hintText: "0",
                  hintStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}