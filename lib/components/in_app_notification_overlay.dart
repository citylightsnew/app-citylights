import 'package:flutter/material.dart';
import '../services/in_app_notification_service.dart';
import '../models/in_app_notification.dart';
import 'in_app_notification_widget.dart';

class InAppNotificationOverlay extends StatefulWidget {
  final Widget child;

  const InAppNotificationOverlay({super.key, required this.child});

  @override
  State<InAppNotificationOverlay> createState() =>
      _InAppNotificationOverlayState();
}

class _InAppNotificationOverlayState extends State<InAppNotificationOverlay> {
  final InAppNotificationService _notificationService =
      InAppNotificationService();
  final List<InAppNotification> _displayedNotifications = [];

  @override
  void initState() {
    super.initState();

    _notificationService.notificationStream.listen((notification) {
      if (mounted) {
        setState(() {
          _displayedNotifications.add(notification);
          if (_displayedNotifications.length > 3) {
            _displayedNotifications.removeAt(0);
          }
        });
      }
    });
  }

  void _dismissNotification(String notificationId) {
    setState(() {
      _displayedNotifications.removeWhere((n) => n.id == notificationId);
    });
    _notificationService.dismiss(notificationId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          widget.child,

          if (_displayedNotifications.isNotEmpty)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Column(
                  children: _displayedNotifications.map((notification) {
                    return InAppNotificationWidget(
                      key: ValueKey(notification.id),
                      notification: notification,
                      onDismiss: () => _dismissNotification(notification.id),
                    );
                  }).toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
