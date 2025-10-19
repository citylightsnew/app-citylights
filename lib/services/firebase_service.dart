import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:uuid/uuid.dart';
import 'dart:io' show Platform;
import 'in_app_notification_service.dart';
import '../firebase_options.dart';
import '../screens/two_factor_approval.dart';
import 'auth_service.dart';

class FirebaseService {
  static const _secureStorage = FlutterSecureStorage();
  static const String _keyFcmToken = 'fcm_token';
  static const String _keyDeviceId = 'device_id';

  static FirebaseMessaging? _messaging;
  static String? _fcmToken;
  static String? _deviceId;

  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      _messaging = FirebaseMessaging.instance;

      final permissionsGranted = await requestPermissions();
      if (!permissionsGranted) {
        print('⚠️ Permisos de notificación no concedidos');
      }

      final token = await getFCMToken();
      if (token == null) {
        print('⚠️ No se pudo obtener el FCM token');
      }

      await generateDeviceId();

      setupMessageHandlers();

    } catch (e) {
      print('❌ Error inicializando Firebase: $e');
      rethrow;
    }
  }

  static Future<bool> requestPermissions() async {
    try {
      if (_messaging == null) {
        return false;
      }

      NotificationSettings settings = await _messaging!.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      bool granted =
          settings.authorizationStatus == AuthorizationStatus.authorized;

      return granted;
    } catch (e) {
      print('❌ Error solicitando permisos: $e');
      return false;
    }
  }

  static Future<String?> getFCMToken() async {
    try {
      if (_messaging == null) {
        return null;
      }

      _fcmToken = await _messaging!.getToken();

      if (_fcmToken != null) {
        await _secureStorage.write(key: _keyFcmToken, value: _fcmToken);
      } else {
        print('⚠️ No se pudo obtener el FCM token');
      }

      return _fcmToken;
    } catch (e) {
      return null;
    }
  }

  static Future<String> generateDeviceId() async {
    try {
      String? storedDeviceId = await _secureStorage.read(key: _keyDeviceId);

      if (storedDeviceId != null && storedDeviceId.isNotEmpty) {
        _deviceId = storedDeviceId;
        return _deviceId!;
      }

      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        _deviceId = 'android_${androidInfo.id}';
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        _deviceId = 'ios_${iosInfo.identifierForVendor}';
      } else {
        const uuid = Uuid();
        _deviceId = 'unknown_${uuid.v4()}';
      }

      await _secureStorage.write(key: _keyDeviceId, value: _deviceId);

      return _deviceId!;
    } catch (e) {
      const uuid = Uuid();
      _deviceId = 'fallback_${uuid.v4()}';
      await _secureStorage.write(key: _keyDeviceId, value: _deviceId);

      return _deviceId!;
    }
  }

  static void setupMessageHandlers() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _handleForegroundMessage(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationTap(message);
    });

    FirebaseMessaging.instance.getInitialMessage().then((
      RemoteMessage? message,
    ) {
      if (message != null) {
        _handleNotificationTap(message);
      }
    });
  }

  static void _handleForegroundMessage(RemoteMessage message) {
    final Map<String, dynamic> notificationData = {
      'type': message.data['type'] ?? 'general',
      'title': message.notification?.title ?? 'Notificación',
      'body': message.notification?.body ?? '',
      ...message.data,
    };

    final InAppNotificationService notificationService =
        InAppNotificationService();
    notificationService.processFirebaseNotification(notificationData);

    switch (message.data['type']) {
      case '2fa_approval_request':
        _navigateToApprovalScreen({
              'requestId': message.data['requestId'] ?? '',
              'userId': message.data['userId'] ?? '',
              'email': message.data['email'] ?? 'Desconocido',
              'userAgent': message.data['userAgent'] ?? 'Desconocido',
              'timestamp':
                  message.data['timestamp'] ?? DateTime.now().toIso8601String(),
            })
            .then((_) {
              print('✅ Navegación a pantalla de aprobación completada');
            })
            .catchError((error) {
              print('❌ Error navegando a pantalla de aprobación: $error');
            });
        break;
      case '2fa_code':
        print('🔐 Código 2FA recibido');
        break;
      case 'security_alert':
        print('⚠️ Alerta de seguridad recibida');
        break;
      case 'test':
        print('🧪 Notificación de prueba recibida');
        break;
      default:
        print('📢 Notificación genérica recibida');
    }
  }

  static void _handleNotificationTap(RemoteMessage message) {
    switch (message.data['type']) {
      case '2fa_approval_request':
        _pendingApprovalData = {
          'requestId': message.data['requestId'] ?? '',
          'userId': message.data['userId'] ?? '',
          'email': message.data['email'] ?? 'Desconocido',
          'userAgent': message.data['userAgent'] ?? 'Desconocido',
          'timestamp':
              message.data['timestamp'] ?? DateTime.now().toIso8601String(),
        };

        if (_navigatorKey?.currentState != null) {
          _navigateToApprovalScreen(_pendingApprovalData!)
              .then((_) {
                print('✅ Navegación desde tap de notificación completada');
              })
              .catchError((error) {
                print('❌ Error navegando desde tap: $error');
              });
        }
        break;
      case '2fa_request':
        print('🔐 Navegando a aprobación 2FA (legacy)');
        break;
      case 'security_alert':
        print('⚠️ Navegando a alertas de seguridad');
        break;
      default:
        print('📱 Notificación genérica');
    }
  }

  static Map<String, dynamic>? _pendingApprovalData;

  static GlobalKey<NavigatorState>? _navigatorKey;

  static bool _isProcessing2FAApproval = false;

  static void setNavigatorKey(GlobalKey<NavigatorState> key) {
    _navigatorKey = key;

    if (_pendingApprovalData != null) {
      final dataCopy = Map<String, dynamic>.from(_pendingApprovalData!);
      _pendingApprovalData = null;

      _navigateToApprovalScreen(dataCopy)
          .then((_) {
            print('✅ Navegación desde datos pendientes completada');
          })
          .catchError((error) {
            print('❌ Error navegando desde datos pendientes: $error');
          });
    }
  }

  static Future<void> _navigateToApprovalScreen(
    Map<String, dynamic> data,
  ) async {
    if (_navigatorKey?.currentState == null) {
      print('⚠️ NavigatorKey no disponible, guardando datos para después');
      return;
    }

    _isProcessing2FAApproval = true;

    try {
      final bool biometricsAvailable =
          await AuthService.isBiometricsAvailable();

      if (!biometricsAvailable) {
        _showApprovalScreen(data);
        return;
      }

      final bool authenticated = await AuthService.authenticateWithBiometrics();

      if (authenticated) {
        _showApprovalScreen(data);
      } else {
        _isProcessing2FAApproval = false;

        final context = _navigatorKey?.currentState?.context;
        if (context != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                '❌ Autenticación requerida para aprobar solicitudes de acceso',
              ),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      _showApprovalScreen(data);
    }
  }

  static void _showApprovalScreen(Map<String, dynamic> data) {
    _navigatorKey?.currentState
        ?.push(
          MaterialPageRoute(
            builder: (context) => TwoFactorApprovalScreen(
              requestId: data['requestId'] ?? '',
              email: data['email'] ?? data['userId'] ?? 'Desconocido',
              requestData: data,
            ),
          ),
        )
        .then((_) {
          _isProcessing2FAApproval = false;
        });
  }

  static Map<String, dynamic>? getPendingApprovalData() {
    final data = _pendingApprovalData;
    _pendingApprovalData = null;
    return data;
  }

  static bool isProcessing2FAApproval() {
    return _isProcessing2FAApproval;
  }

  static void reset2FAApprovalFlag() {
    _isProcessing2FAApproval = false;
  }

  static Future<Map<String, dynamic>> getDeviceInfo() async {
    try {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      Map<String, dynamic> info = {};

      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        info = {
          'platform': 'android',
          'model': androidInfo.model,
          'brand': androidInfo.brand,
          'version': androidInfo.version.release,
          'sdkVersion': androidInfo.version.sdkInt,
        };
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        info = {
          'platform': 'ios',
          'model': iosInfo.model,
          'name': iosInfo.name,
          'version': iosInfo.systemVersion,
        };
      }

      info['deviceId'] = _deviceId ?? await generateDeviceId();
      info['fcmToken'] = _fcmToken ?? await getFCMToken();

      return info;
    } catch (e) {
      return {
        'platform': 'unknown',
        'deviceId': _deviceId ?? 'unknown',
        'fcmToken': _fcmToken,
      };
    }
  }

  static Future<void> refreshToken() async {
    try {
      await getFCMToken();
    } catch (e) {
      print('❌ Error actualizando token: $e');
    }
  }

  static Future<void> clearLocalData() async {
    try {
      await _secureStorage.delete(key: _keyFcmToken);
    } catch (e) {
      print('❌ Error limpiando datos: $e');
    }
  }

  static String? get fcmToken => _fcmToken;
  static String? get deviceId => _deviceId;
  static FirebaseMessaging? get messaging => _messaging;
}
