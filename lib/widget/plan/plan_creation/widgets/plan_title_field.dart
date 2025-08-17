import 'package:flutter/material.dart';

class PlanTitleField extends StatelessWidget {
  final String initialValue;
  final ValueChanged<String> onChanged;
  final String? errorText;

  const PlanTitleField({
    Key? key,
    required this.initialValue,
    required this.onChanged,
    this.errorText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Nazwa planu treningowego",
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          onChanged: onChanged,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
                width: 2,
              ),
            ),
            prefixIcon: Icon(
              Icons.edit,
              color: Theme.of(context).colorScheme.primary,
            ),
            errorText: errorText,
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface.withOpacity(0.5),
          ),
        ),
      ],
    );
  }
}