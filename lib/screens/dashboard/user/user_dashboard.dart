import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/user_model.dart';
import '../../../providers/auth_provider.dart';

class UserDashboard extends StatefulWidget {
  final UserModel user;

  const UserDashboard({super.key, required this.user});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  Map<String, dynamic>? _habitacionData;
  List<dynamic> _garajesData = [];

  @override
  void initState() {
    super.initState();
    // TODO: Fetch user's habitacion and garajes from API
    // _fetchUserDetails();
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<AuthProvider>().logout();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    }
  }

  Future<void> _handleRefresh() async {
    // TODO: Refresh user data from API
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: _buildAppBar(theme),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Header
              _buildWelcomeHeader(theme),
              const SizedBox(height: 32),

              // Personal Info Card
              _buildPersonalInfoCard(theme),
              const SizedBox(height: 24),

              // Property Details
              if (_habitacionData != null) ...[
                _buildPropertyCard(theme),
                const SizedBox(height: 24),
              ],

              // Quick Actions
              _buildQuickActions(theme),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.location_city_rounded,
              color: theme.colorScheme.onPrimary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Text('City Lights', style: TextStyle(fontSize: 18)),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout_outlined),
          onPressed: _handleLogout,
          tooltip: 'Cerrar Sesión',
        ),
      ],
    );
  }

  Widget _buildWelcomeHeader(ThemeData theme) {
    final hour = DateTime.now().hour;
    String greeting = 'Buenas noches';
    if (hour >= 6 && hour < 12) {
      greeting = 'Buenos días';
    } else if (hour >= 12 && hour < 19) {
      greeting = 'Buenas tardes';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${widget.user.nombre} ${widget.user.apellido}',
          style: theme.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalInfoCard(ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Información Personal',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildInfoRow(
              theme,
              icon: Icons.email_outlined,
              label: 'Email',
              value: widget.user.email,
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              theme,
              icon: Icons.phone_outlined,
              label: 'Teléfono',
              value: widget.user.telefono ?? 'No especificado',
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              theme,
              icon: Icons.badge_outlined,
              label: 'ID de Usuario',
              value: widget.user.id,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary.withOpacity(0.7)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPropertyCard(ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.apartment_outlined,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Mi Propiedad',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildInfoRow(
              theme,
              icon: Icons.home_outlined,
              label: 'Habitación',
              value: _habitacionData?['numero'] ?? 'Sin asignar',
            ),
            if (_garajesData.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildInfoRow(
                theme,
                icon: Icons.local_parking_outlined,
                label: 'Garajes',
                value: _garajesData.map((g) => g['numero']).join(', '),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(ThemeData theme) {
    final actions = [
      _QuickAction(
        title: 'Reservar Área Común',
        subtitle: 'Reserva espacios del edificio',
        icon: Icons.event_available_outlined,
        color: Colors.green,
        onTap: () {
          // TODO: Navigate to booking screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Módulo de reservas próximamente...')),
          );
        },
      ),
      _QuickAction(
        title: 'Mis Reservas',
        subtitle: 'Ver mis reservas activas',
        icon: Icons.calendar_today_outlined,
        color: Colors.blue,
        onTap: () {
          // TODO: Navigate to my bookings
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Módulo de reservas próximamente...')),
          );
        },
      ),
      _QuickAction(
        title: 'Historial de Pagos',
        subtitle: 'Revisa tus pagos y facturas',
        icon: Icons.receipt_long_outlined,
        color: Colors.orange,
        onTap: () {
          // TODO: Navigate to payments
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Módulo de pagos próximamente...')),
          );
        },
      ),
      _QuickAction(
        title: 'Soporte',
        subtitle: 'Contacta con administración',
        icon: Icons.support_agent_outlined,
        color: Colors.purple,
        onTap: () {
          // TODO: Navigate to support
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Módulo de soporte próximamente...')),
          );
        },
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Acciones Rápidas',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.3,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: InkWell(
                onTap: action.onTap,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: action.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(action.icon, color: action.color, size: 28),
                      ),
                      const Spacer(),
                      Text(
                        action.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        action.subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _QuickAction {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  _QuickAction({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}
