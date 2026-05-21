import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/constants.dart';

final lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.navy,
    primary: AppColors.navy,
    onPrimary: AppColors.white,
    secondary: AppColors.gold,
    onSecondary: AppColors.navy,
    surface: AppColors.white,
    onSurface: AppColors.text,
    error: AppColors.red,
  ),
  textTheme: GoogleFonts.sourceSerif4TextTheme().apply(
    bodyColor: AppColors.text,
    displayColor: AppColors.navy,
  ),
  scaffoldBackgroundColor: AppColors.cream,
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.white,
    foregroundColor: AppColors.navy,
    elevation: 0,
    centerTitle: false,
  ),
  cardTheme: CardThemeData(
    color: AppColors.white,
    elevation: 2,
    clipBehavior: Clip.antiAlias,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.gold, width: 2),
    ),
    labelStyle: const TextStyle(color: AppColors.muted),
    hintStyle: const TextStyle(color: AppColors.muted),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.navy,
      foregroundColor: AppColors.gold,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.navy,
    foregroundColor: AppColors.gold,
  ),
  chipTheme: ChipThemeData(
    backgroundColor: AppColors.creamDark,
    selectedColor: AppColors.gold.withValues(alpha: 0.3),
    secondarySelectedColor: AppColors.gold,
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    labelStyle: const TextStyle(color: AppColors.navy, fontSize: 12),
    secondaryLabelStyle: const TextStyle(color: AppColors.navy),
    side: BorderSide.none,
  ),

  progressIndicatorTheme: ProgressIndicatorThemeData(
    color: AppColors.gold,
    year2023: false,
  ),
);
