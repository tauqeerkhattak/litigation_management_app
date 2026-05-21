import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:litigation_management_app/models/user_model.dart';
import 'package:litigation_management_app/utils/constants.dart';
import 'package:litigation_management_app/viewmodels/auth_viewmodel.dart';
import 'package:litigation_management_app/views/home_screen.dart';

import 'login_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  Future<void> init(UserData? user) async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              user != null ? const HomeScreen() : const LoginScreen(),
        ),
      );
    });
  }

  void _listener(AuthState? prev, AuthState next) {
    init(next.user);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authProvider, _listener);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.navy, AppColors.navyMid],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.balance, size: 80, color: AppColors.gold),
              const SizedBox(height: 16),
              Text(
                "DC SUKKUR",
                style: GoogleFonts.playfairDisplay(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.gold,
                  letterSpacing: 2,
                ),
              ),
              const Text(
                "LITIGATION MANAGEMENT SYSTEM",
                style: TextStyle(
                  color: AppColors.cream,
                  fontSize: 10,
                  letterSpacing: 1,
                ),
              ),
              SizedBox(height: 48),
              CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
