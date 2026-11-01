import 'package:flutter/material.dart';

class AppTheme {
  // Brand Colors
  static const Color _primary = Color(0xFF816C61);
  static const Color _secondary = Color(0xFF334155);
  static const Color _secondaryCyan = Color(0xFF06B6D4);
  
  // Dark Theme Colors
  static const Color _darkBackground = Color(0xFF0F172A);
  static const Color _darkSurface = Color(0xFF334155);
  static const Color _darkText = Color(0xFFE0F2FE);
  
  // Light Theme Colors
  static const Color _lightBackground = Color(0xFFE0F2FE);
  static const Color _lightSurface = Color(0xFFFFFFFF);
  static const Color _lightText = Color(0xFF0F172A);

  // Semantic Colors (Form Tracking)
  static const Color _successEmerald = Color(0xFF10B981);
  static const Color _errorRose = Color(0xFFF43F5E);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: _lightBackground,
      colorScheme: const ColorScheme.light(
        primary: _primary,
        secondary: _secondary,
        surface: _lightSurface,
        background: _lightBackground,
        error: _errorRose,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: _lightText,
        onBackground: _lightText,
        onError: Colors.white,
      ),
      // Apply success/error globally to extensions or specific widget themes if needed
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: _darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: _primary,
        secondary: _secondaryCyan,
        surface: _darkSurface,
        background: _darkBackground,
        error: _errorRose,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: _darkText,
        onBackground: _darkText,
        onError: Colors.white,
      ),
    );
  }
}
