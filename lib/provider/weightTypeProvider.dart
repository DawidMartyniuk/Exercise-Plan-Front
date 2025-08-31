import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/model/weight_type.dart';

//  PROVIDER DLA GLOBALNEJ JEDNOSTKI WAGI (DOMYŚLNEJ)
final defaultWeightTypeProvider = StateProvider<WeightType>((ref) => WeightType.kg);

// ✅ PROVIDER DLA JEDNOSTKI WAGI PER ĆWICZENIE
final exerciseWeightTypeProvider = StateProvider.family<WeightType, String>((ref, exerciseId) {
  // Pobierz domyślną jednostkę jako fallback
  final defaultType = ref.read(defaultWeightTypeProvider);
  return defaultType;
});

// ✅ HELPER PROVIDER - POBIERA JEDNOSTKĘ DLA ĆWICZENIA LUB DOMYŚLNĄ
final weightTypeForExerciseProvider = Provider.family<WeightType, String>((ref, exerciseId) {
  return ref.watch(exerciseWeightTypeProvider(exerciseId));
});