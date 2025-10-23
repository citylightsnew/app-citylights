class UserModel {
  final String id;
  final String email;
  final String nombre;
  final String apellido;
  final String? telefono;
  final bool emailVerified;
  final bool twoFactorEnabled;
  final bool usePushNotification;
  final List<String> roles;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.email,
    required this.nombre,
    required this.apellido,
    this.telefono,
    required this.emailVerified,
    required this.twoFactorEnabled,
    required this.usePushNotification,
    required this.roles,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      nombre: json['nombre'] as String,
      apellido: json['apellido'] as String,
      telefono: json['telefono'] as String?,
      emailVerified: json['emailVerified'] as bool? ?? false,
      twoFactorEnabled: json['twoFactorEnabled'] as bool? ?? false,
      usePushNotification: json['usePushNotification'] as bool? ?? false,
      roles:
          (json['roles'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nombre': nombre,
      'apellido': apellido,
      'telefono': telefono,
      'emailVerified': emailVerified,
      'twoFactorEnabled': twoFactorEnabled,
      'usePushNotification': usePushNotification,
      'roles': roles,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  String get fullName => '$nombre $apellido';

  bool hasRole(String role) => roles.contains(role);

  bool get isAdmin => hasRole('ADMIN');
  bool get isTrabajador => hasRole('TRABAJADOR');
  bool get isUsuario => hasRole('USUARIO');

  UserModel copyWith({
    String? id,
    String? email,
    String? nombre,
    String? apellido,
    String? telefono,
    bool? emailVerified,
    bool? twoFactorEnabled,
    bool? usePushNotification,
    List<String>? roles,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      telefono: telefono ?? this.telefono,
      emailVerified: emailVerified ?? this.emailVerified,
      twoFactorEnabled: twoFactorEnabled ?? this.twoFactorEnabled,
      usePushNotification: usePushNotification ?? this.usePushNotification,
      roles: roles ?? this.roles,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
