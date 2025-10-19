import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'auth_service.dart';
import 'firebase_service.dart';

class DeviceService {
  static const String _baseUrl = AppConfig.apiBaseUrl;

  static Future<Map<String, dynamic>?> registerCurrentDevice() async {
    try {
      final deviceInfo = await FirebaseService.getDeviceInfo();

      if (deviceInfo['deviceId'] == null) {
        return null;
      }

      final token = await AuthService.getAccessToken();
      if (token == null) {
        return null;
      }

      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/devices/register'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: json.encode({
              'deviceId': deviceInfo['deviceId'],
              'fcmToken': deviceInfo['fcmToken'],
              'platform': deviceInfo['platform'],
              'model': deviceInfo['model'],
              'brand': deviceInfo['brand'],
              'version': deviceInfo['version'],
            }),
          )
          .timeout(
            AppConfig.connectionTimeout,
            onTimeout: () {
              throw Exception('Timeout registrando dispositivo');
            },
          );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return data;
      } else {
        final errorData = json.decode(response.body);
        throw Exception('Error del servidor: ${errorData['message']}');
      }
    } catch (e) {
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>> getMyDevices() async {
    try {
      final token = await AuthService.getAccessToken();
      if (token == null) {
        return [];
      }

      final response = await http
          .get(
            Uri.parse('$_baseUrl/api/devices/my-devices'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(
            AppConfig.connectionTimeout,
            onTimeout: () {
              throw Exception('Timeout obteniendo dispositivos');
            },
          );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final devices = List<Map<String, dynamic>>.from(data['devices'] ?? []);
        return devices;
      } else {
        final errorData = json.decode(response.body);
        print('❌ Error obteniendo dispositivos: ${errorData['message']}');
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  static Future<bool> deactivateDevice(String deviceId) async {
    try {
      final token = await AuthService.getAccessToken();
      if (token == null) {
        return false;
      }

      final response = await http
          .delete(
            Uri.parse('$_baseUrl/api/devices/$deviceId'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(
            AppConfig.connectionTimeout,
            onTimeout: () {
              throw Exception('Timeout desactivando dispositivo');
            },
          );

      if (response.statusCode == 200) {
        return true;
      } else {
        final errorData = json.decode(response.body);
        print('❌ Error desactivando dispositivo: ${errorData['message']}');
        return false;
      }
    } catch (e) {
      return false;
    }
  }
  static Future<void> updateLastSeen() async {
    try {
      final deviceInfo = await FirebaseService.getDeviceInfo();
      final deviceId = deviceInfo['deviceId'];

      if (deviceId == null) return;

      final token = await AuthService.getAccessToken();
      if (token == null) return;

      await http
          .put(
            Uri.parse('$_baseUrl/api/devices/$deviceId/ping'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              return http.Response('timeout', 408);
            },
          );

    } catch (e) {
      print('⚠️ No se pudo actualizar última actividad: $e');
    }
  }

  static Future<bool> isDeviceRegistered() async {
    try {
      final devices = await getMyDevices();
      final deviceInfo = await FirebaseService.getDeviceInfo();
      final currentDeviceId = deviceInfo['deviceId'];

      if (currentDeviceId == null) return false;

      final isRegistered = devices.any(
        (device) =>
            device['deviceId'] == currentDeviceId && device['isActive'] == true,
      );

      return isRegistered;
    } catch (e) {
      return false;
    }
  }

  static Future<void> initializeDeviceSetup() async {
    try {
      final isRegistered = await isDeviceRegistered();

      if (!isRegistered) {
        await registerCurrentDevice();
      } else {
        await updateLastSeen();
      }

    } catch (e) {
      print('❌ Error en configuración inicial del dispositivo: $e');
    }
  }
}
