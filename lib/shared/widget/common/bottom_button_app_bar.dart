import 'package:flutter/material.dart';

class BottomButtonAppBar extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onEnd;
  final String backLabel;
  final String endLabel;
  final IconData backIcon;
  final IconData endIcon;

  const BottomButtonAppBar({
    super.key,
    required this.onBack,
    required this.onEnd,
    this.backLabel = 'Back',
    this.endLabel = 'End',
    this.backIcon = Icons.arrow_back,
    this.endIcon = Icons.stop_circle_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onBack,
                  icon: Icon(backIcon),
                  label: Text(backLabel),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onEnd,
                  icon: Icon(endIcon),
                  label: Text(endLabel),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
