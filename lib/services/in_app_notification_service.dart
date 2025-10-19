import 'dart:async';
import 'package:flutter/material.dart';
import '../models/in_app_notification.dart';

class InAppNotificationService {
  static final InAppNotificationService _instance =
      InAppNotificationService._internal();
  factory InAppNotificationService() => _instance;
  InAppNotificationService._internal();

  final StreamController<InAppNotification> _notificationController =
      StreamController<InAppNotification>.broadcast();

  final List<InAppNotification> _activeNotifications = [];

  static const Duration _defaultDuration = Duration(seconds: 4);

  Stream<InAppNotification> get notificationStream =>
      _notificationController.stream;
  List<InAppNotification> get activeNotifications =>
      List.unmodifiable(_activeNotifications);

  void show(InAppNotification notification, {Duration? duration}) {
    _activeNotifications.add(notification);
    _notificationController.add(notification);

    Timer(duration ?? _defaultDuration, () {
      dismiss(notification.id);
    });
  }

  void dismiss(String notificationId) {
    _activeNotifications.removeWhere((n) => n.id == notificationId);
  }

  void show2FA(String code, {VoidCallback? onTap}) {
    final notification = InAppNotification.from2FA(code: code, onTap: onTap);

    show(
      notification,
      duration: const Duration(seconds: 8),
    ); // Más tiempo para 2FA
  }

  void showSecurityAlert(
    String alertType,
    String message, {
    VoidCallback? onTap,
  }) {
    final notification = InAppNotification.fromSecurityAlert(
      alertType: alertType,
      message: message,
      onTap: onTap,
    );

    show(
      notification,
      duration: const Duration(seconds: 6),
    ); 
  }

  void showGeneral(String title, String message, {VoidCallback? onTap}) {
    final notification = InAppNotification.fromGeneral(
      title: title,
      message: message,
      onTap: onTap,
    );

    show(notification);
  }

  void showTest(String message) {
    final notification = InAppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Notificación de Prueba',
      body: message,
      type: 'test',
      timestamp: DateTime.now(),
    );

    show(notification);
  }

  void processFirebaseNotification(Map<String, dynamic> data) {
    final String? notificationType = data['type'];
    final String? title = data['title'];
    final String? body = data['body'];

    if (title == null || body == null) {
      return;
    }

    switch (notificationType) {
      case '2fa_code':
        final String? code = data['code'];
        if (code != null) {
          show2FA(code);
        }
        break;

      case 'security_alert':
        final String alertType = data['alertType'] ?? 'unknown';
        showSecurityAlert(alertType, body);
        break;

      case 'test':
        showTest(body);
        break;

      default:
        showGeneral(title, body);
    }
  }

  void clearAll() {
    _activeNotifications.clear();
  }

  void dispose() {
    _notificationController.close();
    _activeNotifications.clear();
  }
}
