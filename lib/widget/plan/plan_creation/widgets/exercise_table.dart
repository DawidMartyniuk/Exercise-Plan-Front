import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ExerciseTable extends StatefulWidget {
  final String exerciseId;
  final String exerciseName;
  final List<Map<String, String>> initialRows;
  final Function(List<Map<String, String>>) onRowsChanged;
  final TextEditingController notesController;

  const ExerciseTable({
    Key? key,
    required this.exerciseId,
    required this.exerciseName,
    required this.initialRows,
    required this.onRowsChanged,
    required this.notesController,
  }) : super(key: key);

  @override
  State<ExerciseTable> createState() => _ExerciseTableState();
}

class _ExerciseTableState extends State<ExerciseTable> {
  late List<Map<String, String>> rows;
  late List<TextEditingController> kgControllers;
  late List<TextEditingController> repControllers;

  @override
  void initState() {
    super.initState();
    rows = List.from(widget.initialRows);
    _initializeControllers();
  }

  void _initializeControllers() {
    kgControllers = rows.map((row) => 
        TextEditingController(text: row["colKg"] ?? "0")).toList();
    repControllers = rows.map((row) => 
        TextEditingController(text: row["colRep"] ?? "0")).toList();
    
    // Dodaj listenery
    for (int i = 0; i < kgControllers.length; i++) {
      kgControllers[i].addListener(() => _updateRow(i, "colKg", kgControllers[i].text));
      repControllers[i].addListener(() => _updateRow(i, "colRep", repControllers[i].text));
    }
  }

  void _updateRow(int index, String field, String value) {
    if (index < rows.length) {
      setState(() {
        rows[index][field] = value;
      });
      widget.onRowsChanged(rows);
    }
  }

  void _addRow() {
    setState(() {
      final newIndex = rows.length;
      final lastKg = rows.isNotEmpty ? rows.last["colKg"] ?? "0" : "0";
      final lastRep = rows.isNotEmpty ? rows.last["colRep"] ?? "0" : "0";
      
      rows.add({
        "colStep": "${newIndex + 1}",
        "colKg": lastKg,
        "colRep": lastRep,
      });
      
      // Dodaj nowe kontrolery
      final kgController = TextEditingController(text: lastKg);
      final repController = TextEditingController(text: lastRep);
      
      kgController.addListener(() => _updateRow(newIndex, "colKg", kgController.text));
      repController.addListener(() => _updateRow(newIndex, "colRep", repController.text));
      
      kgControllers.add(kgController);
      repControllers.add(repController);
    });
    widget.onRowsChanged(rows);
  }

  void _removeRow(int index) {
    if (rows.length > 1 && index < rows.length) {
      setState(() {
        rows.removeAt(index);
        kgControllers[index].dispose();
        repControllers[index].dispose();
        kgControllers.removeAt(index);
        repControllers.removeAt(index);
        
        // Aktualizuj numery setów
        for (int i = 0; i < rows.length; i++) {
          rows[i]["colStep"] = "${i + 1}";
        }
      });
      widget.onRowsChanged(rows);
    }
  }

  @override
  void dispose() {
    for (var controller in kgControllers) {
      controller.dispose();
    }
    for (var controller in repControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header tabeli
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
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
                child: Text(
                  "Kg",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 8),
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
              const SizedBox(width: 40), // Miejsce na przycisk usuwania
            ],
          ),
        ),
        
        // Wiersze tabeli
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
          ),
          child: Column(
            children: [
              for (int i = 0; i < rows.length; i++)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
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
                      const SizedBox(width: 8),
                      
                      // Pole kg
                      Expanded(
                        child: TextField(
                          controller: kgControllers[i],
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                          ],
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                              ),
                            ),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      
                      // Pole powtórzeń
                      Expanded(
                        child: TextField(
                          controller: repControllers[i],
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                              ),
                            ),
                            isDense: true,
                          ),
                        ),
                      ),
                      
                      // Przycisk usuwania
                      SizedBox(
                        width: 40,
                        child: rows.length > 1
                            ? IconButton(
                                onPressed: () => _removeRow(i),
                                icon: const Icon(Icons.remove_circle_outline),
                                color: Theme.of(context).colorScheme.error,
                                iconSize: 20,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Przycisk dodawania setu
        Center(
          child: TextButton.icon(
            onPressed: _addRow,
            icon: const Icon(Icons.add),
            label: const Text("Dodaj set"),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Pole notatek
        TextField(
          controller: widget.notesController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: "Notatki do ćwiczenia",
            hintText: "Dodaj uwagi lub instrukcje...",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            alignLabelWithHint: true,
          ),
        ),
      ],
    );
  }
}