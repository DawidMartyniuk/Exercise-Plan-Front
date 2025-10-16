import 'package:flutter/material.dart';

class NameField extends StatelessWidget {
  final TextEditingController nameController;
  final bool isEnabled;

  const NameField({
    super.key,
    required this.nameController,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: nameController,
      keyboardType: TextInputType.name,
      enabled: isEnabled,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        prefixIcon: Icon(
          Icons.person,
          color: isEnabled
              ? Theme.of(context).colorScheme.onSurface
              : Colors.grey,
        ),
        labelText: "Name", // ✅ BEZ GWIAZDKI
        labelStyle: TextStyle(
          color: isEnabled
              ? Theme.of(context).colorScheme.onSurface
              : Colors.grey,
        ),
        filled: true,
        fillColor: isEnabled
            ? Theme.of(context).colorScheme.surface
            : Colors.grey.withAlpha(50),
      ),
      style: TextStyle(
        color: isEnabled
            ? Theme.of(context).colorScheme.onSurface
            : Colors.grey,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your name';
        }
        if (value.length < 3) {
          return 'Name must be at least 3 characters long';
        }
        return null;
      },
    );
  }
}