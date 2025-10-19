import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../components/custom_button.dart';
import '../components/notification_helper.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'dashboard.dart';
import 'login.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;
  final bool usePushNotification;

  const OtpVerificationScreen({
    super.key,
    required this.email,
    this.usePushNotification = false,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  bool _isLoading = false;
  bool _canResend = false;
  int _countdown = 900; // 15 minutos = 900 segundos
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _startCountdown() {
    setState(() {
      _canResend = false;
      _countdown = 900; // 15 minutos = 900 segundos
    });

    _timer?.cancel(); // Cancel any existing timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _countdown--;
      });

      if (_countdown <= 0) {
        timer.cancel();
        setState(() {
          _canResend = true;
        });
      }
    });
  }

  String _formatCountdown(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _onOtpChanged(String value, int index) {
    if (value.length == 1) {
      // Move to next field
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        // Auto-verify when all fields are filled
        String otp = _controllers.map((controller) => controller.text).join();
        if (otp.length == 6) {
          _verifyOtp();
        }
      }
    } else if (value.isEmpty && index > 0) {
      // Move to previous field
      _focusNodes[index - 1].requestFocus();
    }
  }

  Future<void> _verifyOtp() async {
    if (!mounted) return;

    String otp = _controllers.map((controller) => controller.text).join();

    if (otp.length != 6) {
      NotificationHelper.showError(
        context,
        'Por favor ingresa el código completo',
      );
      return;
    }

    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final verifyResponse = await ApiService.verify2FA(widget.email, otp);

      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      await _handleSuccessfulLogin(verifyResponse);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      if (e is ApiException) {
        NotificationHelper.showError(context, e.message);
      } else {
        NotificationHelper.showError(
          context,
          'Error de conexión. Verifica tu conexión a internet.',
        );
      }
      _clearOtp();
    }
  }

  Future<void> _resendCode() async {
    if (!_canResend || !mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      NotificationHelper.showSuccess(context, 'Código reenviado exitosamente');
      _startCountdown();
      _clearOtp();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      NotificationHelper.showError(
        context,
        'Error al reenviar código. Intenta nuevamente.',
      );
    }
  }

  void _clearOtp() {
    for (var controller in _controllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
  }

  Future<void> _handleSuccessfulLogin(TwoFactorResponse verifyResponse) async {
    final bool biometricsAvailable = await AuthService.isBiometricsAvailable();

    if (biometricsAvailable && mounted) {
      final bool? enableBiometrics = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('🔒 Seguridad Adicional'),
            content: const Text(
              '¿Deseas habilitar el desbloqueo biométrico (huella dactilar) '
              'para acceder más rápido a tu cuenta?\n\n'
              'Esto mantendrá tu sesión segura y activa.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Ahora no'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Habilitar'),
              ),
            ],
          );
        },
      );

      // Guardar sesión con configuración de biometría
      final bool biometricsToEnable = enableBiometrics ?? false;

      await AuthService.saveSession(
        accessToken: verifyResponse.accessToken,
        user: verifyResponse.user,
        enableBiometrics: biometricsToEnable,
      );

      if (mounted) {
        NotificationHelper.showSuccess(
          context,
          enableBiometrics == true
              ? '¡Biometría habilitada! Bienvenido ${verifyResponse.user.name}'
              : '¡Bienvenido ${verifyResponse.user.name}!',
        );
      }
    } else {
      await AuthService.saveSession(
        accessToken: verifyResponse.accessToken,
        user: verifyResponse.user,
        enableBiometrics: false,
      );

      if (mounted) {
        NotificationHelper.showSuccess(
          context,
          '¡Bienvenido ${verifyResponse.user.name}!',
        );
      }
    }

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) =>
              DashboardScreen(userName: verifyResponse.user.name),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final logoSize = size.width * 0.3;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: Colors.white.withOpacity(0.8),
            size: 28,
          ),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          },
        ),
      ),
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
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SizedBox(height: size.height * 0.02),

                // Logo/Header Section - Tema Edificio
                Column(
                  children: [
                    // Logo con efecto edificio
                    Container(
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
                                Icons.security,
                                size: 60,
                                color: Colors.white,
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    SizedBox(height: size.height * 0.03),

                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [
                          Color(0xFFFFFFFF),
                          Color(0xFFE0E0E0),
                          Color(0xFFC0C0C0),
                        ],
                      ).createShader(bounds),
                      child: Text(
                        'Verificación de Seguridad',
                        style: TextStyle(
                          fontSize: size.width * 0.065,
                          fontWeight: FontWeight.w300,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                    ),

                    SizedBox(height: size.height * 0.015),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
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
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                widget.usePushNotification
                                    ? Icons.notifications_active
                                    : Icons.email,
                                color: Colors.purple,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                widget.usePushNotification
                                    ? 'Notificación enviada'
                                    : 'Código enviado a',
                                style: TextStyle(
                                  fontSize: size.width * 0.032,
                                  color: Colors.white.withOpacity(0.7),
                                  fontWeight: FontWeight.w300,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.usePushNotification
                                ? 'Revisa tu dispositivo registrado'
                                : widget.email,
                            style: TextStyle(
                              fontSize: size.width * 0.035,
                              fontWeight: FontWeight.w400,
                              color: Colors.white.withOpacity(0.9),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: size.height * 0.04),

                // OTP Form - Estilo oscuro
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 0,
                    vertical: 16,
                  ),
                  padding: const EdgeInsets.all(24),
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
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.verified_user_outlined,
                            color: Colors.white.withOpacity(0.8),
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Código de Acceso',
                            style: TextStyle(
                              fontSize: size.width * 0.048,
                              fontWeight: FontWeight.w300,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: size.height * 0.03),

                      // OTP Input Fields - Estilo oscuro
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(6, (index) {
                          return Container(
                            width: 45,
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withOpacity(0.1),
                                  Colors.white.withOpacity(0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                              ),
                            ),
                            child: TextFormField(
                              controller: _controllers[index],
                              focusNode: _focusNodes[index],
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              maxLength: 1,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              decoration: InputDecoration(
                                counterText: '',
                                border: InputBorder.none,
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.white.withOpacity(0.5),
                                    width: 2,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              onChanged: (value) => _onOtpChanged(value, index),
                            ),
                          );
                        }),
                      ),

                      SizedBox(height: size.height * 0.03),

                      // Verify Button
                      CustomButton(
                        text: 'Verificar Acceso',
                        isLoading: _isLoading,
                        onPressed: _verifyOtp,
                      ),

                      SizedBox(height: size.height * 0.02),

                      // Resend Code Section
                      Column(
                        children: [
                          Text(
                            '¿No recibiste el código?',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: size.width * 0.032,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: _canResend ? _resendCode : null,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    _canResend
                                        ? Colors.white.withOpacity(0.1)
                                        : Colors.white.withOpacity(0.05),
                                    _canResend
                                        ? Colors.white.withOpacity(0.05)
                                        : Colors.white.withOpacity(0.02),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: _canResend
                                      ? Colors.white.withOpacity(0.2)
                                      : Colors.white.withOpacity(0.1),
                                ),
                              ),
                              child: Text(
                                _canResend
                                    ? 'Reenviar código'
                                    : 'Reenviar en ${_formatCountdown(_countdown)}',
                                style: TextStyle(
                                  color: _canResend
                                      ? Colors.white.withOpacity(0.9)
                                      : Colors.white.withOpacity(0.5),
                                  fontWeight: FontWeight.w300,
                                  fontSize: size.width * 0.032,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: size.height * 0.02),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
