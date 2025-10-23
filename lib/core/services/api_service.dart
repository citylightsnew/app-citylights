import 'package:dio/dio.dart';
import '../../config/constants/api_constants.dart';
import 'storage_service.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal() {
    _initializeDio();
  }

  late Dio _dio;
  final _storage = StorageService();

  Dio get dio => _dio;

  void _initializeDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectionTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: {'Content-Type': ApiConstants.contentTypeJson},
      ),
    );

    // Request Interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Agregar token de autenticación si existe
          final token = await _storage.getToken();
          if (token != null) {
            options.headers[ApiConstants.authorizationHeader] =
                '${ApiConstants.bearerPrefix} $token';
          }

          // Log de request (solo en desarrollo)
          _logRequest(options);

          return handler.next(options);
        },
        onResponse: (response, handler) {
          // Log de response (solo en desarrollo)
          _logResponse(response);

          return handler.next(response);
        },
        onError: (error, handler) async {
          // Log de error (solo en desarrollo)
          _logError(error);

          // Manejar error 401 (no autorizado)
          if (error.response?.statusCode == 401) {
            // Limpiar sesión y redirigir a login
            await _storage.clearAll();
            // Nota: La navegación debe manejarse desde el provider/context
          }

          return handler.next(error);
        },
      ),
    );
  }

  void _logRequest(RequestOptions options) {
    logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    logger.d('📤 REQUEST [${options.method}] => ${options.uri}');
    logger.d('Headers: ${options.headers}');
    if (options.data != null) {
      logger.d('Data: ${options.data}');
    }
    if (options.queryParameters.isNotEmpty) {
      logger.d('Query Parameters: ${options.queryParameters}');
    }
    logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  }

  void _logResponse(Response response) {
    logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    logger.d(
      '📥 RESPONSE [${response.statusCode}] => ${response.requestOptions.uri}',
    );
    logger.d('Data: ${response.data}');
    logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  }

  void _logError(DioException error) {
    logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    logger.d(
      '❌ ERROR [${error.response?.statusCode}] => ${error.requestOptions.uri}',
    );
    logger.d('Message: ${error.message}');
    if (error.response?.data != null) {
      logger.d('Response Data: ${error.response?.data}');
    }
    logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  }

  // GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }

  // POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }

  // PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }

  // PATCH request
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }

  // DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Handle error and extract message
  String getErrorMessage(dynamic error) {
    if (error is DioException) {
      if (error.response?.data != null) {
        final data = error.response!.data;
        if (data is Map<String, dynamic>) {
          return data['message'] as String? ?? 'Error desconocido';
        }
      }

      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Tiempo de conexión agotado. Verifica tu internet.';
        case DioExceptionType.connectionError:
          return 'Error de conexión. Verifica tu internet.';
        case DioExceptionType.badResponse:
          return 'Error del servidor. Intenta de nuevo.';
        case DioExceptionType.cancel:
          return 'Solicitud cancelada.';
        default:
          return 'Error inesperado. Intenta de nuevo.';
      }
    }
    return error.toString();
  }
}
