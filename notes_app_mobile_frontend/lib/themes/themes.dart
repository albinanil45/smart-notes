import 'package:flutter/material.dart';

class AppThemes {
  final snackbarTheme = SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );
  static final lightTheme = ThemeData(
    colorScheme: ColorScheme.light(
      primary: Color(0xFF1558BC),
      onPrimary: Color(0xFFF8F8F8),
      surface: Color(0xFFF8F8F8),
      surfaceContainerHighest: Colors.grey[100]!,

      // ✅ Added
      secondary: Color(0xFF4CAF50),
      onSecondary: Colors.white,

      background: Color(0xFFF8F8F8),
      onBackground: Color(0xFF111213),

      onSurface: Color(0xFF111213),
      onSurfaceVariant: Color(0xFF6B7280), // soft grey text

      outline: Color(0xFFE0E0E0),
      outlineVariant: Color(0xFFEEEEEE),

      shadow: Colors.black,

      error: Color(0xFFD32F2F),
      onError: Colors.white,
    ),
  );

  static final darkTheme = ThemeData(
    colorScheme: ColorScheme.dark(
      primary: Color(0xFF8FB8F6),
      onPrimary: Color(0xFF111213),
      surface: Color(0xFF111213),
      surfaceContainerHighest: Colors.grey[800]!,

      // ✅ Added
      secondary: Color(0xFF81C784),
      onSecondary: Color(0xFF111213),

      background: Color(0xFF111213),
      onBackground: Color(0xFFF8F8F8),

      onSurface: Color(0xFFF8F8F8),
      onSurfaceVariant: Color(0xFF9CA3AF),

      outline: Color(0xFF2A2A2A),
      outlineVariant: Color(0xFF3A3A3A),

      shadow: Colors.black,

      error: Color(0xFFEF5350),
      onError: Color(0xFF111213),
    ),
  );
}
