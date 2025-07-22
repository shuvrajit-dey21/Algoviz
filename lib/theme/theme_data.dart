import 'package:flutter/material.dart';

class AppTheme {
  // Light theme
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.blue,
    colorScheme: ColorScheme.light(
      primary: Colors.blue,
      secondary: Colors.blueAccent,
      surface: Colors.white,
      background: const Color(0xFFF5F5F5),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.black87,
      onBackground: Colors.black87,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: const CardTheme(
      color: Colors.white,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black87),
      bodyMedium: TextStyle(color: Colors.black87),
      titleLarge: TextStyle(color: Colors.black87),
    ),
    iconTheme: const IconThemeData(
      color: Colors.black87,
    ),
    scaffoldBackgroundColor: const Color(0xFFF5F5F5),
  );

  // Dark theme
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.deepPurple,
    colorScheme: ColorScheme.dark(
      primary: Colors.deepPurple,
      secondary: Colors.deepPurpleAccent,
      surface: const Color(0xFF303030),
      background: const Color(0xFF121212),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
      onBackground: Colors.white70,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1F1F1F),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: const CardTheme(
      color: Color(0xFF252525),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white70),
      titleLarge: TextStyle(color: Colors.white),
    ),
    iconTheme: const IconThemeData(
      color: Colors.white70,
    ),
    scaffoldBackgroundColor: const Color(0xFF121212),
  );
} 