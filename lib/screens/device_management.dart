import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/device_service.dart';
import '../services/firebase_service.dart';
import 'notification_test.dart';

class DeviceManagementScreen extends StatefulWidget {
  const DeviceManagementScreen({super.key});

  @override
  State<DeviceManagementScreen> createState() => _DeviceManagementScreenState();
}

class _DeviceManagementScreenState extends State<DeviceManagementScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _devices = [];
  String? _errorMessage;
  String? _currentDeviceId;

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Obtener todos los dispositivos del usuario
      final devices = await DeviceService.getMyDevices();

      // Obtener el ID del dispositivo actual para marcarlo
      final currentDeviceInfo = await FirebaseService.getDeviceInfo();

      setState(() {
        _devices = devices;
        _currentDeviceId = currentDeviceInfo['deviceId'];
        _isLoading = false;
      });

    } catch (e) {
      setState(() {
        _errorMessage = 'Error cargando dispositivos: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _deactivateDevice(String deviceId, String deviceName) async {
    final confirmed = await _showDeactivationConfirmDialog(deviceName);
    if (!confirmed) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await DeviceService.deactivateDevice(deviceId);

      if (success) {
        await _loadDevices();

        _showSuccessSnackBar('Dispositivo desactivado exitosamente');
      } else {
        _showErrorSnackBar('No se pudo desactivar el dispositivo');
      }
    } catch (e) {
      _showErrorSnackBar('Error desactivando dispositivo: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<bool> _showDeactivationConfirmDialog(String deviceName) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF1A1A1A),
            title: const Row(
              children: [
                Icon(Icons.warning, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  'Confirmar Desactivación',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            content: Text(
              '¿Estás seguro de que quieres desactivar el dispositivo "$deviceName"?\n\n'
              'Este dispositivo dejará de recibir notificaciones 2FA.',
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
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

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 8),
            Text(message),
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

  void _copyDeviceId(String deviceId) {
    Clipboard.setData(ClipboardData(text: deviceId));
    _showSuccessSnackBar('Device ID copiado al portapapeles');
  }

  String _getDeviceName(Map<String, dynamic> device) {
    final platform = device['platform'] ?? 'Unknown';
    final model = device['model'] ?? '';
    final brand = device['brand'] ?? '';

    if (brand.isNotEmpty && model.isNotEmpty) {
      return '$brand $model';
    } else if (model.isNotEmpty) {
      return model;
    } else {
      return '${platform.toUpperCase()} Device';
    }
  }

  IconData _getPlatformIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'android':
        return Icons.android;
      case 'ios':
        return Icons.phone_iphone;
      case 'web':
        return Icons.web;
      default:
        return Icons.devices;
    }
  }

  Color _getPlatformColor(String platform) {
    switch (platform.toLowerCase()) {
      case 'android':
        return Colors.green;
      case 'ios':
        return Colors.grey;
      case 'web':
        return Colors.blue;
      default:
        return Colors.purple;
    }
  }

  String _formatLastSeen(String? lastSeenString) {
    if (lastSeenString == null) return 'Nunca';

    try {
      final lastSeen = DateTime.parse(lastSeenString);
      final now = DateTime.now();
      final difference = now.difference(lastSeen);

      if (difference.inMinutes < 1) {
        return 'Hace un momento';
      } else if (difference.inHours < 1) {
        return 'Hace ${difference.inMinutes} min';
      } else if (difference.inDays < 1) {
        return 'Hace ${difference.inHours} h';
      } else if (difference.inDays < 30) {
        return 'Hace ${difference.inDays} días';
      } else {
        return 'Hace más de un mes';
      }
    } catch (e) {
      return 'Fecha inválida';
    }
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
          'Dispositivos Registrados',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.science, color: Colors.white),
            tooltip: 'Test de Notificaciones',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const NotificationTestScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadDevices,
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
                    'Cargando dispositivos...',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            )
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadDevices,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderSection(),
                  const SizedBox(height: 24),
                  if (_devices.isEmpty)
                    _buildEmptyState()
                  else
                    _buildDevicesList(),
                ],
              ),
            ),
    );
  }

  Widget _buildHeaderSection() {
    final activeDevices = _devices.where((d) => d['isActive'] == true).length;

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
        border: Border.all(color: Colors.purple.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.purple.withOpacity(0.3),
                      Colors.purple.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.devices,
                  color: Colors.purple,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dispositivos Registrados',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$activeDevices dispositivos activos',
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
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info, color: Colors.blue, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Solo los dispositivos activos pueden recibir notificaciones 2FA',
                    style: TextStyle(color: Colors.blue.shade300, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 60),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.purple.withOpacity(0.3),
                  Colors.purple.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(
              Icons.devices_other,
              color: Colors.purple,
              size: 60,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Sin Dispositivos',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'No tienes dispositivos registrados\npara autenticación móvil',
            style: TextStyle(color: Colors.white60, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Configurar 2FA'),
          ),
        ],
      ),
    );
  }

  Widget _buildDevicesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tus Dispositivos',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _devices.length,
          itemBuilder: (context, index) {
            final device = _devices[index];
            return _buildDeviceCard(device);
          },
        ),
      ],
    );
  }

  Widget _buildDeviceCard(Map<String, dynamic> device) {
    final deviceId = device['deviceId'] ?? '';
    final isCurrentDevice = deviceId == _currentDeviceId;
    final isActive = device['isActive'] == true;
    final platform = device['platform'] ?? 'unknown';
    final deviceName = _getDeviceName(device);
    final lastSeen = _formatLastSeen(device['lastSeen']);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isCurrentDevice
              ? [Colors.purple.withOpacity(0.2), Colors.purple.withOpacity(0.1)]
              : [const Color(0xFF1F1F1F), const Color(0xFF171717)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentDevice
              ? Colors.purple.withOpacity(0.5)
              : Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getPlatformColor(platform).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getPlatformIcon(platform),
                  color: _getPlatformColor(platform),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            deviceName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (isCurrentDevice) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.purple.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Este dispositivo',
                              style: TextStyle(
                                color: Colors.purple,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          isActive ? Icons.circle : Icons.circle_outlined,
                          color: isActive ? Colors.green : Colors.grey,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isActive ? 'Activo' : 'Inactivo',
                          style: TextStyle(
                            color: isActive ? Colors.green : Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Visto: $lastSeen',
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'ID: ${deviceId.substring(0, 8)}...',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _copyDeviceId(deviceId),
                child: Icon(
                  Icons.copy,
                  color: Colors.white.withOpacity(0.4),
                  size: 16,
                ),
              ),
              const Spacer(),
              if (isActive && !isCurrentDevice) ...[
                TextButton(
                  onPressed: () => _deactivateDevice(deviceId, deviceName),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                  ),
                  child: const Text(
                    'Desactivar',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
