import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'help/getting_started_help.dart';
import 'help/algorithms_help.dart';
import 'help/data_structures_help.dart';
import 'help/settings_help.dart';
import 'dart:math';

class HelpCenterPage extends StatefulWidget {
  const HelpCenterPage({Key? key}) : super(key: key);

  @override
  State<HelpCenterPage> createState() => _HelpCenterPageState();
}

class _HelpCenterPageState extends State<HelpCenterPage> with SingleTickerProviderStateMixin {
  // Settings state
  bool isDarkMode = false;
  late AnimationController _backgroundAnimationController;
  late Animation<double> _backgroundAnimation;
  
  // Cache for grid calculations
  final Map<double, int> _crossAxisCountCache = {};
  final Map<double, double> _aspectRatioCache = {};

  // Memoized colors
  late final Color _darkBackgroundStart = const Color.fromRGBO(30, 30, 60, 1.0);
  late final Color _darkBackgroundEnd = const Color.fromRGBO(15, 15, 35, 1.0);
  late final Color _lightBackgroundStart = const Color.fromRGBO(230, 240, 255, 1.0);
  late final Color _lightBackgroundEnd = const Color.fromRGBO(210, 220, 235, 1.0);

  @override
  void initState() {
    super.initState();
    _loadSettings();
    
    // Initialize animation controller with reduced update frequency
    _backgroundAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat(reverse: true);
    
    _backgroundAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
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

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get the current theme brightness
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Help Center',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isDarkMode ? const Color.fromRGBO(40, 40, 70, 1.0) : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : Colors.black87,
        elevation: 4.0,
        shadowColor: isDarkMode ? Colors.black : Colors.grey[300],
        iconTheme: IconThemeData(
          color: isDarkMode ? Colors.white : Colors.black87,
        ),
        actions: [
          // Replace Switch with IconButton
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: isDarkMode ? Colors.white : Colors.grey[800],
            ),
            onPressed: () async {
              setState(() {
                isDarkMode = !isDarkMode;
              });
              // Save the theme setting
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('isDarkMode', isDarkMode);
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
                    begin: Alignment.topLeft.add(Alignment(
                      0.2 * _backgroundAnimation.value, 
                      0.2 * _backgroundAnimation.value
                    )),
                    end: Alignment.bottomRight.add(Alignment(
                      -0.2 * _backgroundAnimation.value, 
                      -0.2 * _backgroundAnimation.value
                    )),
                    colors: isDarkMode
                        ? [
                            _darkBackgroundStart,
                            _darkBackgroundEnd,
                          ]
                        : [
                            _lightBackgroundStart,
                            _lightBackgroundEnd,
                          ],
                    stops: [
                      0.3 * _backgroundAnimation.value,
                      0.7 + (0.3 * _backgroundAnimation.value),
                    ],
                  ),
                ),
              );
            },
          ),
          
          // Subtle pattern overlay with adaptive color
          Opacity(
            opacity: isDarkMode ? 0.12 : 0.06,
            child: CustomPaint(
              painter: BackgroundPatternPainter(
                animation: _backgroundAnimation,
                isDarkMode: isDarkMode,
              ),
              child: Container(),
            ),
          ),
          
          // Content
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  decoration: BoxDecoration(
                    color: isDarkMode 
                        ? const Color.fromRGBO(50, 50, 80, 0.7) 
                        : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDarkMode 
                          ? Colors.grey.shade700 
                          : Colors.grey.shade300,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDarkMode 
                            ? Colors.black.withOpacity(0.2) 
                            : Colors.grey.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search for help...',
                      hintStyle: TextStyle(
                        color: isDarkMode 
                            ? Colors.grey.shade400 
                            : Colors.grey.shade600,
                      ),
                      icon: Icon(
                        Icons.search,
                        color: isDarkMode 
                            ? Colors.lightBlue.shade100 
                            : Colors.blue,
                      ),
                      border: InputBorder.none,
                    ),
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Quick help categories
                Text(
                  'How can we help you?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode 
                        ? Colors.lightBlue.shade100 
                        : Colors.grey.shade800,
                    shadows: isDarkMode ? [
                      const Shadow(
                        color: Colors.black54,
                        blurRadius: 2,
                        offset: Offset(1, 1),
                      )
                    ] : null,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Category grid
                LayoutBuilder(
                  builder: (context, constraints) {
                    final screenWidth = constraints.maxWidth;
                    final isVerySmallScreen = screenWidth < 350;
                    
                    // Get cached or calculate new crossAxisCount
                    final crossAxisCount = _crossAxisCountCache.putIfAbsent(
                      screenWidth,
                      () {
                        if (screenWidth > 1200) return 4;
                        if (screenWidth > 800) return 3;
                        if (screenWidth > 450) return 2;
                        return 1; // Use single column for very small screens
                      },
                    );

                    // Get cached or calculate new aspect ratio
                    final aspectRatio = _aspectRatioCache.putIfAbsent(
                      screenWidth,
                      () {
                        // Adjust aspect ratio for smaller screens
                        if (screenWidth <= 400) {
                          return 3.5; // Make cards wider than tall on very small screens
                        }
                        
                        final cardWidth = (screenWidth - (16.0 * (crossAxisCount + 1))) / crossAxisCount;
                        // Adjust for smaller screens to prevent overflow
                        final cardHeight = cardWidth * (screenWidth < 600 ? 0.32 : 0.45);
                        return cardWidth / cardHeight;
                      },
                    );

                    return GridView.builder(
                      key: const ValueKey('help_categories_grid'),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: aspectRatio,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                      ),
                      itemCount: 4, // Fixed number of categories
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        // Define category data
                        final categories = [
                          (
                            'Getting Started',
                            Icons.play_circle_outline,
                            isDarkMode 
                                ? const Color.fromRGBO(35, 44, 77, 1.0) 
                                : Colors.blue.shade100,
                            isDarkMode 
                                ? Colors.lightBlue.shade200 
                                : Colors.blue.shade900,
                          ),
                          (
                            'Algorithms',
                            Icons.account_tree_outlined,
                            isDarkMode 
                                ? const Color.fromRGBO(35, 52, 44, 1.0) 
                                : Colors.green.shade100,
                            isDarkMode 
                                ? Colors.green.shade200 
                                : Colors.green.shade900,
                          ),
                          (
                            'Data Structures',
                            Icons.storage_outlined,
                            isDarkMode 
                                ? const Color.fromRGBO(52, 40, 32, 1.0) 
                                : Colors.orange.shade100,
                            isDarkMode 
                                ? Colors.orange.shade200 
                                : Colors.orange.shade900,
                          ),
                          (
                            'Settings Help',
                            Icons.settings,
                            isDarkMode 
                                ? const Color.fromRGBO(44, 35, 52, 1.0) 
                                : Colors.purple.shade100,
                            isDarkMode 
                                ? Colors.purple.shade200 
                                : Colors.purple.shade900,
                          ),
                        ];

                        final category = categories[index];
                        return _buildHelpCategory(
                          context,
                          category.$1,
                          category.$2,
                          category.$3,
                          category.$4,
                          key: ValueKey('help_category_$index'),
                        );
                      },
                    );
                  },
                ),
                
                const SizedBox(height: 24),
                
                // FAQs
                Text(
                  'Frequently Asked Questions',
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width < 350 ? 16 : 20,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode 
                        ? Colors.lightBlue.shade100 
                        : Colors.grey.shade800,
                    shadows: isDarkMode ? [
                      const Shadow(
                        color: Colors.black54,
                        blurRadius: 2,
                        offset: Offset(1, 1),
                      )
                    ] : null,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Let's use a shrinkwrapped ListView for FAQs to avoid overflow issues
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 5, // Number of FAQs
                  itemBuilder: (context, index) {
                    // FAQ data
                    final faqs = [
                      (
                        'How do I visualize an algorithm?',
                        'Navigate to the Algorithms section from the sidebar. Choose the algorithm '
                        'you want to visualize. You can adjust the parameters and click "Visualize".',
                      ),
                      (
                        'What algorithms are available?',
                        'AlgoViz includes various sorting algorithms (Bubble Sort, Quick Sort, Merge Sort), '
                        'searching algorithms (Binary Search, Linear Search), and more.',
                      ),
                      (
                        'How do I adjust visualization speed?',
                        'Look for the speed control slider below the visualization area. '
                        'Slide left to slow down or right to speed up the animation.',
                      ),
                      (
                        'Can I save my visualizations?',
                        'Yes, you can save your visualizations. After creating a visualization, '
                        'click the "Save" button and give it a name. You can access saved '
                        'visualizations from your profile.',
                      ),
                      (
                        'How do I change the theme?',
                        'Go to the Settings page and toggle the "Dark Mode" switch to change '
                        'between light and dark themes.',
                      ),
                    ];
                    
                    final faq = faqs[index];
                    return _buildFaqItem(faq.$1, faq.$2);
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Contact support button
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.97, end: 1.03),
                  duration: const Duration(milliseconds: 2000),
                  curve: Curves.easeInOut,
                  builder: (context, value, child) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      transform: Matrix4.identity()..scale(isDarkMode ? value * 0.99 : value * 0.995),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Show contact dialog
                            _showContactDialog(context);
                          },
                          icon: Icon(
                            Icons.email, 
                            size: MediaQuery.of(context).size.width < 350 ? 16 : 20
                          ),
                          label: Text(
                            'Contact Support',
                            style: TextStyle(
                              fontSize: MediaQuery.of(context).size.width < 350 ? 14 : 16
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: isDarkMode 
                                ? Colors.blue.shade800 
                                : Colors.blue,
                            elevation: isDarkMode ? 8 : 4,
                            shadowColor: isDarkMode 
                                ? Colors.black.withOpacity(0.6) 
                                : Colors.blue.withOpacity(0.4),
                            padding: EdgeInsets.symmetric(
                              vertical: MediaQuery.of(context).size.width < 350 ? 8 : 12
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                
                // Add small padding at the bottom to prevent overflow
                SizedBox(height: MediaQuery.of(context).size.width < 350 ? 8 : 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpCategory(
    BuildContext context,
    String title,
    IconData icon,
    Color backgroundColor,
    Color iconColor, {
    Key? key,
  }) {
    // Memoize common values
    final bool isDarkModeLocal = isDarkMode;
    final borderRadius = BorderRadius.circular(18);
    final screenWidth = MediaQuery.of(context).size.width;
    final isVerySmallScreen = screenWidth < 350;
    
    return RepaintBoundary(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        child: Card(
          key: key,
          elevation: isDarkModeLocal ? 5 : 3,
          shadowColor: isDarkModeLocal 
              ? Colors.black.withOpacity(0.5) 
              : Colors.black45.withOpacity(0.3),
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius,
            side: BorderSide(
              color: isDarkModeLocal 
                  ? Colors.white.withOpacity(0.08)
                  : Colors.transparent,
              width: 0.5,
            ),
          ),
          color: backgroundColor,
          child: Material(
            color: Colors.transparent,
            borderRadius: borderRadius,
            child: InkWell(
              onTap: () {
                // Navigate to the appropriate help page using cached widget
                final Widget page;
                switch (title) {
                  case 'Getting Started':
                    page = const GettingStartedHelpPage();
                    break;
                  case 'Algorithms':
                    page = const AlgorithmsHelpPage();
                    break;
                  case 'Data Structures':
                    page = const DataStructuresHelpPage();
                    break;
                  case 'Settings Help':
                    page = const SettingsHelpPage();
                    break;
                  default:
                    return;
                }
                
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => page),
                );
              },
              splashColor: isDarkModeLocal 
                  ? iconColor.withOpacity(0.2) 
                  : iconColor.withOpacity(0.1),
              highlightColor: isDarkModeLocal 
                  ? Colors.white.withOpacity(0.05) 
                  : Colors.black.withOpacity(0.03),
              borderRadius: borderRadius,
              child: Stack(
                children: [
                  // Subtle gradient overlay
                  if (isDarkModeLocal)
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: borderRadius,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(0.05),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.8],
                          ),
                        ),
                      ),
                    ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isVerySmallScreen ? 16.0 : 18.0,
                      vertical: isVerySmallScreen ? 16.0 : 18.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: isVerySmallScreen ? 32 : 36,
                          height: isVerySmallScreen ? 32 : 36,
                          decoration: BoxDecoration(
                            color: isDarkModeLocal 
                                ? Colors.white.withOpacity(0.12)
                                : Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: isDarkModeLocal
                                ? []
                                : [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                      spreadRadius: -2,
                                    ),
                                  ],
                          ),
                          child: Center(
                            child: Icon(
                              icon,
                              size: isVerySmallScreen ? 18 : 20,
                              color: iconColor,
                            ),
                          ),
                        ),
                        SizedBox(width: isVerySmallScreen ? 12 : 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                title,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: isVerySmallScreen ? 13 : 15,
                                  color: isDarkModeLocal ? Colors.white : Colors.black87,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Tap to learn more',
                                style: TextStyle(
                                  fontSize: isVerySmallScreen ? 9 : 10,
                                  color: isDarkModeLocal
                                      ? Colors.white.withOpacity(0.5)
                                      : Colors.black45,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          size: isVerySmallScreen ? 16 : 18,
                          color: isDarkModeLocal 
                              ? Colors.white.withOpacity(0.5) 
                              : Colors.black26,
                        ),
                      ],
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

  Widget _buildFaqItem(String question, String answer) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isVerySmallScreen = screenWidth < 350;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.only(bottom: isVerySmallScreen ? 8 : 12),
      child: Card(
        elevation: 3,
        shadowColor: isDarkMode 
            ? Colors.black87.withOpacity(0.5) 
            : Colors.black45.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: isDarkMode 
              ? BorderSide(
                  color: Colors.lightBlue.withOpacity(0.3), 
                  width: 0.5,
                ) 
              : BorderSide.none,
        ),
        color: isDarkMode 
            ? const Color.fromRGBO(45, 45, 75, 0.85) 
            : Colors.white.withOpacity(0.9),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Theme(
            data: Theme.of(context).copyWith(
              dividerColor: Colors.transparent,
              colorScheme: ColorScheme.fromSeed(
                seedColor: isDarkMode ? Colors.blue : Colors.blueAccent,
                brightness: isDarkMode ? Brightness.dark : Brightness.light,
              ),
            ),
            child: ExpansionTile(
              tilePadding: EdgeInsets.symmetric(
                horizontal: isVerySmallScreen ? 12 : 16, 
                vertical: isVerySmallScreen ? 0 : 4
              ),
              title: Text(
                question,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: isVerySmallScreen ? 13 : (screenWidth < 400 ? 14 : 16),
                  color: isDarkMode 
                      ? Colors.lightBlue.shade100 
                      : Colors.blue.shade800,
                ),
              ),
              iconColor: isDarkMode ? Colors.lightBlue.shade100 : Colors.blue,
              collapsedIconColor: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              childrenPadding: EdgeInsets.zero,
              expandedAlignment: Alignment.topLeft,
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDarkMode 
                        ? Colors.black.withOpacity(0.2) 
                        : Colors.blue.withOpacity(0.05),
                    border: Border(
                      top: BorderSide(
                        color: isDarkMode 
                            ? Colors.grey.shade800 
                            : Colors.grey.shade300,
                        width: 0.5,
                      ),
                    ),
                  ),
                  padding: EdgeInsets.fromLTRB(
                    isVerySmallScreen ? 12 : 16, 
                    isVerySmallScreen ? 8 : 12, 
                    isVerySmallScreen ? 12 : 16, 
                    isVerySmallScreen ? 12 : 16
                  ),
                  child: Text(
                    answer,
                    style: TextStyle(
                      fontSize: isVerySmallScreen ? 12 : (screenWidth < 400 ? 13 : 14),
                      color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showContactDialog(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode 
            ? const Color.fromRGBO(50, 50, 80, 1.0) 
            : Colors.white,
        insetPadding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 16 : 40,
          vertical: 24,
        ),
        contentPadding: EdgeInsets.all(isSmallScreen ? 16 : 24),
        title: Text(
          'Contact Support',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: isSmallScreen ? 18 : 20,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'Your Name',
                  labelStyle: TextStyle(
                    color: isDarkMode 
                        ? Colors.lightBlue.shade100 
                        : Colors.blue.shade700,
                    fontSize: isSmallScreen ? 14 : 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: isDarkMode 
                          ? Colors.grey.shade700 
                          : Colors.grey.shade300,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: isDarkMode 
                          ? Colors.grey.shade700 
                          : Colors.grey.shade300,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: isDarkMode ? Colors.lightBlue : Colors.blue,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: isDarkMode 
                      ? const Color.fromRGBO(40, 40, 70, 1.0) 
                      : Colors.grey.shade50,
                  contentPadding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                ),
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black87,
                  fontSize: isSmallScreen ? 14 : 16,
                ),
              ),
              SizedBox(height: isSmallScreen ? 12 : 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  labelStyle: TextStyle(
                    color: isDarkMode 
                        ? Colors.lightBlue.shade100 
                        : Colors.blue.shade700,
                    fontSize: isSmallScreen ? 14 : 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: isDarkMode 
                          ? Colors.grey.shade700 
                          : Colors.grey.shade300,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: isDarkMode 
                          ? Colors.grey.shade700 
                          : Colors.grey.shade300,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: isDarkMode ? Colors.lightBlue : Colors.blue,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: isDarkMode 
                      ? const Color.fromRGBO(40, 40, 70, 1.0) 
                      : Colors.grey.shade50,
                  contentPadding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                ),
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black87,
                  fontSize: isSmallScreen ? 14 : 16,
                ),
              ),
              SizedBox(height: isSmallScreen ? 12 : 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'How can we help?',
                  labelStyle: TextStyle(
                    color: isDarkMode 
                        ? Colors.lightBlue.shade100 
                        : Colors.blue.shade700,
                    fontSize: isSmallScreen ? 14 : 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: isDarkMode 
                          ? Colors.grey.shade700 
                          : Colors.grey.shade300,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: isDarkMode 
                          ? Colors.grey.shade700 
                          : Colors.grey.shade300,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: isDarkMode ? Colors.lightBlue : Colors.blue,
                      width: 2,
                    ),
                  ),
                  alignLabelWithHint: true,
                  filled: true,
                  fillColor: isDarkMode 
                      ? const Color.fromRGBO(40, 40, 70, 1.0) 
                      : Colors.grey.shade50,
                  contentPadding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                ),
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black87,
                  fontSize: isSmallScreen ? 14 : 16,
                ),
                maxLines: 5,
              ),
            ],
          ),
        ),
        actions: [
          Container(
            decoration: BoxDecoration(
              color: isDarkMode 
                  ? Colors.blue.withOpacity(0.2) 
                  : Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            margin: EdgeInsets.only(right: isSmallScreen ? 4 : 8),
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 8 : 16,
                  vertical: isSmallScreen ? 6 : 8,
                ),
                minimumSize: Size(isSmallScreen ? 60 : 80, 0),
              ),
              child: Text(
                'CANCEL',
                style: TextStyle(
                  color: isDarkMode 
                      ? Colors.lightBlue.shade200 
                      : Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: isSmallScreen ? 12 : 14,
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: isDarkMode 
                  ? Colors.blue.withOpacity(0.3) 
                  : Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDarkMode 
                    ? Colors.blue.shade300 
                    : Colors.blue,
                width: 1.0,
              ),
            ),
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Message sent! We\'ll respond soon.'),
                    backgroundColor: Colors.green.shade700,
                  ),
                );
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 16 : 24,
                  vertical: isSmallScreen ? 6 : 8,
                ),
                minimumSize: Size(isSmallScreen ? 60 : 80, 0),
              ),
              child: Text(
                'SEND',
                style: TextStyle(
                  color: isDarkMode 
                      ? Colors.lightBlue.shade200 
                      : Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: isSmallScreen ? 12 : 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Background pattern painter
class BackgroundPatternPainter extends CustomPainter {
  final Animation<double> animation;
  final bool isDarkMode;
  
  BackgroundPatternPainter({required this.animation, required this.isDarkMode}) : super(repaint: animation);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDarkMode 
          ? Colors.lightBlue.withOpacity(0.4)
          : Colors.blue.withOpacity(0.2)
      ..strokeWidth = isDarkMode ? 1.2 : 1.0
      ..style = PaintingStyle.stroke;
    
    final double offset = animation.value * 20;
    final double scale = 1.0 + (0.1 * animation.value);
    
    // Draw a grid of subtle circles
    for (double x = -50; x < size.width + 50; x += 50) {
      for (double y = -50; y < size.height + 50; y += 50) {
        final double adjustedX = x + (offset * sin(y / 50));
        final double adjustedY = y + (offset * cos(x / 50));
        
        // Varying circle sizes for more depth
        final double radius = 15 + (10 * sin((x + y) / 200 + animation.value * 2));
        
        canvas.drawCircle(
          Offset(adjustedX, adjustedY),
          radius * scale,
          paint,
        );
        
        // Add small dots at intersection points
        if (isDarkMode && (x % 100 == 0 || y % 100 == 0)) {
          canvas.drawCircle(
            Offset(adjustedX, adjustedY),
            3,
            Paint()
              ..color = Colors.lightBlue.withOpacity(0.2)
              ..style = PaintingStyle.fill,
          );
        }
      }
    }
  }
  
  @override
  bool shouldRepaint(BackgroundPatternPainter oldDelegate) => 
    animation != oldDelegate.animation || isDarkMode != oldDelegate.isDarkMode;
} 