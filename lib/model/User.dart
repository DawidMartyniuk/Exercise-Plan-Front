class User {
  final int id;
  final String name;
  final String email;
  final String? avatar;
  final String? description; 
  final int? weight; // Assuming weight is an integer, adjust type if needed
  final String createdAt;
  final String updatedAt;


  User({
    required this.id,
    required this.name,
    required this.email,
    this.weight, // Default weight to 0 if not provided
    this.description,
    this.avatar,
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
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
