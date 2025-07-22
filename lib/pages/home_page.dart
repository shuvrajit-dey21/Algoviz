import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/logo_circle_painter.dart';
import 'dashboard_page.dart';
import 'algorithms_page.dart';
import 'data_structures_page.dart';
import 'developers_page.dart';
import 'settings_page.dart';
import 'help_center_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _isNavRailExtended = false;
  late AnimationController _animationController;
  late AnimationController _logoAnimationController;
  
  late final List<Widget> _pages;

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
    
    // Initialize pages
    _pages = [
      const DashboardPage(),
      const AlgorithmsPage(),
      const DataStructuresPage(),
      const DevelopersPage(),
      const SettingsPage(),
      const HelpCenterPage(),
      const ProfilePage(),
    ];
    
    // Check screen width on init to set rail state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final width = MediaQuery.of(context).size.width;
      if (width > 800) {
        setState(() {
          _isNavRailExtended = true;
        });
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
    
    return Scaffold(
      body: Row(
        children: [
          // Side Navigation Bar with hover effect
          MouseRegion(
            onEnter: (_) {
              if (width <= 800) {
                _animationController.forward();
              }
            },
            onExit: (_) {
              if (width <= 800) {
                _animationController.reverse();
              }
            },
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return NavigationRail(
                  extended: _isNavRailExtended || _animationController.value > 0.5,
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
                                color: Theme.of(context).colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(context).colorScheme.primary.withOpacity(
                                      0.3 + 0.2 * _logoAnimationController.value,
                                    ),
                                    blurRadius: 10 + 5 * _logoAnimationController.value,
                                    spreadRadius: 1 + _logoAnimationController.value,
                                  ),
                                ],
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Background code pattern
                                  Opacity(
                                    opacity: 0.1,
                                    child: Text(
                                      '{ } [ ] ( )',
                                      style: TextStyle(
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                  // Main icon
                                  Icon(
                                    Icons.code,
                                    color: Theme.of(context).colorScheme.primary,
                                    size: 30,
                                  ),
                                  // Animated circle
                                  Positioned.fill(
                                    child: CustomPaint(
                                      painter: LogoCirclePainter(
                                        color: Theme.of(context).colorScheme.primary,
                                        progress: _logoAnimationController.value,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        if (_isNavRailExtended || _animationController.value > 0.5)
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
                  backgroundColor: isDarkMode 
                      ? const Color(0xFF1E1E1E) 
                      : const Color(0xFFF5F5F7),
                  elevation: 4,
                );
              },
            ),
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
      floatingActionButton: _selectedIndex != 0 ? FloatingActionButton(
        onPressed: () {
          // Show a snackbar when the FAB is pressed
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Create new ${_selectedIndex == 1 ? 'algorithm' : 
                           _selectedIndex == 2 ? 'data structure' : 
                           _selectedIndex == 3 ? 'developer profile' : 
                           _selectedIndex == 4 ? 'setting' :
                           _selectedIndex == 5 ? 'help article' : 'profile'}'),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        },
        tooltip: 'Create New',
        child: const Icon(Icons.add),
      ) : null,
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