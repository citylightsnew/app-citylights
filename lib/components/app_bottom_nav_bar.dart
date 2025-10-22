import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../config/app_theme.dart';

class AppBottomNavBar extends StatelessWidget {
  final int selectedIndex;

  const AppBottomNavBar({super.key, this.selectedIndex = 0});

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) {
        // Navegar según la selección
        switch (index) {
          case 0:
            // Inicio - Volver al dashboard
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/dashboard',
              (route) => false,
            );
            break;
          case 1:
            // Estadísticas - Por ahora mostrar mensaje
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Estadísticas - Próximamente'),
                duration: Duration(seconds: 2),
              ),
            );
            break;
          case 2:
            // Notificaciones
            Navigator.pushNamed(context, '/notification-test');
            break;
          case 3:
            // Configuración
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
    );
  }
}
