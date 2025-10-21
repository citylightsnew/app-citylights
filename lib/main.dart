import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/splash.dart';
import 'screens/main_dashboard_screen.dart';
import 'screens/login.dart';
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
          '/dashboard': (context) => const MainDashboardScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
