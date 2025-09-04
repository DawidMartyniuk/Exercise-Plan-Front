import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlanSelected extends ConsumerStatefulWidget {
  final String planName;
  final VoidCallback onRemove;

const PlanSelected({
    super.key,
    required this.planName,
    required this.onRemove,
  });
  
  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _PlanSelectedState();
  }
}

class _PlanSelectedState extends ConsumerState<PlanSelected> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(widget.planName),
        trailing: IconButton(
          icon: Icon(Icons.close),
          onPressed: widget.onRemove,
        ),
      ),
    );
  }
}
