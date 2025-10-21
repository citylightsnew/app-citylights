import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../models/models.dart';
import '../services/firebase_service.dart';
import '../providers/auth_provider.dart';
import 'biometric_auth.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _checkAuthStatus();
  }

  void _setupAnimations() {
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _logoController.forward();
  }

  Future<void> _checkAuthStatus() async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (FirebaseService.isProcessing2FAApproval()) {
      return;
    }

    await Future.delayed(const Duration(milliseconds: 1500));

    try {
      final bool isLoggedIn = await AuthService.isLoggedIn();

      if (!isLoggedIn) {
        _navigateToLogin();
        return;
      }

      final sessionData = await AuthService.getSavedSession();

      if (sessionData == null) {
        _navigateToLogin();
        return;
      }

      final bool isProcessing2FA = FirebaseService.isProcessing2FAApproval();

      if (isProcessing2FA) {
        return;
      }

      final bool biometricsEnabled = sessionData['biometricsEnabled'] ?? false;
      if (biometricsEnabled) {
        final bool biometricsAvailable =
            await AuthService.isBiometricsAvailable();

        if (biometricsAvailable) {
          _navigateToBiometricAuth(sessionData);
          return;
        }
      }

      _navigateToDashboard(sessionData);
    } catch (e) {
      _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  void _navigateToBiometricAuth(Map<String, dynamic> sessionData) {
    if (mounted) {
      if (FirebaseService.isProcessing2FAApproval()) {
        return;
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => BiometricAuthScreen(sessionData: sessionData),
        ),
      );
    }
  }

  void _navigateToDashboard(Map<String, dynamic> sessionData) {
    if (mounted) {
      if (FirebaseService.isProcessing2FAApproval()) {
        return;
      }

      // Cargar los datos del usuario en el Provider
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.loadStoredAuth();

      Navigator.of(context).pushReplacementNamed('/dashboard');
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final logoSize = size.width * 0.35;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [Color(0xFF1A1A1A), Color(0xFF0D0D0D), Color(0xFF000000)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _logoController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _logoScale.value,
                      child: Opacity(
                        opacity: _logoOpacity.value,
                        child: Container(
                          width: logoSize,
                          height: logoSize,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF2A2A2A),
                                Color(0xFF1A1A1A),
                                Color(0xFF0F0F0F),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.6),
                                spreadRadius: 0,
                                blurRadius: 25,
                                offset: const Offset(0, 10),
                              ),
                              BoxShadow(
                                color: Colors.white.withOpacity(0.05),
                                spreadRadius: -2,
                                blurRadius: 10,
                                offset: const Offset(0, -5),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
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
                        ),
                      ),
                    );
                  },
                ),

                SizedBox(height: size.height * 0.05),

                AnimatedBuilder(
                  animation: _logoController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _logoOpacity.value,
                      child: Column(
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [
                                Color(0xFFFFFFFF),
                                Color(0xFFE0E0E0),
                                Color(0xFFC0C0C0),
                              ],
                            ).createShader(bounds),
                            child: Text(
                              'City Lights',
                              style: TextStyle(
                                fontSize: size.width * 0.08,
                                fontWeight: FontWeight.w300,
                                letterSpacing: 3,
                                color: Colors.white,
                              ),
                            ),
                          ),

                          SizedBox(height: size.height * 0.015),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.1),
                                  Colors.white.withOpacity(0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.1),
                              ),
                            ),
                            child: Text(
                              'Iluminando tu camino',
                              style: TextStyle(
                                fontSize: size.width * 0.035,
                                color: Colors.white.withOpacity(0.8),
                                fontWeight: FontWeight.w300,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                SizedBox(height: size.height * 0.08),

                AnimatedBuilder(
                  animation: _logoController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _logoOpacity.value,
                      child: Container(
                        width: 50,
                        height: 50,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(0.1),
                              Colors.white.withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: const CircularProgressIndicator(
                          color: Colors.white70,
                          strokeWidth: 2,
                        ),
                      ),
                    );
                  },
                ),

                SizedBox(height: size.height * 0.03),

                AnimatedBuilder(
                  animation: _logoController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _logoOpacity.value,
                      child: Text(
                        'Verificando sesión...',
                        style: TextStyle(
                          fontSize: size.width * 0.032,
                          color: Colors.white.withOpacity(0.6),
                          fontWeight: FontWeight.w300,
                          letterSpacing: 0.5,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
