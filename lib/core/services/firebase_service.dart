import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:uuid/uuid.dart';
import '../../config/constants/api_constants.dart';
import '../models/device_registration_model.dart';
import 'api_service.dart';
import 'storage_service.dart';

// Handler para mensajes en background
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('📬 Background Message: ${message.messageId}');
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
  print('Data: ${message.data}');
}

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final _api = ApiService();
  final _storage = StorageService();
  final _deviceInfo = DeviceInfoPlugin();
  final _uuid = const Uuid();

  String? _fcmToken;
  String? _deviceId;

  String? get fcmToken => _fcmToken;
  String? get deviceId => _deviceId;

  /// Inicializar Firebase y configurar FCM
  Future<void> initialize() async {
    try {
      // Inicializar Firebase
      await Firebase.initializeApp();
      print('✅ Firebase initialized');

      // Configurar handler de background
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // Solicitar permisos
      await _requestPermissions();

      // Obtener FCM token
      await _getFCMToken();

      // Obtener o generar Device ID
      await _getOrCreateDeviceId();

      // Configurar listeners
      _setupMessageHandlers();

      print('✅ Firebase Service initialized');
    } catch (e) {
      print('❌ Error initializing Firebase: $e');
      rethrow;
    }
  }

  /// Solicitar permisos de notificaciones
  Future<void> _requestPermissions() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('✅ Notification permissions granted');
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        print('⚠️ Provisional notification permissions granted');
      } else {
        print('❌ Notification permissions denied');
      }
    } catch (e) {
      print('❌ Error requesting permissions: $e');
    }
  }

  /// Obtener FCM Token
  Future<void> _getFCMToken() async {
    try {
      // Para iOS, configurar APNS token primero
      if (Platform.isIOS) {
        final apnsToken = await _messaging.getAPNSToken();
        if (apnsToken == null) {
          print('⚠️ APNS token not available yet');
          // Esperar un poco y reintentar
          await Future.delayed(const Duration(seconds: 3));
        }
      }

      _fcmToken = await _messaging.getToken();
      if (_fcmToken != null) {
        print('📱 FCM Token: $_fcmToken');
        await _storage.saveFcmToken(_fcmToken!);
      } else {
        print('⚠️ FCM Token is null');
      }

      // Listener para cuando el token se actualiza
      _messaging.onTokenRefresh.listen((newToken) {
        print('🔄 FCM Token refreshed: $newToken');
        _fcmToken = newToken;
        _storage.saveFcmToken(newToken);
        // TODO: Actualizar token en el servidor
        _updateDeviceToken(newToken);
      });
    } catch (e) {
      print('❌ Error getting FCM token: $e');
    }
  }

  /// Obtener o crear Device ID único
  Future<void> _getOrCreateDeviceId() async {
    try {
      // Intentar obtener del storage
      _deviceId = await _storage.getDeviceId();

      if (_deviceId == null) {
        // Generar nuevo device ID
        String deviceModel = 'Unknown';
        String osVersion = 'Unknown';

        if (Platform.isAndroid) {
          final androidInfo = await _deviceInfo.androidInfo;
          deviceModel = '${androidInfo.manufacturer} ${androidInfo.model}';
          osVersion = 'Android ${androidInfo.version.release}';
        } else if (Platform.isIOS) {
          final iosInfo = await _deviceInfo.iosInfo;
          deviceModel = iosInfo.model;
          osVersion = '${iosInfo.systemName} ${iosInfo.systemVersion}';
        }

        // Generar UUID único
        _deviceId = _uuid.v4();
        await _storage.saveDeviceId(_deviceId!);

        print('📱 New Device ID created: $_deviceId');
        print('📱 Device: $deviceModel');
        print('📱 OS: $osVersion');
      } else {
        print('📱 Existing Device ID: $_deviceId');
      }
    } catch (e) {
      print('❌ Error getting device ID: $e');
    }
  }

  /// Configurar handlers de mensajes
  void _setupMessageHandlers() {
    // Mensaje cuando la app está en foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📨 Foreground Message: ${message.messageId}');
      print('Title: ${message.notification?.title}');
      print('Body: ${message.notification?.body}');
      print('Data: ${message.data}');

      // TODO: Mostrar notificación local o actualizar UI
      _handleMessage(message);
    });

    // Mensaje cuando el usuario toca la notificación
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('🔔 Notification tapped: ${message.messageId}');
      print('Data: ${message.data}');

      // TODO: Navegar a la pantalla correspondiente
      _handleNotificationTap(message);
    });

    // Verificar si la app fue abierta desde una notificación
    _checkInitialMessage();
  }

  /// Verificar mensaje inicial
  Future<void> _checkInitialMessage() async {
    try {
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        print('🚀 App opened from notification: ${initialMessage.messageId}');
        print('Data: ${initialMessage.data}');
        // TODO: Navegar a la pantalla correspondiente
        _handleNotificationTap(initialMessage);
      }
    } catch (e) {
      print('❌ Error checking initial message: $e');
    }
  }

  /// Manejar mensaje recibido
  void _handleMessage(RemoteMessage message) {
    // Extraer datos del mensaje
    final data = message.data;
    final notification = message.notification;

    if (data.containsKey('type')) {
      final type = data['type'];
      print('📋 Message type: $type');

      switch (type) {
        case '2fa_request':
          // Notificación de solicitud 2FA
          print('🔐 2FA Request received');
          break;
        case 'booking_approved':
          // Reserva aprobada
          print('✅ Booking approved');
          break;
        case 'booking_rejected':
          // Reserva rechazada
          print('❌ Booking rejected');
          break;
        case 'payment_due':
          // Pago pendiente
          print('💰 Payment due');
          break;
        default:
          print('📬 Unknown message type: $type');
      }
    }

    // TODO: Mostrar notificación local si la app está en foreground
    if (notification != null) {
      print('Showing local notification...');
      // Implementar con flutter_local_notifications
    }
  }

  /// Manejar tap en notificación
  void _handleNotificationTap(RemoteMessage message) {
    final data = message.data;

    if (data.containsKey('type')) {
      final type = data['type'];
      print('🔔 Notification tap - type: $type');

      // TODO: Navegar a la pantalla correspondiente
      // Esto debería hacerse desde el Provider o usando Navigator key global
      switch (type) {
        case '2fa_request':
          // Navegar a pantalla de 2FA
          break;
        case 'booking_approved':
        case 'booking_rejected':
          // Navegar a mis reservas
          break;
        case 'payment_due':
          // Navegar a pagos
          break;
      }
    }
  }

  /// Registrar dispositivo en el servidor
  Future<void> registerDevice({required String userId}) async {
    try {
      if (_fcmToken == null || _deviceId == null) {
        print('⚠️ Cannot register device: missing token or ID');
        return;
      }

      String deviceModel = 'Unknown';
      String osVersion = 'Unknown';
      String platform = Platform.isAndroid ? 'android' : 'ios';

      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        deviceModel = '${androidInfo.manufacturer} ${androidInfo.model}';
        osVersion = 'Android ${androidInfo.version.release}';
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        deviceModel = iosInfo.model;
        osVersion = '${iosInfo.systemName} ${iosInfo.systemVersion}';
      }

      final deviceData = DeviceRegistration(
        deviceId: _deviceId!,
        fcmToken: _fcmToken!,
        platform: platform,
        deviceModel: deviceModel,
        osVersion: osVersion,
      );

      final response = await _api.post(
        ApiConstants.devicesRegister,
        data: deviceData.toJson(),
      );

      print('✅ Device registered: ${response.data}');
    } catch (e) {
      print('❌ Error registering device: $e');
    }
  }

  /// Actualizar token del dispositivo
  Future<void> _updateDeviceToken(String newToken) async {
    try {
      if (_deviceId == null) return;

      await _api.post(
        ApiConstants.devicesRegister,
        data: {'deviceId': _deviceId, 'fcmToken': newToken},
      );

      print('✅ Device token updated');
    } catch (e) {
      print('❌ Error updating device token: $e');
    }
  }

  /// Eliminar registro de dispositivo
  Future<void> unregisterDevice() async {
    try {
      if (_deviceId == null) return;

      await _api.delete('${ApiConstants.devices}/$_deviceId');

      await _storage.deleteFcmToken();
      _fcmToken = null;

      print('✅ Device unregistered');
    } catch (e) {
      print('❌ Error unregistering device: $e');
    }
  }

  /// Suscribirse a un tópico
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      print('✅ Subscribed to topic: $topic');
    } catch (e) {
      print('❌ Error subscribing to topic: $e');
    }
  }

  /// Desuscribirse de un tópico
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      print('✅ Unsubscribed from topic: $topic');
    } catch (e) {
      print('❌ Error unsubscribing from topic: $e');
    }
  }
}
