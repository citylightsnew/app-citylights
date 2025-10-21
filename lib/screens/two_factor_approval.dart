import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/firebase_service.dart';
import '../components/notification_helper.dart';
import '../models/user_model.dart';
import '../screens/dashboard.dart';

class TwoFactorApprovalScreen extends StatefulWidget {
  final String requestId;
  final String email;
  final Map<String, dynamic> requestData;

  const TwoFactorApprovalScreen({
    super.key,
    required this.requestId,
    required this.email,
    required this.requestData,
  });

  @override
  State<TwoFactorApprovalScreen> createState() =>
      _TwoFactorApprovalScreenState();
}

class _TwoFactorApprovalScreenState extends State<TwoFactorApprovalScreen> {
  bool _isProcessing = false;

  Future<void> _handleApproval(bool approved) async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final response = await ApiService.approveTwoFactor(
        widget.email,
        widget.requestId,
        approved,
      );

      if (!mounted) return;

      if (approved) {
        final accessToken = response['access_token'] as String?;
        final userData = response['user'] as Map<String, dynamic>?;

        if (accessToken != null && userData != null) {
          await AuthService.saveSession(
            accessToken: accessToken,
            user: User(
              id: userData['id'] as String,
              name: userData['name'] as String? ?? '',
              email: userData['email'] as String,
              telephone: userData['telephone'] as String? ?? '',
              roleId:
                  userData['roleId'] as String? ??
                  userData['role_id'] as String? ??
                  '',
              createdAt:
                  DateTime.tryParse(
                    userData['createdAt'] as String? ??
                        userData['created_at'] as String? ??
                        '',
                  ) ??
                  DateTime.now(),
              updatedAt:
                  DateTime.tryParse(
                    userData['updatedAt'] as String? ??
                        userData['updated_at'] as String? ??
                        '',
                  ) ??
                  DateTime.now(),
              twoFactorEnabled:
                  userData['twoFactorEnabled'] as bool? ??
                  userData['two_factor_enabled'] as bool? ??
                  true,
            ),
            enableBiometrics: false,
          );
        }

        NotificationHelper.showSuccess(
          context,
          '✅ Acceso aprobado exitosamente',
        );

        await Future.delayed(const Duration(seconds: 1));

        if (!mounted) return;

        FirebaseService.reset2FAApprovalFlag();

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => DashboardScreen(
              userName:
                  userData?['name'] as String? ??
                  userData?['email'] as String? ??
                  'Usuario',
            ),
          ),
          (route) => false, // Eliminar todas las rutas previas
        );
      } else {
        NotificationHelper.showSuccess(
          context,
          '❌ Acceso rechazado. Tu cuenta está segura.',
        );

        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          FirebaseService.reset2FAApprovalFlag();
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isProcessing = false;
      });

      NotificationHelper.showError(
        context,
        'Error al procesar la solicitud: $e',
      );
    }
  }

  String _getDeviceInfo() {
    final userAgent = widget.requestData['userAgent'] ?? 'Desconocido';

    if (userAgent.toLowerCase().contains('chrome')) {
      return '🌐 Google Chrome';
    } else if (userAgent.toLowerCase().contains('firefox')) {
      return '🦊 Mozilla Firefox';
    } else if (userAgent.toLowerCase().contains('safari')) {
      return '🧭 Safari';
    } else if (userAgent.toLowerCase().contains('edge')) {
      return '🔷 Microsoft Edge';
    } else if (userAgent.toLowerCase().contains('insomnia')) {
      return '⚡ Insomnia (API Client)';
    } else if (userAgent.toLowerCase().contains('postman')) {
      return '📮 Postman (API Client)';
    }

    return '💻 Navegador Desconocido';
  }

  String _getFormattedDate() {
    try {
      final timestamp = widget.requestData['timestamp'];
      if (timestamp != null) {
        final date = DateTime.parse(timestamp);
        final now = DateTime.now();
        final difference = now.difference(date);

        if (difference.inSeconds < 60) {
          return 'Hace ${difference.inSeconds} segundos';
        } else if (difference.inMinutes < 60) {
          return 'Hace ${difference.inMinutes} minutos';
        } else {
          return 'Hace ${difference.inHours} horas';
        }
      }
    } catch (e) {
      print('Error parsing timestamp: $e');
    }
    return 'Ahora mismo';
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.5,
            colors: [Color(0xFF1A1A1A), Color(0xFF0D0D0D), Color(0xFF000000)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: size.height * 0.05),
                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.orange.withOpacity(0.3),
                          Colors.red.withOpacity(0.3),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.3),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.security,
                      size: 60,
                      color: Colors.orange,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                const Text(
                  '🔐 Solicitud de Acceso',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                Text(
                  'Alguien está intentando acceder a tu cuenta',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                // Información de la solicitud
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(
                        Icons.computer,
                        'Dispositivo',
                        _getDeviceInfo(),
                      ),
                      const Divider(height: 32, color: Colors.white24),
                      _buildInfoRow(
                        Icons.access_time,
                        'Hora',
                        _getFormattedDate(),
                      ),
                      const Divider(height: 32, color: Colors.white24),
                      _buildInfoRow(
                        Icons.info_outline,
                        'User Agent',
                        widget.requestData['userAgent'] ?? 'Desconocido',
                        isSmallText: true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.orange,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '¿Fuiste tú quien intentó iniciar sesión?',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isProcessing
                            ? null
                            : () => _handleApproval(false),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.withOpacity(0.2),
                          foregroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: Colors.red.withOpacity(0.5),
                            ),
                          ),
                        ),
                        child: _isProcessing
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.red,
                                  ),
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.block, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Rechazar',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isProcessing
                            ? null
                            : () => _handleApproval(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isProcessing
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.check_circle, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Aprobar',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    bool isSmallText = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.purple.withOpacity(0.8), size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.5),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: isSmallText ? 12 : 16,
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w600,
                ),
                maxLines: isSmallText ? 2 : 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
