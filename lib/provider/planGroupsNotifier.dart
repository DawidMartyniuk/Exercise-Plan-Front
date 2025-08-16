import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:work_plan_front/model/planGroup.dart';
import 'package:work_plan_front/model/exercise_plan.dart';
import 'dart:convert';

class PlanGroupsNotifier extends StateNotifier<List<PlanGroup>> {
  PlanGroupsNotifier() : super([]) {
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final groupsJson = prefs.getString('plan_groups');

      if (groupsJson != null) {
        final List<dynamic> decoded = json.decode(groupsJson);
        state = decoded.map((g) => PlanGroup.fromJson(g)).toList();
      } else {
        // ✅ UTWÓRZ DOMYŚLNĄ GRUPĘ
        state = [PlanGroup(id: 'default', name: 'My Plans', plans: [])];
      }
    } catch (e) {
      print('Error loading groups: $e');
      state = [PlanGroup(id: 'default', name: 'My Plans', plans: [])];
    }
  }

  Future<void> _saveGroups() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final groupsJson = json.encode(state.map((g) => g.toJson()).toList());
      await prefs.setString('plan_groups', groupsJson);
    } catch (e) {
      print('Error saving groups: $e');
    }
  }

  void addGroup(String name) {
    final newGroup = PlanGroup(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      plans: [],
    );
    state = [...state, newGroup];
    _saveGroups();
  }

  void updateGroupName(String groupId, String newName) {
    state =
        state.map((group) {
          if (group.id == groupId) {
            return group.copyWith(name: newName);
          }
          return group;
        }).toList();
    _saveGroups();
  }

  void toggleGroupExpanded(String groupId) {
    state =
        state.map((group) {
          if (group.id == groupId) {
            return group.copyWith(isExpanded: !group.isExpanded);
          }
          return group;
        }).toList();
    _saveGroups();
  }

  void removePlanFromGroups(ExerciseTable plan, String targetGroupId) {
  print("🗑️ Usuwanie planu '${plan.exercise_table}' ze wszystkich grup");

  // ❌ BŁĄD: p.id != p.id zawsze zwraca false!
  // final updatedPlans = group.plans.where((p) => p.id != p.id).toList();

  // ✅ POPRAWKA: Usuń plan o konkretnym ID
  state = state.map((group) {
    final originalCount = group.plans.length;
    final updatedPlans = group.plans.where((p) => p.id != plan.id).toList(); // ✅ POPRAWIONE

    if (originalCount != updatedPlans.length) {
      print("📤 Usunięto plan z grupy '${group.name}' (${originalCount} -> ${updatedPlans.length})");
    }

    return group.copyWith(plans: updatedPlans);
  }).toList();

  // ✅ NIE DODAWAJ PONOWNIE DO GRUPY PRZY USUWANIU!
  // state = state.map((group) {
  //   if(group.id == targetGroupId) {
  //     return group.copyWith(plans: [...group.plans, plan]);
  //   }
  //   return group;
  // }).toList();

  final totalPlans = state.expand((g) => g.plans).length;
  final duplicates = state.expand((g) => g.plans).map((p) => p.id).toList();
  final uniquePlans = duplicates.toSet().length;
  
  print("✅ Łącznie planów: $totalPlans, unikalnych: $uniquePlans");
  if (totalPlans != uniquePlans) {
    print("⚠️ WYKRYTO DUPLIKATY!");
  }

  _saveGroups();
}

  void movePlanToGroup(ExerciseTable plan, String targetGroupId) {
    print(
      "🔄 Przenoszenie planu '${plan.exercise_table}' (id: ${plan.id}) do grupy: $targetGroupId",
    );

    state =
        state.map((group) {
          final originalCount = group.plans.length;
          final updatedPlans =
              group.plans.where((p) => p.id != plan.id).toList();

          if (originalCount != updatedPlans.length) {
            print(
              "📤 Usunięto plan z grupy '${group.name}' (${originalCount} -> ${updatedPlans.length})",
            );
          }

          return group.copyWith(plans: updatedPlans);
        }).toList();

    // ✅ DODAJ PLAN DO DOCELOWEJ GRUPY
    state =
        state.map((group) {
          if (group.id == targetGroupId) {
            return group.copyWith(plans: [...group.plans, plan]);
          }
          return group;
        }).toList();

    final totalPlans = state.expand((g) => g.plans).length;
    final duplicates = state.expand((g) => g.plans).map((p) => p.id).toList();
    final uniquePlans = duplicates.toSet().length;

    print("✅ Łącznie planów: $totalPlans, unikalnych: $uniquePlans");
    if (totalPlans != uniquePlans) {
      print("⚠️ WYKRYTO DUPLIKATY!");
    }

    _saveGroups();
  }

  void deleteGroup(String groupId) {
    if (state.length <= 1) return; // ✅ ZAWSZE ZOSTAW PRZYNAJMNIEJ JEDNĄ GRUPĘ

    // ✅ PRZENIEŚ PLANY DO PIERWSZEJ DOSTĘPNEJ GRUPY
    final groupToDelete = state.firstWhere((g) => g.id == groupId);
    final targetGroup = state.firstWhere((g) => g.id != groupId);

    state =
        state
            .map((group) {
              if (group.id == targetGroup.id) {
                return group.copyWith(
                  plans: [...group.plans, ...groupToDelete.plans],
                );
              }
              return group;
            })
            .where((g) => g.id != groupId)
            .toList();

    _saveGroups();
  }

void initializeWithPlans(List<ExerciseTable> plans) {
  print("🔄 Inicjalizacja grup z ${plans.length} planami");
  
  if (state.isEmpty) {
    print("📝 Tworzenie pierwszej grupy");
    state = [PlanGroup(id: 'default', name: 'My Plans', plans: plans)];
    _saveGroups();
  } else {
    print("📋 Sprawdzanie istniejących planów w grupach");
    
    // ✅ SPRAWDŹ WSZYSTKIE PLANY WE WSZYSTKICH GRUPACH
    final allExistingPlanIds = state
        .expand((group) => group.plans)
        .map((p) => p.id)
        .toSet();
    
    final newPlans = plans.where((plan) => !allExistingPlanIds.contains(plan.id)).toList();
    
    print("🆕 Znaleziono ${newPlans.length} nowych planów do dodania");
    print("📋 Nowe plany: ${newPlans.map((p) => p.exercise_table).join(', ')}");
    
    if (newPlans.isNotEmpty) {
      final firstGroup = state.first;
      state = [
        firstGroup.copyWith(plans: [...firstGroup.plans, ...newPlans]),
        ...state.skip(1),
      ];
      _saveGroups();
      print("✅ Dodano ${newPlans.length} nowych planów do grupy '${firstGroup.name}'");
    }
  }
}
}

final planGroupsProvider =
    StateNotifierProvider<PlanGroupsNotifier, List<PlanGroup>>((ref) {
      return PlanGroupsNotifier();
    });
