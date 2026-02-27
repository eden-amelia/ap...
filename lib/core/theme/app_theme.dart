import 'package:flutter/material.dart';
import '../constants/colors.dart';

/// App theme configuration
class ArtCatTheme {
  ArtCatTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: ArtCatColors.primary,
        secondary: ArtCatColors.secondary,
        surface: ArtCatColors.surface,
        error: ArtCatColors.error,
      ),
      scaffoldBackgroundColor: ArtCatColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: ArtCatColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: ArtCatColors.surface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ArtCatColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ArtCatColors.primary,
          side: const BorderSide(color: ArtCatColors.primary),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: ArtCatColors.secondary,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: ArtCatColors.surface,
        selectedItemColor: ArtCatColors.primary,
        unselectedItemColor: ArtCatColors.textLight,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: ArtCatColors.textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: ArtCatColors.textPrimary,
        ),
        headlineSmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: ArtCatColors.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: ArtCatColors.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: ArtCatColors.textSecondary,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: ArtCatColors.textPrimary,
        ),
      ),
    );
  }
}
