import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_provider.dart';
import '../theme/app_theme.dart';
import '../utils/string_extensions.dart';
import '../widgets/animated_background.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with TickerProviderStateMixin {
  late final TabController _tabController;
  late final AnimationController _particleAnimationController;
  late final AnimationController _welcomeAnimationController;
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
      duration: const Duration(milliseconds: 800),
    )..forward();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _particleAnimationController.dispose();
    _welcomeAnimationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    
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
                      particleCount: width > 800 ? 40 : 20,
                    ),
                  ),
                );
              },
            ),
          ),
          // Main content
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200.0,
                floating: false,
                pinned: true,
                stretch: true,
                backgroundColor: isDarkMode 
                    ? const Color(0xFF1E1E1E).withOpacity(0.8) 
                    : Theme.of(context).colorScheme.surface.withOpacity(0.8),
                flexibleSpace: FlexibleSpaceBar(
                  title: _isSearching
                      ? null
                      : const Text(
                          'Algorithm Visualizer',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        'https://images.unsplash.com/photo-1580894732444-8ecded7900cd?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1470&q=80',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            child: Center(
                              child: Icon(
                                Icons.image_not_supported,
                                color: Theme.of(context).colorScheme.primary,
                                size: 50,
                              ),
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              isDarkMode ? Colors.black.withOpacity(0.7) : Colors.white.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                title: _isSearching
                    ? TextField(
                        controller: _searchController,
                        autofocus: true,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search algorithms, data structures...',
                          hintStyle: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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
                  IconButton(
                    icon: Icon(_isSearching ? Icons.close : Icons.search),
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
                  PopupMenuButton<AppTheme>(
                    icon: const Icon(Icons.palette_outlined),
                    tooltip: 'Change Theme',
                    onSelected: (AppTheme theme) {
                      themeProvider.setTheme(theme);
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
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<AppTheme>>[
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
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
} 