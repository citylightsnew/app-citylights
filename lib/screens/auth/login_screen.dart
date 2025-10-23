import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/biometric_service.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/loading_overlay.dart';
import 'widgets/custom_text_field.dart';
import 'widgets/auth_button.dart';

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
  final _biometricService = BiometricService();

  // Two Factor Authentication
  final _twoFactorCodeController = TextEditingController();
  bool _showTwoFactorStep = false;
  bool _usePushNotification = false;
  String? _twoFactorRequestId;
  String _twoFactorEmail = '';
  bool _isPolling = false;
  Timer? _pollingTimer;
  int _countdown = 0;
  Timer? _countdownTimer;

  // Biometric
  bool _isBiometricAvailable = false;
  bool _isBiometricEnabled = false;
  String _biometricType = 'Biométrico';

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _checkBiometric();
  }

  Future<void> _checkBiometric() async {
    final isSupported = await _biometricService.isDeviceSupported();
    final canCheck = await _biometricService.canCheckBiometrics();
    final isEnabled = await _biometricService.isBiometricLoginEnabled();

    if (isSupported && canCheck) {
      final availableBiometrics = await _biometricService
          .getAvailableBiometrics();
      final typeName = _biometricService.getBiometricTypeName(
        availableBiometrics,
      );

      if (mounted) {
        setState(() {
          _isBiometricAvailable = true;
          _isBiometricEnabled = isEnabled;
          _biometricType = typeName;
        });
      }
    }
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _twoFactorCodeController.dispose();
    _animationController.dispose();
    _stopPolling();
    _stopCountdown();
    super.dispose();
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _isPolling = false;
  }

  void _stopCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
  }

  void _startPolling(AuthProvider authProvider) {
    if (_twoFactorRequestId == null) return;

    _isPolling = true;
    _countdown = 120; // 2 minutos

    // Timer de countdown
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_countdown > 0) {
            _countdown--;
          } else {
            _stopPolling();
            _stopCountdown();
            _showSnackBar('Tiempo agotado. Intenta de nuevo.', isError: true);
            _resetToLogin();
          }
        });
      }
    });

    // Timer de polling
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (!_isPolling || _twoFactorRequestId == null) {
        timer.cancel();
        return;
      }

      try {
        final response = await authProvider.check2FAStatus(
          _twoFactorRequestId!,
        );

        if (!mounted) return;

        if (response.isApproved) {
          _stopPolling();
          _stopCountdown();
          _showSnackBar('¡Autenticación exitosa!');
          _navigateToDashboard();
        } else if (response.isRejected) {
          _stopPolling();
          _stopCountdown();
          _showSnackBar('Autenticación rechazada.', isError: true);
          _resetToLogin();
        } else if (response.isExpired) {
          _stopPolling();
          _stopCountdown();
          _showSnackBar('Solicitud expirada.', isError: true);
          _resetToLogin();
        }
      } catch (e) {
        // Continuar polling si hay error
      }
    });
  }

  void _resetToLogin() {
    setState(() {
      _showTwoFactorStep = false;
      _usePushNotification = false;
      _twoFactorRequestId = null;
      _twoFactorEmail = '';
      _twoFactorCodeController.clear();
    });
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      final response = await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      if (response.requiresTwoFactor) {
        setState(() {
          _twoFactorEmail = _emailController.text.trim();
          _showTwoFactorStep = true;
          _usePushNotification = response.usePushNotification ?? false;
          _twoFactorRequestId = response.requestId;
        });

        if (_usePushNotification && _twoFactorRequestId != null) {
          _showSnackBar(response.message ?? 'Revisa tu dispositivo móvil');
          _startPolling(authProvider);
        }
      } else {
        _showSnackBar('¡Inicio de sesión exitoso!');
        _navigateToDashboard();
      }
    } catch (e) {
      _showSnackBar(e.toString(), isError: true);
    }
  }

  Future<void> _handleBiometricLogin() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      final credentials = await _biometricService.authenticateAndGetCredentials(
        localizedReason: 'Autentícate para iniciar sesión',
      );

      if (credentials == null) {
        // Usuario canceló o falló la autenticación
        return;
      }

      final email = credentials['email'];
      final password = credentials['password'];

      if (email == null || password == null) {
        _showSnackBar('Credenciales no encontradas', isError: true);
        return;
      }

      final response = await authProvider.login(email, password);

      if (!mounted) return;

      if (response.requiresTwoFactor) {
        setState(() {
          _twoFactorEmail = email;
          _showTwoFactorStep = true;
          _usePushNotification = response.usePushNotification ?? false;
          _twoFactorRequestId = response.requestId;
        });

        if (_usePushNotification && _twoFactorRequestId != null) {
          _showSnackBar(response.message ?? 'Revisa tu dispositivo móvil');
          _startPolling(authProvider);
        }
      } else {
        _showSnackBar('¡Inicio de sesión exitoso!');
        _navigateToDashboard();
      }
    } catch (e) {
      _showSnackBar(e.toString(), isError: true);
    }
  }

  Future<void> _handleTwoFactorSubmit() async {
    if (_twoFactorCodeController.text.length != 6) {
      _showSnackBar('Ingresa un código de 6 dígitos', isError: true);
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      await authProvider.verify2FA(
        _twoFactorEmail,
        _twoFactorCodeController.text,
      );

      if (!mounted) return;

      _showSnackBar('¡Verificación exitosa!');
      _navigateToDashboard();
    } catch (e) {
      _showSnackBar(e.toString(), isError: true);
    }
  }

  void _cancelPushAuth() {
    _stopPolling();
    _stopCountdown();
    _resetToLogin();
  }

  void _navigateToDashboard() {
    Navigator.of(context).pushReplacementNamed('/dashboard');
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: LoadingOverlay(
        isLoading: authProvider.isLoading,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: _showTwoFactorStep
                      ? _buildTwoFactorForm(theme, authProvider)
                      : _buildLoginForm(theme, authProvider),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm(ThemeData theme, AuthProvider authProvider) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Logo
          Icon(
            Icons.apartment_rounded,
            size: 80,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            'City Lights',
            style: theme.textTheme.displayMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Subtitle
          Text(
            'Bienvenido de vuelta',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.textTheme.bodyMedium?.color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),

          // Email Field
          CustomTextField(
            controller: _emailController,
            label: 'Correo Electrónico',
            hint: 'tu@email.com',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            textCapitalization: TextCapitalization.none,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Ingresa tu correo electrónico';
              }
              if (!RegExp(
                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
              ).hasMatch(value)) {
                return 'Ingresa un correo válido';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Password Field
          CustomTextField(
            controller: _passwordController,
            label: 'Contraseña',
            hint: '••••••••',
            prefixIcon: Icons.lock_outlined,
            isPassword: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Ingresa tu contraseña';
              }
              if (value.length < 6) {
                return 'La contraseña debe tener al menos 6 caracteres';
              }
              return null;
            },
          ),
          const SizedBox(height: 8),

          // Forgot Password
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/forgot-password');
              },
              child: const Text('¿Olvidaste tu contraseña?'),
            ),
          ),
          const SizedBox(height: 24),

          // Login Button
          AuthButton(
            text: 'Iniciar Sesión',
            onPressed: _handleLogin,
            icon: Icons.login_rounded,
          ),
          const SizedBox(height: 16),

          // Divider
          Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('o', style: theme.textTheme.bodyMedium),
              ),
              const Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 16),

          // Biometric Button (si está disponible y habilitado)
          if (_isBiometricAvailable && _isBiometricEnabled) ...[
            AuthButton(
              text: 'Iniciar con $_biometricType',
              onPressed: _handleBiometricLogin,
              isOutlined: true,
              icon: _biometricType == 'Face ID'
                  ? Icons.face_rounded
                  : Icons.fingerprint_rounded,
            ),
            const SizedBox(height: 16),
          ],

          // Biometric Setup Button (si está disponible pero no habilitado)
          if (_isBiometricAvailable && !_isBiometricEnabled) ...[
            OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).pushNamed('/biometric-setup');
              },
              icon: Icon(
                _biometricType == 'Face ID'
                    ? Icons.face_rounded
                    : Icons.fingerprint_rounded,
                size: 20,
              ),
              label: Text('Configurar $_biometricType'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Register Button
          AuthButton(
            text: 'Crear Cuenta',
            onPressed: () {
              Navigator.of(context).pushNamed('/register');
            },
            isOutlined: true,
            icon: Icons.person_add_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildTwoFactorForm(ThemeData theme, AuthProvider authProvider) {
    if (_usePushNotification && _isPolling) {
      return _buildPushNotificationWaiting(theme);
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Icon
        Icon(
          Icons.security_rounded,
          size: 80,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 24),

        // Title
        Text(
          'Verificación en Dos Pasos',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),

        // Description
        Text(
          'Ingresa el código de 6 dígitos enviado a tu correo',
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),

        // Code Field
        CustomTextField(
          controller: _twoFactorCodeController,
          label: 'Código de Verificación',
          hint: '123456',
          prefixIcon: Icons.pin_outlined,
          keyboardType: TextInputType.number,
          maxLength: 6,
          autofocus: true,
        ),
        const SizedBox(height: 24),

        // Verify Button
        AuthButton(
          text: 'Verificar',
          onPressed: _handleTwoFactorSubmit,
          icon: Icons.check_circle_outline,
        ),
        const SizedBox(height: 16),

        // Resend Code
        TextButton(
          onPressed: () async {
            try {
              await authProvider.resendCode(_twoFactorEmail);
              _showSnackBar('Código reenviado');
            } catch (e) {
              _showSnackBar(e.toString(), isError: true);
            }
          },
          child: const Text('Reenviar código'),
        ),
        const SizedBox(height: 8),

        // Cancel
        TextButton(onPressed: _resetToLogin, child: const Text('Cancelar')),
      ],
    );
  }

  Widget _buildPushNotificationWaiting(ThemeData theme) {
    final minutes = _countdown ~/ 60;
    final seconds = _countdown % 60;
    final timeString =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Animated Icon
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.8, end: 1.0),
          duration: const Duration(seconds: 1),
          curve: Curves.easeInOut,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Icon(
                Icons.notifications_active_rounded,
                size: 100,
                color: theme.colorScheme.primary,
              ),
            );
          },
        ),
        const SizedBox(height: 24),

        // Title
        Text(
          'Revisa tu Dispositivo',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),

        // Description
        Text(
          'Hemos enviado una notificación a tu dispositivo móvil. Por favor, aprueba la solicitud para continuar.',
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),

        // Countdown
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.timer_outlined, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Text(
                'Tiempo restante: $timeString',
                style: theme.textTheme.titleMedium,
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Cancel Button
        AuthButton(
          text: 'Cancelar',
          onPressed: _cancelPushAuth,
          isOutlined: true,
        ),
      ],
    );
  }
}
