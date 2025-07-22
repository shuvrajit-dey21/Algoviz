import 'package:flutter/material.dart';
import 'dart:math';

class BSTVisualization extends StatelessWidget {
  const BSTVisualization({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BSTVisualizationScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class BSTVisualizationScreen extends StatefulWidget {
  const BSTVisualizationScreen({super.key});

  @override
  _BSTVisualizationScreenState createState() => _BSTVisualizationScreenState();
}

class _BSTVisualizationScreenState extends State<BSTVisualizationScreen> with SingleTickerProviderStateMixin {
  final List<int> traversalOrder = []; // Stores the order of traversal
  final Map<int, Offset> nodePositions = {}; // Stores positions of nodes
  bool showDFSOptions = false; // Controls visibility of DFS sub-options
  final Map<int, List<int>> bst = {}; // BST structure
  final TextEditingController _nodeController = TextEditingController();
  double minX = 0; // Tracks the leftmost position of the tree
  double maxX = 0; // Tracks the rightmost position of the tree
  double maxY = 0; // Tracks the bottommost position of the tree
  int? searchedNode; // Stores the searched node for highlighting
  List<String> processLog = []; // Store operation logs
  late TabController _tabController;
  bool isDarkMode = false; // Track theme state
  
  // Light theme colors
  late Color primaryColor;
  late Color secondaryColor;
  late Color accentColor;
  late Color backgroundColor;
  late Color surfaceColor;
  late Color buttonTextColor;
  late Color textColor;

  // Dark theme colors
  final darkPrimaryColor = Color(0xFF1565C0);
  final darkSecondaryColor = Color(0xFF0D47A1);
  final darkAccentColor = Color(0xFF42A5F5);
  final darkBackgroundColor = Color(0xFF121212);
  final darkSurfaceColor = Color(0xFF1E1E1E);
  final darkButtonTextColor = Colors.white;
  final darkTextColor = Colors.white;

  // Light theme colors
  final lightPrimaryColor = Color(0xFF1976D2);
  final lightSecondaryColor = Color(0xFF0D47A1);
  final lightAccentColor = Color(0xFF42A5F5);
  final lightBackgroundColor = Color(0xFFF5F5F5);
  final lightSurfaceColor = Colors.white;
  final lightButtonTextColor = Colors.white;
  final lightTextColor = Colors.black87;

  // Add new properties for animation
  final Map<int, bool> activeNodes = {};
  final Duration animationDuration = Duration(milliseconds: 800);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _updateThemeColors(); // Initialize theme colors
  }

  // Add theme toggle method
  void _toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
      _updateThemeColors();
    });
  }

  // Update colors based on theme
  void _updateThemeColors() {
    primaryColor = isDarkMode ? darkPrimaryColor : lightPrimaryColor;
    secondaryColor = isDarkMode ? darkSecondaryColor : lightSecondaryColor;
    accentColor = isDarkMode ? darkAccentColor : lightAccentColor;
    backgroundColor = isDarkMode ? darkBackgroundColor : lightBackgroundColor;
    surfaceColor = isDarkMode ? darkSurfaceColor : lightSurfaceColor;
    buttonTextColor = isDarkMode ? darkButtonTextColor : lightButtonTextColor;
    textColor = isDarkMode ? darkTextColor : lightTextColor;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _addToLog(String message) {
    setState(() {
      // Insert at the beginning for reverse chronological order
      processLog.insert(0, "${DateTime.now().toString().substring(11, 19)} - $message");
      
      // Trigger animation by temporarily removing and re-adding the first item
      if (processLog.length > 1) {
        String temp = processLog.removeAt(0);
        Future.delayed(Duration(milliseconds: 50), () {
          setState(() {
            processLog.insert(0, temp);
          });
        });
      }
    });
  }

  // Insert a node into the BST
  void _insertNode(int value) {
    setState(() {
      _insertBST(1, value);
      _calculateNodePositions(1, Offset(0, 50), MediaQuery.of(context).size.width / 4);
      searchedNode = null;
      traversalOrder.clear();
      _addToLog("Inserted node with value: $value");
    });
  }

  // Recursive function to insert a node into the BST
  void _insertBST(int root, int value) {
    if (!bst.containsKey(root)) {
      bst[root] = [];
    }

    if (value < root) {
      if (bst[root]!.isEmpty) {
        bst[root]!.add(value);
        bst[value] = [];
      } else {
        _insertBST(bst[root]![0], value);
      }
    } else if (value > root) {
      if (bst[root]!.length < 2) {
        bst[root]!.add(value);
        bst[value] = [];
      } else {
        _insertBST(bst[root]![1], value);
      }
    }
  }

  // Search for a node in the BST
  void _searchNode(int value) {
    setState(() {
      traversalOrder.clear();
      searchedNode = _searchBST(1, value);
      _addToLog("Searched for node with value: $value - ${searchedNode != null ? 'Found' : 'Not found'}");
    });
  }

  // Recursive function to search for a node in the BST
  int? _searchBST(int root, int value) {
    if (root == value) {
      return root;
    }

    if (value < root && bst[root]!.isNotEmpty) {
      return _searchBST(bst[root]![0], value);
    } else if (value > root && bst[root]!.length > 1) {
      return _searchBST(bst[root]![1], value);
    }

    return null; // Node not found
  }

  // Start traversal based on the selected type
  void _startTraversal(String type) async {
    traversalOrder.clear();
    searchedNode = null;
    _addToLog("Started $type traversal");
    setState(() {});

    switch (type) {
      case 'Pre-order':
        await _preOrderTraversal(1);
        break;
      case 'In-order':
        await _inOrderTraversal(1);
        break;
      case 'Post-order':
        await _postOrderTraversal(1);
        break;
      case 'BFS':
        await _breadthFirstTraversal();
        break;
    }
    _addToLog("Completed $type traversal");
  }

  // Pre-order traversal algorithm
  Future<void> _preOrderTraversal(int node) async {
    setState(() {
      activeNodes[node] = true;
    });
    traversalOrder.add(node);
    setState(() {});
    await Future.delayed(animationDuration);
    setState(() {
      activeNodes[node] = false;
    });
    
    if (bst[node] != null && bst[node]!.isNotEmpty) {
      await _preOrderTraversal(bst[node]![0]);
      if (bst[node]!.length > 1) {
        await _preOrderTraversal(bst[node]![1]);
      }
    }
  }

  // In-order traversal algorithm
  Future<void> _inOrderTraversal(int node) async {
    if (bst[node] != null && bst[node]!.isNotEmpty) {
      await _inOrderTraversal(bst[node]![0]);
    }
    
    setState(() {
      activeNodes[node] = true;
    });
    traversalOrder.add(node);
    setState(() {});
    await Future.delayed(animationDuration);
    setState(() {
      activeNodes[node] = false;
    });

    if (bst[node] != null && bst[node]!.isNotEmpty && bst[node]!.length > 1) {
      await _inOrderTraversal(bst[node]![1]);
    }
  }

  // Post-order traversal algorithm
  Future<void> _postOrderTraversal(int node) async {
    if (bst[node] != null && bst[node]!.isNotEmpty) {
      await _postOrderTraversal(bst[node]![0]);
      if (bst[node]!.length > 1) {
        await _postOrderTraversal(bst[node]![1]);
      }
    }
    
    setState(() {
      activeNodes[node] = true;
    });
    traversalOrder.add(node);
    setState(() {});
    await Future.delayed(animationDuration);
    setState(() {
      activeNodes[node] = false;
    });
  }

  // Breadth-First Traversal (BFS) algorithm
  Future<void> _breadthFirstTraversal() async {
    final queue = [1];

    while (queue.isNotEmpty) {
      final node = queue.removeAt(0);
      setState(() {
        activeNodes[node] = true;
      });
      traversalOrder.add(node);
      setState(() {});
      await Future.delayed(animationDuration);
      setState(() {
        activeNodes[node] = false;
      });

      if (bst[node] != null && bst[node]!.isNotEmpty) {
        queue.add(bst[node]![0]);
        if (bst[node]!.length > 1) {
          queue.add(bst[node]![1]);
        }
      }
    }
  }

  // Calculate node positions recursively
  void _calculateNodePositions(int node, Offset offset, double horizontalGap) {
    nodePositions[node] = offset; // Save the position of the node

    // Update minX, maxX, and maxY to track the tree's bounds
    if (offset.dx < minX) minX = offset.dx;
    if (offset.dx > maxX) maxX = offset.dx;
    if (offset.dy > maxY) maxY = offset.dy;

    if (bst[node] != null && bst[node]!.isNotEmpty) {
      // Calculate positions for left and right children
      _calculateNodePositions(
        bst[node]![0],
        Offset(offset.dx - horizontalGap, offset.dy + 80),
        horizontalGap / 2,
      );
      if (bst[node]!.length > 1) {
        _calculateNodePositions(
          bst[node]![1],
          Offset(offset.dx + horizontalGap, offset.dy + 80),
          horizontalGap / 2,
        );
      }
    }
  }

  // Clear the entire BST
  void _clearBST() {
    setState(() {
      bst.clear();
      nodePositions.clear();
      traversalOrder.clear();
      activeNodes.clear();
      minX = 0;
      maxX = 0;
      maxY = 0;
      searchedNode = null;
      _addToLog("Cleared BST");
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    _calculateNodePositions(1, Offset(0, 50), screenWidth / 4);
    final requiredWidth = maxX - minX + screenWidth;
    final requiredHeight = maxY + 100;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Binary Search Tree Visualization',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: buttonTextColor,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 4,
        shadowColor: Colors.black26,
        actions: [
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: buttonTextColor,
            ),
            onPressed: _toggleTheme,
            tooltip: '${isDarkMode ? "Light" : "Dark"} Mode',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: Icon(Icons.account_tree, size: 24),
              text: "Visualization",
              iconMargin: EdgeInsets.only(bottom: 4),
            ),
            Tab(
              icon: Icon(Icons.list_alt, size: 24),
              text: "Process Log",
              iconMargin: EdgeInsets.only(bottom: 4),
            ),
          ],
          labelStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          indicatorColor: buttonTextColor,
          indicatorWeight: 3,
          labelColor: buttonTextColor,
          unselectedLabelColor: buttonTextColor.withOpacity(0.7),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Visualization Tab
          Column(
        children: [
          Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  margin: EdgeInsets.all(16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                          width: requiredWidth,
                          height: requiredHeight,
                  child: CustomPaint(
                            size: Size(requiredWidth, requiredHeight),
                    painter: TreePainter(
                      nodePositions,
                      bst,
                      traversalOrder,
                      screenWidth,
                      minX,
                      searchedNode,
                              primaryColor,
                              accentColor,
                              activeNodes,
                    ),
                    child: Stack(
                              children: nodePositions.entries.map((entry) {
                            final node = entry.key;
                            final offset = entry.value;
                            return Positioned(
                                  left: offset.dx - minX + (screenWidth / 2) - 30,
                                  top: offset.dy - 30,
                                  child: _buildNode(node, offset),
                            );
                          }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                      children: [
                    TextField(
                      controller: _nodeController,
                      decoration: InputDecoration(
                        labelText: 'Enter Node Value',
                        labelStyle: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: primaryColor, width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: primaryColor.withOpacity(0.5), width: 2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: primaryColor, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                        prefixIcon: Icon(Icons.input, color: primaryColor),
                      ),
                      keyboardType: TextInputType.number,
                      style: TextStyle(fontSize: 16),
                  ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                        _buildActionButton(
                      onPressed: () {
                        final value = int.tryParse(_nodeController.text);
                        if (value != null) {
                          _insertNode(value);
                          _nodeController.clear();
                        }
                      },
                          icon: Icons.add_circle_outline,
                          label: 'Insert',
                          color: primaryColor,
                    ),
                        _buildActionButton(
                      onPressed: () {
                        final value = int.tryParse(_nodeController.text);
                        if (value != null) {
                          _searchNode(value);
                        }
                      },
                          icon: Icons.search,
                          label: 'Search',
                          color: secondaryColor,
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildActionButton(
                          onPressed: () {
                            setState(() {
                              showDFSOptions = !showDFSOptions;
                            });
                          },
                          icon: Icons.account_tree,
                          label: 'DFS',
                          color: accentColor,
                          isSelected: showDFSOptions,
                        ),
                        _buildActionButton(
                          onPressed: () => _startTraversal('BFS'),
                          icon: Icons.waves,
                          label: 'BFS',
                          color: accentColor,
                        ),
                        _buildActionButton(
                          onPressed: _clearBST,
                          icon: Icons.delete_outline,
                          label: 'Clear',
                          color: Colors.red[600]!,
                        ),
                      ],
                    ),
                    if (showDFSOptions)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildTraversalButton('Pre-order', () => _startTraversal('Pre-order')),
                            _buildTraversalButton('In-order', () => _startTraversal('In-order')),
                            _buildTraversalButton('Post-order', () => _startTraversal('Post-order')),
                          ],
                        ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Process Log Tab
          Container(
            color: backgroundColor,
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: isDarkMode ? Colors.black26 : Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.history, color: primaryColor, size: 24),
                          SizedBox(width: 8),
                          Text(
                            'Operation Log',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!),
                      boxShadow: [
                        BoxShadow(
                          color: isDarkMode ? Colors.black26 : Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListView.builder(
                      itemCount: processLog.length,
                      itemBuilder: (context, index) {
                        return AnimatedContainer(
                          duration: Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: surfaceColor,
                            border: Border(
                              bottom: BorderSide(
                                color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
                                width: 1,
                              ),
                            ),
                          ),
                          child: TweenAnimationBuilder(
                            duration: Duration(milliseconds: 500),
                            tween: Tween<double>(begin: 0.0, end: 1.0),
                            builder: (context, double value, child) {
                              return Transform.translate(
                                offset: Offset(50 * (1 - value), 0),
                                child: Opacity(
                                  opacity: value,
                                  child: child,
                                ),
                              );
                            },
                            child: Row(
                              children: [
                                Icon(
                                  Icons.arrow_right,
                                  color: primaryColor,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    processLog[index],
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: textColor.withOpacity(0.87),
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color color,
    bool isSelected = false,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? color : color.withOpacity(0.9),
        foregroundColor: buttonTextColor,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: isSelected ? 4 : 2,
        shadowColor: Colors.black38,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTraversalButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: accentColor.withOpacity(0.9),
        foregroundColor: buttonTextColor,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
        shadowColor: Colors.black38,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildNode(int node, Offset offset) {
    bool isActive = activeNodes[node] ?? false;
    bool isSearched = searchedNode == node;
    bool isTraversed = traversalOrder.contains(node);

    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 500),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, double value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              isActive 
                ? Colors.yellow[400]!
                : isSearched
                  ? Colors.lightBlue[300]!
                  : isTraversed
                    ? Colors.blue[300]!
                    : Colors.indigo[300]!,
              isActive
                ? Colors.orange[600]!
                : isSearched
                  ? Colors.lightBlue[700]!
                  : isTraversed
                    ? Colors.blue[700]!
                    : Colors.indigo[700]!,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: isActive
                ? Colors.yellow.withOpacity(0.6)
                : isSearched
                  ? Colors.lightBlue[300]!.withOpacity(0.6)
                  : isTraversed
                    ? Colors.blue[300]!.withOpacity(0.4)
                    : Colors.indigo[300]!.withOpacity(0.4),
              blurRadius: isActive ? 20 : 12,
              spreadRadius: isActive ? 4 : 2,
              offset: Offset(0, 4),
            ),
            if (isActive)
              BoxShadow(
                color: Colors.yellow.withOpacity(0.3),
                blurRadius: 30,
                spreadRadius: 10,
                offset: Offset(0, 0),
              ),
          ],
          border: Border.all(
            color: isActive
              ? Colors.yellow[100]!
              : Colors.white.withOpacity(0.8),
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            '$node',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: Colors.black26,
                  offset: Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Custom Painter to draw edges between nodes
class TreePainter extends CustomPainter {
  final Map<int, Offset> nodePositions;
  final Map<int, List<int>> tree;
  final List<int> traversalOrder;
  final double screenWidth;
  final double minX;
  final int? searchedNode;
  final Color primaryColor;
  final Color accentColor;
  final Map<int, bool> activeNodes;

  TreePainter(
    this.nodePositions,
    this.tree,
    this.traversalOrder,
    this.screenWidth,
    this.minX,
    this.searchedNode,
    this.primaryColor,
    this.accentColor,
    this.activeNodes,
  );

  // Add helper method for vector normalization
  Offset _normalizeVector(Offset vector) {
    double length = sqrt(vector.dx * vector.dx + vector.dy * vector.dy);
    if (length == 0) return Offset.zero;
    return Offset(vector.dx / length, vector.dy / length);
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Draw edges between nodes
    for (final entry in tree.entries) {
      final parent = entry.key;
      final children = entry.value;

      if (nodePositions.containsKey(parent)) {
        final parentOffset = nodePositions[parent]!;

        for (final child in children) {
          if (nodePositions.containsKey(child)) {
            final childOffset = nodePositions[child]!;
            
            // Calculate control points for curved lines
            final startPoint = Offset(
                parentOffset.dx - minX + (screenWidth / 2),
              parentOffset.dy + 30,
            );
            final endPoint = Offset(
                childOffset.dx - minX + (screenWidth / 2),
              childOffset.dy - 30,
            );
            
            final controlPoint1 = Offset(
              startPoint.dx,
              startPoint.dy + (endPoint.dy - startPoint.dy) / 3,
            );
            final controlPoint2 = Offset(
              endPoint.dx,
              startPoint.dy + (endPoint.dy - startPoint.dy) * 2 / 3,
            );

            // Draw edge shadow
            final shadowPath = Path()
              ..moveTo(startPoint.dx, startPoint.dy)
              ..cubicTo(
                controlPoint1.dx, controlPoint1.dy,
                controlPoint2.dx, controlPoint2.dy,
                endPoint.dx, endPoint.dy,
              );

            canvas.drawPath(
              shadowPath,
              Paint()
                ..color = Colors.black26
                ..strokeWidth = 4
                ..style = PaintingStyle.stroke
                ..strokeCap = StrokeCap.round
                ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4),
            );

            // Draw the main edge
            final path = Path()
              ..moveTo(startPoint.dx, startPoint.dy)
              ..cubicTo(
                controlPoint1.dx, controlPoint1.dy,
                controlPoint2.dx, controlPoint2.dy,
                endPoint.dx, endPoint.dy,
              );

            final gradient = LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                primaryColor.withOpacity(0.8),
                accentColor.withOpacity(0.8),
              ],
            );

            final paint = Paint()
              ..shader = gradient.createShader(Rect.fromPoints(startPoint, endPoint))
              ..strokeWidth = 3
              ..style = PaintingStyle.stroke
              ..strokeCap = StrokeCap.round;

            canvas.drawPath(path, paint);

            // Draw direction arrow
            final arrowSize = 12.0;
            final direction = _normalizeVector(endPoint - controlPoint2);
            final arrowPoint = endPoint - Offset(direction.dx * arrowSize, direction.dy * arrowSize);
            final leftPoint = arrowPoint + 
                Offset(direction.dy * arrowSize / 2, -direction.dx * arrowSize / 2);
            final rightPoint = arrowPoint + 
                Offset(-direction.dy * arrowSize / 2, direction.dx * arrowSize / 2);

            final arrowPath = Path()
              ..moveTo(endPoint.dx, endPoint.dy)
              ..lineTo(leftPoint.dx, leftPoint.dy)
              ..lineTo(rightPoint.dx, rightPoint.dy)
              ..close();

            canvas.drawPath(
              arrowPath,
              Paint()
                ..color = accentColor.withOpacity(0.9)
                ..style = PaintingStyle.fill
                ..strokeCap = StrokeCap.round
                ..strokeJoin = StrokeJoin.round,
            );
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant TreePainter oldDelegate) => true;
}
