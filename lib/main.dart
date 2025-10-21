import 'package:flutter/material.dart';
import 'screens/splash.dart';
import 'services/firebase_service.dart';
import 'components/in_app_notification_overlay.dart';

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
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'City Lights',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        fontFamily: 'Roboto',
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const InAppNotificationOverlay(child: SplashScreen()),
      debugShowCheckedModeBanner: false,
    );
  }
}
