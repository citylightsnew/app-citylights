import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'auth_service.dart';

class NotificationTestService {
  static const String _baseUrl = AppConfig.apiBaseUrl;

  static Future<Map<String, dynamic>?> sendTestNotification({
    String? customMessage,
  }) async {
    try {
      final token = await AuthService.getAccessToken();
      if (token == null) {
        return null;
      }

      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/notifications/test'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: json.encode({
              if (customMessage != null) 'message': customMessage,
            }),
          )
          .timeout(
            AppConfig.connectionTimeout,
            onTimeout: () {
              throw Exception('Timeout enviando notificación de prueba');
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

  static Future<Map<String, dynamic>?> sendTest2FANotification() async {
    try {
      final token = await AuthService.getAccessToken();
      if (token == null) {
        return null;
      }

      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/notifications/test-2fa'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(
            AppConfig.connectionTimeout,
            onTimeout: () {
              throw Exception('Timeout enviando notificación 2FA');
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

  static Future<Map<String, dynamic>?> getNotificationStats() async {
    try {

      final token = await AuthService.getAccessToken();
      if (token == null) {
        return null;
      }

      final response = await http
          .get(
            Uri.parse('$_baseUrl/api/notifications/stats'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(
            AppConfig.connectionTimeout,
            onTimeout: () {
              throw Exception('Timeout obteniendo estadísticas');
            },
          );

      if (response.statusCode == 200) {
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

  static Future<Map<String, dynamic>?> sendSecurityAlert(
    String alertType,
  ) async {
    try {
      final token = await AuthService.getAccessToken();
      if (token == null) {
        return null;
      }

      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/notifications/security-alert/$alertType'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: json.encode({
              'testMode': true,
              'timestamp': DateTime.now().toIso8601String(),
            }),
          )
          .timeout(
            AppConfig.connectionTimeout,
            onTimeout: () {
              throw Exception('Timeout enviando alerta de seguridad');
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

  static Future<bool> canReceiveNotifications() async {
    try {
      final stats = await getNotificationStats();
      if (stats == null) return false;

      return stats['canReceiveNotifications'] == true &&
          stats['devicesWithFCM'] > 0;
    } catch (e) {
      return false;
    }
  }

  static Future<Map<String, dynamic>> testFullConnectivity() async {
    try {
      final stats = await getNotificationStats();
      if (stats == null) {
        return {
          'success': false,
          'error': 'No se pudieron obtener estadísticas',
          'step': 'stats',
        };
      }

      final testResult = await sendTestNotification(
        customMessage: 'Prueba de conectividad completa 🚀',
      );
      if (testResult == null) {
        return {
          'success': false,
          'error': 'No se pudo enviar notificación de prueba',
          'step': 'test_notification',
          'stats': stats,
        };
      }

      return {
        'success': true,
        'stats': stats,
        'testResult': testResult,
        'message': 'Conectividad completa verificada',
      };
    } catch (e) {
      return {'success': false, 'error': e.toString(), 'step': 'unknown'};
    }
  }
}
