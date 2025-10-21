import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/models.dart';
import 'dio_client.dart';

class ApiService {
  // URL base desde la configuración
  static String get baseUrl => AppConfig.apiBaseUrl;

  // Función para probar la conexión
  static Future<bool> testConnection() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/api/health'), // endpoint de salud si existe
            headers: _headers,
          )
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Headers por defecto
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
    'Access-Control-Allow-Headers':
        'Origin, Content-Type, Accept, Authorization',
  };

  // 1. Login (Primer paso - genera 2FA)
  static Future<LoginResponse> login(String email, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/auth/login'),
            headers: _headers,
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(AppConfig.connectionTimeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return LoginResponse.fromJson(data);
      } else {
        // Manejar message como array o string
        String errorMessage;
        if (data['message'] is List) {
          errorMessage = (data['message'] as List).join(', ');
        } else {
          errorMessage = data['message']?.toString() ?? 'Error en el login';
        }

        throw ApiException(
          message: errorMessage,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Error de conexión: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  // 2. Verificar código 2FA (segundo paso - obtener token)
  static Future<TwoFactorResponse> verify2FA(String email, String code) async {
    try {
      final bodyData = {'email': email, 'code': code};
      final bodyJson = jsonEncode(bodyData);

      final response = await http
          .post(
            Uri.parse('$baseUrl/api/auth/verify-2fa'),
            headers: _headers,
            body: bodyJson,
          )
          .timeout(AppConfig.connectionTimeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return TwoFactorResponse.fromJson(data);
      } else {
        // Manejar message como array o string
        String errorMessage;
        if (data['message'] is List) {
          errorMessage = (data['message'] as List).join(', ');
        } else {
          errorMessage =
              data['message']?.toString() ?? 'Código de verificación inválido';
        }

        throw ApiException(
          message: errorMessage,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Error de conexión: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  // 🔐 **APROBAR/RECHAZAR SOLICITUD 2FA**
  static Future<Map<String, dynamic>> approveTwoFactor(
    String email,
    String requestId,
    bool approved,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/auth/approve-2fa'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'email': email,
              'requestId': requestId,
              'approved': approved,
            }),
          )
          .timeout(
            AppConfig.connectionTimeout,
            onTimeout: () {
              throw Exception('Timeout al aprobar/rechazar acceso');
            },
          );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw ApiException(
          message: data['message'] ?? 'Error al procesar solicitud',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Error de conexión: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  // 📊 **VERIFICAR ESTADO DE SOLICITUD 2FA (Polling)**
  static Future<Map<String, dynamic>> checkTwoFactorStatus(
    String email,
    String requestId,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/auth/check-2fa-status'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'email': email, 'requestId': requestId}),
          )
          .timeout(
            AppConfig.connectionTimeout,
            onTimeout: () {
              throw Exception('Timeout al verificar estado');
            },
          );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw ApiException(
          message: data['message'] ?? 'Error al verificar estado',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Error de conexión: ${e.toString()}',
        statusCode: 0,
      );
    }
  }
}
