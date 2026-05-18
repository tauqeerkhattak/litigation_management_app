import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'utils/constants.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'views/home_screen.dart';
import 'views/login_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
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
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.navy,
          primary: AppColors.navy,
          secondary: AppColors.gold,
        ),
        textTheme: GoogleFonts.sourceSerif4TextTheme(),
        scaffoldBackgroundColor: AppColors.cream,
      ),
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
