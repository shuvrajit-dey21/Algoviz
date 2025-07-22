import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'theme/theme_provider.dart';
import 'pages/home_page.dart';

class AlgorithmVisualizerApp extends StatelessWidget {
  const AlgorithmVisualizerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          title: 'Algorithm Visualizer',
          debugShowCheckedModeBanner: false,
          theme: AppThemeData.getThemeData(AppTheme.light),
          darkTheme: AppThemeData.getThemeData(AppTheme.dark),
          themeMode: themeProvider.themeMode,
          home: HomePage(),
        );
      },
    );
  }
} 