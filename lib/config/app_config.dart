class AppConfig {
  // IMPORTANTE: Cambia esta URL por tu túnel ngrok o la IP de tu servidor local

  // Para túnel ngrok: 'https://tu-hash.ngrok-free.app'
  // Para red local: 'http://192.168.1.xxx:4000' (reemplaza xxx por tu IP)
  // Para localhost: 'http://localhost:4000' (solo funciona en emuladores)
  static const String apiBaseUrl = 'http://localhost:4000';

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  static const String appName = 'City Lights';
  static const String appVersion = '1.0.0';

  static const Duration successNotificationDuration = Duration(seconds: 4);
  static const Duration errorNotificationDuration = Duration(seconds: 5);
  static const Duration warningNotificationDuration = Duration(seconds: 4);
  static const Duration infoNotificationDuration = Duration(seconds: 4);
}
