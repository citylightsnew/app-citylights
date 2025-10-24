import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'screens/splash.dart';
import 'screens/dashboards/dashboard_router.dart';
import 'screens/login.dart';
import 'screens/modules/edificios_screen.dart';
import 'screens/modules/habitaciones_screen.dart';
import 'screens/modules/garajes_screen.dart';
import 'screens/modules/areas_screen.dart';
import 'screens/modules/reservas_screen.dart';
import 'screens/modules/users_screen.dart';
import 'screens/modules/roles_screen.dart';
import 'screens/modules/settings_screen.dart';
import 'screens/modules/module_placeholder_screen.dart';
import 'services/firebase_service.dart';
import 'components/in_app_notification_overlay.dart';
import 'providers/auth_provider.dart';
import 'config/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await FirebaseService.initialize();
  } catch (e) {
    print('Error inicializando Firebase: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    FirebaseService.setNavigatorKey(_navigatorKey);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthProvider())],
      child: MaterialApp(
        navigatorKey: _navigatorKey,
        title: 'City Lights',
        theme: ThemeData(
          primaryColor: AppTheme.primary,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppTheme.primary,
            brightness: Brightness.dark,
            background: AppTheme.background,
            surface: AppTheme.surface,
          ),
          scaffoldBackgroundColor: AppTheme.background,
          fontFamily: 'Roboto',
          visualDensity: VisualDensity.adaptivePlatformDensity,
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) =>
              const InAppNotificationOverlay(child: SplashScreen()),
          '/login': (context) => const LoginScreen(),
          '/dashboard': (context) {
            final authProvider = Provider.of<AuthProvider>(
              context,
              listen: false,
            );
            final user = authProvider.user;
            return DashboardRouter(
              userName: user?.name ?? 'Usuario',
              user: user,
            );
          },
          '/edificios': (context) => const EdificiosScreen(),
          '/habitaciones': (context) => const HabitacionesScreen(),
          '/garajes': (context) => const GarajesScreen(),
          '/areas': (context) => const AreasScreen(),
          '/reservas': (context) => const ReservasScreen(),
          '/pagos': (context) => const ModulePlaceholderScreen(
            title: 'Pagos',
            icon: FontAwesomeIcons.creditCard,
            color: Color(0xFF10B981),
          ),
          '/facturas': (context) => const ModulePlaceholderScreen(
            title: 'Facturas',
            icon: FontAwesomeIcons.fileInvoiceDollar,
            color: Color(0xFFF59E0B),
          ),
          '/empleados': (context) => const ModulePlaceholderScreen(
            title: 'Empleados',
            icon: FontAwesomeIcons.userTie,
            color: Color(0xFF6366F1),
          ),
          '/nomina': (context) => const ModulePlaceholderScreen(
            title: 'Nómina',
            icon: FontAwesomeIcons.moneyBillWave,
            color: Color(0xFF14B8A6),
          ),
          '/users': (context) => const UsersScreen(),
          '/roles': (context) => const RolesScreen(),
          '/settings': (context) => const SettingsScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
