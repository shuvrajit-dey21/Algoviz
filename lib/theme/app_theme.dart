import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum AppTheme {
  light,
  dark,
}

class AppThemeData {
  static ThemeData getThemeData(AppTheme theme) {
    switch (theme) {
      case AppTheme.light:
        return ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF4285F4),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          textTheme: GoogleFonts.poppinsTextTheme(),
          cardTheme: CardTheme(
            elevation: 6,
            shadowColor: Colors.black26,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: false,
            titleTextStyle: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            foregroundColor: Colors.black87,
            iconTheme: IconThemeData(color: Colors.black87),
          ),
        );
      case AppTheme.dark:
        return ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF4285F4),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
          textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
          cardTheme: CardTheme(
            elevation: 6,
            shadowColor: Colors.black45,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: false,
            titleTextStyle: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            foregroundColor: Colors.white,
            iconTheme: IconThemeData(color: Colors.white),
          ),
        );

    }
  }
} 