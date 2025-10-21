import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../models/models.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final _storage = const FlutterSecureStorage();

  User? _user;
  String? _token;
  bool _isAuthenticated = false;
  bool _isLoading = false;

  User? get user => _user;
  String? get token => _token;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;

  AuthProvider() {
    loadStoredAuth();
  }

  Future<void> loadStoredAuth() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      final userData = await _storage.read(key: 'user_data');

      if (token != null && userData != null) {
        _token = token;
        _user = User.fromJson(jsonDecode(userData));
        _isAuthenticated = true;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading stored auth: $e');
    }
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Primero obtenemos el código 2FA
      final loginResponse = await _authService.login(email, password);

      // Si no requiere 2FA, obtenemos el token directamente
      // Si requiere 2FA, necesitamos esperar el código
      // Por ahora, asumimos que ya tenemos el token
      if (loginResponse.token != null) {
        _token = loginResponse.token;
        _user = loginResponse.user;
        _isAuthenticated = true;

        // Guardar en storage
        await _storage.write(key: 'auth_token', value: _token);
        await _storage.write(
          key: 'user_data',
          value: jsonEncode(_user!.toJson()),
        );
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> verify2FA(String email, String code) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _authService.verify2FA(email, code);

      _token = response.token;
      _user = response.user;
      _isAuthenticated = true;

      // Guardar en storage
      await _storage.write(key: 'auth_token', value: _token);
      await _storage.write(
        key: 'user_data',
        value: jsonEncode(_user!.toJson()),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String telephone,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.register(
        name: name,
        email: email,
        password: password,
        telephone: telephone,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> verifyEmail(String email, String code) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.verifyEmail(email, code);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _user = null;
    _token = null;
    _isAuthenticated = false;

    // Limpiar storage
    await _storage.delete(key: 'auth_token');
    await _storage.delete(key: 'user_data');

    notifyListeners();
  }

  Future<void> refreshUser() async {
    if (_user != null) {
      try {
        // Aquí puedes hacer una llamada al backend para obtener datos actualizados del usuario
        // Por ahora solo notificamos
        notifyListeners();
      } catch (e) {
        debugPrint('Error refreshing user: $e');
      }
    }
  }
}

class LoginResponse {
  final String? token;
  final User? user;
  final bool require2FA;
  final String? message;

  LoginResponse({this.token, this.user, this.require2FA = false, this.message});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      require2FA: json['require2FA'] ?? false,
      message: json['message'],
    );
  }
}

class TwoFactorResponse {
  final String token;
  final User user;

  TwoFactorResponse({required this.token, required this.user});

  factory TwoFactorResponse.fromJson(Map<String, dynamic> json) {
    return TwoFactorResponse(
      token: json['token'] ?? '',
      user: User.fromJson(json['user']),
    );
  }
}
