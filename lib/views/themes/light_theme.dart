import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/constants.dart';

final lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.navy,
    primary: AppColors.navy,
    secondary: AppColors.gold,
  ),
  textTheme: GoogleFonts.sourceSerif4TextTheme(),
  scaffoldBackgroundColor: AppColors.cream,
  inputDecorationTheme: InputDecorationTheme(
    hintStyle: const TextStyle(color: Colors.white60),
    filled: true,
    fillColor: Colors.white.withValues(alpha: 0.1),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
  ),
);
