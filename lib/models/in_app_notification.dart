import 'package:flutter/material.dart';

class InAppNotification {
  final String id;
  final String title;
  final String body;
  final String type;
  final DateTime timestamp;
  final Map<String, dynamic>? data;
  final VoidCallback? onTap;

  InAppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.timestamp,
    this.data,
    this.onTap,
  });

  factory InAppNotification.from2FA({
    required String code,
    VoidCallback? onTap,
  }) {
    return InAppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Código de Verificación',
      body: 'Tu código de seguridad: $code',
      type: '2fa_code',
      timestamp: DateTime.now(),
      data: {'code': code},
      onTap: onTap,
    );
  }

  factory InAppNotification.fromSecurityAlert({
    required String alertType,
    required String message,
    VoidCallback? onTap,
  }) {
    return InAppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Alerta de Seguridad',
      body: message,
      type: 'security_alert',
      timestamp: DateTime.now(),
      data: {'alertType': alertType},
      onTap: onTap,
    );
  }

  factory InAppNotification.fromGeneral({
    required String title,
    required String message,
    VoidCallback? onTap,
  }) {
    return InAppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: message,
      type: 'general',
      timestamp: DateTime.now(),
      onTap: onTap,
    );
  }

  IconData get icon {
    switch (type) {
      case '2fa_code':
        return Icons.security;
      case 'security_alert':
        return Icons.warning;
      case 'test':
        return Icons.science;
      default:
        return Icons.notifications;
    }
  }

  Color get color {
    switch (type) {
      case '2fa_code':
        return Colors.purple;
      case 'security_alert':
        return Colors.orange;
      case 'test':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
