import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfilScreen extends ConsumerStatefulWidget{

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _ProfilScreenState();
  }
}
class _ProfilScreenState extends ConsumerState<ProfilScreen>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body:  Center(
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