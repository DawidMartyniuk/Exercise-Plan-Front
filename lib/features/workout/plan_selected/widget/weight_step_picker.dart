import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/features/workout/provider/weight_step_provider.dart';// ✅ DODAJ IMPORT

class WeightStepPickerBottomSheet extends ConsumerStatefulWidget { // ✅ ZMIEŃ NA ConsumerStatefulWidget
  final double currentStep;
  final Function(double) onStepSelected;
  final String planId; // ✅ DODAJ PLAN ID

  const WeightStepPickerBottomSheet({
    super.key,
    required this.currentStep,
    required this.onStepSelected,
    required this.planId, // ✅ DODAJ PLAN ID
  });

  @override
  ConsumerState<WeightStepPickerBottomSheet> createState() => _WeightStepPickerBottomSheetState();
}

class _WeightStepPickerBottomSheetState extends ConsumerState<WeightStepPickerBottomSheet> {
  late double selectedStep;
  
  final List<double> predefinedSteps = [0.25, 0.5, 1.0, 1.25, 2.5, 5.0];
  bool isCustomStep = false;
  final TextEditingController _customStepController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedStep = widget.currentStep;
    
    if (!predefinedSteps.contains(selectedStep)) {
      isCustomStep = true;
      _customStepController.text = selectedStep.toString();
    }
  }

  @override
  void dispose() {
    _customStepController.dispose();
    super.dispose();
  }

  //  USTAW GLOBALNY KROK DLA CAŁEGO PLANU
  void _setGlobalStep() {
    final customStep = double.tryParse(_customStepController.text);
    final stepToSet = isCustomStep && customStep != null && customStep > 0 
        ? customStep 
        : selectedStep;
    
    //  USTAW GLOBALNIE W PROVIDERZE
    ref.read(globalWeightStepProvider(widget.planId).notifier).setGlobalStep(stepToSet);
    
    // ✅POKAŻ POTWIERDZENIE
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.settings, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Global weight step set to ${stepToSet}kg for this plan',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // ✅ OBSERWUJ GLOBALNY KROK
    final globalStep = ref.watch(globalWeightStepProvider(widget.planId));
    
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ NAGŁÓWEK Z INFORMACJĄ O GLOBALNYM KROKU
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'Select Weight Step',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // ✅ POKAŻ AKTUALNY GLOBALNY KROK
                    if (globalStep != 1.0) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Global: ${globalStep}kg',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Text(
            'Current step: ${selectedStep}kg',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 24),

          Text(
            'Popular steps:',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 12),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 2.5,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: predefinedSteps.length,
            itemBuilder: (context, index) {
              final step = predefinedSteps[index];
              final isSelected = selectedStep == step && !isCustomStep;
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedStep = step;
                    isCustomStep = false;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.surface,
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      '${step}kg',
                      style: TextStyle(
                        color: isSelected
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSurface,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          Text(
            'Custom step:',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _customStepController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    hintText: 'e.g. 1.25',
                    suffixText: 'kg',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    final customStep = double.tryParse(value);
                    if (customStep != null && customStep > 0) {
                      setState(() {
                        selectedStep = customStep;
                        isCustomStep = true;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              // ✅ PRZYCISK SET GLOBAL - ZAWSZE AKTYWNY
              ElevatedButton(
                onPressed: _setGlobalStep, // ✅ ZAWSZE DOSTĘPNY
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary, // ✅ INNY KOLOR
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Set Global',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // ✅ PRZYCISKI AKCJI
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: selectedStep > 0
                      ? () {
                          widget.onStepSelected(selectedStep); // ✅ TYLKO DLA TEGO WIERSZA
                          Navigator.pop(context);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Confirm ${selectedStep}kg', // ✅ TYLKO DLA TEGO WIERSZA
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }
}