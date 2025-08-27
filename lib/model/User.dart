import 'package:work_plan_front/model/weight_type.dart';

class User {
  final int id;
  final String name;
  final String email;
  final String? avatar;
  final String? description; 
  final int? weight;
  final WeightType preferredWeightUnit; // ✅ DODAJ NOWE POLE
  final String createdAt;
  final String updatedAt;


  User({
    required this.id,
    required this.name,
    required this.email,
    this.weight, // Default weight to 0 if not provided
    this.description,
    this.avatar,
    this.preferredWeightUnit = WeightType.kg, // ✅ DOMYŚLNA WARTOŚĆ
    required this.createdAt,
    required this.updatedAt,
  });

 
 factory User.fromJson(Map<String, dynamic> json) {
  return User(
    id: json['id'] as int,
    name: json['name'] as String,
    email: json['email'] as String,
    avatar: json['avatar'] as String?,
    description: json['description'] as String?,
    // ✅ KONWERTUJ STRING NA INT
    weight: json['weight'] != null 
        ? int.tryParse(json['weight'].toString()) 
        : null,
    // ✅ PARSUJ ENUM Z BAZY DANYCH
    preferredWeightUnit: WeightType.fromString(
        json['preferred_weight_unit']?.toString() ?? 'kg'
    ),
    createdAt: json['created_at'] as String,
    updatedAt: json['updated_at'] as String,
  );
}
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar': avatar,
      'description': description,
      'weight': weight,
      'preferred_weight_unit': preferredWeightUnit.toDbString(), // ✅ KONWERTUJ DO STRING
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

   User copyWith({
    int? id,
    String? name,
    String? email,
    String? avatar,
    int? weight,
    String? description,
    WeightType? preferredWeightUnit, // ✅ DODAJ DO copyWith
    String? createdAt,
    String? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      weight: weight ?? this.weight,
      description: description ?? this.description,
      preferredWeightUnit: preferredWeightUnit ?? this.preferredWeightUnit, // ✅ DODAJ
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  //  DODAJ NOWĄ METODĘ - merge tylko niepustych pól
  User mergeWith(User updatedUser) {
    return User(
      id: this.id, 
    
      name: updatedUser.name.isNotEmpty ? updatedUser.name : this.name,
      email: updatedUser.email.isNotEmpty ? updatedUser.email : this.email,
      avatar: (updatedUser.avatar != null && updatedUser.avatar!.isNotEmpty) 
          ? updatedUser.avatar 
          : this.avatar,
      description: updatedUser.description ?? this.description,
      weight: updatedUser.weight ?? this.weight,
      preferredWeightUnit: updatedUser.preferredWeightUnit, 
      createdAt: updatedUser.createdAt.isNotEmpty ? updatedUser.createdAt : this.createdAt,
      updatedAt: updatedUser.updatedAt.isNotEmpty ? updatedUser.updatedAt : this.updatedAt,
    );
  }

  // ✅ HELPER METHODS
  String getFormattedWeight() {
    if (weight == null) return 'Nie podano';
    return preferredWeightUnit.formatWeight(weight!.toDouble(), decimals: 0);
  }

  double? getWeightInUnit(WeightType targetUnit) {
    if (weight == null) return null;
    return preferredWeightUnit.convertTo(weight!.toDouble(), targetUnit);
  }
}
