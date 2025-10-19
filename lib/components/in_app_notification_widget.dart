import 'package:flutter/material.dart';
import '../models/in_app_notification.dart';

class InAppNotificationWidget extends StatefulWidget {
  final InAppNotification notification;
  final VoidCallback onDismiss;

  const InAppNotificationWidget({
    super.key,
    required this.notification,
    required this.onDismiss,
  });

  @override
  State<InAppNotificationWidget> createState() =>
      _InAppNotificationWidgetState();
}

class _InAppNotificationWidgetState extends State<InAppNotificationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutBack,
          ),
        );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    await _animationController.reverse();
    widget.onDismiss();
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) {
      return 'Ahora';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}m';
    } else {
      return '${diff.inHours}h';
    }
  }

  @override
  Widget build(BuildContext context) {
    final notification = widget.notification;

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                if (notification.onTap != null) {
                  notification.onTap!();
                }
                _dismiss();
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: notification.color.withOpacity(0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: notification.color.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                    const BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Ícono
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: notification.color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        notification.icon,
                        color: notification.color,
                        size: 20,
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Contenido
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  notification.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Text(
                                _formatTime(notification.timestamp),
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 4),

                          Text(
                            notification.body,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          if (notification.type == '2fa_code' &&
                              notification.data?['code'] != null) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.purple.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: Colors.purple.withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                notification.data!['code'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Botón cerrar
                    InkWell(
                      onTap: _dismiss,
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.close,
                          color: Colors.white.withOpacity(0.6),
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
