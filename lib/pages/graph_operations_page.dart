import 'package:flutter/material.dart';
import 'dart:ui';    // Add this import for ImageFilter
import '/algorithms/mst.dart';
import '/algorithms/shortest_path.dart';
import '/algorithms/graph_traversal.dart';
import 'package:flutter/rendering.dart';

class GraphOperationsPage extends StatefulWidget {
  const GraphOperationsPage({super.key});

  @override
  State<GraphOperationsPage> createState() => _GraphOperationsPageState();
}

class _GraphOperationsPageState extends State<GraphOperationsPage> {
  bool isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 4,
        backgroundColor: isDarkMode 
            ? Colors.black.withOpacity(0.7) 
            : Colors.white.withOpacity(0.9),
        iconTheme: IconThemeData(
          color: isDarkMode ? Colors.white : Colors.black87,
          size: 26,
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
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
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                    width: 2.0,
                  ),
                ),
              ),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Graph Algorithms',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
                letterSpacing: 0.5,
                shadows: [
                  Shadow(
                    color: isDarkMode ? Colors.black : Colors.white,
                    offset: const Offset(0, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
            Text(
              'Explore Graph Operations',
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? Colors.white70 : Colors.grey[800],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          // Theme toggle button
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: isDarkMode ? Colors.amber : Colors.blueGrey[800],
              size: 26,
            ),
            onPressed: () {
              setState(() {
                isDarkMode = !isDarkMode;
              });
            },
            tooltip: 'Toggle Theme',
          ),
          // Info button
          IconButton(
            icon: Icon(
              Icons.info_outline,
              color: isDarkMode ? Colors.white : Colors.blueGrey[800],
              size: 26,
            ),
            onPressed: () {
              _showInfoDialog(context);
            },
            tooltip: 'Information',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode 
                ? [
                    Colors.grey[900]!,
                    Colors.black,
                  ]
                : [
                    Colors.blue[50]!,
                    Colors.blue[100]!,
                  ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select a Graph Operation',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose an algorithm to explore graph operations',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      final operations = [
                        _OperationItem(
                          'Traversal',
                          'Explore graph traversal algorithms like BFS and DFS.',
                          Icons.timeline_rounded,
                          Colors.blue,
                          const GraphTraversal(),
                        ),
                        _OperationItem(
                          'Shortest Path',
                          'Find the shortest path in a graph using algorithms like Dijkstra\'s.',
                          Icons.alt_route_rounded,
                          Colors.green,
                          const ShortestPath(),
                        ),
                        _OperationItem(
                          'Minimum Spanning Tree (MST)',
                          'Learn about MST algorithms like Kruskal\'s and Prim\'s.',
                          Icons.account_tree_rounded,
                          Colors.orange,
                          const MST(),
                        ),
                      ];

                      return AnimatedBuilder(
                        animation: Tween<double>(begin: 0, end: 1).animate(
                          CurvedAnimation(
                            parent: ModalRoute.of(context)!.animation!,
                            curve: Interval(
                              index * 0.2,
                              0.6 + index * 0.2,
                              curve: Curves.easeOut,
                            ),
                          ),
                        ),
                        builder: (context, child) => TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeOut,
                          builder: (context, value, child) {
                            return Transform.translate(
                              offset: Offset(0, 50 * (1 - value)),
                              child: Opacity(
                                opacity: value,
                                child: child,
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: _buildOperationCard(
                              context,
                              operations[index].title,
                              operations[index].description,
                              operations[index].icon,
                              operations[index].color,
                              operations[index].targetPage,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
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
      elevation: 8,
      shadowColor: color.withOpacity(0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => targetPage,
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(1.0, 0.0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: isDarkMode 
                  ? [
                      color.withOpacity(0.2),
                      Colors.grey[850]!,
                    ]
                  : [
                      color.withOpacity(0.1),
                      Colors.white,
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: isDarkMode 
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.2),
                      blurRadius: 4,
                      spreadRadius: 0,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withOpacity(isDarkMode ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(icon, size: 36, color: color),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDarkMode ? Colors.white70 : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.arrow_forward_ios, size: 20, color: color),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: isDarkMode ? Colors.grey[850] : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 16,
          child: Container(
            width: screenSize.width * 0.85,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.info_outline,
                        color: Theme.of(context).primaryColor,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        'About Graph Algorithms',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  constraints: BoxConstraints(
                    maxHeight: screenSize.height * 0.4,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoItem(
                          context,
                          Icons.timeline_rounded,
                          'Graph Traversal',
                          'Algorithms like BFS and DFS that help explore all vertices in a graph systematically.',
                          Colors.blue,
                        ),
                        const SizedBox(height: 16),
                        _buildInfoItem(
                          context,
                          Icons.alt_route_rounded,
                          'Shortest Path',
                          'Algorithms like Dijkstra\'s and Bellman-Ford that find the optimal route between nodes in a weighted graph.',
                          Colors.green,
                        ),
                        const SizedBox(height: 16),
                        _buildInfoItem(
                          context,
                          Icons.account_tree_rounded,
                          'Minimum Spanning Tree',
                          'Algorithms like Kruskal\'s and Prim\'s that connect all vertices with minimum total edge weight.',
                          Colors.orange,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Got it'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    IconData icon,
    String title,
    String description,
    Color color,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 24, color: color),
        ),
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
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OperationItem {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final Widget targetPage;

  _OperationItem(
    this.title,
    this.description,
    this.icon,
    this.color,
    this.targetPage,
  );
}
