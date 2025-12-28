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

  void addPlanToGroupAtPosition(
    ExerciseTable plan,
    String targetGroupId,
    int position,
  ) {
    print(
      "🎯 Dodawanie planu '${plan.exercise_table}' do grupy $targetGroupId na pozycji $position",
    );

   
    state =
        state.map((group) {
          final updatedPlans =
              group.plans.where((p) => p.id != plan.id).toList();
          return group.copyWith(plans: updatedPlans);
        }).toList();

   
    state =
        state.map((group) {
          if (group.id == targetGroupId) {
            final updatedPlans = List<ExerciseTable>.from(group.plans);
            final insertPosition = position.clamp(0, updatedPlans.length);
            updatedPlans.insert(insertPosition, plan);

            print(
              "✅ Plan dodany na pozycji $insertPosition (z ${updatedPlans.length} planów)",
            );
            return group.copyWith(plans: updatedPlans);
          }
          return group;
        }).toList();

    _saveGroups();
  }

  //  POPRAW ISTNIEJĄCĄ METODĘ - UŻYJ NOWEJ METODY
  void movePlanToGroupAtEnd(ExerciseTable plan, String targetGroupId) {
    //  UŻYJ NOWEJ METODY Z POZYCJĄ NA KOŃCU
    addPlanToGroupAtPosition(plan, targetGroupId, 999);
  }

  void removePlanFromGroups(ExerciseTable plan, String targetGroupId) {
    print("🗑️ Usuwanie planu '${plan.exercise_table}' ze wszystkich grup");

    state =
        state.map((group) {
          final originalCount = group.plans.length;
          final updatedPlans =
              group.plans
                  .where((p) => p.id != plan.id)
                  .toList(); //  POPRAWIONE

          if (originalCount != updatedPlans.length) {
            print(
              "📤 Usunięto plan z grupy '${group.name}' ($originalCount -> ${updatedPlans.length})",
            );
          }

          return group.copyWith(plans: updatedPlans);
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
              "📤 Usunięto plan z grupy '${group.name}' ($originalCount -> ${updatedPlans.length})",
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
    if (state.length <= 1) return; // ZAWSZE ZOSTAW PRZYNAJMNIEJ JEDNĄ GRUPĘ

    //  PRZENIEŚ PLANY DO PIERWSZEJ DOSTĘPNEJ GRUPY
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

    final backendPlansId = plans.map((p)=> p.id).toSet();
    state = state.map((g) {
      final originalCount = g.plans.length;
      final validPlans = g.plans.where((plan) =>
          backendPlansId.contains(plan.id)).toList();

      // if (originalCount != validPlans.length) {
      //   print(
      //     "📤 Usunięto plany z grupy '${g.name}' (${originalCount} -> ${validPlans.length})",
      //   );
      // }

      return g.copyWith(plans: validPlans);
    }).toList();

         // DODAJ NOWE PLANY
    final allExistingPlanIds = state.expand((group) => group.plans).map((p) => p.id).toSet();
    final newPlans = plans.where((plan) => !allExistingPlanIds.contains(plan.id)).toList();

    if (newPlans.isNotEmpty) {
      print("🆕 Dodaję ${newPlans.length} nowych planów: ${newPlans.map((p) => p.exercise_table).join(', ')}");
      
      final firstGroup = state.isNotEmpty ? state.first : PlanGroup(id: 'default', name: 'My Plans', plans: []);
      
      if (state.isEmpty) {
        state = [firstGroup.copyWith(plans: [...firstGroup.plans, ...newPlans])];
      } else {
        state = [
          firstGroup.copyWith(plans: [...firstGroup.plans, ...newPlans]),
          ...state.skip(1),
        ];
      }
    }
    
    _saveGroups();
    print("✅ Synchronizacja zakończona - grupy zawierają tylko aktualne plany");
  }
}

final planGroupsProvider =
    StateNotifierProvider<PlanGroupsNotifier, List<PlanGroup>>((ref) {
      return PlanGroupsNotifier();
    });
