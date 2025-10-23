import 'package:flutter/foundation.dart';
import '../core/models/auth_models.dart';
import '../core/models/user_model.dart';
import '../core/services/auth_service.dart';
import '../core/services/firebase_service.dart';

enum AuthStatus { initial, authenticated, unauthenticated, loading }

class AuthProvider with ChangeNotifier {
  final _authService = AuthService();
  final _firebaseService = FirebaseService();

  AuthStatus _status = AuthStatus.initial;
  UserModel? _user;
  String? _error;
  bool _isLoading = false;

  // Getters
  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get error => _error;
  String? get errorMessage => _error;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  // Initialize auth state
  Future<void> initializeAuth() async {
    _setLoading(true);
    try {
      final isAuth = await _authService.isAuthenticated();

      if (isAuth) {
        final user = await _authService.getCurrentUser();
        if (user != null) {
          _user = user;
          _status = AuthStatus.authenticated;
        } else {
          _status = AuthStatus.unauthenticated;
        }
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Login
  Future<LoginResponse> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final request = LoginRequest(email: email, password: password);
      final response = await _authService.login(request);

      // Si no requiere 2FA, actualizar estado
      if (!response.requiresTwoFactor && response.user != null) {
        _user = UserModel.fromJson(response.user as Map<String, dynamic>);
        _status = AuthStatus.authenticated;
      }

      _setLoading(false);
      return response;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      rethrow;
    }
  }

  // Register
  Future<RegisterResponse> register({
    required String email,
    required String password,
    required String nombre,
    required String apellido,
    String? telefono,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final request = RegisterRequest(
        email: email,
        password: password,
        nombre: nombre,
        apellido: apellido,
        telefono: telefono,
      );

      final response = await _authService.register(request);
      _setLoading(false);
      return response;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      rethrow;
    }
  }

  // Verify Email
  Future<VerifyEmailResponse> verifyEmail(String email, String code) async {
    _setLoading(true);
    _clearError();

    try {
      final request = VerifyEmailRequest(email: email, code: code);
      final response = await _authService.verifyEmail(request);
      _setLoading(false);
      return response;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      rethrow;
    }
  }

  // Verify 2FA
  Future<Verify2FAResponse> verify2FA(String email, String code) async {
    _setLoading(true);
    _clearError();

    try {
      final request = Verify2FARequest(email: email, code: code);
      final response = await _authService.verify2FA(request);

      // Actualizar estado
      _user = UserModel.fromJson(response.user as Map<String, dynamic>);
      _status = AuthStatus.authenticated;

      // Registrar dispositivo en Firebase
      _registerDeviceInFirebase();

      _setLoading(false);
      return response;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      rethrow;
    }
  }

  // Check 2FA Status
  Future<Check2FAStatusResponse> check2FAStatus(String requestId) async {
    _clearError();

    try {
      final request = Check2FAStatusRequest(requestId: requestId);
      final response = await _authService.check2FAStatus(request);

      // Si fue aprobado, actualizar estado
      if (response.isApproved && response.user != null) {
        _user = UserModel.fromJson(response.user as Map<String, dynamic>);
        _status = AuthStatus.authenticated;

        // Registrar dispositivo en Firebase
        _registerDeviceInFirebase();

        notifyListeners();
      }

      return response;
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  // Registrar dispositivo en Firebase
  void _registerDeviceInFirebase() {
    if (_user?.id != null) {
      _firebaseService.registerDevice(userId: _user!.id.toString());
    }
  }

  // Resend Code
  Future<ResendCodeResponse> resendCode(String email) async {
    _clearError();

    try {
      final request = ResendCodeRequest(email: email);
      final response = await _authService.resendCode(request);
      return response;
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  // Forgot Password
  Future<bool> forgotPassword(String email) async {
    _setLoading(true);
    _clearError();

    try {
      // Llamar al servicio de auth
      await _authService.forgotPassword(email);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Reset Password
  Future<bool> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.resetPassword(
        email: email,
        code: code,
        newPassword: newPassword,
      );
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Refresh Profile
  Future<void> refreshProfile() async {
    try {
      final user = await _authService.getProfile();
      _user = user;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Logout
  Future<void> logout() async {
    _setLoading(true);
    try {
      await _authService.logout();
      _user = null;
      _status = AuthStatus.unauthenticated;
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Helper methods
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _error = message;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
