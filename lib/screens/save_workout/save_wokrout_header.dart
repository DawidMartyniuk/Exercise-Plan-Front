import 'package:flutter/material.dart';

class SaveWorkoutHeader extends StatelessWidget {
  final TextEditingController controller;
 
  final int hourFrom;
  final int minuteFrom;
  final VoidCallback onDateTap;
  final VoidCallback onTimeTap;

  const SaveWorkoutHeader({
    super.key,
    required this.controller,
    required this.hourFrom,
    required this.minuteFrom,
    required this.onDateTap,
    required this.onTimeTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 20, left: 26, right: 26),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: TextField(
                  controller: controller,
                  style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                  textAlign: TextAlign.left,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    hintText: 'Tytuł treningu',
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Icon(
                  Icons.edit,
                  color: Theme.of(context).colorScheme.onSurface,
                  size: 30,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: onDateTap,
                child: Text(
                  "${DateTime.now().day.toString().padLeft(2, '0')}.${DateTime.now().month.toString().padLeft(2, '0')}.${DateTime.now().year.toString().padLeft(4, '0')}",
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const SizedBox(width: 32),
              GestureDetector(
                onTap: onTimeTap,
                child: Text(
                  "${hourFrom.toString().padLeft(2, '0')}:${minuteFrom.toString().padLeft(2, '0')} - ${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}",
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
