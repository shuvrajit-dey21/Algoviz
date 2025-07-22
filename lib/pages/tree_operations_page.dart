import 'package:flutter/material.dart';
import 'dart:math';  // Add this import for math functions (cos, sin, pi)
import 'dart:ui';    // Add this import for ImageFilter
import '/algorithms/tree.dart'; // Import your Tree page
import '/algorithms/binary_tree.dart'; // Import your Binary Tree page
import '/algorithms/binary_search_tree.dart'; // Import your Binary Search Tree page

class TreeOperationsPage extends StatefulWidget {
  const TreeOperationsPage({super.key});

  @override
  State<TreeOperationsPage> createState() => _TreeOperationsPageState();
}

class _TreeOperationsPageState extends State<TreeOperationsPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 4,
        backgroundColor: isDarkMode 
            ? Colors.black.withOpacity(0.7) 
            : Colors.white.withOpacity(0.9),
        shadowColor: isDarkMode 
            ? Colors.black 
            : Colors.grey[400],
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDarkMode 
                      ? [Colors.black54, Colors.black45]
                      : [Colors.white.withOpacity(0.9), Colors.white70],
                ),
              ),
            ),
          ),
        ),
        title: Text(
          'Tree Algorithms',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black87,
            fontSize: 22,
          ),
        ),
        iconTheme: IconThemeData(
          color: isDarkMode ? Colors.white : Colors.black87,
          size: 24,
        ),
        actions: [
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: isDarkMode ? Colors.amber : Colors.blueGrey[800],
            ),
            onPressed: () {
              setState(() {
                isDarkMode = !isDarkMode;
              });
            },
          ),
          IconButton(
            icon: Icon(
              Icons.info_outline,
              color: isDarkMode ? Colors.white : Colors.blueGrey[800],
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: isDarkMode ? Colors.grey[850] : Colors.white,
                  title: Text(
                    'About Tree Algorithms',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  content: Text(
                    'This section covers various tree data structures and their implementations.',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Close',
                        style: TextStyle(
                          color: isDarkMode ? Colors.blue[200] : Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        child: Stack(
          children: [
            // Animated Background
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return CustomPaint(
                    painter: AnimatedBackgroundPainter(
                      animation: _controller,
                      isDarkMode: isDarkMode,
                    ),
                  );
                },
              ),
            ),
            // Main Content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 80),
                  Text(
                    'Select a Tree Algorithm:',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView(
                      children: [
                        _buildOperationCard(
                          context,
                          'Tree',
                          'Learn about basic tree structures and their properties.',
                          Icons.account_tree_rounded,
                          isDarkMode ? Colors.blue[300]! : Colors.blue,
                          const TreeVisualization(),
                        ),
                        const SizedBox(height: 16),
                        _buildOperationCard(
                          context,
                          'Binary Tree',
                          'Explore binary trees and their traversal algorithms.',
                          Icons.call_split_rounded,
                          isDarkMode ? Colors.green[300]! : Colors.green,
                          const BinaryTreeVisualization(),
                        ),
                        const SizedBox(height: 16),
                        _buildOperationCard(
                          context,
                          'Binary Search Tree',
                          'Understand binary search trees and their operations.',
                          Icons.search_rounded,
                          isDarkMode ? Colors.orange[300]! : Colors.orange,
                          const BSTVisualization(),
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
      color: isDarkMode ? Colors.grey[850] : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withOpacity(0.5), width: 1.5),
      ),
      child: InkWell(
        onTap: () {
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
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode 
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
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AnimatedBackgroundPainter extends CustomPainter {
  final Animation<double> animation;
  final bool isDarkMode;

  AnimatedBackgroundPainter({required this.animation, required this.isDarkMode});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    for (int i = 1; i <= 5; i++) {
      final progress = (animation.value + i / 5) % 1.0;
      final center = Offset(
        size.width * (0.5 + 0.3 * cos(progress * 2 * pi)),
        size.height * (0.5 + 0.3 * sin(progress * 2 * pi)),
      );
      
      final gradient = RadialGradient(
        colors: isDarkMode
            ? [
                Colors.blue.withOpacity(0.3),
                Colors.purple.withOpacity(0.1),
                Colors.transparent,
              ]
            : [
                Colors.blue.withOpacity(0.2),
                Colors.green.withOpacity(0.1),
                Colors.transparent,
              ],
      );

      paint.shader = gradient.createShader(
        Rect.fromCircle(center: center, radius: size.width * 0.6),
      );
      
      canvas.drawCircle(center, size.width * 0.6, paint);
    }
  }

  @override
  bool shouldRepaint(AnimatedBackgroundPainter oldDelegate) => true;
}
