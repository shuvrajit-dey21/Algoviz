import 'package:flutter/material.dart';
import 'app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  AppTheme _currentTheme = AppTheme.light;

  AppTheme get currentTheme => _currentTheme;

  void setTheme(AppTheme theme) {
    _currentTheme = theme;
    notifyListeners();
  }

  ThemeMode get themeMode =>
      _currentTheme == AppTheme.light
          ? ThemeMode.light
          : ThemeMode.dark;
} 