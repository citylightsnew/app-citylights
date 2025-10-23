import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/user_model.dart';
import '../../../providers/auth_provider.dart';

class AdminDashboard extends StatefulWidget {
  final UserModel user;

  const AdminDashboard({super.key, required this.user});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  String _activeView = 'dashboard';

  final List<MenuItem> _menuItems = [
    MenuItem(
      id: 'dashboard',
      label: 'Panel Principal',
      icon: Icons.dashboard_outlined,
    ),
    MenuItem(id: 'users', label: 'Usuarios', icon: Icons.people_outline),
    MenuItem(
      id: 'roles',
      label: 'Roles',
      icon: Icons.admin_panel_settings_outlined,
    ),
    MenuItem(
      id: 'habitaciones',
      label: 'Habitaciones',
      icon: Icons.apartment_outlined,
    ),
    MenuItem(id: 'areas', label: 'Áreas Comunes', icon: Icons.place_outlined),
    MenuItem(id: 'reservas', label: 'Reservas', icon: Icons.event_outlined),
  ];

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: _buildAppBar(theme),
      body: Row(
        children: [
          // Sidebar
          _buildSidebar(theme),

          // Content
          Expanded(child: _buildContent(theme)),
        ],
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('City Lights', style: TextStyle(fontSize: 18)),
              Text(
                'Panel de Administración',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        // User info
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${widget.user.nombre} ${widget.user.apellido}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        size: 12,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Administrador',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(Icons.logout_outlined),
                onPressed: _handleLogout,
                tooltip: 'Cerrar Sesión',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSidebar(ThemeData theme) {
    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          right: BorderSide(color: theme.colorScheme.outlineVariant, width: 1),
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        children: _menuItems.map((item) {
          final isActive = _activeView == item.id;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: ListTile(
              selected: isActive,
              selectedTileColor: theme.colorScheme.primaryContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              leading: Icon(
                item.icon,
                color: isActive
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              title: Text(
                item.label,
                style: TextStyle(
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  color: isActive
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                ),
              ),
              onTap: () {
                setState(() {
                  _activeView = item.id;
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    switch (_activeView) {
      case 'dashboard':
        return _buildDashboardView(theme);
      case 'users':
        return _buildComingSoon(theme, 'Gestión de Usuarios');
      case 'roles':
        return _buildComingSoon(theme, 'Gestión de Roles');
      case 'habitaciones':
        return _buildComingSoon(theme, 'Gestión de Habitaciones');
      case 'areas':
        return _buildComingSoon(theme, 'Áreas Comunes');
      case 'reservas':
        return _buildComingSoon(theme, 'Gestión de Reservas');
      default:
        return _buildDashboardView(theme);
    }
  }

  Widget _buildDashboardView(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Panel de Control',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Resumen general del sistema',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 32),

          // Stats Cards
          _buildStatsGrid(theme),
          const SizedBox(height: 32),

          // Quick Actions
          Text(
            'Acceso Rápido',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildQuickActions(theme),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(ThemeData theme) {
    final stats = [
      _StatCard(
        title: 'Usuarios',
        value: '0',
        icon: Icons.people_outline,
        color: Colors.blue,
      ),
      _StatCard(
        title: 'Reservas',
        value: '0',
        icon: Icons.event_outlined,
        color: Colors.green,
      ),
      _StatCard(
        title: 'Habitaciones',
        value: '0',
        icon: Icons.apartment_outlined,
        color: Colors.purple,
      ),
      _StatCard(
        title: 'Áreas Comunes',
        value: '0',
        icon: Icons.place_outlined,
        color: Colors.orange,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.8,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: stat.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(stat.icon, color: stat.color, size: 24),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stat.value,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: stat.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      stat.title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickActions(ThemeData theme) {
    final actions = [
      _QuickAction(
        title: 'Nuevo Usuario',
        icon: Icons.person_add_outlined,
        color: Colors.blue,
        onTap: () => setState(() => _activeView = 'users'),
      ),
      _QuickAction(
        title: 'Nueva Reserva',
        icon: Icons.event_available_outlined,
        color: Colors.green,
        onTap: () => setState(() => _activeView = 'reservas'),
      ),
      _QuickAction(
        title: 'Gestionar Áreas',
        icon: Icons.place_outlined,
        color: Colors.purple,
        onTap: () => setState(() => _activeView = 'areas'),
      ),
      _QuickAction(
        title: 'Ver Habitaciones',
        icon: Icons.apartment_outlined,
        color: Colors.orange,
        onTap: () => setState(() => _activeView = 'habitaciones'),
      ),
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: actions.map((action) {
        return SizedBox(
          width: 200,
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              onTap: action.onTap,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: action.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(action.icon, color: action.color, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        action.title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildComingSoon(ThemeData theme, String title) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.construction_outlined,
            size: 80,
            color: theme.colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Próximamente...',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class MenuItem {
  final String id;
  final String label;
  final IconData icon;

  MenuItem({required this.id, required this.label, required this.icon});
}

class _StatCard {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });
}

class _QuickAction {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  _QuickAction({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}
