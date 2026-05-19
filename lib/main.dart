import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:litigation_management_app/views/themes/light_theme.dart';

import 'firebase_options.dart';
import 'services/locator.dart';
import 'utils/constants.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'views/home_screen.dart';
import 'views/login_screen.dart';

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
      home: const MainGate(),
    );
  }
}

class MainGate extends ConsumerWidget {
  const MainGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    if (authState.isLoading && authState.user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.gold)),
      );
    }

    if (authState.user == null) {
      return const LoginScreen();
    }
    return const HomeScreen();
  }
}
