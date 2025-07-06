import 'dart:io';
import 'package:flutter/material.dart';

class SaveWorkoutImageAndDescription extends StatelessWidget {
  final TextEditingController descriptionController;
  final File? selectedImage;
  final VoidCallback onImagePick;

  const SaveWorkoutImageAndDescription({
    super.key,
    required this.descriptionController,
    required this.selectedImage,
    required this.onImagePick,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageContent = TextButton.icon(
      onPressed: onImagePick,
      icon: Icon(
        Icons.add_a_photo,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      label: Text(
        'Add Image',
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start, // <-- dodane
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 10),
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: const Color.fromARGB(255, 75, 65, 65),
            ),
            child:
                selectedImage != null
                    ? Image.file(selectedImage!, fit: BoxFit.cover)
                    : imageContent,
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // <-- dodane
            children: [
              Text(
                'Opis',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: descriptionController,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.left,
                maxLines: 5,
                decoration: InputDecoration(
                  hint: Text(
                    "Tutaj możesz dodać szczegóły dotyczące treningu.",
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
