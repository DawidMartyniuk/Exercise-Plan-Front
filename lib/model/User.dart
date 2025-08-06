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

  // ✅ DODAJ NOWĄ METODĘ - merge tylko niepustych pól
  User mergeWith(User updatedUser) {
    return User(
      id: this.id, // ID nie zmienia się
      // ✅ Użyj nowej wartości tylko jeśli nie jest pusta/null
      name: updatedUser.name.isNotEmpty ? updatedUser.name : this.name,
      email: updatedUser.email.isNotEmpty ? updatedUser.email : this.email,
      // ✅ Avatar: użyj nowy TYLKO jeśli nie jest null i nie jest pusty
      avatar: (updatedUser.avatar != null && updatedUser.avatar!.isNotEmpty) 
          ? updatedUser.avatar 
          : this.avatar,
      // ✅ Description: użyj nowy TYLKO jeśli backend go zwrócił
      description: updatedUser.description != null 
          ? updatedUser.description 
          : this.description,
      // ✅ Weight: użyj nowy TYLKO jeśli nie jest null
      weight: updatedUser.weight != null 
          ? updatedUser.weight 
          : this.weight,
      // ✅ Timestamps zawsze aktualizuj (backend zawsze je zwraca)
      createdAt: updatedUser.createdAt.isNotEmpty ? updatedUser.createdAt : this.createdAt,
      updatedAt: updatedUser.updatedAt.isNotEmpty ? updatedUser.updatedAt : this.updatedAt,
    );
  }
}
