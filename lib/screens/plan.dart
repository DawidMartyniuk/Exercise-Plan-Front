import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlanScreen extends ConsumerStatefulWidget{

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _PlanScreenState();
  }
}
class _PlanScreenState extends ConsumerState<PlanScreen>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plan'),
      ),
      body:  Center(
        child: Text(
          'Welcome to the Start Plan!, in development',
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}