import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'storage_service.dart';

enum BiometricType { fingerprint, face, iris, none }

class BiometricService {
  static final BiometricService _instance = BiometricService._internal();
  factory BiometricService() => _instance;
  BiometricService._internal();

  final LocalAuthentication _localAuth = LocalAuthentication();
  final _storage = StorageService();

  /// Check if device supports biometrics
  Future<bool> isDeviceSupported() async {
    try {
      return await _localAuth.isDeviceSupported();
    } catch (e) {
      print('Error checking device support: $e');
      return false;
    }
  }

  /// Check if biometrics are available (enrolled)
  Future<bool> canCheckBiometrics() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (e) {
      print('Error checking biometrics: $e');
      return false;
    }
  }

  /// Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      final List<BiometricType> biometrics = <BiometricType>[];
      final availableBiometrics = await _localAuth.getAvailableBiometrics();

      if (availableBiometrics.contains(BiometricType.fingerprint)) {
        biometrics.add(BiometricType.fingerprint);
      }
      if (availableBiometrics.contains(BiometricType.face)) {
        biometrics.add(BiometricType.face);
      }
      if (availableBiometrics.contains(BiometricType.iris)) {
        biometrics.add(BiometricType.iris);
      }

      return biometrics;
    } catch (e) {
      print('Error getting available biometrics: $e');
      return [];
    }
  }

  /// Get biometric type name for display
  String getBiometricTypeName(List<BiometricType> types) {
    if (types.isEmpty) return 'Biométrico';

    if (types.contains(BiometricType.face)) {
      return 'Face ID';
    } else if (types.contains(BiometricType.fingerprint)) {
      return 'Huella Digital';
    } else if (types.contains(BiometricType.iris)) {
      return 'Iris';
    }

    return 'Biométrico';
  }

  /// Authenticate using biometrics
  Future<bool> authenticate({
    String localizedReason = 'Autentícate para continuar',
  }) async {
    try {
      final isSupported = await isDeviceSupported();
      if (!isSupported) {
        print('Device does not support biometrics');
        return false;
      }

      final canCheck = await canCheckBiometrics();
      if (!canCheck) {
        print('Biometrics not available');
        return false;
      }

      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: localizedReason,
      );

      return didAuthenticate;
    } on PlatformException catch (e) {
      print('Biometric authentication error: $e');
      if (e.code == 'NotAvailable') {
        // Biometrics not available
      } else if (e.code == 'NotEnrolled') {
        // No biometrics enrolled
      } else if (e.code == 'LockedOut') {
        // Too many failed attempts
      } else if (e.code == 'PermanentlyLockedOut') {
        // Biometrics locked permanently
      }
      return false;
    } catch (e) {
      print('Unexpected error: $e');
      return false;
    }
  }

  /// Check if biometric login is enabled
  Future<bool> isBiometricLoginEnabled() async {
    try {
      final enabled = await _storage.getBiometricEnabled();
      return enabled ?? false;
    } catch (e) {
      print('Error checking biometric login status: $e');
      return false;
    }
  }

  /// Enable biometric login and save credentials
  Future<void> enableBiometricLogin({
    required String email,
    required String password,
  }) async {
    try {
      await _storage.saveBiometricEnabled(true);
      await _storage.saveBiometricCredentials(email: email, password: password);
    } catch (e) {
      print('Error enabling biometric login: $e');
      rethrow;
    }
  }

  /// Disable biometric login and clear credentials
  Future<void> disableBiometricLogin() async {
    try {
      await _storage.saveBiometricEnabled(false);
      await _storage.deleteBiometricCredentials();
    } catch (e) {
      print('Error disabling biometric login: $e');
      rethrow;
    }
  }

  /// Get saved biometric credentials
  Future<Map<String, String>?> getBiometricCredentials() async {
    try {
      final credentials = await _storage.getBiometricCredentials();
      return credentials;
    } catch (e) {
      print('Error getting biometric credentials: $e');
      return null;
    }
  }

  /// Authenticate and get credentials for auto-login
  Future<Map<String, String>?> authenticateAndGetCredentials({
    String localizedReason = 'Autentícate para iniciar sesión',
  }) async {
    try {
      final isEnabled = await isBiometricLoginEnabled();
      if (!isEnabled) {
        return null;
      }

      final didAuthenticate = await authenticate(
        localizedReason: localizedReason,
      );

      if (!didAuthenticate) {
        return null;
      }

      return await getBiometricCredentials();
    } catch (e) {
      print('Error authenticating and getting credentials: $e');
      return null;
    }
  }

  /// Check if biometric setup is complete (enabled and has credentials)
  Future<bool> isBiometricSetupComplete() async {
    try {
      final isEnabled = await isBiometricLoginEnabled();
      if (!isEnabled) return false;

      final credentials = await getBiometricCredentials();
      return credentials != null &&
          credentials.containsKey('email') &&
          credentials.containsKey('password');
    } catch (e) {
      print('Error checking biometric setup: $e');
      return false;
    }
  }
}
