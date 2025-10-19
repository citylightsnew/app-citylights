import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login.dart';
import 'two_factor_setup.dart';

class DashboardScreen extends StatefulWidget {
  final String userName;

  const DashboardScreen({super.key, required this.userName});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    _checkFor2FASetup();
  }

  Future<void> _checkFor2FASetup() async {
    await Future.delayed(const Duration(milliseconds: 500));

    final shouldShow = await AuthService.shouldShow2FASetup();

    if (shouldShow && mounted) {
      await AuthService.setHasLoggedInBefore();

      _showAutomatic2FASetup();
    }
  }

  void _showAutomatic2FASetup() {
    showDialog(
      context: context,
      barrierDismissible: false, // No se puede cerrar tocando fuera
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.security, color: Colors.purple, size: 24),
            SizedBox(width: 12),
            Text(
              'Configurar Seguridad',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Para mantener tu cuenta segura, te recomendamos configurar la autenticación en dos factores.',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              '• Protege tu cuenta con notificaciones push\n• Recibe alertas de accesos sospechosos\n• Configuración rápida y fácil',
              style: TextStyle(color: Colors.white60, fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              'Más tarde',
              style: TextStyle(color: Colors.white60),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const TwoFactorSetupScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
            ),
            child: const Text('Configurar ahora'),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Buenos días';
    } else if (hour < 18) {
      return 'Buenas tardes';
    } else {
      return 'Buenas noches';
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2A2A2A), Color(0xFF1A1A1A)],
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Icon(
                Icons.business_outlined,
                color: Colors.white.withOpacity(0.8),
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'City Lights - Panel',
              style: TextStyle(
                fontWeight: FontWeight.w300,
                fontSize: size.width * 0.045,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.red.withOpacity(0.2),
                  Colors.red.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: IconButton(
              icon: const Icon(Icons.logout_rounded, size: 20),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor: const Color(0xFF1F1F1F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: BorderSide(color: Colors.white.withOpacity(0.1)),
                      ),
                      title: Text(
                        'Cerrar Sesión',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      content: Text(
                        '¿Deseas salir del sistema del edificio?',
                        style: TextStyle(color: Colors.white.withOpacity(0.8)),
                      ),
                      actions: [
                        TextButton(
                          child: Text(
                            'Cancelar',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.red.withOpacity(0.8),
                                Colors.red.withOpacity(0.6),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TextButton(
                            child: const Text(
                              'Cerrar Sesión',
                              style: TextStyle(color: Colors.white),
                            ),
                            onPressed: () async {
                              Navigator.of(context).pop();
                              await AuthService.clearSession();
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 2.0,
            colors: [Color(0xFF1A1A1A), Color(0xFF0D0D0D), Color(0xFF000000)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting Card - Estilo edificio oscuro
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF1F1F1F),
                        Color(0xFF171717),
                        Color(0xFF0F0F0F),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        spreadRadius: 0,
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue.withOpacity(0.3),
                              Colors.purple.withOpacity(0.3),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        child: Icon(
                          Icons.person_outline_rounded,
                          size: 28,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_getGreeting()}!',
                              style: TextStyle(
                                fontSize: size.width * 0.04,
                                color: Colors.white.withOpacity(0.7),
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              widget.userName,
                              style: TextStyle(
                                fontSize: size.width * 0.05,
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.green.withOpacity(0.2),
                              Colors.green.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.green.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified_outlined,
                              size: 14,
                              color: Colors.green.withOpacity(0.8),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Conectado',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.green.withOpacity(0.9),
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Welcome Message - Tema edificio
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF1F1F1F),
                        Color(0xFF171717),
                        Color(0xFF0F0F0F),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        spreadRadius: 0,
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.blue.withOpacity(0.3),
                                  Colors.purple.withOpacity(0.3),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.business_center_outlined,
                              color: Colors.white.withOpacity(0.9),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Panel de Control - Edificio',
                            style: TextStyle(
                              fontSize: size.width * 0.045,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Bienvenido al sistema de gestión del edificio City Lights. Desde aquí puedes monitorear y controlar los diferentes servicios.',
                        style: TextStyle(
                          fontSize: size.width * 0.038,
                          color: Colors.white.withOpacity(0.8),
                          height: 1.5,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue.withOpacity(0.15),
                              Colors.purple.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.blue.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              color: Colors.blue.withOpacity(0.8),
                              size: 18,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Sistema en desarrollo. Nuevas funcionalidades de edificio próximamente.',
                                style: TextStyle(
                                  color: Colors.blue.withOpacity(0.9),
                                  fontSize: size.width * 0.032,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF1F1F1F), Color(0xFF171717)],
                          ),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.blue.withOpacity(0.3),
                                    Colors.blue.withOpacity(0.2),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.electrical_services_outlined,
                                size: 24,
                                color: Colors.blue.withOpacity(0.9),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Iluminación',
                              style: TextStyle(
                                fontSize: size.width * 0.035,
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Operativo',
                              style: TextStyle(
                                fontSize: size.width * 0.028,
                                color: Colors.green.withOpacity(0.8),
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF1F1F1F), Color(0xFF171717)],
                          ),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.green.withOpacity(0.3),
                                    Colors.green.withOpacity(0.2),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.security_outlined,
                                size: 24,
                                color: Colors.green.withOpacity(0.9),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Seguridad',
                              style: TextStyle(
                                fontSize: size.width * 0.035,
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Activo',
                              style: TextStyle(
                                fontSize: size.width * 0.028,
                                color: Colors.green.withOpacity(0.8),
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF1F1F1F),
                        Color(0xFF171717),
                        Color(0xFF0F0F0F),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.purple.withOpacity(0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.1),
                        spreadRadius: 0,
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.purple.withOpacity(0.3),
                                  Colors.purple.withOpacity(0.2),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.security,
                              color: Colors.purple.withOpacity(0.9),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Configuración de Seguridad',
                            style: TextStyle(
                              fontSize: size.width * 0.045,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Protege tu cuenta con autenticación de dos factores',
                        style: TextStyle(
                          fontSize: size.width * 0.035,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const TwoFactorSetupScreen(),
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.purple.withOpacity(0.2),
                                Colors.purple.withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.purple.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.smartphone,
                                color: Colors.purple,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Autenticación Móvil',
                                      style: TextStyle(
                                        fontSize: size.width * 0.04,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Configura notificaciones push para 2FA',
                                      style: TextStyle(
                                        fontSize: size.width * 0.032,
                                        color: Colors.white60,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.purple.withOpacity(0.7),
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF1F1F1F),
                        Color(0xFF171717),
                        Color(0xFF0F0F0F),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        spreadRadius: 0,
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.touch_app_outlined,
                            color: Colors.white.withOpacity(0.8),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Servicios del Edificio',
                            style: TextStyle(
                              fontSize: size.width * 0.045,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Control de Iluminación
                      _buildServiceTile(
                        context,
                        size,
                        icon: Icons.lightbulb_outline_rounded,
                        title: 'Control de Iluminación',
                        subtitle: 'Gestionar luces del edificio',
                        color: Colors.orange,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                'Sistema de luces próximamente',
                              ),
                              backgroundColor: Colors.orange.withOpacity(0.8),
                            ),
                          );
                        },
                      ),

                      _buildDivider(),

                      _buildServiceTile(
                        context,
                        size,
                        icon: Icons.door_front_door_outlined,
                        title: 'Control de Accesos',
                        subtitle: 'Puertas y ascensores',
                        color: Colors.blue,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                'Control de accesos próximamente',
                              ),
                              backgroundColor: Colors.blue.withOpacity(0.8),
                            ),
                          );
                        },
                      ),

                      _buildDivider(),

                      _buildServiceTile(
                        context,
                        size,
                        icon: Icons.build_outlined,
                        title: 'Mantenimiento',
                        subtitle: 'Reportes y solicitudes',
                        color: Colors.green,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                'Sistema de mantenimiento próximamente',
                              ),
                              backgroundColor: Colors.green.withOpacity(0.8),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceTile(
    BuildContext context,
    Size size, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.3), color.withOpacity(0.2)],
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: color.withOpacity(0.4)),
              ),
              child: Icon(icon, color: color.withOpacity(0.9), size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: size.width * 0.04,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: size.width * 0.032,
                      color: Colors.white.withOpacity(0.6),
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: Colors.white.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            Colors.white.withOpacity(0.1),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}
