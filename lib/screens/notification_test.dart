import 'package:flutter/material.dart';
import '../services/notification_test_service.dart';
import '../services/in_app_notification_service.dart';

class NotificationTestScreen extends StatefulWidget {
  const NotificationTestScreen({super.key});

  @override
  State<NotificationTestScreen> createState() => _NotificationTestScreenState();
}

class _NotificationTestScreenState extends State<NotificationTestScreen> {
  bool _isLoading = false;
  Map<String, dynamic>? _stats;
  String? _lastResult;
  bool _canReceiveNotifications = false;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final stats = await NotificationTestService.getNotificationStats();
      final canReceive =
          await NotificationTestService.canReceiveNotifications();

      setState(() {
        _stats = stats;
        _canReceiveNotifications = canReceive;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Error cargando estadísticas: $e');
    }
  }

  Future<void> _sendTestNotification() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await NotificationTestService.sendTestNotification(
        customMessage: 'Esta es una notificación de prueba desde la app! 📱',
      );

      if (result != null && result['success'] == true) {
        setState(() {
          _lastResult =
              'Notificación enviada a ${result['devicesNotified']} dispositivo(s)';
        });
        _showSuccessSnackBar('Notificación enviada exitosamente');
      } else {
        _showErrorSnackBar(result?['message'] ?? 'Error desconocido');
      }
    } catch (e) {
      _showErrorSnackBar('Error enviando notificación: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendTest2FA() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await NotificationTestService.sendTest2FANotification();

      if (result != null && result['success'] == true) {
        setState(() {
          _lastResult = 'Notificación 2FA enviada exitosamente';
        });
        _showSuccessSnackBar('Notificación 2FA enviada');
      } else {
        _showErrorSnackBar(result?['message'] ?? 'Error desconocido');
      }
    } catch (e) {
      _showErrorSnackBar('Error enviando 2FA: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendSecurityAlert(String alertType) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await NotificationTestService.sendSecurityAlert(alertType);

      if (result != null && result['success'] == true) {
        setState(() {
          _lastResult = 'Alerta de seguridad "$alertType" enviada';
        });
        _showSuccessSnackBar('Alerta enviada exitosamente');
      } else {
        _showErrorSnackBar(result?['message'] ?? 'Error desconocido');
      }
    } catch (e) {
      _showErrorSnackBar('Error enviando alerta: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _runFullConnectivityTest() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await NotificationTestService.testFullConnectivity();

      if (result['success'] == true) {
        setState(() {
          _lastResult = 'Prueba completa exitosa: ${result['message']}';
        });
        _showSuccessSnackBar('Conectividad verificada exitosamente');

        await _loadStats();
      } else {
        _showErrorSnackBar(
          'Error en step "${result['step']}": ${result['error']}',
        );
      }
    } catch (e) {
      _showErrorSnackBar('Error en prueba completa: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _testInApp2FA() {
    final inAppService = InAppNotificationService();
    final randomCode =
        (100000 + (DateTime.now().millisecondsSinceEpoch % 900000)).toString();

    inAppService.show2FA(
      randomCode,
      onTap: () {
        _showSuccessSnackBar('Código 2FA copiado: $randomCode');
      },
    );

    setState(() {
      _lastResult = 'Notificación in-app 2FA mostrada con código: $randomCode';
    });
    _showSuccessSnackBar('Notificación in-app 2FA enviada');
  }

  void _testInAppGeneral() {
    final inAppService = InAppNotificationService();

    inAppService.showGeneral(
      'Prueba de Notificación',
      'Esta es una notificación in-app de prueba generada localmente',
      onTap: () {
        _showSuccessSnackBar('Notificación in-app tocada');
      },
    );

    setState(() {
      _lastResult = 'Notificación in-app general mostrada';
    });
    _showSuccessSnackBar('Notificación in-app general enviada');
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFF1A1A1A),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.red),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFF1A1A1A),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Test de Notificaciones',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadStats,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.purple),
                  SizedBox(height: 16),
                  Text(
                    'Procesando...',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsCard(),
                  const SizedBox(height: 24),
                  _buildTestSection(),
                  if (_lastResult != null) ...[
                    const SizedBox(height: 24),
                    _buildResultCard(),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1F1F1F), Color(0xFF171717)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _canReceiveNotifications
              ? Colors.green.withValues(alpha: 0.3)
              : Colors.orange.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _canReceiveNotifications
                      ? Colors.green.withValues(alpha: 0.2)
                      : Colors.orange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _canReceiveNotifications
                      ? Icons.notifications_active
                      : Icons.notifications_off,
                  color: _canReceiveNotifications
                      ? Colors.green
                      : Colors.orange,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _canReceiveNotifications
                          ? 'Notificaciones Activas'
                          : 'Notificaciones Inactivas',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _canReceiveNotifications
                          ? 'Listo para recibir notificaciones push'
                          : 'No se pueden recibir notificaciones',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_stats != null) ...[
            const SizedBox(height: 16),
            const Divider(color: Colors.white24),
            const SizedBox(height: 16),
            _buildStatRow('Dispositivos Totales', '${_stats!['totalDevices']}'),
            _buildStatRow(
              'Dispositivos Activos',
              '${_stats!['activeDevices']}',
            ),
            _buildStatRow('Con FCM Token', '${_stats!['devicesWithFCM']}'),
          ],
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white60)),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pruebas de Notificaciones',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // Notificación simple
        _buildTestButton(
          'Notificación Simple',
          'Enviar una notificación de prueba básica',
          Icons.notifications,
          Colors.blue,
          _sendTestNotification,
        ),

        const SizedBox(height: 12),

        // Notificación 2FA
        _buildTestButton(
          'Notificación 2FA',
          'Simular notificación de código de seguridad',
          Icons.security,
          Colors.purple,
          _sendTest2FA,
        ),

        const SizedBox(height: 12),

        // Alerta de seguridad
        _buildTestButton(
          'Alerta de Seguridad',
          'Enviar alerta de nuevo inicio de sesión',
          Icons.warning,
          Colors.orange,
          () => _sendSecurityAlert('login_attempt'),
        ),

        const SizedBox(height: 20),

        // Prueba completa
        _buildTestButton(
          'Prueba Completa',
          'Verificar conectividad completa del sistema',
          Icons.play_circle_filled,
          Colors.green,
          _runFullConnectivityTest,
          isHighlighted: true,
        ),

        const SizedBox(height: 20),

        const Divider(color: Colors.white24),

        const SizedBox(height: 16),

        const Text(
          'Pruebas In-App',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        // Test notificación in-app 2FA
        _buildTestButton(
          'Notificación In-App 2FA',
          'Probar notificación local con código',
          Icons.phonelink_lock,
          Colors.purple,
          _testInApp2FA,
        ),

        const SizedBox(height: 12),

        // Test notificación in-app general
        _buildTestButton(
          'Notificación In-App General',
          'Probar notificación local simple',
          Icons.notifications_active,
          Colors.teal,
          _testInAppGeneral,
        ),
      ],
    );
  }

  Widget _buildTestButton(
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onPressed, {
    bool isHighlighted = false,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isHighlighted
              ? color.withValues(alpha: 0.2)
              : const Color(0xFF1A1A1A),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(
            color: color.withValues(alpha: isHighlighted ? 0.5 : 0.3),
          ),
          elevation: 0,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 12, color: Colors.white60),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.white60,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Último Resultado',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _lastResult!,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
