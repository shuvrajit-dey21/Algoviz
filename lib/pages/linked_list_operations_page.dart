import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_application_2/algorithms/singly_linked_list.dart';
import 'package:flutter_application_2/algorithms/circular_linked_list.dart';
import 'package:flutter_application_2/algorithms/doubly_linked_list.dart';

class LinkedListOperationsPage extends StatefulWidget {
  const LinkedListOperationsPage({super.key});

  @override
  State<LinkedListOperationsPage> createState() => _LinkedListOperationsPageState();
}

class _LinkedListOperationsPageState extends State<LinkedListOperationsPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Node> _nodes = [];
  final int nodeCount = 10; // Reduced for better performance
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20), 
    )..repeat();

    // Create random nodes for background animation
    final random = math.Random();
    for (int i = 0; i < nodeCount; i++) {
      _nodes.add(
        Node(
          position: Offset(
            random.nextDouble() * 400,
            random.nextDouble() * 800,
          ),
          size: random.nextDouble() * 8 + 3,
          speed: random.nextDouble() * 0.8 + 0.2,
          angle: random.nextDouble() * math.pi * 2,
          color: [
            Colors.blue.shade200,
            Colors.blue.shade300,
            Colors.lightBlue.shade200,
          ][random.nextInt(3)].withOpacity(0.3),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Apply theme based on dark mode setting
    final appBarColor = isDarkMode ? Colors.grey.shade900 : Colors.blue;
    final backgroundColor = isDarkMode 
        ? Colors.grey.shade900 
        : Colors.white;
    final gradientTopColor = isDarkMode 
        ? Colors.black 
        : Colors.blue.shade50;
    final gradientBottomColor = isDarkMode 
        ? Colors.grey.shade900 
        : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final secondaryTextColor = isDarkMode ? Colors.white70 : Colors.black54;
    
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: appBarColor,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        title: Row(
          children: [
            // Enhanced logo with animation
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 800),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey.shade800 : Colors.white,
                      shape: BoxShape.circle,
                      border: isDarkMode ? Border.all(color: Colors.grey.shade700, width: 1) : null,
                      boxShadow: [
                        BoxShadow(
                          color: (isDarkMode ? Colors.tealAccent : Colors.blue).withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.link,
                      color: isDarkMode ? Colors.tealAccent : Colors.blue,
                      size: 20,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: 12),
            // Animated title appearance
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(20 * (1 - value), 0),
                    child: Text(
                      'Linked Lists',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
            const Spacer(),
            IconButton(
              icon: Icon(
                isDarkMode ? Icons.light_mode : Icons.dark_mode,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  isDarkMode = !isDarkMode;
                });
              },
              style: IconButton.styleFrom(
                highlightColor: isDarkMode ? Colors.tealAccent.withOpacity(0.2) : Colors.white.withOpacity(0.2),
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.info_outline,
                color: Colors.white,
              ),
              onPressed: () {
                _showInfoDialog(context);
              },
              style: IconButton.styleFrom(
                highlightColor: isDarkMode ? Colors.tealAccent.withOpacity(0.2) : Colors.white.withOpacity(0.2),
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Enhanced animated background with particles
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  gradientTopColor,
                  gradientBottomColor,
                ],
              ),
            ),
          ),
          // Enhanced background nodes animation
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: EnhancedNodesPainter(
                  _nodes, 
                  _controller.value,
                  isDarkMode: isDarkMode,
                ),
                size: Size.infinite,
              );
            },
          ),
          // Main content
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Enhanced info header with animation
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOutBack,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            decoration: BoxDecoration(
                              color: isDarkMode 
                                  ? Colors.grey.shade800.withOpacity(0.5) 
                                  : Colors.blue.shade100.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: (isDarkMode ? Colors.black : Colors.blue.shade200).withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: isDarkMode 
                                        ? Colors.grey.shade700 
                                        : Colors.blue.shade50,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: (isDarkMode ? Colors.tealAccent : Colors.blue).withOpacity(0.2),
                                        blurRadius: 5,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.lightbulb_outline,
                                    color: isDarkMode 
                                        ? Colors.tealAccent 
                                        : Colors.blue.shade700,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    'Learn about sequential access data structures',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: textColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // Animated cards
                    _buildAnimatedCard(
                      index: 0,
                      child: _buildEnhancedCard(
                        title: 'Singly Linked List',
                        description: 'Linear collection with nodes pointing to the next element.',
                        operations: [
                          'Insertion (beginning, end, position)',
                          'Deletion (beginning, end, position)',
                          'Traversal and Search',
                          'Reversal and Length calculation'
                        ],
                        icon: Icons.arrow_forward,
                        color: isDarkMode ? Colors.tealAccent : Colors.blue,
                        textColor: textColor,
                        secondaryTextColor: secondaryTextColor,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SinglyLinkedListVisualization()),
                          );
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    _buildAnimatedCard(
                      index: 1,
                      child: _buildEnhancedCard(
                        title: 'Doubly Linked List',
                        description: 'Nodes have both next and previous pointers for bidirectional traversal.',
                        operations: [
                          'Bidirectional traversal',
                          'Insertion (beginning, end, position)',
                          'Deletion (beginning, end, position)',
                          'Forward and backward iteration'
                        ],
                        icon: Icons.swap_horiz_rounded,
                        color: isDarkMode ? Colors.lightGreenAccent : Colors.green,
                        textColor: textColor,
                        secondaryTextColor: secondaryTextColor,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const DoublyLinkedListVisualization()),
                          );
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    _buildAnimatedCard(
                      index: 2,
                      child: _buildEnhancedCard(
                        title: 'Circular Linked List',
                        description: 'Last node points back to the first, forming a circle.',
                        operations: [
                          'Circular traversal',
                          'Insertion (beginning, end, position)',
                          'Deletion (beginning, end, position)',
                          'Cycle detection and verification'
                        ],
                        icon: Icons.loop,
                        color: isDarkMode ? Colors.purpleAccent : Colors.purple,
                        textColor: textColor,
                        secondaryTextColor: secondaryTextColor,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const CircularLinkedListVisualization()),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedCard({required int index, required Widget child}) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 600 + (index * 200)),
      curve: Curves.easeOutQuart,
      builder: (context, value, _) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 50 * (1 - value)),
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildEnhancedCard({
    required String title,
    required String description,
    required List<String> operations,
    required IconData icon,
    required Color color,
    required Color textColor,
    required Color secondaryTextColor,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shadowColor: color.withOpacity(0.3),
      color: isDarkMode ? Colors.grey.shade800 : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isDarkMode ? color.withOpacity(0.2) : Colors.transparent,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: color.withOpacity(0.1),
        highlightColor: color.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title row
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(
                      icon,
                      color: isDarkMode ? Colors.black87 : Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: color,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 14,
                            color: secondaryTextColor,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 22),
              
              // Operations section with enhanced styling
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 22,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Operations:',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...operations.asMap().entries.map((entry) {
                    final index = entry.key;
                    final op = entry.value;
                    return TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: Duration(milliseconds: 300 + (index * 100)),
                      curve: Curves.easeOut,
                      builder: (context, value, _) {
                        return Opacity(
                          opacity: value,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: color,
                                  size: 18,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    op,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: secondaryTextColor,
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ],
              ),
              
              // Enhanced Explore button with animation
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: isDarkMode ? Colors.black87 : Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 4,
                      shadowColor: color.withOpacity(0.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          'Explore',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, size: 18),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey.shade700 : Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.info_outline,
                color: isDarkMode ? Colors.tealAccent : Colors.blue,
                size: 24,
              ),
            ),
            SizedBox(width: 16),
            Flexible(
              child: Text(
                'About Linked Lists',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoItem(
                icon: Icons.data_array,
                text: 'Linked Lists are linear data structures where elements are stored in nodes.',
              ),
              SizedBox(height: 16),
              _buildInfoItem(
                icon: Icons.memory,
                text: 'Unlike arrays, linked list elements are not stored at contiguous memory locations.',
              ),
              SizedBox(height: 16),
              _buildInfoItem(
                icon: Icons.view_carousel,
                text: 'This page demonstrates three types of linked lists with interactive visualizations.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: isDarkMode ? Colors.tealAccent : Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: const Text(
              'Close',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({required IconData icon, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          margin: const EdgeInsets.only(right: 12, top: 2),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey.shade700 : Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isDarkMode ? Colors.tealAccent : Colors.blue,
            size: 18,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? Colors.white70 : Colors.black87,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

// Simple Node class for background animation
class Node {
  Offset position;
  final double size;
  final double speed;
  double angle;
  final Color color;

  Node({
    required this.position,
    required this.size,
    required this.speed,
    required this.angle,
    required this.color,
  });

  void update(Size canvasSize) {
    final dx = math.cos(angle) * speed;
    final dy = math.sin(angle) * speed;
    position = Offset(position.dx + dx, position.dy + dy);

    // Bounce off edges
    if (position.dx < 0 || position.dx > canvasSize.width) {
      angle = math.pi - angle;
    }
    if (position.dy < 0 || position.dy > canvasSize.height) {
      angle = -angle;
    }
  }
}

// Custom painter for subtle background animation
class NodesPainter extends CustomPainter {
  final List<Node> nodes;
  final double animationValue;
  final bool isDarkMode;

  NodesPainter(this.nodes, this.animationValue, {this.isDarkMode = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    
    // Update and draw nodes
    for (var node in nodes) {
      node.update(size);
      
      // Draw node
      paint.color = isDarkMode 
          ? node.color.withBlue(230).withGreen(230) // Make nodes brighter in dark mode 
          : node.color;
      canvas.drawCircle(node.position, node.size, paint);

      // Draw connections
      for (var otherNode in nodes) {
        if (node != otherNode) {
          final distance = (node.position - otherNode.position).distance;
          if (distance < 150) {
            linePaint.color = (isDarkMode 
                ? node.color.withBlue(230).withGreen(230)
                : node.color).withOpacity((1 - distance / 150) * 0.3);
            canvas.drawLine(node.position, otherNode.position, linePaint);
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant NodesPainter oldDelegate) => 
      oldDelegate.animationValue != animationValue || 
      oldDelegate.isDarkMode != isDarkMode;
}

// Custom painter for enhanced background animation
class EnhancedNodesPainter extends CustomPainter {
  final List<Node> nodes;
  final double animationValue;
  final bool isDarkMode;

  EnhancedNodesPainter(this.nodes, this.animationValue, {this.isDarkMode = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    
    // Update and draw nodes
    for (var node in nodes) {
      node.update(size);
      
      // Draw node with pulsating effect
      final pulseValue = 0.2 * math.sin(animationValue * 2 * math.pi + node.position.dx * 0.05);
      final nodeSize = node.size * (1 + pulseValue);
      
      // Draw node
      paint.color = isDarkMode 
          ? node.color.withBlue(230).withGreen(230).withOpacity(0.7) // Make nodes brighter in dark mode
          : node.color.withOpacity(0.7);
      
      // Add glow effect
      final glowPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = paint.color.withOpacity(0.3);
      
      canvas.drawCircle(node.position, nodeSize * 1.8, glowPaint);
      canvas.drawCircle(node.position, nodeSize, paint);

      // Draw connections with pulse effect
      for (var otherNode in nodes) {
        if (node != otherNode) {
          final distance = (node.position - otherNode.position).distance;
          if (distance < 180) {
            final opacityFactor = (1 - distance / 180);
            final lineOpacity = opacityFactor * 0.5 * (1 + 0.2 * math.sin(animationValue * 2 * math.pi + distance * 0.02));
            
            linePaint.color = (isDarkMode 
                ? node.color.withBlue(230).withGreen(230)
                : node.color).withOpacity(lineOpacity);
            
            // Draw curved connection with a slight arc for a network effect
            final midPoint = Offset(
              (node.position.dx + otherNode.position.dx) / 2,
              (node.position.dy + otherNode.position.dy) / 2
            );
            final controlPoint = Offset(
              midPoint.dx + 20 * math.sin(animationValue * 2 * math.pi + distance * 0.01),
              midPoint.dy + 20 * math.cos(animationValue * 2 * math.pi + distance * 0.01)
            );
            
            final path = Path()
              ..moveTo(node.position.dx, node.position.dy)
              ..quadraticBezierTo(controlPoint.dx, controlPoint.dy, otherNode.position.dx, otherNode.position.dy);
            
            canvas.drawPath(path, linePaint);
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
