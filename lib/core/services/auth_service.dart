import '../../config/constants/api_constants.dart';
import '../models/auth_models.dart';
import '../models/user_model.dart';
import 'api_service.dart';
import 'storage_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final _api = ApiService();
  final _storage = StorageService();

  // Login
  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await _api.post(
        ApiConstants.authLogin,
        data: request.toJson(),
      );

      final loginResponse = LoginResponse.fromJson(
        response.data as Map<String, dynamic>,
      );

      // Si no requiere 2FA, guardar token y usuario
      if (!loginResponse.requiresTwoFactor &&
          loginResponse.token != null &&
          loginResponse.user != null) {
        await _storage.saveToken(loginResponse.token!);
        final user = UserModel.fromJson(
          loginResponse.user as Map<String, dynamic>,
        );
        await _storage.saveUser(user);
      }

      return loginResponse;
    } catch (e) {
      throw _api.getErrorMessage(e);
    }
  }

  // Register
  Future<RegisterResponse> register(RegisterRequest request) async {
    try {
      final response = await _api.post(
        ApiConstants.authRegister,
        data: request.toJson(),
      );

      return RegisterResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw _api.getErrorMessage(e);
    }
  }

  // Verify Email
  Future<VerifyEmailResponse> verifyEmail(VerifyEmailRequest request) async {
    try {
      final response = await _api.post(
        ApiConstants.authVerifyEmail,
        data: request.toJson(),
      );

      return VerifyEmailResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } catch (e) {
      throw _api.getErrorMessage(e);
    }
  }

  // Verify 2FA
  Future<Verify2FAResponse> verify2FA(Verify2FARequest request) async {
    try {
      final response = await _api.post(
        ApiConstants.authVerify2FA,
        data: request.toJson(),
      );

      final verify2FAResponse = Verify2FAResponse.fromJson(
        response.data as Map<String, dynamic>,
      );

      // Guardar token y usuario
      await _storage.saveToken(verify2FAResponse.token);
      final user = UserModel.fromJson(
        verify2FAResponse.user as Map<String, dynamic>,
      );
      await _storage.saveUser(user);

      return verify2FAResponse;
    } catch (e) {
      throw _api.getErrorMessage(e);
    }
  }

  // Check 2FA Status
  Future<Check2FAStatusResponse> check2FAStatus(
    Check2FAStatusRequest request,
  ) async {
    try {
      final response = await _api.post(
        ApiConstants.authCheck2FAStatus,
        data: request.toJson(),
      );

      final statusResponse = Check2FAStatusResponse.fromJson(
        response.data as Map<String, dynamic>,
      );

      // Si fue aprobado, guardar token y usuario
      if (statusResponse.isApproved &&
          statusResponse.token != null &&
          statusResponse.user != null) {
        await _storage.saveToken(statusResponse.token!);
        final user = UserModel.fromJson(
          statusResponse.user as Map<String, dynamic>,
        );
        await _storage.saveUser(user);
      }

      return statusResponse;
    } catch (e) {
      throw _api.getErrorMessage(e);
    }
  }

  // Resend Code
  Future<ResendCodeResponse> resendCode(ResendCodeRequest request) async {
    try {
      final response = await _api.post(
        ApiConstants.authResendCode,
        data: request.toJson(),
      );

      return ResendCodeResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw _api.getErrorMessage(e);
    }
  }

  // Forgot Password
  Future<void> forgotPassword(String email) async {
    try {
      await _api.post(ApiConstants.authForgotPassword, data: {'email': email});
    } catch (e) {
      throw _api.getErrorMessage(e);
    }
  }

  // Reset Password
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    try {
      await _api.post(
        ApiConstants.authResetPassword,
        data: {'email': email, 'code': code, 'newPassword': newPassword},
      );
    } catch (e) {
      throw _api.getErrorMessage(e);
    }
  }

  // Get Profile
  Future<UserModel> getProfile() async {
    try {
      final response = await _api.get(ApiConstants.authProfile);

      final user = UserModel.fromJson(response.data as Map<String, dynamic>);

      // Actualizar usuario en storage
      await _storage.saveUser(user);

      return user;
    } catch (e) {
      throw _api.getErrorMessage(e);
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      // Intentar hacer logout en el servidor
      await _api.post(ApiConstants.authLogout);
    } catch (e) {
      // Ignorar errores del servidor en logout
    } finally {
      // Siempre limpiar storage local
      await _storage.clearAll();
    }
  }

  // Get current user from storage
  Future<UserModel?> getCurrentUser() async {
    return await _storage.getUser();
  }

  // Get current token from storage
  Future<String?> getCurrentToken() async {
    return await _storage.getToken();
  }

  // Check if authenticated
  Future<bool> isAuthenticated() async {
    return await _storage.isAuthenticated();
  }
}
