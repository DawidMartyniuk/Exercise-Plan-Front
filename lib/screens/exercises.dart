import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExercisesScreen extends ConsumerStatefulWidget{
  const ExercisesScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ExercisesScreen> createState() => _ExercisesScreenState();
}
class _ExercisesScreenState extends ConsumerState<ExercisesScreen>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercises'),
      ),
      body: Center(
         child: Text(
          'Welcome to the Start Screen!, in development',
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}