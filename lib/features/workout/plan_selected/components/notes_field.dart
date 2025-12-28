import 'package:flutter/material.dart';

class NotesField extends StatelessWidget {
  final String notes;
  final ValueChanged<String> onChanged;

  const NotesField({
    super.key,
    required this.notes,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: TextField(
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          hintText: "notes",
          hintStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            fontSize: 16,
          ),
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.all(8),
        ),
        minLines: 1,
        maxLines: 3,
        onChanged: onChanged,
        controller: TextEditingController(text: notes),
      ),
    );
  }
}