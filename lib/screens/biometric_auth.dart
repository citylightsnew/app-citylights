import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../components/notification_helper.dart';
import '../providers/auth_provider.dart';
import 'login.dart';

class BiometricAuthScreen extends StatefulWidget {
  final Map<String, dynamic> sessionData;

  const BiometricAuthScreen({Key? key, required this.sessionData})
    : super(key: key);

  @override
  State<BiometricAuthScreen> createState() => _BiometricAuthScreenState();
}

class _BiometricAuthScreenState extends State<BiometricAuthScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isAuthenticating = false;
  List<BiometricType> _availableBiometrics = [];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadBiometrics();
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);
  }

  Future<void> _loadBiometrics() async {
    final biometrics = await AuthService.getAvailableBiometrics();
    setState(() {
      _availableBiometrics = biometrics;
    });

    if (biometrics.isNotEmpty) {
      await Future.delayed(const Duration(milliseconds: 500));
      _authenticate();
    }
  }

  Future<void> _authenticate() async {
    if (_isAuthenticating) return;

    setState(() {
      _isAuthenticating = true;
    });

    try {
      final bool authenticated = await AuthService.authenticateWithBiometrics();

      if (authenticated && mounted) {
        // Cargar los datos del usuario en el Provider
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.loadStoredAuth();

        Navigator.of(context).pushReplacementNamed('/dashboard');
      } else if (mounted) {
        setState(() {
          _isAuthenticating = false;
        });
        NotificationHelper.showError(
          context,
          'Autenticación fallida. Intenta de nuevo.',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAuthenticating = false;
        });
        NotificationHelper.showError(
          context,
          'Error durante la autenticación: ${e.toString()}',
        );
      }
    }
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cerrar Sesión'),
          content: const Text('¿Estás seguro que deseas cerrar tu sesión?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await AuthService.clearSession();
                if (mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                }
              },
              child: const Text('Cerrar Sesión'),
            ),
          ],
        );
      },
    );
  }

  IconData _getBiometricIcon() {
    if (_availableBiometrics.contains(BiometricType.fingerprint)) {
      return Icons.fingerprint_rounded;
    } else if (_availableBiometrics.contains(BiometricType.face)) {
      return Icons.face_rounded;
    } else if (_availableBiometrics.contains(BiometricType.iris)) {
      return Icons.visibility_rounded;
    } else if (_availableBiometrics.contains(BiometricType.strong) ||
        _availableBiometrics.contains(BiometricType.weak)) {
      return Icons.fingerprint_rounded; // Para tipos genéricos, usar huella
    }
    return Icons.security_rounded;
  }

  String _getBiometricText() {
    if (_availableBiometrics.contains(BiometricType.fingerprint)) {
      return 'Coloca tu dedo en el sensor';
    } else if (_availableBiometrics.contains(BiometricType.face)) {
      return 'Mira hacia la cámara';
    } else if (_availableBiometrics.contains(BiometricType.iris)) {
      return 'Acerca tu ojo al sensor';
    } else if (_availableBiometrics.contains(BiometricType.strong) ||
        _availableBiometrics.contains(BiometricType.weak)) {
      return 'Usa tu huella o PIN';
    }
    return 'Usa tu método de desbloqueo';
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userData = widget.sessionData['user'] as Map<String, String>;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Fondo oscuro
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1E1E1E), // Gris oscuro arriba
              Color(0xFF121212), // Negro en el centro
              Color(0xFF0A0A0A), // Negro más profundo abajo
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.08,
              vertical: screenHeight * 0.04,
            ),
            child: Column(
              children: [
                // Header minimalista con logout
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Espaciador invisible para centrar el logo
                    SizedBox(width: 40),

                    // Logo centrado
                    Container(
                      width: 45,
                      height: 45,
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          // Fallback en caso de error con la imagen
                          return Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.blue.withOpacity(0.8),
                                  Colors.purple.withOpacity(0.8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Icon(
                              Icons.lightbulb_outlined,
                              color: Colors.white,
                              size: 60,
                            ),
                          );
                        },
                      ),
                    ),

                    // Botón logout
                    IconButton(
                      onPressed: _logout,
                      icon: const Icon(
                        Icons.logout_rounded,
                        color: Colors.white70,
                        size: 24,
                      ),
                    ),
                  ],
                ),

                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          Text(
                            'Hola ${userData['name']?.split(' ')[0] ?? 'Usuario'}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenHeight * 0.032,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),

                          SizedBox(height: screenHeight * 0.01),

                          Text(
                            'Desbloquea para continuar',
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: screenHeight * 0.018,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: screenHeight * 0.08),

                      AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _isAuthenticating
                                ? 1.0
                                : _pulseAnimation.value,
                            child: Container(
                              width: screenWidth * 0.28,
                              height: screenWidth * 0.28,
                              decoration: BoxDecoration(
                                color: _isAuthenticating
                                    ? Colors.grey[800]
                                    : const Color(0xFF6C63FF).withOpacity(0.15),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _isAuthenticating
                                      ? Colors.grey[600]!
                                      : const Color(
                                          0xFF6C63FF,
                                        ).withOpacity(0.6),
                                  width: 2,
                                ),
                              ),
                              child: _isAuthenticating
                                  ? const Center(
                                      child: CircularProgressIndicator(
                                        color: Color(0xFF6C63FF),
                                        strokeWidth: 3,
                                      ),
                                    )
                                  : Icon(
                                      _getBiometricIcon(),
                                      size: screenWidth * 0.12,
                                      color: const Color(0xFF6C63FF),
                                    ),
                            ),
                          );
                        },
                      ),

                      SizedBox(height: screenHeight * 0.04),

                      // Texto instructivo
                      Text(
                        _isAuthenticating
                            ? 'Autenticando...'
                            : _getBiometricText(),
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: screenHeight * 0.020,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                if (!_isAuthenticating) ...[
                  Container(
                    width: double.infinity,
                    height: 50,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ElevatedButton(
                      onPressed: _authenticate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Intentar de nuevo',
                        style: TextStyle(
                          fontSize: screenHeight * 0.018,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  TextButton(
                    onPressed: () async {
                      await AuthService.clearSession();
                      if (mounted) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      }
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white54,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      'Usar otra cuenta',
                      style: TextStyle(
                        fontSize: screenHeight * 0.016,
                        fontWeight: FontWeight.w400,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.white54,
                      ),
                    ),
                  ),
                ],

                SizedBox(height: screenHeight * 0.02),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
