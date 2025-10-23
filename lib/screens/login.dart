import 'package:flutter/material.dart';
import '../components/custom_text_field.dart';
import '../components/custom_button.dart';
import '../components/notification_helper.dart';
import '../services/auth_service.dart';
import '../services/dio_client.dart';
import 'otp_verification.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu email';
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Por favor ingresa un email válido';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu contraseña';
    }

    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }

    return null;
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      // Llamada real a la API
      final loginResponse = await _authService.login(email, password);

      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      // La respuesta siempre requiere 2FA según el backend
      NotificationHelper.showSuccess(
        context,
        loginResponse.message ?? 'Código enviado',
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => OtpVerificationScreen(email: email),
        ),
      );
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final logoSize = size.width * 0.25;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Stack(
        children: [
          // Fondo animado con gradiente
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topRight,
                radius: 1.5,
                colors: [
                  const Color(0xFF1A1A2E).withValues(alpha: 0.3),
                  const Color(0xFF16213E).withValues(alpha: 0.2),
                  const Color(0xFF0A0A0A),
                ],
              ),
            ),
          ),
          // Círculos decorativos con efecto blur
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.blue.withValues(alpha: 0.15),
                    Colors.purple.withValues(alpha: 0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.purple.withValues(alpha: 0.1),
                    Colors.blue.withValues(alpha: 0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Contenido principal
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  child: SizedBox(
                    height: size.height - MediaQuery.of(context).padding.top,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo/Header Section
                        Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            children: [
                              // Logo mejorado con animación
                              TweenAnimationBuilder<double>(
                                duration: const Duration(milliseconds: 1500),
                                tween: Tween(begin: 0.0, end: 1.0),
                                curve: Curves.elasticOut,
                                builder: (context, value, child) {
                                  return Transform.scale(
                                    scale: value,
                                    child: child,
                                  );
                                },
                                child: Container(
                                  width: logoSize,
                                  height: logoSize,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        const Color(0xFF2A2A3E),
                                        const Color(0xFF1A1A2E),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(28),
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.15,
                                      ),
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.blue.withValues(
                                          alpha: 0.3,
                                        ),
                                        spreadRadius: 0,
                                        blurRadius: 30,
                                        offset: const Offset(0, 10),
                                      ),
                                      BoxShadow(
                                        color: Colors.purple.withValues(
                                          alpha: 0.2,
                                        ),
                                        spreadRadius: 0,
                                        blurRadius: 20,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(26),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        // Efecto de brillo
                                        Positioned.fill(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [
                                                  Colors.white.withValues(
                                                    alpha: 0.1,
                                                  ),
                                                  Colors.transparent,
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        Image.asset(
                                          'assets/images/logo.png',
                                          fit: BoxFit.contain,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return Container(
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      begin: Alignment.topLeft,
                                                      end:
                                                          Alignment.bottomRight,
                                                      colors: [
                                                        Colors.blue.withValues(
                                                          alpha: 0.7,
                                                        ),
                                                        Colors.purple
                                                            .withValues(
                                                              alpha: 0.7,
                                                            ),
                                                      ],
                                                    ),
                                                  ),
                                                  child: const Icon(
                                                    Icons.apartment,
                                                    size: 60,
                                                    color: Colors.white,
                                                  ),
                                                );
                                              },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(height: size.height * 0.03),

                              // Título con gradiente mejorado
                              ShaderMask(
                                shaderCallback: (bounds) =>
                                    const LinearGradient(
                                      colors: [
                                        Color(0xFFFFFFFF),
                                        Color(0xFFE0E0FF),
                                        Color(0xFFC0C0FF),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ).createShader(bounds),
                                child: Text(
                                  'City Lights',
                                  style: TextStyle(
                                    fontSize: size.width * 0.085,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 3,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        color: Colors.blue.withValues(
                                          alpha: 0.5,
                                        ),
                                        offset: const Offset(0, 2),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              SizedBox(height: size.height * 0.012),

                              // Subtítulo mejorado
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white.withValues(alpha: 0.12),
                                      Colors.white.withValues(alpha: 0.06),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.15),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.2,
                                      ),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.blue.withValues(alpha: 0.6),
                                            Colors.purple.withValues(
                                              alpha: 0.6,
                                            ),
                                          ],
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.apartment_rounded,
                                        size: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Gestión Inteligente',
                                      style: TextStyle(
                                        fontSize: size.width * 0.032,
                                        color: Colors.white.withValues(
                                          alpha: 0.9,
                                        ),
                                        fontWeight: FontWeight.w400,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Tarjeta de login mejorada
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minHeight: constraints.maxHeight,
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.fromLTRB(
                                      24,
                                      12,
                                      24,
                                      24,
                                    ),
                                    padding: const EdgeInsets.all(28),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          const Color(
                                            0xFF1F1F2E,
                                          ).withValues(alpha: 0.95),
                                          const Color(
                                            0xFF16162A,
                                          ).withValues(alpha: 0.9),
                                          const Color(
                                            0xFF0F0F1E,
                                          ).withValues(alpha: 0.95),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(28),
                                      border: Border.all(
                                        color: Colors.white.withValues(
                                          alpha: 0.12,
                                        ),
                                        width: 1.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.6,
                                          ),
                                          spreadRadius: 0,
                                          blurRadius: 40,
                                          offset: const Offset(0, 15),
                                        ),
                                        BoxShadow(
                                          color: Colors.blue.withValues(
                                            alpha: 0.1,
                                          ),
                                          spreadRadius: -5,
                                          blurRadius: 20,
                                          offset: const Offset(0, -5),
                                        ),
                                      ],
                                    ),
                                    child: Form(
                                      key: _formKey,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // Encabezado del formulario
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(
                                                  10,
                                                ),
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Colors.blue.withValues(
                                                        alpha: 0.3,
                                                      ),
                                                      Colors.purple.withValues(
                                                        alpha: 0.3,
                                                      ),
                                                    ],
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  border: Border.all(
                                                    color: Colors.white
                                                        .withValues(alpha: 0.1),
                                                  ),
                                                ),
                                                child: Icon(
                                                  Icons.login_rounded,
                                                  color: Colors.white
                                                      .withValues(alpha: 0.9),
                                                  size: 20,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Text(
                                                'Iniciar Sesión',
                                                style: TextStyle(
                                                  fontSize: size.width * 0.058,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                            ],
                                          ),

                                          SizedBox(height: size.height * 0.035),

                                          // Campos del formulario
                                          CustomTextField(
                                            label: 'Correo Electrónico',
                                            hint: 'ejemplo@citylights.com',
                                            controller: _emailController,
                                            keyboardType:
                                                TextInputType.emailAddress,
                                            prefixIcon: Icons.email_outlined,
                                            validator: _validateEmail,
                                          ),

                                          const SizedBox(height: 22),

                                          CustomTextField(
                                            label: 'Contraseña',
                                            hint: '••••••••',
                                            controller: _passwordController,
                                            obscureText: !_isPasswordVisible,
                                            prefixIcon: Icons.lock_outline,
                                            suffixIcon: _isPasswordVisible
                                                ? Icons.visibility_off_outlined
                                                : Icons.visibility_outlined,
                                            onSuffixIconTap: () {
                                              setState(() {
                                                _isPasswordVisible =
                                                    !_isPasswordVisible;
                                              });
                                            },
                                            validator: _validatePassword,
                                          ),

                                          const SizedBox(height: 32),

                                          // Botón de login mejorado
                                          CustomButton(
                                            text: 'Acceder',
                                            isLoading: _isLoading,
                                            onPressed: _handleLogin,
                                          ),

                                          const SizedBox(height: 24),

                                          // Divider con texto
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Divider(
                                                  color: Colors.white
                                                      .withValues(alpha: 0.1),
                                                  thickness: 1,
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                    ),
                                                child: Text(
                                                  '¿Necesitas ayuda?',
                                                  style: TextStyle(
                                                    color: Colors.white
                                                        .withValues(alpha: 0.5),
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w300,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Divider(
                                                  color: Colors.white
                                                      .withValues(alpha: 0.1),
                                                  thickness: 1,
                                                ),
                                              ),
                                            ],
                                          ),

                                          const SizedBox(height: 20),

                                          // Botón de ayuda
                                          Center(
                                            child: TextButton.icon(
                                              onPressed: () {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: const Text(
                                                      'Contacta al administrador del edificio',
                                                    ),
                                                    backgroundColor:
                                                        const Color(0xFF1F1F2E),
                                                    behavior: SnackBarBehavior
                                                        .floating,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                    ),
                                                  ),
                                                );
                                              },
                                              icon: Icon(
                                                Icons.help_outline_rounded,
                                                size: 18,
                                                color: Colors.white.withValues(
                                                  alpha: 0.7,
                                                ),
                                              ),
                                              label: Text(
                                                'Problemas de acceso',
                                                style: TextStyle(
                                                  color: Colors.white
                                                      .withValues(alpha: 0.7),
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              style: TextButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 12,
                                                    ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  side: BorderSide(
                                                    color: Colors.white
                                                        .withValues(alpha: 0.1),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
