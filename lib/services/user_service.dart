import 'package:dio/dio.dart';
import '../models/user_model.dart';
import 'dio_client.dart';

class UserService {
  final DioClient _client = DioClient();

  // Obtener todos los usuarios
  Future<List<User>> getAllUsers() async {
    try {
      final response = await _client.get('/api/users');
      final List<dynamic> data = response.data;
      return data.map((json) => User.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  // Obtener usuario por ID
  Future<User> getUserById(String id) async {
    try {
      final response = await _client.get('/api/users/$id');
      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  // Crear usuario
  Future<User> createUser({
    required String name,
    required String email,
    required String password,
    required String telephone,
    required String roleId,
  }) async {
    try {
      final response = await _client.post(
        '/api/users',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'telephone': telephone,
          'roleId': roleId,
        },
      );
      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  // Actualizar usuario
  Future<User> updateUser({
    required String id,
    String? name,
    String? email,
    String? password,
    String? telephone,
    String? roleId,
    bool? twoFactorEnabled,
    bool? verified,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (email != null) data['email'] = email;
      if (password != null) data['password'] = password;
      if (telephone != null) data['telephone'] = telephone;
      if (roleId != null) data['roleId'] = roleId;
      if (twoFactorEnabled != null) data['twoFactorEnabled'] = twoFactorEnabled;
      if (verified != null) data['verified'] = verified;

      final response = await _client.patch('/api/users/$id', data: data);
      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  // Eliminar usuario
  Future<void> deleteUser(String id) async {
    try {
      await _client.delete('/api/users/$id');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  // Cambiar rol de usuario
  Future<User> changeUserRole(String userId, String roleId) async {
    try {
      final response = await _client.patch(
        '/api/users/$userId/role',
        data: {'roleId': roleId},
      );
      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  // Obtener todos los roles
  Future<List<Role>> getAllRoles() async {
    try {
      final response = await _client.get('/api/roles');
      final List<dynamic> data = response.data;
      return data.map((json) => Role.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  // Crear rol
  Future<Role> createRole({
    required String name,
    required String description,
    List<String>? permissions,
  }) async {
    try {
      final response = await _client.post(
        '/api/roles',
        data: {
          'name': name,
          'description': description,
          if (permissions != null) 'permissions': permissions,
        },
      );
      return Role.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  // Actualizar rol
  Future<Role> updateRole({
    required String id,
    String? name,
    String? description,
    List<String>? permissions,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (description != null) data['description'] = description;
      if (permissions != null) data['permissions'] = permissions;

      final response = await _client.patch('/api/roles/$id', data: data);
      return Role.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  // Eliminar rol
  Future<void> deleteRole(String id) async {
    try {
      await _client.delete('/api/roles/$id');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
