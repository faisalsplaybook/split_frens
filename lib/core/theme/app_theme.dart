import 'package:flutter/material.dart';

/// AppTheme defines the visual styling for the entire application.
class AppTheme {
  /// Private constructor to prevent instantiation.
  /// We only use static methods here since we don't need to create an object of AppTheme.
  AppTheme._();

  /// Returns the dark theme configuration for the app.
  static ThemeData get darkTheme {
    const primaryTeal = Color(0xFF14B8A6);
    const backgroundNavy = Color(0xFF0F172A);
    const cardNavy = Color(0xFF1E293B);
    const textWhite = Color(0xFFF8FAFC);
    const textSubtitle = Color(0xFF94A3B8);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundNavy,
      colorScheme: const ColorScheme.dark(
        primary: primaryTeal,
        surface: backgroundNavy,
        onSurface: textWhite,
        error: Color(0xFFF59E0B), // Soft amber for warning/owes
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: textWhite),
        bodyMedium: TextStyle(color: textWhite),
        titleLarge: TextStyle(color: textWhite),
        titleMedium: TextStyle(color: textWhite),
        titleSmall: TextStyle(color: textSubtitle),
        labelLarge: TextStyle(color: textWhite),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundNavy,
        foregroundColor: textWhite,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: cardNavy,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryTeal,
          foregroundColor: textWhite,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryTeal,
          side: const BorderSide(color: primaryTeal),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: backgroundNavy, // Darker inset for inputs
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF334155)), // Subtle border
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryTeal, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF334155)), // Subtle border
        ),
        hintStyle: const TextStyle(color: textSubtitle),
      ),
      listTileTheme: const ListTileThemeData(
        textColor: textWhite,
        iconColor: primaryTeal,
      ),
      iconTheme: const IconThemeData(color: primaryTeal),
    );
  }
}
