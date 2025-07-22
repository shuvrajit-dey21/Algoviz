import 'package:flutter/material.dart';
import 'package:shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
  
  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  ThemeData get themeData {
    return _isDarkMode ? 
      ThemeData.dark().copyWith(
        primaryColor: Colors.blue,
        colorScheme: const ColorScheme.dark().copyWith(
          primary: Colors.blue,
          secondary: Colors.blueAccent,
        ),
      ) : 
      ThemeData.light().copyWith(
        primaryColor: Colors.blue,
        colorScheme: const ColorScheme.light().copyWith(
          primary: Colors.blue,
          secondary: Colors.blueAccent,
        ),
      );
  }
} 