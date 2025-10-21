class User {
  final String id;
  final String name;
  final String email;
  final String telephone;
  final String roleId;
  final Role? role;
  final bool twoFactorEnabled;
  final bool verified;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.telephone,
    required this.roleId,
    this.role,
    this.twoFactorEnabled = false,
    this.verified = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      telephone: json['telephone'] ?? '',
      roleId: json['roleId'] ?? '',
      role: json['role'] != null ? Role.fromJson(json['role']) : null,
      twoFactorEnabled: json['twoFactorEnabled'] ?? false,
      verified: json['verified'] ?? false,
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'telephone': telephone,
      'roleId': roleId,
      'role': role?.toJson(),
      'twoFactorEnabled': twoFactorEnabled,
      'verified': verified,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class Role {
  final String id;
  final String name;
  final String description;
  final List<String>? permissions;
  final DateTime createdAt;
  final DateTime updatedAt;

  Role({
    required this.id,
    required this.name,
    required this.description,
    this.permissions,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      permissions: json['permissions'] != null
          ? List<String>.from(json['permissions'])
          : null,
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'permissions': permissions,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
