import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/biometric_service.dart';
import '../../providers/auth_provider.dart';
import '../auth/widgets/custom_text_field.dart';
import '../auth/widgets/auth_button.dart';

class BiometricSetupScreen extends StatefulWidget {
  const BiometricSetupScreen({super.key});

  @override
  State<BiometricSetupScreen> createState() => _BiometricSetupScreenState();
}

class _BiometricSetupScreenState extends State<BiometricSetupScreen> {
  final _biometricService = BiometricService();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isDeviceSupported = false;
  bool _isBiometricEnabled = false;
  String _biometricType = 'Biométrico';

  @override
  void initState() {
    super.initState();
    _checkBiometricStatus();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkBiometricStatus() async {
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
          _isDeviceSupported = true;
          _isBiometricEnabled = isEnabled;
          _biometricType = typeName;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isDeviceSupported = false;
        });
      }
    }
  }

  Future<void> _handleEnableBiometric() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Autenticar con biométrico primero
      final authenticated = await _biometricService.authenticate(
        localizedReason: 'Autentícate para habilitar $_biometricType',
      );

      if (!authenticated) {
        _showSnackBar('Autenticación cancelada', isError: true);
        setState(() => _isLoading = false);
        return;
      }

      // Guardar credenciales
      await _biometricService.enableBiometricLogin(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        setState(() {
          _isBiometricEnabled = true;
          _isLoading = false;
        });

        _showSnackBar('$_biometricType habilitado correctamente');
        _emailController.clear();
        _passwordController.clear();
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Error al habilitar $_biometricType: $e', isError: true);
    }
  }

  Future<void> _handleDisableBiometric() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Deshabilitar $_biometricType'),
        content: Text(
          '¿Estás seguro de que deseas deshabilitar el inicio de sesión con $_biometricType?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Deshabilitar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      await _biometricService.disableBiometricLogin();

      if (mounted) {
        setState(() {
          _isBiometricEnabled = false;
          _isLoading = false;
        });

        _showSnackBar('$_biometricType deshabilitado correctamente');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Error al deshabilitar $_biometricType: $e', isError: true);
    }
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
      appBar: AppBar(title: const Text('Configuración Biométrica')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Icon
              Icon(
                _biometricType == 'Face ID'
                    ? Icons.face_rounded
                    : Icons.fingerprint_rounded,
                size: 80,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                'Inicio de Sesión $_biometricType',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Description
              if (!_isDeviceSupported)
                _buildUnsupportedMessage(theme)
              else if (_isBiometricEnabled)
                _buildEnabledStatus(theme)
              else
                _buildSetupForm(theme, authProvider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUnsupportedMessage(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.error.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
          const SizedBox(height: 16),
          Text(
            'Dispositivo no compatible',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.error,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Tu dispositivo no soporta autenticación biométrica o no tiene biometría configurada.',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEnabledStatus(ThemeData theme) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 24),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 48,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                '$_biometricType Habilitado',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Puedes iniciar sesión usando $_biometricType en lugar de tu contraseña.',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        AuthButton(
          text: 'Deshabilitar $_biometricType',
          onPressed: _handleDisableBiometric,
          isLoading: _isLoading,
          isOutlined: true,
          icon: Icons.block,
          textColor: theme.colorScheme.error,
        ),
      ],
    );
  }

  Widget _buildSetupForm(ThemeData theme, AuthProvider authProvider) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Ingresa tus credenciales para habilitar el inicio de sesión con $_biometricType',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Email Field
          CustomTextField(
            controller: _emailController,
            label: 'Correo Electrónico',
            hint: 'tu@email.com',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
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
          const SizedBox(height: 24),

          // Info Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tus credenciales se guardarán de forma segura y encriptada.',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Enable Button
          AuthButton(
            text: 'Habilitar $_biometricType',
            onPressed: _handleEnableBiometric,
            isLoading: _isLoading,
            icon: _biometricType == 'Face ID'
                ? Icons.face_rounded
                : Icons.fingerprint_rounded,
          ),
        ],
      ),
    );
  }
}
