import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_2/algorithms/ins_del.dart';
import 'package:flutter_application_2/pages/linked_list_operations_page.dart';
import 'package:flutter_application_2/pages/stack_queue_page.dart';
import 'package:flutter_application_2/pages/tree_operations_page.dart';
import '/pages/coming_soon.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animated_background/animated_background.dart';
import 'dart:math';
import 'dart:ui';
import 'algorithms/search_visualizer.dart';
import 'algorithms/sorting_visualizer.dart';

// Import screens
import 'pages/linked_list_operations_page.dart';
import 'pages/stack_queue_page.dart';
import 'pages/tree_operations_page.dart';
import 'pages/graph_operations_page.dart';
import 'screens/auth/login_screen.dart';
import 'pages/settings_page.dart';  // Add this import
import 'pages/help_center_page.dart';

// Add extension for String to add capitalize method
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

// Define custom theme enum
enum AppTheme { light, dark }

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );
  runApp(
    const AuthWrapper(),
  ); // Use AuthWrapper instead of directly starting with AlgorithmVisualizerApp
}

// App wrapper that handles auth state
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  AppTheme _currentTheme = AppTheme.light;

  void _setTheme(AppTheme theme) {
    setState(() {
      _currentTheme = theme;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Algorithm Visualizer',
      debugShowCheckedModeBanner: false,
      theme: _getThemeData(AppTheme.light),
      darkTheme: _getThemeData(AppTheme.dark),
      themeMode:
          _currentTheme == AppTheme.light
              ? ThemeMode.light
              : ThemeMode.dark,
      // Start with the LoginScreen
      home: LoginScreen(onLoginSuccess: _handleLoginSuccess),
      routes: {
        '/settings': (context) => const SettingsPage(),
        '/help-center': (context) => const HelpCenterPage(),
      },
    );
  }

  // Copy the existing _getThemeData method from your AlgorithmVisualizerApp class
  ThemeData _getThemeData(AppTheme theme) {
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

  // Handle successful login
  void _handleLoginSuccess() {
    // Navigate to the main app
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder:
            (context) => AlgorithmVisualizerApp(initialTheme: _currentTheme),
      ),
    );
  }
}

// Modify AlgorithmVisualizerApp to accept an initial theme
class AlgorithmVisualizerApp extends StatefulWidget {
  final AppTheme initialTheme;

  const AlgorithmVisualizerApp({super.key, this.initialTheme = AppTheme.light});

  @override
  State<AlgorithmVisualizerApp> createState() => _AlgorithmVisualizerAppState();
}

class _AlgorithmVisualizerAppState extends State<AlgorithmVisualizerApp> {
  late AppTheme _currentTheme;

  @override
  void initState() {
    super.initState();
    _currentTheme = widget.initialTheme;
  }

