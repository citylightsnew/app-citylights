class ApiConstants {
  // Base URL - Cambiar según tu entorno
  static const String baseUrl =
      'http://localhost:4000'; // Para emulador Android: http://10.0.2.2:4000

  // Endpoints de autenticación
  static const String authRegister = '/auth/register';
  static const String authLogin = '/auth/login';
  static const String authVerifyEmail = '/auth/verify-email';
  static const String authVerify2FA = '/auth/verify-2fa';
  static const String authCheck2FAStatus = '/auth/check-2fa-status';
  static const String authResendCode = '/auth/resend-code';
  static const String authForgotPassword = '/auth/forgot-password';
  static const String authResetPassword = '/auth/reset-password';
  static const String authProfile = '/auth/profile';
  static const String authLogout = '/auth/logout';

  // Endpoints de usuarios
  static const String users = '/users';

  // Endpoints de edificios
  static const String edificios = '/edificios';

  // Endpoints de habitaciones
  static const String habitaciones = '/habitaciones';

  // Endpoints de reservas
  static const String reservas = '/booking/reservas';
  static const String areasComunesEndpoint = '/booking/areas-comunes';
  static const String bloqueos = '/booking/bloqueos';

  // Endpoints de nómina
  static const String empleados = '/nomina/empleados';
  static const String pagosNomina = '/nomina/pagos';

  // Endpoints de pagos
  static const String pagos = '/payments/pagos';
  static const String facturas = '/payments/facturas';

  // Endpoints de roles
  static const String roles = '/roles';

  // Endpoints de notificaciones
  static const String notifications = '/notifications';

  // Endpoints de dispositivos
  static const String devices = '/devices';
  static const String devicesRegister = '/devices/register';

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Headers
  static const String contentTypeJson = 'application/json';
  static const String authorizationHeader = 'Authorization';
  static const String bearerPrefix = 'Bearer';
}
