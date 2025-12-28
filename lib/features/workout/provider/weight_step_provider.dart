import 'package:flutter_riverpod/flutter_riverpod.dart';

// ✅ PROVIDER DLA GLOBALNEGO KROKU WAGI (PER PLAN)
final globalWeightStepProvider = StateNotifierProvider.family<GlobalWeightStepNotifier, double, String>(
  (ref, planId) => GlobalWeightStepNotifier(),
);

class GlobalWeightStepNotifier extends StateNotifier<double> {
  GlobalWeightStepNotifier() : super(1.0); // ✅ DOMYŚLNY KROK 1.0kg

  void setGlobalStep(double step) {
    state = step;
    print("🎛️ Global weight step set to: ${step}kg"); // ✅ DEBUG
  }

  void resetToDefault() {
    state = 1.0;
  }
}