  void _setTheme(AppTheme theme) {
    setState(() {
      _currentTheme = theme;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Algorithm Visualizer',
      debugShowCheckedModeBanner: false,
      theme: _getThemeData(AppTheme.light),
      darkTheme: _getThemeData(AppTheme.dark),
      themeMode:
          _currentTheme == AppTheme.light
              ? ThemeMode.light
              : ThemeMode.dark,
      home: HomePage(setTheme: _setTheme, currentTheme: _currentTheme),
    );
  }

  ThemeData _getThemeData(AppTheme theme) {
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

class HomePage extends StatefulWidget {
  final Function(AppTheme) setTheme;
  final AppTheme currentTheme;

  const HomePage({
    super.key,
    required this.setTheme,
    required this.currentTheme,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _isNavRailExtended = false;
  late AnimationController _animationController;
  late AnimationController _logoAnimationController;

  final List<Widget> _pages = [];
  // Add a GlobalKey for the scaffold to access the drawer
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _logoAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    // Initialize pages with the theme toggle function
    _pages.addAll([
      DashboardPage(
        setTheme: widget.setTheme,
        currentTheme: widget.currentTheme,
      ),
      const AlgorithmsPage(),
      const DataStructuresPage(),
      const DevelopersPage(),
      const SettingsPage(),
      const HelpCenterPage(),
      const ProfilePage(),
    ]);

    // Check screen width on init to set rail state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final width = MediaQuery.of(context).size.width;
      if (width > 800) {
        setState(() {
          _isNavRailExtended = true;
        });
        // Start with the rail extended on desktop
        _animationController.value = 1.0;
      }

      // Ensure animation controllers are running regardless of screen size
      if (!_logoAnimationController.isAnimating) {
        _logoAnimationController.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _logoAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final isSmallScreen = width < 600; // Define small screen threshold

    return Scaffold(
      key: _scaffoldKey,
      // Add AppBar for mobile screens
      appBar:
          isSmallScreen
              ? AppBar(
                title: Text(
                  'AlgoViz',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                iconTheme: IconThemeData(
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
                leading: IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    _scaffoldKey.currentState?.openDrawer();
                  },
                ),
                actions: const [], // Empty actions list
              )
              : null,
      // Add drawer for mobile screens
      drawer: isSmallScreen ? _buildDrawer(context) : null,
      body: SafeArea(
        child: Row(
          children: [
            // Show NavigationRail only on larger screens
            if (!isSmallScreen)
              LayoutBuilder(
                builder: (context, constraints) {
                  return MouseRegion(
                    onEnter: (_) {
                      if (width <= 800 && !_isNavRailExtended) {
                        _animationController.forward();
                      }
                    },
                    onExit: (_) {
                      if (width <= 800 && !_isNavRailExtended) {
                        _animationController.reverse();
                      }
                    },
                    child: AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return NavigationRail(
                          extended:
                              _isNavRailExtended ||
                              _animationController.value > 0.5,
                          minExtendedWidth: 220,
                          leading: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Column(
                              children: [
                                // Animated App Logo
                                AnimatedBuilder(
                                  animation: _logoAnimationController,
                                  builder: (context, child) {
                                    return Container(
                                      height: 60,
                                      width: 60,
                                      decoration: BoxDecoration(
                                        gradient: RadialGradient(
                                          colors: [
                                            Theme.of(
                                              context,
                                            ).colorScheme.primaryContainer,
                                            Theme.of(context)
                                                .colorScheme
                                                .primaryContainer
                                                .withOpacity(0.9),
                                          ],
                                          radius: 0.8,
                                        ),
                                        borderRadius: BorderRadius.circular(15),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withOpacity(0.4),
                                            blurRadius: 12,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          // Animated circle
                                          Positioned.fill(
                                            child: CustomPaint(
                                              painter: LogoCirclePainter(
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.primary,
                                                progress:
                                                    _logoAnimationController
                                                        .value,
                                              ),
                                            ),
                                          ),
                                          // Main icon with subtle pulse effect
                                          TweenAnimationBuilder<double>(
                                            tween: Tween<double>(
                                              begin: 0.95,
                                              end: 1.05,
                                            ),
                                            duration: const Duration(
                                              milliseconds: 1500,
                                            ),
                                            curve: Curves.easeInOut,
                                            builder: (context, value, child) {
                                              return Transform.scale(
                                                scale: value,
                                                child: Icon(
                                                  Icons.code,
                                                  color:
                                                      Theme.of(
                                                        context,
                                                      ).colorScheme.primary,
                                                  size: 28,
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                if (_isNavRailExtended ||
                                    _animationController.value > 0.5)
                                  const Padding(
                                    padding: EdgeInsets.only(top: 12),
                                    child: Text(
                                      'AlgoViz',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          destinations: [
                            _buildNavRailDestination(
                              Icons.dashboard_rounded,
                              'Dashboard',
                              0,
                            ),
                            _buildNavRailDestination(
                              Icons.auto_graph_rounded,
                              'Algorithms',
                              1,
                            ),
                            _buildNavRailDestination(
                              Icons.account_tree_rounded,
                              'Data Structures',
                              2,
                            ),
                            _buildNavRailDestination(
                              Icons.groups_rounded,
                              'Developers',
                              3,
                            ),
                            _buildNavRailDestination(
                              Icons.settings_rounded,
                              'Settings',
                              4,
                            ),
                            _buildNavRailDestination(
                              Icons.help_outline_rounded,
                              'Help Center',
                              5,
                            ),
                            _buildNavRailDestination(
                              Icons.person_rounded,
                              'Profile',
                              6,
                            ),
                          ],
                          selectedIndex: _selectedIndex,
                          onDestinationSelected: (int index) {
                            setState(() {
                              _selectedIndex = index;
                            });
                          },
                          backgroundColor:
                              isDarkMode
                                  ? const Color(0xFF1E1E1E)
                                  : const Color(0xFFF5F5F7),
                          elevation: 4,
                          // Add toggle button for desktop mode
                          trailing: Padding(
                            padding: const EdgeInsets.only(bottom: 20.0),
                            child: IconButton(
                              icon: Icon(
                                _isNavRailExtended
                                    ? Icons.chevron_left
                                    : Icons.chevron_right,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.7),
                              ),
                              onPressed: () {
                                setState(() {
                                  _isNavRailExtended = !_isNavRailExtended;
                                  if (_isNavRailExtended) {
                                    _animationController.forward();
                                  } else {
                                    _animationController.reverse();
                                  }
                                });
                              },
                              tooltip:
                                  _isNavRailExtended ? 'Collapse' : 'Expand',
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),

            // Main Content with animated transition
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.05, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: _pages[_selectedIndex],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton:
          _selectedIndex != 0
              ? FloatingActionButton(
                onPressed: () {
                  // Show a snackbar when the FAB is pressed
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Create new ${_selectedIndex == 1
                            ? 'algorithm'
                            : _selectedIndex == 2
                            ? 'data structure'
                            : _selectedIndex == 3
                            ? 'developer profile'
                            : _selectedIndex == 4
                            ? 'setting'
                            : _selectedIndex == 5
                            ? 'help article'
                            : 'profile'}',
                      ),
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                tooltip: 'Create New',
                child: const Icon(Icons.add),
              )
              : null,
    );
  }

  // Add a method to build the drawer for mobile screens
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Replace static logo with animated logo
                AnimatedBuilder(
                  animation: _logoAnimationController,
                  builder: (context, child) {
                    return Container(
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            Theme.of(context).colorScheme.primaryContainer,
                            Theme.of(
                              context,
                            ).colorScheme.primaryContainer.withOpacity(0.9),
                          ],
                          radius: 0.8,
                        ),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.4),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Animated circle
                          Positioned.fill(
                            child: CustomPaint(
                              painter: LogoCirclePainter(
                                color: Theme.of(context).colorScheme.primary,
                                progress: _logoAnimationController.value,
                              ),
                            ),
                          ),
                          // Main icon with subtle pulse effect
                          TweenAnimationBuilder<double>(
                            tween: Tween<double>(begin: 0.95, end: 1.05),
                            duration: const Duration(milliseconds: 1500),
                            curve: Curves.easeInOut,
                            builder: (context, value, child) {
                              return Transform.scale(
                                scale: value,
                                child: Icon(
                                  Icons.code,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 28,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                const Text(
                  'AlgoViz',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  context,
                  Icons.dashboard_rounded,
                  'Dashboard',
                  0,
                ),
                _buildDrawerItem(
                  context,
                  Icons.auto_graph_rounded,
                  'Algorithms',
                  1,
                ),
                _buildDrawerItem(
                  context,
                  Icons.account_tree_rounded,
                  'Data Structures',
                  2,
                ),
                _buildDrawerItem(
                  context,
                  Icons.groups_rounded,
                  'Developers',
                  3,
                ),
                _buildDrawerItem(
                  context,
                  Icons.settings_rounded,
                  'Settings',
                  4,
                ),
                _buildDrawerItem(
                  context,
                  Icons.help_outline_rounded,
                  'Help Center',
                  5,
                ),
                _buildDrawerItem(context, Icons.person_rounded, 'Profile', 6),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.color_lens_outlined),
                  title: const Text('Change Theme'),
                  onTap: () {
                    Navigator.pop(context); // Close drawer
                    _showThemeOptions(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Add a method to build drawer items
  Widget _buildDrawerItem(
    BuildContext context,
    IconData icon,
    String label,
    int index,
  ) {
    final isSelected = _selectedIndex == index;
    return ListTile(
      leading: Icon(
        icon,
        color:
            isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: Theme.of(
        context,
      ).colorScheme.primaryContainer.withOpacity(0.3),
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        Navigator.pop(context); // Close drawer
      },
    );
  }

  // Add a method to show theme options dialog
  void _showThemeOptions(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Select Theme'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildThemeOption(
                  context,
                  AppTheme.light,
                  'Light Theme',
                  Icons.light_mode,
                  Colors.amber,
                ),
                _buildThemeOption(
                  context,
                  AppTheme.dark,
                  'Dark Theme',
                  Icons.dark_mode,
                  Colors.indigo,
                ),

              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
    );
  }

  // Add a method to build theme option items
  Widget _buildThemeOption(
    BuildContext context,
    AppTheme theme,
    String label,
    IconData icon,
    Color color,
  ) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label),
      selected: widget.currentTheme == theme,
      onTap: () {
        widget.setTheme(theme);
        Navigator.pop(context);
        // Show a snackbar to confirm theme change
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Switched to ${theme.name.capitalize()} Theme'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 1),
          ),
        );
      },
    );
  }

  NavigationRailDestination _buildNavRailDestination(
    IconData icon,
    String label,
    int index,
  ) {
    final isSelected = _selectedIndex == index;
    return NavigationRailDestination(
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color:
              isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
        ),
      ),
      selectedIcon: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Theme.of(context).colorScheme.primary),
      ),
      label: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}

// Custom painter for animated logo circle
class LogoCirclePainter extends CustomPainter {
  final Color color;
  final double progress;

  LogoCirclePainter({required this.color, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.4;

    // Create a vibrant outer glow
    final outerGlowPaint =
        Paint()
          ..color = color.withOpacity(0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12.0);

    canvas.drawCircle(center, radius * 1.3, outerGlowPaint);

    // Draw a clean, bold circle
    final circlePaint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0;

    canvas.drawCircle(center, radius, circlePaint);

    // Draw pulsing dots at cardinal points
    final dotPaint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;

    // Calculate dot positions with pulsing size
    for (int i = 0; i < 4; i++) {
      final angle = i * pi / 2 + progress * 2 * pi;
      final dotSize = 3.0 + sin(progress * 2 * pi) * 1.5;

      final dotPosition = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );

      canvas.drawCircle(dotPosition, dotSize, dotPaint);
    }

    // Draw a simple binary/code pattern that rotates
    final codeSymbols = ['0', '1'];

    for (int i = 0; i < 8; i++) {
      final angle = i * pi / 4 + progress * pi;
      final distance = radius * 0.7;

      final symbolPosition = Offset(
        center.dx + distance * cos(angle),
        center.dy + distance * sin(angle),
      );

      final textPainter = TextPainter(
        text: TextSpan(
          text: codeSymbols[i % 2],
          style: TextStyle(
            color: color.withOpacity(0.7),
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();

      canvas.save();
      canvas.translate(symbolPosition.dx, symbolPosition.dy);
      canvas.rotate(angle + pi / 2);
      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );
      canvas.restore();
    }

    // Draw a clean inner ring that pulses
    final innerRingPaint =
        Paint()
          ..color = color.withValues(alpha: (0.5 + 0.3 * sin(progress * 2 * pi)).clamp(0.0, 1.0))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;

    canvas.drawCircle(
      center,
      radius * (0.7 + 0.05 * sin(progress * 2 * pi)),
      innerRingPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Dashboard Page with animated background
class DashboardPage extends StatefulWidget {
  final Function(AppTheme) setTheme;
  final AppTheme currentTheme;

  const DashboardPage({
    super.key,
    required this.setTheme,
    required this.currentTheme,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  late final AnimationController _particleAnimationController;
  late final AnimationController _welcomeAnimationController;
  late final AnimationController _pulseAnimationController;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Add animation controller for particles
    _particleAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    // Add animation controller for welcome text
    _welcomeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    // Add pulse animation for interactive elements
    _pulseAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _particleAnimationController.dispose();
    _welcomeAnimationController.dispose();
    _pulseAnimationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final width = MediaQuery.of(context).size.width;
    final isSmallScreen = width < 600;

    return Scaffold(
      body: Stack(
        children: [
          // Animated background with particles
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _particleAnimationController,
              builder: (context, child) {
                return RepaintBoundary(
                  child: CustomPaint(
                    painter: AnimatedParticleBackgroundPainter(
                      color: Theme.of(context).colorScheme.primary,
                      animation: _particleAnimationController,
                      particleCount:
                          width > 800
                              ? 40
                              : 20, // Adjust particle count based on screen size
                      isDarkMode: isDarkMode, // Pass theme info to painter
                    ),
                  ),
                );
              },
            ),
          ),
          // Main content
          CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 200.0,
                floating: false,
                pinned: true,
                stretch: true,
                backgroundColor:
                    isDarkMode
                        ? const Color(0xFF1E1E1E).withOpacity(0.95)
                        : Theme.of(context).colorScheme.surface.withOpacity(0.95),
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: false,
                  titlePadding: const EdgeInsets.only(
                    left: 16,
                    bottom: 16,
                    right: 16,
                  ),
                  title:
                      _isSearching
                          ? null
                          : Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Algorithm Visualizer',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: isSmallScreen ? 16 : 20,
                                letterSpacing: 0.5,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    offset: const Offset(0, 1),
                                    blurRadius: 3.0,
                                    color: Colors.black.withOpacity(0.5),
                                  ),
                                ],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Algorithm-themed banner with adjusted colors for blue theme
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Theme.of(context).colorScheme.primary,
                              Theme.of(context).colorScheme.tertiary,
                            ],
                          ),
                        ),
                        child: CustomPaint(
                          painter: AlgorithmBannerPainter(
                            color: Colors.white,
                            animation: _particleAnimationController,
                          ),
                        ),
                      ),
                      // Add animated text overlay with better visibility and positioning
                      Positioned(
                        bottom:
                            70, // Increased bottom position to avoid overlap
                        left: 20,
                        right: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.5),
                                end: Offset.zero,
                              ).animate(
                                CurvedAnimation(
                                  parent: _welcomeAnimationController,
                                  curve: Curves.easeOutQuint,
                                ),
                              ),
                              child: FadeTransition(
                                opacity: CurvedAnimation(
                                  parent: _welcomeAnimationController,
                                  curve: Curves.easeIn,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Visualize. Learn. Master.',
                                    style: TextStyle(
                                      fontSize: isSmallScreen ? 18 : 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          offset: const Offset(0, 1),
                                          blurRadius: 3.0,
                                          color: Colors.black.withOpacity(0.7),
                                        ),
                                      ],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.5),
                                end: Offset.zero,
                              ).animate(
                                CurvedAnimation(
                                  parent: _welcomeAnimationController,
                                  curve: const Interval(
                                    0.2,
                                    1.0,
                                    curve: Curves.easeOutQuint,
                                  ),
                                ),
                              ),
                              child: FadeTransition(
                                opacity: CurvedAnimation(
                                  parent: _welcomeAnimationController,
                                  curve: const Interval(
                                    0.2,
                                    1.0,
                                    curve: Curves.easeIn,
                                  ),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Interactive algorithm visualizations at your fingertips',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          offset: const Offset(0, 1),
                                          blurRadius: 2.0,
                                          color: Colors.black.withOpacity(0.7),
                                        ),
                                      ],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Gradient overlay for better text readability
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(
                                0.8,
                              ), // Increased opacity for better contrast
                            ],
                            stops: const [0.4, 1.0], // Start gradient higher
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                title:
                    _isSearching
                        ? TextField(
                          controller: _searchController,
                          autofocus: true,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search algorithms, data structures...',
                            hintStyle: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.6),
                            ),
                            border: InputBorder.none,
                          ),
                          onSubmitted: (value) {
                            // Handle search
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Searching for: $value'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            setState(() {
                              _isSearching = false;
                            });
                          },
                        )
                        : null,
                actions: [
                  // Improved icon visibility with container backgrounds
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color:
                          isDarkMode
                              ? Colors.white.withOpacity(0.15)
                              : Colors.black.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: Icon(
                        _isSearching ? Icons.close : Icons.search,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                      onPressed: () {
                        setState(() {
                          _isSearching = !_isSearching;
                          if (!_isSearching) {
                            _searchController.clear();
                          }
                        });
                      },
                      tooltip: _isSearching ? 'Cancel Search' : 'Search',
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color:
                          isDarkMode
                              ? Colors.white.withValues(alpha: 0.15)
                              : Colors.black.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: PopupMenuButton<AppTheme>(
                      icon: Icon(
                        Icons.palette_outlined,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                      tooltip: 'Change Theme',
                      onSelected: (AppTheme theme) {
                        widget.setTheme(theme);
                        // Show a snackbar to confirm theme change
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Switched to ${theme.name.capitalize()} Theme',
                            ),
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      itemBuilder:
                          (BuildContext context) => <PopupMenuEntry<AppTheme>>[
                            const PopupMenuItem<AppTheme>(
                              value: AppTheme.light,
                              child: Row(
                                children: [
                                  Icon(Icons.light_mode, color: Colors.amber),
                                  SizedBox(width: 12),
                                  Text('Light Theme'),
                                ],
                              ),
                            ),
                            const PopupMenuItem<AppTheme>(
                              value: AppTheme.dark,
                              child: Row(
                                children: [
                                  Icon(Icons.dark_mode, color: Colors.indigo),
                                  SizedBox(width: 12),
                                  Text('Dark Theme'),
                                ],
                              ),
                            ),

                          ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color:
                          isDarkMode
                              ? Colors.white.withOpacity(0.15)
                              : Colors.black.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.notifications_outlined,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                      onPressed: () {
                        // Show a snackbar for notifications
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('No new notifications'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      tooltip: 'Notifications',
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical:
                        MediaQuery.of(context).size.width > 600 ? 16.0 : 12.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Animated welcome text
                      SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, -0.5),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: _welcomeAnimationController,
                            curve: Curves.easeOutQuint,
                          ),
                        ),
                        child: FadeTransition(
                          opacity: CurvedAnimation(
                            parent: _welcomeAnimationController,
                            curve: Curves.easeIn,
                          ),
                          child: Text(
                            'Welcome back!',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                              color:
                                  Theme.of(context)
                                      .colorScheme
                                      .onSurface, // Use onBackground for better contrast
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.5),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: _welcomeAnimationController,
                            curve: Curves.easeOutQuint,
                            reverseCurve: Curves.easeIn,
                          ),
                        ),
                        child: FadeTransition(
                          opacity: CurvedAnimation(
                            parent: _welcomeAnimationController,
                            curve: const Interval(
                              0.3,
                              1.0,
                              curve: Curves.easeIn,
                            ),
                          ),
                          child: Text(
                            'Continue your learning journey with interactive visualizations',
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(
                                0.8,
                              ), // Increased opacity for better visibility
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Stats cards with improved layout for desktop
                      LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth > 600) {
                            return Row(
                              children: [
                                Expanded(
                                  child: _buildStatCard(
                                    context,
                                    'Completed',
                                    '12',
                                    Icons.check_circle_outline,
                                    Colors.green,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildStatCard(
                                    context,
                                    'In Progress',
                                    '5',
                                    Icons.pending_outlined,
                                    Colors.orange,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildStatCard(
                                    context,
                                    'Points',
                                    '850',
                                    Icons.star_outline,
                                    Colors.amber,
                                  ),
                                ),
                              ],
                            );
                          } else {
                            return Column(
                              children: [
                                _buildStatCard(
                                  context,
                                  'Completed',
                                  '12',
                                  Icons.check_circle_outline,
                                  Colors.green,
                                ),
                                const SizedBox(height: 12),
                                _buildStatCard(
                                  context,
                                  'In Progress',
                                  '5',
                                  Icons.pending_outlined,
                                  Colors.orange,
                                ),
                                const SizedBox(height: 12),
                                _buildStatCard(
                                  context,
                                  'Points',
                                  '850',
                                  Icons.star_outline,
                                  Colors.amber,
                                ),
                              ],
                            );
                          }
                        },
                      ),

                      const SizedBox(height: 24),

                      // Tab bar for categories
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          tabs: const [
                            Tab(text: 'Popular'),
                            Tab(text: 'Recent'),
                            Tab(text: 'Recommended'),
                          ],
                          indicator: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color:
                                Theme.of(context).colorScheme.primaryContainer,
                          ),
                          labelColor: Theme.of(context).colorScheme.primary,
                          unselectedLabelColor: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.7),
                          labelStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      // Fixed height container for tab content to prevent overflow
                      SizedBox(
                        height:
                            MediaQuery.of(context).size.width > 600 ? 220 : 240,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildTabContent(context, 'Popular'),
                            _buildTabContent(context, 'Recent'),
                            _buildTabContent(context, 'Recommended'),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      const Text(
                        'Explore Topics',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              // Feature cards grid with responsive layout
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: _calculateGridCrossAxisCount(width),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: _calculateChildAspectRatio(width),
                  ),
                  delegate: SliverChildListDelegate([
                    _buildFeatureCard(
                      context,
                      'Sorting Algorithms',
                      'Learn and visualize different sorting techniques',
                      Icons.sort_rounded,
                      Colors.blue,
                      SortingVisualizer(),
                    ),
                    _buildFeatureCard(
                      context,
                      'Searching Algorithms',
                      'Explore efficient ways to find elements',
                      Icons.search_rounded,
                      Colors.green,
                      SearchVisualizer(),
                    ),
                    _buildFeatureCard(
                      context,
                      'Array Algorithms',
                      'Explore efficient ways to find elements',
                      Icons.abc_sharp,
                      Colors.green,
                      ArrayOperations(),
                    ),
                    _buildFeatureCard(
                      context,
                      'Graph Algorithms',
                      'Visualize pathfinding and network flows',
                      Icons.hub_rounded,
                      Colors.orange,
                      GraphOperationsPage(),
                    ),
                    _buildFeatureCard(
                      context,
                      'Tree Operations',
                      'Understand hierarchical data structures',
                      Icons.account_tree_rounded,
                      Colors.purple,
                      TreeOperationsPage(),
                    ),
                    _buildFeatureCard(
                      context,
                      'Linked Lists',
                      'Learn about sequential access data structures',
                      Icons.link_rounded,
                      Colors.red,
                      LinkedListOperationsPage(),
                    ),
                    _buildFeatureCard(
                      context,
                      'Stack & Queue',
                      'Visualize LIFO and FIFO operations',
                      Icons.layers_rounded,
                      Colors.teal,
                      StackQueueOperationsPage(),
                    ),
                    _buildFeatureCard(
                      context,
                      'Quiz Section',
                      'Test your knowledge with interactive quizzes',
                      Icons.quiz_rounded,
                      Colors.amber,
                      ComingSoon(),
                    ),
                    _buildFeatureCard(
                      context,
                      'Leaderboard',
                      'Compare your progress with other learners',
                      Icons.leaderboard_rounded,
                      Colors.indigo,
                      ComingSoon(),
                    ),
                  ]),
                ),
              ),
              // Add bottom padding to prevent content from being cut off
              SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ],
      ),
    );
  }

  // Helper method to calculate grid cross axis count based on screen width
  int _calculateGridCrossAxisCount(double width) {
    if (width > 1400) return 5;
    if (width > 1200) return 4;
    if (width > 800) return 3;
    if (width > 600) return 2;
    return 2;
  }

  // Helper method to calculate child aspect ratio based on screen width
  double _calculateChildAspectRatio(double width) {
    if (width > 1200) return 1.2;
    if (width > 800) return 1.1;
    if (width > 600) return 1.0;
    return 0.85;
  }

  // Enhanced tab content cards with fixed overflow issues
  Widget _buildTabContent(BuildContext context, String category) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final cardWidth = width > 600 ? 280.0 : min(260.0, width * 0.8);

    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final cardColor =
              [
                Colors.blue,
                Colors.green,
                Colors.orange,
                Colors.purple,
                Colors.red,
              ][index % 5];

          return Container(
            width: cardWidth,
            margin: const EdgeInsets.only(right: 16),
            child: Card(
              clipBehavior: Clip.antiAlias,
              elevation: 6, // Increased elevation
              shadowColor: cardColor.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: cardColor.withOpacity(0.5), width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [cardColor, cardColor.withOpacity(0.7)],
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Add decorative elements
                        Positioned.fill(
                          child: CustomPaint(
                            painter: CardHeaderPainter(
                              color: Colors.white,
                              isDarkMode: isDarkMode,
                            ),
                          ),
                        ),
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              [
                                Icons.sort,
                                Icons.search,
                                Icons.hub,
                                Icons.account_tree,
                                Icons.link,
                              ][index % 5],
                              color: Colors.white,
                              size: 36,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$category Algorithm ${index + 1}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color:
                                  isDarkMode
                                      ? cardColor.withOpacity(0.9)
                                      : cardColor.withOpacity(0.8),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: Text(
                              'Interactive visualization with step-by-step explanation',
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.8),
                                fontSize: 12,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Enhanced feature card with better responsiveness
  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
    Widget targetPage, // Add this parameter
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Hero(
      tag: title,
      child: Card(
        elevation: 6,
        shadowColor: color.withOpacity(0.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: color.withOpacity(0.5), width: 1.5),
        ),
        child: InkWell(
          onTap: () {
            // Navigate to the specified target page
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => targetPage),
            );
          },
          borderRadius: BorderRadius.circular(20),
          splashColor: color.withOpacity(0.2),
          highlightColor: color.withOpacity(0.1),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  isDarkMode ? color.withOpacity(0.1) : color.withOpacity(0.05),
                  Colors.transparent,
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          isDarkMode
                              ? color.withOpacity(0.2)
                              : color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      border: Border.all(
                        color: color.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      icon,
                      size: 30,
                      color: isDarkMode ? color.withOpacity(0.9) : color,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                      color:
                          isDarkMode
                              ? color.withOpacity(0.9)
                              : color.withOpacity(0.8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Text(
                      description,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.8),
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Add the missing _buildStatCard method
  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 4, // Increased elevation
      shadowColor: color.withOpacity(0.4), // Color-tinted shadow
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: color.withOpacity(0.5), // Colored border
          width: 1.5,
        ),
      ),
      color:
          isDarkMode
              ? Theme.of(context).colorScheme.surface.withOpacity(0.9)
              : Theme.of(context).colorScheme.surface,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              isDarkMode ? color.withOpacity(0.05) : color.withOpacity(0.05),
              Colors.transparent,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(isDarkMode ? 0.2 : 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface
                          .withOpacity(0.9), // Increased opacity
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: TextStyle(
                  fontSize: 28, // Larger font
                  fontWeight: FontWeight.bold,
                  color:
                      isDarkMode
                          ? color.withOpacity(0.9)
                          : color.withOpacity(0.8), // Colored value
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Add this new painter for tab content card headers
class CardHeaderPainter extends CustomPainter {
  final Color color;
  final bool isDarkMode;
  final Random random = Random();

  CardHeaderPainter({required this.color, required this.isDarkMode});

  @override
  void paint(Canvas canvas, Size size) {
    // Draw decorative elements for card headers
    final paint =
        Paint()
          ..color = color.withOpacity(0.1)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;

    // Draw some geometric shapes
    for (int i = 0; i < 5; i++) {
      final x = size.width * random.nextDouble();
      final y = size.height * random.nextDouble();
      final radius = 5 + random.nextDouble() * 15;

      canvas.drawCircle(Offset(x, y), radius, paint);
    }

    // Draw some lines
    for (int i = 0; i < 8; i++) {
      final startX = size.width * random.nextDouble();
      final startY = size.height * random.nextDouble();
      final endX = startX + (random.nextDouble() - 0.5) * 40;
      final endY = startY + (random.nextDouble() - 0.5) * 40;

      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
    }

    // Draw a subtle grid pattern
    final gridSize = 20.0;
    final gridPaint =
        Paint()
          ..color = color.withOpacity(0.05)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5;

    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Enhanced animated particle background painter
class AnimatedParticleBackgroundPainter extends CustomPainter {
  final Color color;
  final Animation<double> animation;
  final List<AnimatedParticle> particles = [];
  final Random random = Random();
  final int particleCount;
  final bool isDarkMode; // Add theme awareness

  AnimatedParticleBackgroundPainter({
    required this.color,
    required this.animation,
    this.particleCount = 30,
    required this.isDarkMode, // Add this parameter
  }) : super(repaint: animation) {
    // Initialize particles with simpler, cleaner shapes
    for (int i = 0; i < particleCount; i++) {
      particles.add(
        AnimatedParticle(
          position: Offset(
            random.nextDouble() * 1000,
            random.nextDouble() * 1000,
          ),
          speed: Offset(
            (random.nextDouble() - 0.5) * 0.8, // Slower, more subtle movement
            (random.nextDouble() - 0.5) * 0.8,
          ),
          radius: 1 + random.nextDouble() * 2, // Smaller particles
          color: color.withOpacity(
            isDarkMode ? 0.2 : 0.15,
          ), // Adjust opacity based on theme
          type: random.nextInt(
            2,
          ), // Only circles and code symbols for cleaner look
        ),
      );
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Draw a clean, subtle gradient background - adjusted for theme
    final Paint gradientPaint = Paint();
    final Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);

    gradientPaint.shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        color.withOpacity(isDarkMode ? 0.1 : 0.07),
        color.withOpacity(isDarkMode ? 0.05 : 0.02),
      ],
      stops: const [0.0, 1.0],
    ).createShader(rect);

    canvas.drawRect(rect, gradientPaint);

    // Draw a subtle, clean grid pattern - adjusted for theme
    final gridPaint =
        Paint()
          ..color = color.withOpacity(isDarkMode ? 0.08 : 0.05)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5;

    // Draw fewer grid lines for a cleaner look
    final gridSize = 80.0;
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Draw clean, simple particles
    for (var particle in particles) {
      // Update position based on animation value
      final currentPosition = Offset(
        (particle.position.dx + particle.speed.dx * animation.value * 20) %
            size.width,
        (particle.position.dy + particle.speed.dy * animation.value * 20) %
            size.height,
      );

      final paint =
          Paint()
            ..color = particle.color
            ..style = PaintingStyle.fill;

      // Draw simple shapes
      if (particle.type == 0) {
        // Simple circle
        canvas.drawCircle(currentPosition, particle.radius, paint);
      } else {
        // Simple code symbol
        final symbols = ['0', '1', '{', '}'];
        final symbol = symbols[random.nextInt(symbols.length)];

        final textPainter = TextPainter(
          text: TextSpan(
            text: symbol,
            style: TextStyle(
              color: particle.color,
              fontSize: particle.radius * 3,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        );

        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(
            currentPosition.dx - textPainter.width / 2,
            currentPosition.dy - textPainter.height / 2,
          ),
        );
      }
    }

    // Add a few larger, eye-catching elements
    final highlightCount = 3;
    for (int i = 0; i < highlightCount; i++) {
      final x = size.width * (i + 1) / (highlightCount + 1);
      final y = size.height * 0.3 + 100 * sin(animation.value * pi + i);

      // Draw a pulsing circle
      final highlightPaint =
          Paint()
            ..color = color.withValues(
              alpha: (0.1 + 0.05 * sin(animation.value * pi + i)).clamp(0.0, 1.0),
            )
            ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(x, y),
        20 + 5 * sin(animation.value * pi + i),
        highlightPaint,
      );

      // Add a simple code pattern inside
      final codePattern = i % 2 == 0 ? '{ }' : '[ ]';
      final textPainter = TextPainter(
        text: TextSpan(
          text: codePattern,
          style: TextStyle(
            color: color.withValues(alpha: (0.6 + 0.2 * sin(animation.value * pi + i)).clamp(0.0, 1.0)),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class AnimatedParticle {
  Offset position;
  Offset speed;
  double radius;
  Color color;
  int type; // 0: circle, 1: code symbol

  AnimatedParticle({
    required this.position,
    required this.speed,
    required this.radius,
    required this.color,
    required this.type,
  });
}

// Add this new class after the AnimatedParticle class
class AlgorithmBannerPainter extends CustomPainter {
  final Color color;
  final Animation<double> animation;

  AlgorithmBannerPainter({required this.color, required this.animation})
    : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    // Simple gradient background that adapts to theme
    final backgroundPaint = Paint();
    final Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);

    backgroundPaint.shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        color.withValues(alpha: 0.1),
        color.withValues(alpha: 0.05),
      ],
    ).createShader(rect);

    canvas.drawRect(rect, backgroundPaint);

    // Simple animated dots pattern
    final dotPaint = Paint()..color = color.withValues(alpha: 0.3);
    final dotCount = 12;

    for (int i = 0; i < dotCount; i++) {
      final angle = (i * 2 * pi / dotCount) + (animation.value * 2 * pi * 0.1);
      final radius = size.width * 0.3;
      final x = size.width * 0.5 + radius * cos(angle);
      final y = size.height * 0.5 + radius * sin(angle);

      final dotRadius = 4.0 + 2.0 * sin(animation.value * 2 * pi + i);
      canvas.drawCircle(Offset(x, y), dotRadius, dotPaint);
    }

    // Central pulsing circle
    final centerX = size.width * 0.5;
    final centerY = size.height * 0.5;
    final pulseRadius = 30.0 + 10.0 * sin(animation.value * 2 * pi);

    final centralPaint = Paint()..color = color.withValues(alpha: 0.2);
    canvas.drawCircle(Offset(centerX, centerY), pulseRadius, centralPaint);

    // Inner circle
    final innerPaint = Paint()..color = color.withValues(alpha: 0.4);
    canvas.drawCircle(Offset(centerX, centerY), pulseRadius * 0.5, innerPaint);
  }


  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class AlgorithmsPage extends StatefulWidget {
  const AlgorithmsPage({super.key});

  @override
  State<AlgorithmsPage> createState() => _AlgorithmsPageState();
}


class _AlgorithmsPageState extends State<AlgorithmsPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;
    final isVerySmallScreen = size.width < 360;
    final isLargeScreen = size.width >= 1200;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Algorithms',
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
          ),
        ),
        iconTheme: IconThemeData(
          color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implement search functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Implement filter functionality
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isVerySmallScreen ? 8.0 : (isSmallScreen ? 12.0 : 20.0),
          vertical: isVerySmallScreen ? 12.0 : 16.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Explore Algorithms',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: isVerySmallScreen ? 18 : null,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Learn and visualize various algorithmic approaches',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                fontSize: isVerySmallScreen ? 12 : null,
              ),
            ),
            SizedBox(height: isVerySmallScreen ? 16 : 24),

            // Grid of algorithm cards with staggered animations
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isVerySmallScreen ? 1 : (isLargeScreen ? 4 : (isSmallScreen ? 2 : 3)),
                crossAxisSpacing: isVerySmallScreen ? 8 : (isSmallScreen ? 12 : 16),
                mainAxisSpacing: isVerySmallScreen ? 8 : (isSmallScreen ? 12 : 16),
                childAspectRatio: isVerySmallScreen ? 1.2 : (isLargeScreen ? 1.1 : (isSmallScreen ? 0.85 : 1.0)),
              ),
              itemCount: 8,
              itemBuilder: (context, index) {
                final items = [
                  _AlgorithmItem(
                    title: 'Sorting',
                    description: 'Compare sorting techniques',
                    icon: Icons.sort_rounded,
                    color: Colors.blue,
                    algorithms: ['Bubble', 'Quick', 'Merge'],
                  ),
                  _AlgorithmItem(
                    title: 'Searching',
                    description: 'Find elements efficiently',
                    icon: Icons.search_rounded,
                    color: Colors.green,
                    algorithms: ['Binary', 'Linear', 'Jump'],
                  ),
                  _AlgorithmItem(
                    title: 'Graph',
                    description: 'Network-based problems',
                    icon: Icons.hub_rounded,
                    color: Colors.purple,
                    algorithms: ['DFS', 'BFS', 'Dijkstra'],
                  ),
                  _AlgorithmItem(
                    title: 'Dynamic',
                    description: 'Optimize complex problems',
                    icon: Icons.auto_graph_rounded,
                    color: Colors.orange,
                    algorithms: ['Fibonacci', 'Knapsack', 'LCS'],
                  ),
                  _AlgorithmItem(
                    title: 'Greedy',
                    description: 'Make optimal choices',
                    icon: Icons.trending_up_rounded,
                    color: Colors.red,
                    algorithms: ['Scheduling', 'Huffman', "Prim's"],
                  ),
                  _AlgorithmItem(
                    title: 'Backtracking',
                    description: 'Constraint solving',
                    icon: Icons.route_rounded,
                    color: Colors.teal,
                    algorithms: ['N-Queens', 'Sudoku', 'Maze'],
                  ),
                  _AlgorithmItem(
                    title: 'String',
                    description: 'Text processing',
                    icon: Icons.text_fields_rounded,
                    color: Colors.indigo,
                    algorithms: ['KMP', 'Rabin-K', 'Boyer-M'],
                  ),
                  _AlgorithmItem(
                    title: 'Divide & Conquer',
                    description: 'Break down problems',
                    icon: Icons.account_tree_rounded,
                    color: Colors.amber,
                    algorithms: ['Binary', 'Merge', 'Strassen'],
                  ),
                ];
                
                // Create staggered animation for each item
                final delay = index * 0.15;
                final animation = CurvedAnimation(
                  parent: _animationController,
                  curve: Interval(
                    delay.clamp(0.0, 0.9),
                    (delay + 0.4).clamp(0.0, 1.0),
                    curve: Curves.easeOutQuart,
                  ),
                );
                
                return AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: Transform.translate(
                        offset: Offset(0, 30 * (1 - animation.value)),
                        child: child,
                      ),
                    );
                  },
                  child: _buildAlgorithmCard(context, items[index]),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Add new algorithm implementation'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAlgorithmCard(BuildContext context, _AlgorithmItem item) {
    final size = MediaQuery.of(context).size;
    final isVerySmallScreen = size.width < 360;
    final isSmallScreen = size.width < 600;
    final isLargeScreen = size.width >= 1200;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Modified hover transform for safer scaling
    return Card(
      elevation: 6,
      shadowColor: item.color.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isLargeScreen ? 16 : 12),
        side: BorderSide(
          color: item.color.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Opening ${item.title} visualization'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        borderRadius: BorderRadius.circular(isLargeScreen ? 16 : 12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(isLargeScreen ? 16 : 12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                item.color.withValues(alpha: isDarkMode ? 0.1 : 0.05),
                item.color.withValues(alpha: isDarkMode ? 0.25 : 0.15),
              ],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(isVerySmallScreen ? 8 : (isSmallScreen ? 10 : 12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with icon and title
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(isVerySmallScreen ? 6 : (isSmallScreen ? 8 : 10)),
                      decoration: BoxDecoration(
                        color: item.color.withOpacity(isDarkMode ? 0.3 : 0.2),
                        borderRadius: BorderRadius.circular(isLargeScreen ? 10 : 8),
                        boxShadow: [
                          BoxShadow(
                            color: item.color.withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: -2,
                          ),
                        ],
                      ),
                      child: Icon(
                        item.icon,
                        color: isDarkMode ? item.color.withOpacity(0.9) : item.color,
                        size: isVerySmallScreen ? 16 : (isSmallScreen ? 18 : (isLargeScreen ? 22 : 20)),
                      ),
                    ),
                    SizedBox(width: isVerySmallScreen ? 6 : (isSmallScreen ? 8 : 10)),
                    Expanded(
                      child: Text(
                        item.title,
                        style: TextStyle(
                          fontSize: isVerySmallScreen ? 13 : (isSmallScreen ? 15 : (isLargeScreen ? 18 : 16)),
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                          letterSpacing: 0.3,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isVerySmallScreen ? 6 : (isSmallScreen ? 8 : 10)),
                // Description
                Text(
                  item.description,
                  style: TextStyle(
                    fontSize: isVerySmallScreen ? 10 : (isSmallScreen ? 11 : (isLargeScreen ? 14 : 12)),
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.85),
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                // Algorithm tags
                Wrap(
                  spacing: isVerySmallScreen ? 4 : 5,
                  runSpacing: isVerySmallScreen ? 4 : 5,
                  children: item.algorithms.map((algorithm) {
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isVerySmallScreen ? 4 : (isSmallScreen ? 5 : 7),
                        vertical: isVerySmallScreen ? 2 : 3,
                      ),
                      decoration: BoxDecoration(
                        color: item.color.withOpacity(isDarkMode ? 0.25 : 0.15),
                        borderRadius: BorderRadius.circular(isLargeScreen ? 8 : 6),
                        border: Border.all(
                          color: item.color.withOpacity(0.3),
                          width: 0.8,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: item.color.withOpacity(0.15),
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Text(
                        algorithm,
                        style: TextStyle(
                          color: isDarkMode ? item.color.withOpacity(0.95) : item.color.withOpacity(0.9),
                          fontSize: isVerySmallScreen ? 8 : (isSmallScreen ? 9 : (isLargeScreen ? 11 : 10)),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AlgorithmItem {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final List<String> algorithms;

  _AlgorithmItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.algorithms,
  });
}

class DataStructuresPage extends StatefulWidget {
  const DataStructuresPage({super.key});

  @override
  State<DataStructuresPage> createState() => _DataStructuresPageState();
}

class _DataStructuresPageState extends State<DataStructuresPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isVerySmallScreen = size.width < 360;
    final isSmallScreen = size.width < 600;
    final isLargeScreen = size.width >= 1200;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Data Structures',
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
          ),
        ),
        iconTheme: IconThemeData(
          color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implement search functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Implement filter functionality
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isVerySmallScreen ? 8.0 : (isSmallScreen ? 12.0 : 20.0),
          vertical: isVerySmallScreen ? 12.0 : 16.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Learn Data Structures',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: isVerySmallScreen ? 18 : null,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Master the fundamentals of data organization and manipulation',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                fontSize: isVerySmallScreen ? 12 : null,
              ),
            ),
            SizedBox(height: isVerySmallScreen ? 16 : 24),

            // Grid of data structure cards with staggered animations
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isVerySmallScreen ? 1 : (isLargeScreen ? 4 : (isSmallScreen ? 2 : 3)),
                crossAxisSpacing: isVerySmallScreen ? 8 : (isSmallScreen ? 12 : 16),
                mainAxisSpacing: isVerySmallScreen ? 8 : (isSmallScreen ? 12 : 16),
                childAspectRatio: isVerySmallScreen ? 1.2 : (isLargeScreen ? 1.1 : (isSmallScreen ? 0.85 : 1.0)),
              ),
              itemCount: 8,
              itemBuilder: (context, index) {
                final items = [
                  _DataStructureItem(
                    title: 'Arrays',
                    description: 'Sequential collection',
                    icon: Icons.grid_on_rounded,
                    color: Colors.blue,
                    topics: ['Indexing', 'Sorting', 'Searching'],
                  ),
                  _DataStructureItem(
                    title: 'Linked Lists',
                    description: 'Sequential access',
                    icon: Icons.link_rounded,
                    color: Colors.green,
                    topics: ['Singly', 'Doubly', 'Circular'],
                  ),
                  _DataStructureItem(
                    title: 'Stack',
                    description: 'LIFO structure',
                    icon: Icons.layers_rounded,
                    color: Colors.orange,
                    topics: ['Push', 'Pop', 'Peek'],
                  ),
                  _DataStructureItem(
                    title: 'Queue',
                    description: 'FIFO structure',
                    icon: Icons.queue_rounded,
                    color: Colors.purple,
                    topics: ['Enqueue', 'Dequeue', 'Front'],
                  ),
                  _DataStructureItem(
                    title: 'Trees',
                    description: 'Hierarchical structure',
                    icon: Icons.account_tree_rounded,
                    color: Colors.red,
                    topics: ['Binary', 'AVL', 'Red-Black'],
                  ),
                  _DataStructureItem(
                    title: 'Graphs',
                    description: 'Network structure',
                    icon: Icons.hub_rounded,
                    color: Colors.teal,
                    topics: ['DFS', 'BFS', 'Shortest Path'],
                  ),
                  _DataStructureItem(
                    title: 'Hash Table',
                    description: 'Key-value pairs',
                    icon: Icons.table_chart_rounded,
                    color: Colors.indigo,
                    topics: ['Hashing', 'Collision', 'Chaining'],
                  ),
                  _DataStructureItem(
                    title: 'Heaps',
                    description: 'Tree-based structure',
                    icon: Icons.architecture_rounded,
                    color: Colors.amber,
                    topics: ['Min Heap', 'Max Heap', 'Priority Queue'],
                  ),
                ];
                
                // Create staggered animation for each item
                final delay = index * 0.15;
                final animation = CurvedAnimation(
                  parent: _animationController,
                  curve: Interval(
                    delay.clamp(0.0, 0.9),
                    (delay + 0.4).clamp(0.0, 1.0),
                    curve: Curves.easeOutQuart,
                  ),
                );
                
                return AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: Transform.translate(
                        offset: Offset(0, 30 * (1 - animation.value)),
                        child: child,
                      ),
                    );
                  },
                  child: _buildDataStructureCard(context, items[index]),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new data structure implementation
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Create new data structure implementation'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDataStructureCard(BuildContext context, _DataStructureItem item) {
    final size = MediaQuery.of(context).size;
    final isVerySmallScreen = size.width < 360;
    final isSmallScreen = size.width < 600;
    final isLargeScreen = size.width >= 1200;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Card(
      elevation: 6,
      shadowColor: item.color.withOpacity(0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isLargeScreen ? 16 : 12),
        side: BorderSide(
          color: item.color.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to detailed view
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Opening ${item.title} visualization'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        borderRadius: BorderRadius.circular(isLargeScreen ? 16 : 12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(isLargeScreen ? 16 : 12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                item.color.withOpacity(isDarkMode ? 0.1 : 0.05),
                item.color.withOpacity(isDarkMode ? 0.25 : 0.15),
              ],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(isVerySmallScreen ? 8 : (isSmallScreen ? 10 : 12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with icon and title
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(isVerySmallScreen ? 6 : (isSmallScreen ? 8 : 10)),
                      decoration: BoxDecoration(
                        color: item.color.withOpacity(isDarkMode ? 0.3 : 0.2),
                        borderRadius: BorderRadius.circular(isLargeScreen ? 10 : 8),
                        boxShadow: [
                          BoxShadow(
                            color: item.color.withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: -2,
                          ),
                        ],
                      ),
                      child: Icon(
                        item.icon,
                        color: isDarkMode ? item.color.withOpacity(0.9) : item.color,
                        size: isVerySmallScreen ? 16 : (isSmallScreen ? 18 : (isLargeScreen ? 22 : 20)),
                      ),
                    ),
                    SizedBox(width: isVerySmallScreen ? 6 : (isSmallScreen ? 8 : 10)),
                    Expanded(
                      child: Text(
                        item.title,
                        style: TextStyle(
                          fontSize: isVerySmallScreen ? 13 : (isSmallScreen ? 15 : (isLargeScreen ? 18 : 16)),
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                          letterSpacing: 0.3,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isVerySmallScreen ? 6 : (isSmallScreen ? 8 : 10)),
                // Description
                Text(
                  item.description,
                  style: TextStyle(
                    fontSize: isVerySmallScreen ? 10 : (isSmallScreen ? 11 : (isLargeScreen ? 14 : 12)),
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.85),
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                // Topic tags
                Wrap(
                  spacing: isVerySmallScreen ? 4 : 5,
                  runSpacing: isVerySmallScreen ? 4 : 5,
                  children: item.topics.map((topic) {
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isVerySmallScreen ? 4 : (isSmallScreen ? 5 : 7),
                        vertical: isVerySmallScreen ? 2 : 3,
                      ),
                      decoration: BoxDecoration(
                        color: item.color.withOpacity(isDarkMode ? 0.25 : 0.15),
                        borderRadius: BorderRadius.circular(isLargeScreen ? 8 : 6),
                        border: Border.all(
                          color: item.color.withOpacity(0.3),
                          width: 0.8,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: item.color.withOpacity(0.15),
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Text(
                        topic,
                        style: TextStyle(
                          color: isDarkMode ? item.color.withOpacity(0.95) : item.color.withOpacity(0.9),
                          fontSize: isVerySmallScreen ? 8 : (isSmallScreen ? 9 : (isLargeScreen ? 11 : 10)),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DataStructureItem {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final List<String> topics;

  _DataStructureItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.topics,
  });
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // You can add more sections as needed
  final Map<String, bool> _expandedSections = {
    'Personal Information': false,
    'Account Settings': false,
    'Privacy & Security': false,
    'Developer Options': false,
    'About': false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
          ),
        ),
        elevation: 0,
        iconTheme: IconThemeData(
          color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile header with avatar
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.person, size: 50, color: Colors.white),
                    // You can use a network image here
                    // backgroundImage: NetworkImage('user_avatar_url'),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'User Name',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'user@example.com',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            const Divider(thickness: 1),

            // Expandable sections
            ..._buildExpandableSections(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildExpandableSections() {
    return _expandedSections.entries.map((entry) {
      return Column(
        children: [
          ListTile(
            title: Text(
              entry.key,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            trailing: Icon(
              entry.value ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            ),
            onTap: () {
              setState(() {
                _expandedSections[entry.key] = !entry.value;
              });
            },
          ),
          if (entry.value) _buildSectionContent(entry.key),
          const Divider(thickness: 1),
        ],
      );
    }).toList();
  }

  Widget _buildSectionContent(String section) {
    switch (section) {
      case 'Personal Information':
        return Column(
          children: [
            _buildSettingItem('Name', 'User Name', Icons.edit),
            _buildSettingItem('Email', 'user@example.com', Icons.edit),
            _buildSettingItem('Phone', '+1 234 567 8900', Icons.edit),
          ],
        );
      case 'Account Settings':
        return Column(
          children: [
            _buildSettingItem(
              'Language',
              'English',
              Icons.arrow_forward_ios,
              isSwitch: false,
            ),
            _buildSettingItem(
              'Notifications',
              'On',
              null,
              isSwitch: true,
              switchValue: true,
            ),
            _buildSettingItem(
              'Dark Mode',
              'Off',
              null,
              isSwitch: true,
              switchValue: false,
            ),
          ],
        );
      case 'Privacy & Security':
        return Column(
          children: [
            _buildSettingItem('Change Password', '', Icons.arrow_forward_ios),
            _buildSettingItem(
              'Two-Factor Authentication',
              'Off',
              null,
              isSwitch: true,
              switchValue: false,
            ),
            _buildSettingItem(
              'Data Sharing',
              'Limited',
              Icons.arrow_forward_ios,
            ),
          ],
        );
      case 'Developer Options':
        return Column(
          children: [
            _buildSettingItem(
              'Debug Mode',
              'Off',
              null,
              isSwitch: true,
              switchValue: false,
            ),
            _buildSettingItem(
              'API Environment',
              'Production',
              Icons.arrow_forward_ios,
            ),
            _buildSettingItem('Clear Cache', '', Icons.delete_outline),
            _buildSettingItem('Log Level', 'Warning', Icons.arrow_forward_ios),
            _buildSettingItem(
              'Show Layout Bounds',
              'Off',
              null,
              isSwitch: true,
              switchValue: false,
            ),
          ],
        );
      case 'About':
        return Column(
          children: [
            _buildSettingItem('App Version', '1.0.0', null),
            _buildSettingItem('Terms of Service', '', Icons.arrow_forward_ios),
            _buildSettingItem('Privacy Policy', '', Icons.arrow_forward_ios),
            _buildSettingItem('Licenses', '', Icons.arrow_forward_ios),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildSettingItem(
    String title,
    String subtitle,
    IconData? trailingIcon, {
    bool isSwitch = false,
    bool switchValue = false,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 32.0),
      title: Text(title),
      subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
      trailing:
          isSwitch
              ? Switch(
                value: switchValue,
                onChanged: (value) {
                  // Handle switch change
                  setState(() {
                    // You would typically have a variable to track this state
                    // For this example, we're not persisting the changes
                  });
                },
              )
              : trailingIcon != null
              ? Icon(trailingIcon, size: 20)
              : null,
      onTap:
          trailingIcon != null
              ? () {
                // Handle tap for items with trailing icons
                print('Tapped on $title');
              }
              : null,
    );
  }
}

// New Developers Page
class DevelopersPage extends StatefulWidget {
  const DevelopersPage({super.key});

  @override
  State<DevelopersPage> createState() => _DevelopersPageState();
}

class _DevelopersPageState extends State<DevelopersPage> with SingleTickerProviderStateMixin {
  late AnimationController _backgroundAnimationController;
  late Animation<double> _backgroundAnimation;
  
  @override
  void initState() {
    super.initState();
    _backgroundAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
    
    _backgroundAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _backgroundAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }
  
  @override
  void dispose() {
    _backgroundAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Developers',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: theme.brightness == Brightness.dark ? Colors.white : Colors.black87,
          ),
        ),
        iconTheme: IconThemeData(
          color: theme.brightness == Brightness.dark ? Colors.white : Colors.black87,
        ),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: theme.colorScheme.surface.withOpacity(0.7),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Search coming soon'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Filter options'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // Animated background
          AnimatedBuilder(
            animation: _backgroundAnimation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.scaffoldBackgroundColor,
                      theme.colorScheme.primary.withOpacity(0.05),
                      theme.colorScheme.secondary.withOpacity(0.08),
                    ],
                    stops: [0, 0.5 + (_backgroundAnimation.value * 0.2), 1],
                    transform: GradientRotation(_backgroundAnimation.value * 0.2 * pi),
                  ),
                ),
              );
            },
          ),
          // Animated particles (dots)
          AnimatedBuilder(
            animation: _backgroundAnimation,
            builder: (context, child) {
              return CustomPaint(
                size: Size.infinite,
                painter: DotsPainter(
                  animationValue: _backgroundAnimation.value,
                  primaryColor: theme.colorScheme.primary,
                  secondaryColor: theme.colorScheme.secondary,
                ),
              );
            },
          ),
          // Content
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                // Header section with animation
                _buildAnimatedHeader(context),
                
                const SizedBox(height: 40),

                // Developer cards with animation
                _buildAnimatedCard(
                  context: context,
                  index: 0,
                  child: _buildDeveloperCard(
                    context,
                    'Shuvrajit Dey',
                    'Lead Developer',
                    'Specializes in algorithm optimization and UI design',
                    'https://randomuser.me/api/portraits/men/32.jpg',
                    ['Flutter', 'Algorithms', 'UI/UX'],
                  ),
                ),
                const SizedBox(height: 20),
                _buildAnimatedCard(
                  context: context,
                  index: 1,
                  child: _buildDeveloperCard(
                    context,
                    'Debajyoti Nath',
                    'Backend Developer',
                    'Expert in data structures and algorithm implementation',
                    'https://randomuser.me/api/portraits/women/44.jpg',
                    ['Data Structures', 'Backend', 'Performance'],
                  ),
                ),

                const SizedBox(height: 40),

                // Join the team section
                _buildAnimatedCard(
                  context: context,
                  index: 4,
                  child: _buildJoinTeamCard(context),
                ),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAnimatedCard({
    required BuildContext context,
    required int index,
    required Widget child,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + (index * 200)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  Widget _buildAnimatedHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              height: 40,
              width: 5,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 16),
            const Text(
              'Meet Our Team',
              style: TextStyle(
                fontSize: 32, 
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.only(left: 21),
          child: Text(
            'The brilliant minds behind Algorithm Visualizer',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w400,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              letterSpacing: 0.2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDeveloperCard(
    BuildContext context,
    String name,
    String role,
    String bio,
    String imageUrl,
    List<String> skills,
  ) {
    return Card(
      elevation: 8,
      shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Developer image
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.network(
                      imageUrl,
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.person,
                            color: Theme.of(context).colorScheme.primary,
                            size: 45,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                // Developer info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          role,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              bio,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Skills',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            // Skills
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: skills.map((skill) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).shadowColor.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    skill,
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJoinTeamCard(BuildContext context) {
    return Card(
      elevation: 10,
      shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.8),
              Theme.of(context).colorScheme.primary.withOpacity(0.6),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.group_add_rounded,
                  color: Theme.of(context).colorScheme.onPrimary,
                  size: 36,
                ),
                const SizedBox(width: 16),
                Text(
                  'Join Our Team',
                  style: TextStyle(
                    fontSize: 26, 
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'We\'re always looking for talented developers and designers to join our team. If you\'re passionate about algorithms and creating educational tools, we\'d love to hear from you!',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.9),
                fontSize: 16,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  // Show application info
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Application form will be available soon!',
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.send),
                label: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  child: Text(
                    'Apply Now',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.onPrimary,
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  elevation: 4,
                  shadowColor: Colors.black45,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Add missing placeholder pages
class SettingsPagePlaceholder extends StatelessWidget {
  const SettingsPagePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
          ),
        ),
        iconTheme: IconThemeData(
          color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
        ),
      ),
      body: const Center(child: Text('Settings Page')),
    );
  }
}

class HelpCenterPagePlaceholder extends StatelessWidget {
  const HelpCenterPagePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Help Center',
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
          ),
        ),
        iconTheme: IconThemeData(
          color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
        ),
      ),
      body: const Center(child: Text('Help Center Page')),
    );
  }
}

// Add the correct login handling at the end of your file
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AppTheme _currentTheme = AppTheme.light;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Algorithm Visualizer',
      debugShowCheckedModeBanner: false,
      theme: _getThemeData(AppTheme.light),
      darkTheme: _getThemeData(AppTheme.dark),
      themeMode:
          _currentTheme == AppTheme.light
              ? ThemeMode.light
              : ThemeMode.dark,
      home: LoginScreen(
        onLoginSuccess: () {
          // Launch the main app directly without MaterialPageRoute
          runApp(AlgorithmVisualizerApp(initialTheme: _currentTheme));
        },
      ),
      routes: {
        '/settings': (context) => const SettingsPage(),
        '/help-center': (context) => const HelpCenterPage(),
      },
    );
  }

  // Reuse the existing theme data method
  ThemeData _getThemeData(AppTheme theme) {
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

// Add this class before DevelopersPage
class DotsPainter extends CustomPainter {
  final double animationValue;
  final Color primaryColor;
  final Color secondaryColor;
  final Random random = Random(42); // Fixed seed for consistent pattern
  final int dotsCount = 50;
  
  DotsPainter({
    required this.animationValue,
    required this.primaryColor,
    required this.secondaryColor,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < dotsCount; i++) {
      // Create a predictable but seemingly random position for each dot
      final double randomX = random.nextDouble() * size.width;
      final double randomY = random.nextDouble() * size.height;
      
      // Move dots slightly based on animation value
      final double offsetX = sin(animationValue * 2 * pi + i * 0.1) * 15;
      final double offsetY = cos(animationValue * 2 * pi + i * 0.1) * 15;
      
      // Vary size based on position
      final double dotSize = 2 + (random.nextDouble() * 3);
      
      // Mix colors based on position
      final double colorMix = random.nextDouble();
      final Color dotColor = Color.lerp(
        primaryColor,
        secondaryColor,
        colorMix,
      )!.withOpacity(0.2);
      
      final Offset position = Offset(
        (randomX + offsetX) % size.width,
        (randomY + offsetY) % size.height,
      );
      
      final Paint paint = Paint()
        ..color = dotColor
        ..style = PaintingStyle.fill;
      
      // Draw the dot
      canvas.drawCircle(position, dotSize, paint);
    }
  }
  
  @override
  bool shouldRepaint(DotsPainter oldDelegate) => 
    oldDelegate.animationValue != animationValue;
}

// Add this widget for the team page
class TeamPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Developers',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
          ),
        ),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Theme.of(context).scaffoldBackgroundColor
            : Colors.white,
        elevation: 2,
        iconTheme: IconThemeData(
          color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.search,
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(
              Icons.menu,
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: TeamPageContent(),
    );
  }
}

class TeamPageContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue.shade50, Colors.blue.shade100],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0, bottom: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Meet Our Team',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'The brilliant minds behind Algorithm Visualizer',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  _buildTeamMemberCard(
                    name: 'Shuvrajit',
                    role: 'Lead Developer',
                    bio: 'Specializes in algorithm optimization and UI design',
                    skills: ['Flutter', 'Algorithms', 'UI/UX'],
                    context: context,
                  ),
                  SizedBox(height: 16),
                  _buildTeamMemberCard(
                    name: 'Debajyoti',
                    role: 'Backend Developer',
                    bio: 'Expert in data structures and algorithm implementation',
                    skills: ['Python', 'Data Structures', 'Algorithms'],
                    context: context,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamMemberCard({
    required String name,
    required String role,
    required String bio,
    required List<String> skills,
    required BuildContext context,
  }) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      shadowColor: Theme.of(context).primaryColor.withOpacity(0.5),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.blue.shade50],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.blue.shade100,
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 4),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            role,
                            style: TextStyle(
                              color: Colors.blue.shade800,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text(
                bio,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Skills',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: skills.map((skill) => Chip(
                  label: Text(skill),
                  backgroundColor: Colors.blue.shade100,
                  labelStyle: TextStyle(color: Colors.blue.shade800),
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                )).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
