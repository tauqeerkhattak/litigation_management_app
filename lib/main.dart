import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:litigation_management_app/views/splash_screen.dart';
import 'package:litigation_management_app/views/themes/light_theme.dart';

import 'firebase_options.dart';
import 'services/locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDependencies();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final notificationService = locator<NotificationService>();
  await notificationService.init();
  await notificationService.requestPermissions();

  runApp(const ProviderScope(child: LitigationApp()));
}

final navigatorKey = GlobalKey<NavigatorState>();

class LitigationApp extends StatelessWidget {
  const LitigationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'DC Sukkur Litigation',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: lightTheme,
      home: const SplashScreen(),
    );
  }
}
