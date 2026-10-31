import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/welcome_screen.dart';
import 'screens/main_screen.dart';
import 'utils/app_theme.dart';
import 'services/storage_service.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize storage service safely
  try {
    await StorageService.init();
  } catch (e) {
    debugPrint('Error initializing StorageService: $e');
  }
  
  // Initialize notification service safely
  try {
    await NotificationService.init();
  } catch (e) {
    debugPrint('Error initializing NotificationService: $e');
  }
  
  try {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  } catch (e) {
    debugPrint('Error setting orientations: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Word Giant',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const WelcomeScreen(),
      routes: {
        '/main': (context) => const MainScreen(),
      },
    );
  }
}
