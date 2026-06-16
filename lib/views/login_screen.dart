import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:litigation_management_app/utils/validators.dart';
import 'package:litigation_management_app/views/home_screen.dart';

import '../utils/constants.dart';
import '../viewmodels/auth_viewmodel.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _onLoginTap() {
    if (!_formKey.currentState!.validate()) return;
    ref
        .read(authProvider.notifier)
        .login(_emailController.text, _passwordController.text);
  }

  void _listener(AuthState? prev, AuthState next) {
    if (next.user != null) {
      Navigator.pushReplacement(
        context,
        CupertinoPageRoute(builder: (_) => HomeScreen()),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authProvider, _listener);
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: _LoginBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 48),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const _BrandHeader(),
                  const SizedBox(height: 48),

                  _LoginCard(
                    children: [
                      _AuthField(
                        controller: _emailController,
                        hint: 'Email address',
                        icon: Icons.email_outlined,
                        validator: Validators.email,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      _AuthField(
                        controller: _passwordController,
                        hint: 'Password',
                        icon: Icons.lock_outline,
                        validator: Validators.password,
                        obscureText: true,
                      ),
                      const SizedBox(height: 28),
                      _LoginButton(
                        isLoading: authState.isLoading,
                        onTap: _onLoginTap,
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                  const _FooterLabel(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


class _LoginBackground extends StatelessWidget {
  const _LoginBackground({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.5, 1.0],
          colors: [
            AppColors.navy,
            Color(0xFF0D2240), // slightly lighter navy mid
            AppColors.navyMid,
          ],
        ),
      ),
      child: child,
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.gold.withValues(alpha: 0.12),
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.4), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withValues(alpha: 0.25),
                blurRadius: 24,
                spreadRadius: 4,
              ),
            ],
          ),
          child: const Icon(Icons.balance, size: 44, color: AppColors.gold),
        ),
        const SizedBox(height: 20),
        Text(
          'DC SUKKUR',
          style: GoogleFonts.playfairDisplay(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: AppColors.gold,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _GoldDividerLine(),
            const SizedBox(width: 10),
            const Text(
              'LITIGATION MANAGEMENT SYSTEM',
              style: TextStyle(
                color: AppColors.cream,
                fontSize: 9.5,
                letterSpacing: 1.8,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(width: 10),
            _GoldDividerLine(),
          ],
        ),
      ],
    );
  }
}

class _GoldDividerLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 1,
      color: AppColors.gold.withValues(alpha: 0.5),
    );
  }
}

class _LoginCard extends StatelessWidget {
  const _LoginCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Sign in to continue',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.cream,
              fontSize: 13,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 22),
          ...children,
        ],
      ),
    );
  }
}

class _AuthField extends StatelessWidget {
  const _AuthField({
    required this.controller,
    required this.hint,
    required this.icon,
    required this.validator,
    this.obscureText = false,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final String? Function(String?) validator;
  final bool obscureText;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      cursorColor: AppColors.gold,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.38), fontSize: 14),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.07),
        prefixIcon: Icon(icon, color: AppColors.gold, size: 20),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.gold, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.4),
        ),
        errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 11),
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  const _LoginButton({required this.isLoading, required this.onTap});
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: AppColors.navy,
          disabledBackgroundColor: AppColors.gold.withValues(alpha: 0.5),
          elevation: isLoading ? 0 : 4,
          shadowColor: AppColors.gold.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            color: AppColors.navy,
            strokeWidth: 2.5,
          ),
        )
            : const Text(
          'LOGIN',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}

class _FooterLabel extends StatelessWidget {
  const _FooterLabel();

  @override
  Widget build(BuildContext context) {
    return Text(
      'District Courts · Sukkur Division',
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.28),
        fontSize: 11,
        letterSpacing: 0.6,
      ),
    );
  }
}
