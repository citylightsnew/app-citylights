import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../providers/auth_provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MainDashboardScreen extends StatefulWidget {
  const MainDashboardScreen({super.key});

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> {
  int _selectedIndex = 0;

  final List<DashboardModule> _modules = [
    DashboardModule(
      title: 'Edificios',
      subtitle: 'Gestión de edificios y unidades',
      icon: FontAwesomeIcons.building,
      color: AppTheme.primary,
      route: '/edificios',
    ),
    DashboardModule(
      title: 'Habitaciones',
      subtitle: 'Administrar habitaciones',
      icon: FontAwesomeIcons.doorOpen,
      color: AppTheme.secondary,
      route: '/habitaciones',
    ),
    DashboardModule(
      title: 'Garajes',
      subtitle: 'Control de estacionamientos',
      icon: FontAwesomeIcons.car,
      color: AppTheme.accent,
      route: '/garajes',
    ),
    DashboardModule(
      title: 'Áreas Comunes',
      subtitle: 'Reservas de espacios',
      icon: FontAwesomeIcons.users,
      color: const Color(0xFFEC4899),
      route: '/areas',
    ),
    DashboardModule(
      title: 'Reservas',
      subtitle: 'Gestión de reservas',
      icon: FontAwesomeIcons.calendarCheck,
      color: const Color(0xFF8B5CF6),
      route: '/reservas',
    ),
    DashboardModule(
      title: 'Pagos',
      subtitle: 'Pagos y facturación',
      icon: FontAwesomeIcons.creditCard,
      color: const Color(0xFF10B981),
      route: '/pagos',
    ),
    DashboardModule(
      title: 'Facturas',
      subtitle: 'Historial de facturas',
      icon: FontAwesomeIcons.fileInvoiceDollar,
      color: const Color(0xFFF59E0B),
      route: '/facturas',
    ),
    DashboardModule(
      title: 'Empleados',
      subtitle: 'Recursos humanos',
      icon: FontAwesomeIcons.userTie,
      color: const Color(0xFF6366F1),
      route: '/empleados',
    ),
    DashboardModule(
      title: 'Nómina',
      subtitle: 'Pagos de nómina',
      icon: FontAwesomeIcons.moneyBillWave,
      color: const Color(0xFF14B8A6),
      route: '/nomina',
    ),
    DashboardModule(
      title: 'Usuarios',
      subtitle: 'Gestión de usuarios',
      icon: FontAwesomeIcons.users,
      color: const Color(0xFF8B5CF6),
      route: '/users',
    ),
    DashboardModule(
      title: 'Roles',
      subtitle: 'Permisos y roles',
      icon: FontAwesomeIcons.userShield,
      color: const Color(0xFFEF4444),
      route: '/roles',
    ),
    DashboardModule(
      title: 'Configuración',
      subtitle: 'Ajustes de la aplicación',
      icon: FontAwesomeIcons.gear,
      color: const Color(0xFF6B7280),
      route: '/settings',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: AppTheme.surface,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primary,
                      AppTheme.primaryDark,
                      AppTheme.secondary,
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -50,
                      top: -50,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                    Positioned(
                      left: -30,
                      bottom: -30,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              title: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hola, ${user?.name ?? "Usuario"}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: AppTheme.fontSizeLG,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.role?.name ?? 'Usuario',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: AppTheme.fontSizeSM,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(FontAwesomeIcons.bell),
                color: Colors.white,
                onPressed: () {
                  // Navegar a notificaciones
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(AppTheme.paddingMD),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.1,
                crossAxisSpacing: AppTheme.paddingMD,
                mainAxisSpacing: AppTheme.paddingMD,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final module = _modules[index];
                return _ModuleCard(
                  module: module,
                  onTap: () {
                    // Navegar al módulo usando la ruta nombrada
                    Navigator.pushNamed(context, module.route);
                  },
                );
              }, childCount: _modules.length),
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });

          // Navegar según la selección
          switch (index) {
            case 0:
              // Ya estamos en Inicio
              break;
            case 1:
              // Estadísticas - Por ahora mostrar mensaje
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Estadísticas - Próximamente')),
              );
              break;
            case 2:
              // Notificaciones - Navegar a pantalla de notificaciones
              Navigator.pushNamed(context, '/notification-test');
              break;
            case 3:
              // Perfil/Configuración
              Navigator.pushNamed(context, '/settings');
              break;
          }
        },
        backgroundColor: AppTheme.surface,
        elevation: 8,
        destinations: const [
          NavigationDestination(
            icon: FaIcon(FontAwesomeIcons.house, size: 20),
            selectedIcon: FaIcon(FontAwesomeIcons.house, size: 22),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: FaIcon(FontAwesomeIcons.chartLine, size: 20),
            selectedIcon: FaIcon(FontAwesomeIcons.chartLine, size: 22),
            label: 'Estadísticas',
          ),
          NavigationDestination(
            icon: FaIcon(FontAwesomeIcons.bell, size: 20),
            selectedIcon: FaIcon(FontAwesomeIcons.bell, size: 22),
            label: 'Notificaciones',
          ),
          NavigationDestination(
            icon: FaIcon(FontAwesomeIcons.gear, size: 20),
            selectedIcon: FaIcon(FontAwesomeIcons.gear, size: 22),
            label: 'Configuración',
          ),
        ],
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final DashboardModule module;
  final VoidCallback onTap;

  const _ModuleCard({required this.module, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusLG),
          border: Border.all(color: AppTheme.border),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: module.color.withOpacity(0.1),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppTheme.paddingMD),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: module.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                    ),
                    child: FaIcon(module.icon, color: module.color, size: 24),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        module.title,
                        style: const TextStyle(
                          fontSize: AppTheme.fontSizeMD,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        module.subtitle,
                        style: const TextStyle(
                          fontSize: AppTheme.fontSizeXS,
                          color: AppTheme.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardModule {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String route;

  DashboardModule({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.route,
  });
}
