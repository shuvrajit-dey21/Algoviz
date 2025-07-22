import 'package:flutter/material.dart';
import '/algorithms/stack.dart'; // Import your Stack page
import '/algorithms/queue.dart'; // Import your Queue page
import 'dart:math' as math; // Add this import for sin and cos functions
import 'package:shared_preferences/shared_preferences.dart'; // For saving theme preference

class StackQueueOperationsPage extends StatefulWidget {
  const StackQueueOperationsPage({super.key});

  @override
  State<StackQueueOperationsPage> createState() => _StackQueueOperationsPageState();
}

class _StackQueueOperationsPageState extends State<StackQueueOperationsPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isDarkMode = false;
  String _currentView = 'All';
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
    
    // Load saved theme preference when the page initializes
    _loadThemePreference();
  }
  
  // Load theme preference from shared preferences
  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }
  
  // Save theme preference to shared preferences
  Future<void> _saveThemePreference(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Get theme data based on dark mode setting
  ThemeData _getTheme() {
    return _isDarkMode
        ? ThemeData.dark().copyWith(
            primaryColor: Colors.deepPurple,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
            ),
            cardTheme: CardTheme(
              color: Colors.grey[800],
            ),
            chipTheme: ChipThemeData(
              backgroundColor: Colors.deepPurple.withOpacity(0.3),
              labelStyle: const TextStyle(color: Colors.white70),
            ),
            dialogTheme: DialogTheme(
              backgroundColor: Colors.grey[900],
              titleTextStyle: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              contentTextStyle: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          )
        : ThemeData.light().copyWith(
            primaryColor: Colors.purple,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
            ),
            cardTheme: const CardTheme(
              color: Colors.white,
            ),
            chipTheme: ChipThemeData(
              backgroundColor: Colors.purple.withOpacity(0.2),
              labelStyle: const TextStyle(color: Colors.black87),
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    // Apply the theme based on current mode
    final theme = _getTheme();
    
    return Theme(
      data: theme,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Stack & Queue Operations'),
          actions: [
            // Filter dropdown
            PopupMenuButton<String>(
              icon: const Icon(Icons.filter_list),
              tooltip: 'Filter view',
              onSelected: (String value) {
                setState(() {
                  _currentView = value;
                });
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'All',
                  child: Text('Show All'),
                ),
                const PopupMenuItem<String>(
                  value: 'Stack',
                  child: Text('Stack Only'),
                ),
                const PopupMenuItem<String>(
                  value: 'Queue',
                  child: Text('Queue Only'),
                ),
              ],
            ),
            // Info button
            IconButton(
              icon: const Icon(Icons.info_outline),
              tooltip: 'Information',
              onPressed: () {
                _showInfoDialog(context);
              },
            ),
            // Dark mode toggle
            IconButton(
              icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
              tooltip: 'Toggle theme',
              onPressed: () {
                setState(() {
                  _isDarkMode = !_isDarkMode;
                  // Save the theme preference when toggled
                  _saveThemePreference(_isDarkMode);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_isDarkMode 
                        ? 'Dark mode enabled' 
                        : 'Light mode enabled'),
                      duration: const Duration(seconds: 1),
                      backgroundColor: _isDarkMode ? Colors.deepPurple : Colors.purple,
                    ),
                  );
                });
              },
            ),
          ],
          elevation: 4,
        ),
        body: Stack(
          children: [
            // Animated Background
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  painter: BackgroundPainter(_controller.value, _isDarkMode),
                  child: Container(width: double.infinity, height: double.infinity),
                );
              },
            ),
            // Main Content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select an Operation:',
                        style: TextStyle(
                          fontSize: 20, 
                          fontWeight: FontWeight.bold,
                          color: _isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                      Chip(
                        label: Text(
                          'View: $_currentView',
                          style: TextStyle(
                            color: _isDarkMode ? Colors.white70 : Colors.black87,
                          ),
                        ),
                        backgroundColor: (_isDarkMode 
                            ? Colors.deepPurple 
                            : Colors.purple).withOpacity(0.2),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView(
                      children: [
                        if (_currentView == 'All' || _currentView == 'Stack')
                          _buildOperationCard(
                            context,
                            'Stack',
                            'Learn about stack data structure and its operations like push and pop.',
                            Icons.layers_rounded,
                            _isDarkMode ? Colors.deepPurpleAccent : Colors.purple,
                            const StackAnimation(), // Target page for Stack
                          ),
                        if (_currentView == 'All' || _currentView == 'Stack')  
                          const SizedBox(height: 16),
                        if (_currentView == 'All' || _currentView == 'Queue')
                          _buildOperationCard(
                            context,
                            'Queue',
                            'Explore queue data structure and its operations like enqueue and dequeue.',
                            Icons.queue_rounded,
                            _isDarkMode ? Colors.tealAccent : Colors.teal,
                            const QueueAnimation(), // Target page for Queue
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: _isDarkMode ? Colors.grey[850] : null,
          title: Text(
            'About Data Structures',
            style: TextStyle(
              color: _isDarkMode ? Colors.white : Colors.black87,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Stacks:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _isDarkMode ? Colors.white : Colors.black87,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'A stack is a linear data structure that follows the Last In First Out (LIFO) principle. The operations include push (insert) and pop (remove).',
                  style: TextStyle(
                    color: _isDarkMode ? Colors.white : Colors.black54,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Queues:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _isDarkMode ? Colors.white : Colors.black87,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'A queue is a linear data structure that follows the First In First Out (FIFO) principle. The operations include enqueue (insert) and dequeue (remove).',
                  style: TextStyle(
                    color: _isDarkMode ? Colors.white : Colors.black54,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Close',
                style: TextStyle(
                  color: _isDarkMode ? Colors.deepPurpleAccent[100] : Colors.purple,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          // Add a border to make the dialog stand out in dark mode
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: _isDarkMode 
                ? BorderSide(color: Colors.deepPurpleAccent[100]!, width: 1) 
                : BorderSide.none,
          ),
        );
      },
    );
  }

  Widget _buildOperationCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
    Widget targetPage,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withOpacity(0.5), width: 1.5),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to the target page
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => targetPage),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: _isDarkMode 
                            ? Colors.white70 
                            : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios, 
                size: 20,
                color: _isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom Painter for the background animation
class BackgroundPainter extends CustomPainter {
  final double animationValue;
  final bool isDarkMode;
  
  BackgroundPainter(this.animationValue, this.isDarkMode);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: isDarkMode ? [
          Colors.black.withOpacity(0.6),
          Colors.deepPurple.withOpacity(0.3),
          Colors.indigo.withOpacity(0.2),
        ] : [
          Colors.blue.withOpacity(0.3),
          Colors.purple.withOpacity(0.3),
          Colors.teal.withOpacity(0.3),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    
    // Draw background gradient
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
    
    // Draw animated shapes
    final shapePaint = Paint()
      ..color = (isDarkMode ? Colors.deepPurple : Colors.white).withOpacity(0.1)
      ..style = PaintingStyle.fill;
    
    // Draw multiple circles that move with the animation
    for (int i = 0; i < 5; i++) {
      double offset = i / 5;
      double x = size.width * 0.5 + 
          size.width * 0.4 * math.sin((animationValue * 2 * math.pi) + offset * math.pi);
      double y = size.height * 0.5 + 
          size.height * 0.4 * math.cos((animationValue * 2 * math.pi) + offset * math.pi);
      
      canvas.drawCircle(
        Offset(x, y), 
        20.0 + (10.0 * i), 
        shapePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
