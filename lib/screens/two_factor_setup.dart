import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/firebase_service.dart';
import '../services/device_service.dart';
import '../services/auth_service.dart';
import 'device_management.dart';

class TwoFactorSetupScreen extends StatefulWidget {
  const TwoFactorSetupScreen({super.key});

  @override
  State<TwoFactorSetupScreen> createState() => _TwoFactorSetupScreenState();
}

class _TwoFactorSetupScreenState extends State<TwoFactorSetupScreen> {
  bool _isLoading = false;
  bool _isDeviceRegistered = false;
  bool _notificationsEnabled = false;
  Map<String, dynamic>? _deviceInfo;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDeviceStatus();
  }

  Future<void> _loadDeviceStatus() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final registered = await DeviceService.isDeviceRegistered();

      final deviceInfo = await FirebaseService.getDeviceInfo();

      final notificationsEnabled = await FirebaseService.requestPermissions();

      setState(() {
        _isDeviceRegistered = registered;
        _notificationsEnabled = notificationsEnabled;
        _deviceInfo = deviceInfo;
        _isLoading = false;
      });

    } catch (e) {
      setState(() {
        _errorMessage = 'Error cargando estado del dispositivo: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _enableTwoFactor() async {
    if (!_notificationsEnabled) {
      _showPermissionsDialog();
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (!_isDeviceRegistered) {
        final result = await DeviceService.registerCurrentDevice();

        if (result != null) {
          setState(() {
            _isDeviceRegistered = true;
          });

          await AuthService.set2FASetup(true);

          _showSuccessDialog();
        } else {
          throw Exception('No se pudo registrar el dispositivo');
        }
      } else {
        _showAlreadyEnabledDialog();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error activando 2FA: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _disableTwoFactor() async {
    final confirmed = await _showDisableConfirmationDialog();
    if (!confirmed) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final deviceId = _deviceInfo?['deviceId'];
      if (deviceId != null) {
        final success = await DeviceService.deactivateDevice(deviceId);

        if (success) {
          setState(() {
            _isDeviceRegistered = false;
          });

          await AuthService.set2FASetup(false);

          _showDisabledDialog();
        } else {
          throw Exception('No se pudo desactivar el dispositivo');
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error desactivando 2FA: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showPermissionsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.notifications_off, color: Colors.orange),
            SizedBox(width: 8),
            Text('Permisos Requeridos'),
          ],
        ),
        content: const Text(
          'Para usar la autenticación móvil necesitas permitir que la app envíe notificaciones.\n\n'
          'Ve a Configuración → Apps → City Lights → Notificaciones y actívalas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('¡2FA Activado!'),
          ],
        ),
        content: const Text(
          'Tu dispositivo está ahora registrado para autenticación de dos factores.\n\n'
          'La próxima vez que inicies sesión, recibirás una notificación push para verificar tu identidad.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Excelente'),
          ),
        ],
      ),
    );
  }

  void _showAlreadyEnabledDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info, color: Colors.blue),
            SizedBox(width: 8),
            Text('Ya Activado'),
          ],
        ),
        content: const Text(
          'Tu dispositivo ya está registrado para 2FA móvil.\n\n'
          'Puedes gestionar tus dispositivos desde la sección de configuración.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<bool> _showDisableConfirmationDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.warning, color: Colors.red),
                SizedBox(width: 8),
                Text('Desactivar 2FA'),
              ],
            ),
            content: const Text(
              '¿Estás seguro de que quieres desactivar la autenticación móvil?\n\n'
              'Tendrás que usar códigos por email para iniciar sesión.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Desactivar'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showDisabledDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.orange),
            SizedBox(width: 8),
            Text('2FA Desactivado'),
          ],
        ),
        content: const Text(
          'La autenticación móvil ha sido desactivada.\n\n'
          'Ahora usarás códigos por email para iniciar sesión.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
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
          'Autenticación Móvil',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.purple),
                  SizedBox(height: 16),
                  Text(
                    'Configurando dispositivo...',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderSection(),
                  const SizedBox(height: 32),
                  _buildStatusCard(),
                  const SizedBox(height: 24),
                  _buildBenefitsSection(),
                  const SizedBox(height: 24),
                  _buildDeviceInfoSection(),
                  const SizedBox(height: 32),
                  _buildActionButton(),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    _buildErrorCard(),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.purple, Colors.blue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.security, color: Colors.white, size: 40),
        ),
        const SizedBox(height: 16),
        const Text(
          'Autenticación de Dos Factores',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Protege tu cuenta con notificaciones push seguras',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildStatusCard() {
    final isActive = _isDeviceRegistered && _notificationsEnabled;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? Colors.green : Colors.orange,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isActive ? Icons.check_circle : Icons.warning,
                color: isActive ? Colors.green : Colors.orange,
              ),
              const SizedBox(width: 8),
              Text(
                isActive ? 'Activo' : 'Inactivo',
                style: TextStyle(
                  color: isActive ? Colors.green : Colors.orange,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isActive
                ? 'Tu dispositivo está configurado para 2FA móvil'
                : 'Activa 2FA móvil para mayor seguridad',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Beneficios',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildBenefitItem(
          Icons.speed,
          'Acceso Rápido',
          'Solo toca la notificación para aprobar',
        ),
        _buildBenefitItem(
          Icons.security,
          'Más Seguro',
          'Sin códigos que copiar o recordar',
        ),
        _buildBenefitItem(
          Icons.offline_bolt,
          'Sin Internet',
          'Funciona incluso sin conexión estable',
        ),
      ],
    );
  }

  Widget _buildBenefitItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.purple, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(color: Colors.white60, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceInfoSection() {
    if (_deviceInfo == null) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Información del Dispositivo',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildDeviceInfoRow(
                'Plataforma',
                _deviceInfo!['platform'] ?? 'Unknown',
              ),
              _buildDeviceInfoRow('Modelo', _deviceInfo!['model'] ?? 'Unknown'),
              if (_deviceInfo!['brand'] != null)
                _buildDeviceInfoRow('Marca', _deviceInfo!['brand']),
              _buildDeviceInfoRow(
                'Device ID',
                (_deviceInfo!['deviceId']?.substring(0, 8) ?? 'Unknown') +
                    '...',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDeviceInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white60)),
          Text(value, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading
                ? null
                : (_isDeviceRegistered ? _disableTwoFactor : _enableTwoFactor),
            style: ElevatedButton.styleFrom(
              backgroundColor: _isDeviceRegistered ? Colors.red : Colors.purple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              _isDeviceRegistered
                  ? 'Desactivar 2FA Móvil'
                  : 'Activar 2FA Móvil',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),

        const SizedBox(height: 12),

        if (_isDeviceRegistered) ...[
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _isLoading
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DeviceManagementScreen(),
                        ),
                      );
                    },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white70,
                side: BorderSide(color: Colors.white.withOpacity(0.3)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.devices, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Gestionar Dispositivos',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildErrorCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
