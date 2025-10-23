import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import 'package:dio/dio.dart';
import 'dio_client.dart';
import '../models/models.dart';

class AuthService {
  final DioClient _client = DioClient();

  // Instancia del secure storage
  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  static const String _keyAccessToken = 'access_token';
  static const String _keyUserData = 'user_data';
  static const String _keyBiometricsEnabled = 'biometrics_enabled';
  static const String _keyIsLoggedIn = 'is_logged_in';

  static final LocalAuthentication _localAuth = LocalAuthentication();

  // ============================================
  // NUEVOS MÉTODOS CON DIO
  // ============================================

  Future<LoginResponse> login(String email, String password) async {
    try {
      final response = await _client.post(
        '/api/auth/login',
        data: {'email': email, 'password': password},
      );
      return LoginResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<TwoFactorResponse> verify2FA(String email, String code) async {
    try {
      final response = await _client.post(
        '/api/auth/verify-2fa',
        data: {'email': email, 'code': code},
      );
      return TwoFactorResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<RegisterResponse> register({
    required String name,
    required String email,
    required String password,
    required String telephone,
  }) async {
    try {
      final response = await _client.post(
        '/api/auth/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'telephone': telephone,
        },
      );
      return RegisterResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<VerifyEmailResponse> verifyEmail(String email, String code) async {
    try {
      final response = await _client.post(
        '/api/auth/verify-email',
        data: {'email': email, 'code': code},
      );
      return VerifyEmailResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> resendCode(String email) async {
    try {
      await _client.post('/api/auth/resend-code', data: {'email': email});
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<User> getCurrentUser() async {
    try {
      final response = await _client.get('/api/auth/me');
      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  // ============================================
  // MÉTODOS DE BIOMETRÍA
  // ============================================

  static Future<bool> isBiometricsAvailable() async {
    try {
      final bool isAvailable = await _localAuth.canCheckBiometrics;
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();
      return isAvailable && isDeviceSupported;
    } catch (e) {
      return false;
    }
  }

  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  static Future<bool> authenticateWithBiometrics() async {
    try {
      final bool canCheck = await _localAuth.canCheckBiometrics;

      final bool isDeviceSupported = await _localAuth.isDeviceSupported();

      if (!canCheck || !isDeviceSupported) {
        return false;
      }

      final List<BiometricType> availableBiometrics = await _localAuth
          .getAvailableBiometrics();

      if (availableBiometrics.isEmpty) {
        return false;
      }

      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Usa tu huella dactilar para acceder a City Lights',
      );

      return didAuthenticate;
    } catch (e) {
      return false;
    }
  }

  static Future<void> saveSession({
    required String accessToken,
    required User user,
    bool enableBiometrics = false,
  }) async {
    try {
      await _secureStorage.write(key: _keyAccessToken, value: accessToken);

      final userData = jsonEncode(user.toJson());

      await _secureStorage.write(key: _keyUserData, value: userData);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyIsLoggedIn, true);
      await prefs.setBool(_keyBiometricsEnabled, enableBiometrics);
    } catch (e) {
      print('❌ Error saving session: $e');
    }
  }

  static Future<Map<String, dynamic>?> getSavedSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bool isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;

      if (!isLoggedIn) return null;

      final String? accessToken = await _secureStorage.read(
        key: _keyAccessToken,
      );
      final String? userDataString = await _secureStorage.read(
        key: _keyUserData,
      );

      if (accessToken == null || userDataString == null) return null;

      final userData = jsonDecode(userDataString);

      return {
        'accessToken': accessToken,
        'user': User.fromJson(userData),
        'biometricsEnabled': prefs.getBool(_keyBiometricsEnabled) ?? false,
      };
    } catch (e) {
      return null;
    }
  }

  static Future<void> clearSession() async {
    try {
      await _secureStorage.delete(key: _keyAccessToken);
      await _secureStorage.delete(key: _keyUserData);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyIsLoggedIn, false);
      await prefs.setBool(_keyBiometricsEnabled, false);
    } catch (e) {
      print('❌ Error clearing session: $e');
    }
  }

  static Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keyIsLoggedIn) ?? false;
    } catch (e) {
      return false;
    }
  }

  static Future<String?> getAccessToken() async {
    try {
      return await _secureStorage.read(key: _keyAccessToken);
    } catch (e) {
      return null;
    }
  }

  static Future<bool> isBiometricsEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keyBiometricsEnabled) ?? false;
    } catch (e) {
      return false;
    }
  }

  static Future<void> setBiometricsEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyBiometricsEnabled, enabled);
    } catch (e) {
      print('❌ Error setting biometrics: $e');
    }
  }

  static Future<bool> isFirstLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return !(prefs.getBool('has_logged_in_before') ?? false);
    } catch (e) {
      return true; // Asumir primer login en caso de error
    }
  }

  static Future<void> setHasLoggedInBefore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_logged_in_before', true);
    } catch (e) {
      print('❌ Error setting has logged in before: $e');
    }
  }

  static Future<bool> is2FASetup() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('has_2fa_setup') ?? false;
    } catch (e) {
      return false;
    }
  }

  static Future<void> set2FASetup(bool isSetup) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_2fa_setup', isSetup);
    } catch (e) {
      print('❌ Error setting 2FA setup: $e');
    }
  }

  static Future<bool> shouldShow2FASetup() async {
    try {
      final isFirst = await isFirstLogin();
      final has2FA = await is2FASetup();

      return isFirst && !has2FA;
    } catch (e) {
      return false;
    }
  }

  // Método para cerrar sesión
  Future<void> logout() async {
    try {
      // Intentar cerrar sesión en el backend
      try {
        await _client.post('/api/auth/logout');
      } catch (e) {
        // Continuar con el logout local aunque falle el backend
        print('⚠️ Error al cerrar sesión en el servidor: $e');
      }

      // Limpiar el storage local
      await _secureStorage.delete(key: _keyAccessToken);
      await _secureStorage.delete(key: _keyUserData);
      await _secureStorage.delete(key: _keyIsLoggedIn);

      // Limpiar preferencias de SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      print('✅ Sesión cerrada exitosamente');
    } catch (e) {
      print('❌ Error al cerrar sesión: $e');
      throw ApiException(message: 'Error al cerrar sesión', statusCode: 500);
    }
  }
}
