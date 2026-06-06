import 'package:flutter/material.dart';

/// AppTheme defines the visual styling for the entire application.
class AppTheme {
  /// Private constructor to prevent instantiation.
  /// We only use static methods here since we don't need to create an object of AppTheme.
  AppTheme._();

  /// Returns the light theme configuration for the app.
  static ThemeData get lightTheme {
    return ThemeData(
      // 1. Material 3 Enabled
      // This tells Flutter to use the newer Material Design 3 guidelines
      // which brings updated colors, typography, and widget shapes.
      useMaterial3: true,

      // 2. Primary Color
      // ColorScheme.fromSeed is a Material 3 feature that generates a harmonious
      // color palette based on a single "seed" color. We'll use a shade of blue here.
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),

      // 3. Scaffold Background
      // The Scaffold is the base widget for most screens. This sets its default background color.
      // We use a very light grey to make white cards stand out.
      scaffoldBackgroundColor: const Color(
        0xFFF8F9FA,
      ), // A soft off-white/light grey
      // 4. Card Theme
      // This defines how all Card widgets will look globally unless overridden.
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation:
            2, // Gives the card a slight shadow to lift it off the background
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // Smooth rounded corners
        ),
      ),

      // 5. Button Theme
      // We style ElevatedButton, which is the standard filled button in Material 3.
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent, // The button's background color
          foregroundColor:
              Colors.white, // The color of the text/icons inside the button
          elevation: 0, // Flat look, common in modern designs
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              12,
            ), // Rounded corners for buttons
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),

      // 6. Input Decoration Theme
      // This styles TextFields and TextFormFields (for user input like text boxes).
      inputDecorationTheme: InputDecorationTheme(
        filled: true, // Fills the background of the input field
        fillColor: Colors.white, // Background color of the input field
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        // The border when the field is inactive
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        // The border when the field is selected/focused
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
        ),
        // The border when the field is enabled but not focused
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        // Hint text color
        hintStyle: TextStyle(color: Colors.grey.shade500),
      ),
    );
  }
}
