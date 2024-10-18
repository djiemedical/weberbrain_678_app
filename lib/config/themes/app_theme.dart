// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  static const Color _primaryColor = Color(0xFF1F2225);
  static const Color _accentColor = Color(0xFF4A90E2);
  static const Color _backgroundColor = Color(0xFF1F2225);
  static const Color _surfaceColor = Color(0xFF2C2F33);
  static const Color _errorColor = Color(0xFFE57373);
  static const Color _onPrimaryColor = Color(0xFFFFFFFF);
  static const Color _onSurfaceColor = Color(0xFFE0E0E0);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: _primaryColor,
        secondary: _accentColor,
        surface: _surfaceColor,
        error: _errorColor,
        onPrimary: _onPrimaryColor,
        onSurface: _onSurfaceColor,
      ),
      scaffoldBackgroundColor: _backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: _primaryColor,
        foregroundColor: _onPrimaryColor,
        elevation: 0,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: _onPrimaryColor,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: _onPrimaryColor,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: _onSurfaceColor,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: _onSurfaceColor,
          fontSize: 14,
        ),
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: _accentColor,
        textTheme: ButtonTextTheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: _onPrimaryColor,
          backgroundColor: _accentColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _accentColor),
        ),
        labelStyle: const TextStyle(color: _onSurfaceColor),
      ),
    );
  }

  // You can add a dark theme here if needed
  static ThemeData get darkTheme {
    return lightTheme; // For now, we'll use the same theme for both light and dark modes
  }
}
