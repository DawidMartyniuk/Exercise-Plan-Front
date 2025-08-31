import 'package:flutter/material.dart';

class RepsInfoBottomSheet extends StatelessWidget {
  const RepsInfoBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Text(
          'Zmiana liczby powtórzeń będzie dostępna w przyszłej wersji.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}