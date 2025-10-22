import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _biometricEnabled = false;
  bool _darkMode = true;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Configuración'),
        backgroundColor: const Color(0xFF6B7280),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Perfil del usuario
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF6B7280),
                    const Color(0xFF6B7280).withOpacity(0.8),
                  ],
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: Text(
                      user?.name.isNotEmpty == true
                          ? user!.name[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.name ?? 'Usuario',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (user?.role != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.shield,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            user!.role!.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Sección: Preferencias
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'PREFERENCIAS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textSecondary.withOpacity(0.7),
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 12),

            _buildSettingCard(
              icon: FontAwesomeIcons.bell,
              title: 'Notificaciones',
              subtitle: 'Recibir alertas y notificaciones push',
              trailing: Switch(
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() => _notificationsEnabled = value);
                },
                activeColor: const Color(0xFF6B7280),
              ),
            ),

            _buildSettingCard(
              icon: FontAwesomeIcons.fingerprint,
              title: 'Autenticación Biométrica',
              subtitle: 'Usar huella o Face ID para login',
              trailing: Switch(
                value: _biometricEnabled,
                onChanged: (value) {
                  setState(() => _biometricEnabled = value);
                },
                activeColor: const Color(0xFF6B7280),
              ),
            ),

            _buildSettingCard(
              icon: FontAwesomeIcons.moon,
              title: 'Modo Oscuro',
              subtitle: 'Tema oscuro de la aplicación',
              trailing: Switch(
                value: _darkMode,
                onChanged: (value) {
                  setState(() => _darkMode = value);
                },
                activeColor: const Color(0xFF6B7280),
              ),
            ),

            const SizedBox(height: 24),

            // Sección: Cuenta
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'CUENTA',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textSecondary.withOpacity(0.7),
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 12),

            _buildSettingCard(
              icon: FontAwesomeIcons.userPen,
              title: 'Editar Perfil',
              subtitle: 'Actualizar información personal',
              onTap: () {
                // TODO: Navegar a editar perfil
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Función en desarrollo')),
                );
              },
            ),

            _buildSettingCard(
              icon: FontAwesomeIcons.lock,
              title: 'Cambiar Contraseña',
              subtitle: 'Actualizar tu contraseña de acceso',
              onTap: () {
                // TODO: Navegar a cambiar contraseña
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Función en desarrollo')),
                );
              },
            ),

            _buildSettingCard(
              icon: FontAwesomeIcons.shield,
              title: 'Seguridad',
              subtitle: 'Configurar opciones de seguridad',
              onTap: () {
                // TODO: Navegar a configuración de seguridad
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Función en desarrollo')),
                );
              },
            ),

            const SizedBox(height: 24),

            // Sección: Soporte
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'SOPORTE',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textSecondary.withOpacity(0.7),
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 12),

            _buildSettingCard(
              icon: FontAwesomeIcons.circleQuestion,
              title: 'Centro de Ayuda',
              subtitle: 'Preguntas frecuentes y soporte',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Función en desarrollo')),
                );
              },
            ),

            _buildSettingCard(
              icon: FontAwesomeIcons.circleInfo,
              title: 'Acerca de',
              subtitle: 'Versión 1.0.0',
              onTap: () {
                _showAboutDialog();
              },
            ),

            const SizedBox(height: 24),

            // Botón de Cerrar Sesión
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () => _showLogoutDialog(authProvider),
                  icon: const Icon(FontAwesomeIcons.rightFromBracket),
                  label: const Text(
                    'Cerrar Sesión',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 80), // Espacio para el navbar
          ],
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Card(
      color: AppTheme.surface,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppTheme.border),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF6B7280).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF6B7280), size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
        ),
        trailing:
            trailing ??
            (onTap != null
                ? const Icon(Icons.chevron_right, color: AppTheme.textSecondary)
                : null),
      ),
    );
  }

  void _showLogoutDialog(AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text(
          '¿Cerrar Sesión?',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: const Text(
          '¿Estás seguro que deseas cerrar sesión?',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await authProvider.logout();

                if (mounted) {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/login', (route) => false);
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al cerrar sesión: ${e.toString()}'),
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                FontAwesomeIcons.building,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'City Lights',
              style: TextStyle(color: AppTheme.textPrimary),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sistema de Gestión de Edificios',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Versión 1.0.0',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 16),
            const Text(
              'Gestiona edificios, habitaciones, garajes, áreas comunes, reservas y más de manera eficiente.',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 16),
            Text(
              '© 2025 City Lights. Todos los derechos reservados.',
              style: TextStyle(
                color: AppTheme.textSecondary.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
