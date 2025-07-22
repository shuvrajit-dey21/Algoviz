import 'package:flutter/material.dart';
import 'dart:math' as math;

class TreeVisualization extends StatefulWidget {
  const TreeVisualization({super.key});

  @override
  _TreeVisualizationState createState() => _TreeVisualizationState();
}

class _TreeVisualizationState extends State<TreeVisualization> {
  bool _isDarkMode = false;

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Color(0xFF6200EE),
        colorScheme: ColorScheme.light(
          primary: Color(0xFF6200EE),
          secondary: Color(0xFF03DAC6),
        ),
        scaffoldBackgroundColor: Color(0xFFF5F5F5),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Color(0xFF7B61FF),
        colorScheme: ColorScheme.dark(
          primary: Color(0xFF7B61FF),
          secondary: Color(0xFF52F2DC),
          background: Color(0xFF121212),
          surface: Color(0xFF212121),
        ),
        scaffoldBackgroundColor: Color(0xFF121212),
        cardColor: Color(0xFF212121),
      ),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: TreeVisualizationScreen(toggleTheme: _toggleTheme, isDarkMode: _isDarkMode),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TreeVisualizationScreen extends StatefulWidget {
  final Function toggleTheme;
  final bool isDarkMode;
  
  const TreeVisualizationScreen({
    super.key, 
    required this.toggleTheme,
    required this.isDarkMode,
  });

  @override
  _TreeVisualizationScreenState createState() =>
      _TreeVisualizationScreenState();
}

class _TreeVisualizationScreenState extends State<TreeVisualizationScreen> with TickerProviderStateMixin {
  final List<int> traversalOrder = []; // Stores the order of traversal
  final Map<int, Offset> nodePositions = {}; // Stores positions of nodes
  bool showDFSOptions = false; // Controls visibility of DFS sub-options
  final Map<int, List<int>> tree = {}; // User-defined tree structure
  final TextEditingController _parentController = TextEditingController();
  final TextEditingController _childController = TextEditingController();
  final TextEditingController _searchController =
      TextEditingController(); // For search node
  double minX = 0; // Tracks the leftmost position of the tree
  double maxX = 0; // Tracks the rightmost position of the tree
  double maxY = 0; // Tracks the bottommost position of the tree
  int? searchedNode; // Stores the searched node for highlighting
  String _currentStep = ""; // To display the current traversal step
  late AnimationController _buttonAnimController;
  late Animation<double> _buttonScaleAnimation;
  late AnimationController _nodeAnimController;
  late Animation<double> _nodeScaleAnimation;
  late AnimationController _stepAnimController;
  late Animation<double> _stepSlideAnimation;
  late Animation<double> _stepFadeAnimation;
  
  // Theme colors dynamically determined based on theme mode
  late Color primaryColor;
  late Color secondaryColor;
  late Color backgroundColor;
  late Color accentColor;
  late Color cardColor;
  late Color textColor;
  late Color textSecondaryColor;
  late Color nodeDefaultColor;
  late Color edgeDefaultColor;

  // Add this to store all steps
  final List<String> stepsHistory = [];
  
  // Add this to the state class
  List<String> traversalPath = [];

  @override
  void initState() {
    super.initState();
    // Initialize with the default tree structure
    tree.addAll({
      1: [2, 3, 4],
      2: [5, 6],
      3: [7],
      4: [8, 9],
      5: [],
      6: [],
      7: [],
      8: [],
      9: [],
    });
    
    // Initialize animation controllers
    _buttonAnimController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
    _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _buttonAnimController,
        curve: Curves.easeInOut,
      ),
    );
    
    _nodeAnimController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    _nodeScaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(
        parent: _nodeAnimController,
        curve: Curves.elasticOut,
      ),
    );
    
    // Initialize step animation controller
    _stepAnimController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    
    _stepSlideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _stepAnimController,
      curve: Curves.easeOutCubic,
    ));
    
    _stepFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _stepAnimController,
      curve: Curves.easeOut,
    ));
    
    _updateThemeColors();
  }
  
  // Update theme colors based on the current theme mode
  void _updateThemeColors() {
    if (widget.isDarkMode) {
      // Dark theme colors
      primaryColor = Color(0xFF7B61FF);      // Lighter purple for dark mode
      secondaryColor = Color(0xFF52F2DC);    // Brighter teal for dark mode
      backgroundColor = Color(0xFF121212);   // Dark background
      accentColor = Color(0xFFFFB74D);       // Lighter orange for dark mode
      cardColor = Color(0xFF212121);         // Dark card color
      textColor = Colors.white;              // White text
      textSecondaryColor = Colors.white70;   // Light gray text
      nodeDefaultColor = Colors.grey.shade600; // Darker gray for nodes
      edgeDefaultColor = Colors.grey.shade600; // Darker gray for edges - increased contrast
    } else {
      // Light theme colors
      primaryColor = Color(0xFF6200EE);      // Default purple
      secondaryColor = Color(0xFF03DAC6);    // Default teal
      backgroundColor = Color(0xFFF5F5F5);   // Light background
      accentColor = Color(0xFFFF9800);       // Default orange
      cardColor = Colors.white;              // White card color
      textColor = Colors.black87;            // Dark text
      textSecondaryColor = Colors.black54;   // Gray text
      nodeDefaultColor = Colors.grey.shade400; // Light gray for nodes
      edgeDefaultColor = Colors.grey.shade300; // Light gray for edges
    }
  }

  @override
  void didUpdateWidget(TreeVisualizationScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isDarkMode != widget.isDarkMode) {
      _updateThemeColors();
      setState(() {});
    }
  }

  @override
  void dispose() {
    _buttonAnimController.dispose();
    _nodeAnimController.dispose();
    _stepAnimController.dispose();
    super.dispose();
  }

  // Update the existing _currentStep setter
  void _updateStep(String step) {
    setState(() {
      _currentStep = step;
      stepsHistory.add(step);
      _stepAnimController.reset();
      _stepAnimController.forward();
    });
  }

  // Start traversal based on the selected type
  void _startTraversal(String type) async {
    traversalOrder.clear();
    searchedNode = null;
    setState(() {
      stepsHistory.clear();
      traversalPath.clear(); // Clear previous path
    });
    _updateStep("Starting $type traversal...");

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
    
    // Add final path step
    _updateStep("$type traversal completed!");
    setState(() {
      traversalPath = traversalOrder.map((node) => node.toString()).toList();
      stepsHistory.add("Final Path: ${traversalPath.join(' → ')}");
    });
  }

  // Pre-order traversal algorithm
  Future<void> _preOrderTraversal(int node) async {
    // Animate the node
    _animateNode(node);
    
    _updateStep("Pre-order: Visit node $node");
    traversalOrder.add(node);
    await Future.delayed(Duration(milliseconds: 800)); // Animation delay
    
    if (tree[node] != null && tree[node]!.isNotEmpty) {
      for (final child in tree[node]!) {
        _updateStep("Pre-order: Moving from node $node to child $child");
        await Future.delayed(Duration(milliseconds: 300));
        await _preOrderTraversal(child); // Traverse each child
      }
    }
  }

  // In-order traversal algorithm
  Future<void> _inOrderTraversal(int node) async {
    if (tree[node] != null && tree[node]!.isNotEmpty) {
      for (int i = 0; i < tree[node]!.length; i++) {
        if (i == 0) {
          _updateStep("In-order: Going to left subtree of node $node");
          await Future.delayed(Duration(milliseconds: 300));
        }
        
        if (i == tree[node]!.length ~/ 2) {
          _animateNode(node);
          _updateStep("In-order: Visit node $node");
          traversalOrder.add(node);
          await Future.delayed(Duration(milliseconds: 800)); // Animation delay
        }
        
        if (i > tree[node]!.length ~/ 2) {
          _updateStep("In-order: Going to right subtree of node $node");
          await Future.delayed(Duration(milliseconds: 300));
        }
        
        await _inOrderTraversal(tree[node]![i]); // Traverse each child
      }
    } else {
      _animateNode(node);
      _updateStep("In-order: Visit leaf node $node");
      traversalOrder.add(node);
      await Future.delayed(Duration(milliseconds: 800)); // Animation delay
    }
  }

  // Post-order traversal algorithm
  Future<void> _postOrderTraversal(int node) async {
    if (tree[node] != null && tree[node]!.isNotEmpty) {
      _updateStep("Post-order: Traversing children of node $node first");
      await Future.delayed(Duration(milliseconds: 300));
      
      for (final child in tree[node]!) {
        await _postOrderTraversal(child); // Traverse each child
      }
    }
    
    _animateNode(node);
    _updateStep("Post-order: Visit node $node (after all children)");
    traversalOrder.add(node);
    await Future.delayed(Duration(milliseconds: 800)); // Animation delay
  }

  // Breadth-First Traversal (BFS) algorithm
  Future<void> _breadthFirstTraversal() async {
    final queue = [1]; // Start with the root node
    int level = 0;
    List<int> currentLevel = [1];

    while (queue.isNotEmpty) {
      List<int> nextLevel = [];
      _updateStep("BFS: Visiting level $level nodes: ${currentLevel.join(', ')}");
      
      for (final node in currentLevel) {
        final currNode = queue.removeAt(0);
        _animateNode(currNode);
        traversalOrder.add(currNode);
        await Future.delayed(Duration(milliseconds: 800)); // Animation delay

      // Add child nodes to the queue
        if (tree[currNode] != null && tree[currNode]!.isNotEmpty) {
          queue.addAll(tree[currNode]!); // Add all children
          nextLevel.addAll(tree[currNode]!);
        }
      }
      
      currentLevel = nextLevel;
      level++;
    }
  }

  // Animate a node when it's being visited
  void _animateNode(int node) {
    _nodeAnimController.reset();
    _nodeAnimController.forward();
  }

  // Calculate node positions recursively
  void _calculateNodePositions(int node, Offset offset, double horizontalGap) {
    nodePositions[node] = offset; // Save the position of the node

    // Update minX, maxX, and maxY to track the tree's bounds
    if (offset.dx < minX) minX = offset.dx;
    if (offset.dx > maxX) maxX = offset.dx;
    if (offset.dy > maxY) maxY = offset.dy;

    if (tree[node] != null && tree[node]!.isNotEmpty) {
      final childCount = tree[node]!.length;
      final startX = offset.dx - (horizontalGap * (childCount - 1)) / 2;

      for (int i = 0; i < childCount; i++) {
        _calculateNodePositions(
          tree[node]![i],
          Offset(startX + i * horizontalGap, offset.dy + 80),
          horizontalGap / childCount,
        );
      }
    }
  }

  // Add a new node to the tree
  void _addNode() {
    final parent = int.tryParse(_parentController.text);
    final child = int.tryParse(_childController.text);

    if (parent != null && child != null) {
      setState(() {
        if (tree.containsKey(parent)) {
          tree[parent]!.add(child);
        } else {
          tree[parent] = [child];
        }
        if (!tree.containsKey(child)) {
          tree[child] = [];
        }

        // Recalculate node positions and update minX, maxX, and maxY
        _calculateNodePositions(
          1,
          Offset(0, 50),
          MediaQuery.of(context).size.width / 4,
        );
        searchedNode = null; // Reset searched node when a new node is added
      });
      _parentController.clear();
      _childController.clear();
    }
  }

  // Search for a node in the tree
  void _searchNode(int value) {
    setState(() {
      traversalOrder.clear(); // Clear traversal order when searching
      searchedNode = _searchTree(1, value); // Start search from the root
    });
  }

  // Recursive function to search for a node in the tree
  int? _searchTree(int root, int value) {
    if (root == value) {
      return root;
    }

    if (tree[root] != null && tree[root]!.isNotEmpty) {
      for (final child in tree[root]!) {
        final result = _searchTree(child, value);
        if (result != null) {
          return result;
        }
      }
    }

    return null; // Node not found
  }

  // Clear the entire tree
  void _clearTree() {
    setState(() {
      tree.clear(); // Clear the tree structure
      nodePositions.clear(); // Clear node positions
      traversalOrder.clear(); // Clear traversal order
      minX = 0; // Reset minX
      maxX = 0; // Reset maxX
      maxY = 0; // Reset maxY
      searchedNode = null; // Reset searched node
    });
  }

  // Animated button widget
  Widget _buildAnimatedButton({
    required VoidCallback onPressed, 
    required String text, 
    Color? color,
    IconData? icon
  }) {
    return GestureDetector(
      onTapDown: (_) => _buttonAnimController.forward(),
      onTapUp: (_) {
        _buttonAnimController.reverse();
        onPressed();
      },
      onTapCancel: () => _buttonAnimController.reverse(),
      child: AnimatedBuilder(
        animation: _buttonAnimController,
        builder: (context, child) {
          return Transform.scale(
            scale: _buttonScaleAnimation.value,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: color ?? primaryColor,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: widget.isDarkMode ? Colors.black38 : Colors.black26,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) 
                    Icon(icon, color: Colors.white, size: 18),
                  if (icon != null) 
                    SizedBox(width: 8),
                  Text(
                    text,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
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

  // Add this method to the state class
  void _resetTree() {
    setState(() {
      // Reset traversal and search states
      traversalOrder.clear();
      stepsHistory.clear();
      traversalPath.clear();
      searchedNode = null;
      _currentStep = "";
      
      // Reset the tree to initial state
      tree.clear();
      tree.addAll({
        1: [2, 3, 4],
        2: [5, 6],
        3: [7],
        4: [8, 9],
        5: [],
        6: [],
        7: [],
        8: [],
        9: [],
      });
      
      // Reset positions
      nodePositions.clear();
      minX = 0;
      maxX = 0;
      maxY = 0;
    });
  }

  // Update the _showTraversalInfo method
  void _showTraversalInfo() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: TweenAnimationBuilder(
          duration: Duration(milliseconds: 600),
          tween: Tween<double>(begin: 0, end: 1),
          builder: (context, double value, child) {
            return Opacity(
              opacity: value,
              child: Transform.scale(
                scale: 0.8 + (0.2 * value),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: primaryColor,
                      size: 28,
                    ),
                    SizedBox(width: 8),
                    Text('Tree Traversal Guide', style: TextStyle(color: textColor)),
                  ],
                ),
              ),
            );
          },
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInfoSection(
                'Depth-First Search (DFS)',
                [
                  _buildTraversalInfo(
                    'Pre-order (Root → Left → Right)',
                    'Visits the root first, then traverses the left subtree, and finally the right subtree.',
                    'Example: 1 → 2 → 4 → 5 → 3 → 6 → 7',
                  ),
                  _buildPseudocode(
                    'Pre-order Pseudocode',
                    [
                      'preorder(node):',
                      '  if node == null:',
                      '    return',
                      '  visit(node)',
                      '  preorder(node.left)',
                      '  preorder(node.right)',
                    ],
                  ),
                  _buildTraversalInfo(
                    'In-order (Left → Root → Right)',
                    'Traverses the left subtree first, then visits the root, and finally traverses the right subtree.',
                    'Example: 4 → 2 → 5 → 1 → 6 → 3 → 7',
                  ),
                  _buildPseudocode(
                    'In-order Pseudocode',
                    [
                      'inorder(node):',
                      '  if node == null:',
                      '    return',
                      '  inorder(node.left)',
                      '  visit(node)',
                      '  inorder(node.right)',
                    ],
                  ),
                  _buildTraversalInfo(
                    'Post-order (Left → Right → Root)',
                    'Traverses the left subtree first, then the right subtree, and finally visits the root.',
                    'Example: 4 → 5 → 2 → 6 → 7 → 3 → 1',
                  ),
                  _buildPseudocode(
                    'Post-order Pseudocode',
                    [
                      'postorder(node):',
                      '  if node == null:',
                      '    return',
                      '  postorder(node.left)',
                      '  postorder(node.right)',
                      '  visit(node)',
                    ],
                  ),
                ],
              ),
              Divider(height: 24, color: widget.isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300),
              _buildInfoSection(
                'Breadth-First Search (BFS)',
                [
                  _buildTraversalInfo(
                    'Level Order',
                    'Visits all nodes at the current level before moving to the next level.',
                    'Example: 1 → 2 → 3 → 4 → 5 → 6 → 7',
                  ),
                  _buildPseudocode(
                    'BFS Pseudocode',
                    [
                      'bfs(root):',
                      '  if root == null:',
                      '    return',
                      '  queue = new Queue()',
                      '  queue.add(root)',
                      '  while !queue.isEmpty:',
                      '    node = queue.remove()',
                      '    visit(node)',
                      '    queue.add(node.left)',
                      '    queue.add(node.right)',
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TweenAnimationBuilder(
            duration: Duration(milliseconds: 600),
            tween: Tween<double>(begin: 0, end: 1),
            builder: (context, double value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text('Got it'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Helper method to build info sections
  Widget _buildInfoSection(String title, List<Widget> content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        SizedBox(height: 12),
        ...content,
      ],
    );
  }

  // Update the _buildPseudocode method
  Widget _buildPseudocode(String title, List<String> steps) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 800),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: Container(
              margin: EdgeInsets.only(top: 8, bottom: 16),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: widget.isDarkMode ? Colors.black : Colors.grey.shade900,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: widget.isDarkMode ? Colors.black38 : Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Divider(color: Colors.white24),
                  ...steps.asMap().entries.map((entry) {
                    // Calculate a delay factor based on the index
                    final delayFactor = entry.key * 0.2;
                    return TweenAnimationBuilder(
                      duration: Duration(milliseconds: 500),
                      tween: Tween<double>(
                        begin: 0,
                        end: value > delayFactor ? 1 : 0, // Start animation based on parent's progress
                      ),
                      builder: (context, double stepValue, child) {
                        return Opacity(
                          opacity: stepValue,
                          child: Transform.translate(
                            offset: Offset(20 * (1 - stepValue), 0),
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Text(
                                    '${entry.key + 1}.',
                                    style: TextStyle(
                                      color: accentColor,
                                      fontFamily: 'monospace',
                                      fontSize: 13,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      entry.value,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'monospace',
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Update the _buildTraversalInfo method to include animations
  Widget _buildTraversalInfo(String title, String description, String example) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 800),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: Container(
              margin: EdgeInsets.only(bottom: 16),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: widget.isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: widget.isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
                ),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(widget.isDarkMode ? 0.2 : 0.1),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: accentColor,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: textColor,
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(widget.isDarkMode ? 0.2 : 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.code,
                          size: 16,
                          color: primaryColor,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            example,
                            style: TextStyle(
                              fontSize: 14,
                              color: primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Calculate node positions before building the tree
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    _calculateNodePositions(1, Offset(0, 50), screenWidth / 4);

    // Calculate the required width and height for the scrollable area
    final requiredWidth = maxX - minX + screenWidth;
    final requiredHeight = maxY + 100; // Add some padding at the bottom

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.account_tree_rounded,
              color: Colors.white,
              size: 24,
            ),
            SizedBox(width: 10),
            Text(
              'Tree Traversals', 
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: primaryColor,
        elevation: widget.isDarkMode ? 4 : 0,
        shadowColor: widget.isDarkMode ? Colors.black54 : null,
        shape: widget.isDarkMode ? null : RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(15),
          ),
        ),
        actions: <Widget>[
          // Add theme toggle button
          Container(
            margin: EdgeInsets.only(right: 8),
            child: IconButton(
              icon: Icon(
                widget.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                color: Colors.white,
                size: 24,
              ),
              tooltip: widget.isDarkMode ? 'Switch to Light Theme' : 'Switch to Dark Theme',
              onPressed: () {
                widget.toggleTheme();
              },
            ),
          ),
          Container(
            margin: EdgeInsets.only(right: 8),
            child: IconButton(
              icon: Icon(
                Icons.info_outline,
                color: Colors.white,
                size: 24,
              ),
              tooltip: 'Traversal Guide',
              onPressed: _showTraversalInfo,
            ),
          ),
          Container(
            margin: EdgeInsets.only(right: 8),
            child: IconButton(
              icon: Stack(
                children: [
                  Icon(Icons.refresh, color: Colors.white),
                  if (traversalOrder.isNotEmpty || searchedNode != null)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: accentColor,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              tooltip: 'Reset Tree',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    backgroundColor: cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    title: Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded, 
                          color: accentColor,
                          size: 28,
                        ),
                        SizedBox(width: 8),
                        Text('Reset Tree', style: TextStyle(color: textColor)),
                      ],
                    ),
                    content: Text(
                      'This will reset the tree to its initial state and clear all operations. Are you sure you want to continue?',
                      style: TextStyle(color: textSecondaryColor),
                    ),
                    actions: [
                      TextButton(
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      Container(
                        margin: EdgeInsets.only(right: 8),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text('Reset'),
                          onPressed: () {
                            _resetTree();
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          // Traversal Steps container
          Container(
            height: 150,
            margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: widget.isDarkMode ? Colors.black38 : Colors.black12,
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
              border: widget.isDarkMode ? Border.all(
                color: Colors.grey.shade700,
                width: 1,
              ) : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryColor, primaryColor.withOpacity(0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                    boxShadow: widget.isDarkMode ? [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ] : null,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.history, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Traversal Steps',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${stepsHistory.length} steps',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    itemCount: stepsHistory.length,
                    reverse: true,
                    itemBuilder: (context, index) {
                      final step = stepsHistory[stepsHistory.length - 1 - index];
                      final isLatestStep = index == 0;
                      final isFinalPath = step.startsWith("Final Path:");
                      
                      return AnimatedBuilder(
                        animation: _stepAnimController,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, isLatestStep ? _stepSlideAnimation.value : 0),
                            child: Opacity(
                              opacity: isLatestStep ? _stepFadeAnimation.value : 1.0,
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  gradient: isFinalPath
                                    ? LinearGradient(
                                        colors: [
                                          accentColor.withOpacity(0.2),
                                          accentColor.withOpacity(0.05),
                                        ],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      )
                                    : isLatestStep
                                      ? LinearGradient(
                                          colors: [
                                            primaryColor.withOpacity(0.15),
                                            primaryColor.withOpacity(0.05),
                                          ],
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                        )
                                      : null,
                                  color: isFinalPath 
                                      ? null
                                      : isLatestStep 
                                          ? null
                                          : widget.isDarkMode ? Color(0xFF1E1E1E) : Colors.grey.shade50,
                                  border: Border.all(
                                    color: isFinalPath
                                        ? accentColor.withOpacity(0.3)
                                        : isLatestStep 
                                            ? primaryColor.withOpacity(0.3)
                                            : widget.isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: (isLatestStep || isFinalPath) ? [
                                    BoxShadow(
                                      color: isFinalPath
                                          ? accentColor.withOpacity(0.1)
                                          : primaryColor.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: Offset(0, 2),
                                    ),
                                  ] : null,
                                ),
                                child: Row(
                                  children: [
                                    if (!isFinalPath) Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: isLatestStep
                                              ? [primaryColor, primaryColor.withOpacity(0.8)]
                                              : widget.isDarkMode 
                                                  ? [Colors.grey.shade600, Colors.grey.shade700]
                                                  : [Colors.grey.shade400, Colors.grey.shade300],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        shape: BoxShape.circle,
                                        boxShadow: isLatestStep ? [
                                          BoxShadow(
                                            color: primaryColor.withOpacity(0.3),
                                            blurRadius: 4,
                                            offset: Offset(0, 2),
                                          ),
                                        ] : null,
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${stepsHistory.length - index}',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (!isFinalPath) SizedBox(width: 12),
                                    Expanded(
                                      child: isFinalPath
                                          ? SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: Row(
                                                children: step.split('→').map((node) {
                                                  return Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Container(
                                                        padding: EdgeInsets.symmetric(
                                                          horizontal: 12,
                                                          vertical: 6,
                                                        ),
                                                        decoration: BoxDecoration(
                                                          color: accentColor,
                                                          borderRadius: BorderRadius.circular(15),
                                                        ),
                                                        child: Text(
                                                          node.trim(),
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                      if (node != step.split('→').last)
                                                        Padding(
                                                          padding: EdgeInsets.symmetric(horizontal: 8),
                                                          child: Icon(
                                                            Icons.arrow_forward,
                                                            color: accentColor,
                                                            size: 20,
                                                          ),
                                                        ),
                                                    ],
                                                  );
                                                }).toList(),
                                              ),
                                            )
                                          : Text(
                                              step,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: isLatestStep 
                                                    ? textColor
                                                    : textSecondaryColor,
                                                fontWeight: isLatestStep
                                                    ? FontWeight.w500
                                                    : FontWeight.normal,
                                              ),
                                            ),
                                    ),
                                    if (isLatestStep && !isFinalPath)
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: widget.isDarkMode ? 
                                            primaryColor.withOpacity(0.3) : 
                                            primaryColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: primaryColor.withOpacity(0.5),
                                            width: 1,
                                          ),
                                        ),
                                        child: Text(
                                          'Current',
                                          style: TextStyle(
                                            color: widget.isDarkMode ? Colors.white : primaryColor,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Tree Visualization Area
          Expanded(
            flex: 3, // Gives 3x weight to the visualization area
            child: Container(
              margin: EdgeInsets.fromLTRB(12, 6, 12, 6),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: widget.isDarkMode ? Colors.black38 : Colors.black12,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
                border: widget.isDarkMode ? Border.all(
                  color: Colors.grey.shade800,
                  width: 1,
                ) : null,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: InteractiveViewer( // Added InteractiveViewer for zoom and pan
                  boundaryMargin: EdgeInsets.all(20),
                  minScale: 0.5,
                  maxScale: 2.5,
                  child: Container(
                    color: widget.isDarkMode ? Color(0xFF1A1A1A) : Colors.white,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: requiredWidth, // Dynamically adjust width
                          height: requiredHeight, // Dynamically adjust height
                          child: CustomPaint(
                            size: Size(requiredWidth, requiredHeight), // Canvas size
                            painter: TreePainter(
                              nodePositions,
                              tree,
                              traversalOrder,
                              screenWidth,
                              minX,
                              searchedNode,
                              primaryColor,
                              accentColor,
                              secondaryColor,
                              edgeDefaultColor,
                              widget.isDarkMode,
                            ),
                            child: Stack(
                              children: nodePositions.entries.map((entry) {
                                final node = entry.key;
                                final offset = entry.value;
                                return Positioned(
                                  left: offset.dx - minX + (screenWidth / 2) - 25, // Adjust for minX
                                  top: offset.dy - 25,
                                  child: AnimatedBuilder(
                                    animation: _nodeAnimController,
                                    builder: (context, child) {
                                      double scale = traversalOrder.isNotEmpty && 
                                                traversalOrder.last == node ? 
                                                _nodeScaleAnimation.value : 1.0;
                                      
                                      Color nodeColor;
                                      if (searchedNode == node) {
                                        nodeColor = accentColor; // Highlight searched node
                                      } else if (traversalOrder.contains(node)) {
                                        nodeColor = primaryColor; // Highlight traversed nodes
                                      } else {
                                        nodeColor = nodeDefaultColor; // Default color for other nodes
                                      }
                                      
                                      return Transform.scale(
                                        scale: scale,
                                        child: Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            color: nodeColor,
                                            gradient: LinearGradient(
                                              colors: [
                                                nodeColor,
                                                nodeColor.withOpacity(0.8),
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: widget.isDarkMode ? Colors.black45 : Colors.black26,
                                                blurRadius: 4,
                                                offset: Offset(0, 2),
                                              ),
                                            ],
                                            border: Border.all(
                                              color: widget.isDarkMode ? 
                                                nodeColor == nodeDefaultColor ? Colors.grey.shade700 : Colors.white30 :
                                                Colors.white,
                                              width: 2,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              '$node',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                shadows: [
                                                  if (widget.isDarkMode) 
                                                    Shadow(
                                                      color: Colors.black45,
                                                      blurRadius: 2,
                                                      offset: Offset(0, 1),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                  ),
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
            ),
          ),
          
          // Controls Section - Smaller and scrollable
          Expanded(
            flex: 2, // Gives 2x weight to the controls (smaller than visualization)
            child: Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.isDarkMode ? Colors.black38 : Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  ),
                ],
                border: widget.isDarkMode ? Border.all(
                  color: Colors.grey.shade800,
                  width: 1,
                ) : null,
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle indicator for dragging
                    Container(
                      width: 40,
                      height: 5,
                      margin: EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: widget.isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    
                    // Traversal buttons - more compact layout
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildAnimatedButton(
                          onPressed: () {
                            setState(() {
                              showDFSOptions = !showDFSOptions; // Toggle DFS options
                            });
                          },
                          text: 'DFS',
                          color: primaryColor,
                          icon: Icons.account_tree,
                        ),
                        _buildAnimatedButton(
                          onPressed: () => _startTraversal('BFS'),
                          text: 'BFS',
                          color: secondaryColor,
                          icon: Icons.layers,
                        ),
                        _buildAnimatedButton(
                          onPressed: _clearTree, // Clear the tree
                          text: 'Clear Tree',
                          color: Colors.redAccent,
                          icon: Icons.delete_outline,
                        ),
                      ],
                    ),
                    
                    if (showDFSOptions) // Show DFS sub-options if toggled
                      AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(top: 10),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: widget.isDarkMode ? Color(0xFF1E1E1E) : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(15),
                          border: widget.isDarkMode ? Border.all(
                            color: Colors.grey.shade800,
                            width: 1,
                          ) : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: _buildAnimatedButton(
                                onPressed: () => _startTraversal('Pre-order'),
                                text: 'Pre-order',
                                color: primaryColor.withOpacity(0.8),
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: _buildAnimatedButton(
                                onPressed: () => _startTraversal('In-order'),
                                text: 'In-order',
                                color: primaryColor.withOpacity(0.8),
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: _buildAnimatedButton(
                                onPressed: () => _startTraversal('Post-order'),
                                text: 'Post-order',
                                color: primaryColor.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                    SizedBox(height: 15),
                    
                    // Node management section - more compact
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: widget.isDarkMode ? Color(0xFF1E1E1E) : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(15),
                        border: widget.isDarkMode ? Border.all(
                          color: Colors.grey.shade800,
                          width: 1,
                        ) : null,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.add_circle, color: primaryColor),
                              SizedBox(width: 8),
                              Text(
                                'Add Node',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _parentController,
                                  decoration: InputDecoration(
                                    labelText: 'Parent',
                                    labelStyle: TextStyle(color: widget.isDarkMode ? Colors.grey.shade400 : null),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(color: widget.isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300),
                                    ),
                                    filled: true,
                                    fillColor: widget.isDarkMode ? Color(0xFF2A2A2A) : Colors.white,
                                    isDense: true,
                                    prefixIcon: Icon(Icons.account_tree, size: 18, color: widget.isDarkMode ? Colors.grey.shade400 : null),
                                  ),
                                  keyboardType: TextInputType.number,
                                  style: TextStyle(color: textColor),
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _childController,
                                  decoration: InputDecoration(
                                    labelText: 'Child',
                                    labelStyle: TextStyle(color: widget.isDarkMode ? Colors.grey.shade400 : null),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(color: widget.isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300),
                                    ),
                                    filled: true,
                                    fillColor: widget.isDarkMode ? Color(0xFF2A2A2A) : Colors.white,
                                    isDense: true,
                                    prefixIcon: Icon(Icons.child_care, size: 18, color: widget.isDarkMode ? Colors.grey.shade400 : null),
                                  ),
                                  keyboardType: TextInputType.number,
                                  style: TextStyle(color: textColor),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          _buildAnimatedButton(
                            onPressed: _addNode,
                            text: 'Add Node',
                            color: accentColor,
                            icon: Icons.add_circle_outline,
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 10),
                    
                    // Search section with fixed decoration
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: widget.isDarkMode ? Color(0xFF1E1E1E) : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(15),
                        border: widget.isDarkMode ? Border.all(
                          color: Colors.grey.shade800,
                          width: 1,
                        ) : null,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.search, color: primaryColor),
                              SizedBox(width: 8),
                              Text(
                                'Search Node',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Enter node value',
                              hintStyle: TextStyle(color: widget.isDarkMode ? Colors.grey.shade500 : null),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: widget.isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300),
                              ),
                              filled: true,
                              fillColor: widget.isDarkMode ? Color(0xFF2A2A2A) : Colors.white,
                              isDense: true,
                              prefixIcon: Icon(Icons.search, size: 18, color: widget.isDarkMode ? Colors.grey.shade400 : null),
                              suffixIcon: IconButton(
                                icon: Icon(Icons.clear, size: 16, color: widget.isDarkMode ? Colors.grey.shade400 : null),
                                onPressed: () => _searchController.clear(),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            style: TextStyle(color: textColor),
                            onSubmitted: (value) {
                              final nodeValue = int.tryParse(value);
                              if (nodeValue != null) {
                                _searchNode(nodeValue);
                              }
                            },
                          ),
                          SizedBox(height: 8),
                          _buildAnimatedButton(
                            onPressed: () {
                              final value = int.tryParse(_searchController.text);
                              if (value != null) {
                                _searchNode(value);
                              }
                            },
                            text: 'Search',
                            color: secondaryColor,
                            icon: Icons.search,
                          ),
                        ],
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
  final Color secondaryColor;
  final Color defaultEdgeColor;
  final bool isDarkMode;

  TreePainter(
    this.nodePositions,
    this.tree,
    this.traversalOrder,
    this.screenWidth,
    this.minX,
    this.searchedNode,
    this.primaryColor,
    this.accentColor,
    this.secondaryColor,
    this.defaultEdgeColor,
    this.isDarkMode,
  );

  @override
  void paint(Canvas canvas, Size size) {
    // Draw edges between parent and child nodes
    for (final entry in tree.entries) {
      final parent = entry.key;
      final children = entry.value;

      if (nodePositions.containsKey(parent)) {
        final parentOffset = nodePositions[parent]!;

        for (final child in children) {
          if (nodePositions.containsKey(child)) {
            final childOffset = nodePositions[child]!;
            
            // Determine edge color based on traversal
            Color edgeColor;
            if (traversalOrder.contains(parent) && traversalOrder.contains(child)) {
              // Both parent and child have been visited
              edgeColor = primaryColor;
            } else if (traversalOrder.contains(parent)) {
              // Only parent has been visited
              edgeColor = secondaryColor;
            } else {
              // Default edge color
              edgeColor = defaultEdgeColor;
            }
            
            final paint = Paint()
              ..color = edgeColor
              ..strokeWidth = 3
              ..style = PaintingStyle.stroke;
            
            // Draw curved paths for a more appealing look
            final path = Path();
            final startPoint = Offset(
              parentOffset.dx - minX + (screenWidth / 2),
              parentOffset.dy + 25,
            );
            final endPoint = Offset(
              childOffset.dx - minX + (screenWidth / 2),
              childOffset.dy - 25,
            );
            
            path.moveTo(startPoint.dx, startPoint.dy);
            
            // Calculate control points for the curve
            final controlPointX = (startPoint.dx + endPoint.dx) / 2;
            final controlPointY1 = startPoint.dy + (endPoint.dy - startPoint.dy) * 0.25;
            final controlPointY2 = startPoint.dy + (endPoint.dy - startPoint.dy) * 0.75;
            
            path.cubicTo(
              controlPointX, controlPointY1,
              controlPointX, controlPointY2,
              endPoint.dx, endPoint.dy
            );
            
            canvas.drawPath(path, paint);
            
            // Draw fixed-color arrow at the end (avoiding opacity to prevent errors)
            final arrowSize = 7.0;
            final angle = math.atan2(endPoint.dy - controlPointY2, endPoint.dx - controlPointX);
            
            // Using solid colors without opacity for arrows
            final arrowPaint = Paint()
              ..color = edgeColor // Using the same color as the edge
              ..style = PaintingStyle.fill;
            
            final arrowPath = Path();
            arrowPath.moveTo(endPoint.dx, endPoint.dy);
            arrowPath.lineTo(
              endPoint.dx - arrowSize * math.cos(angle - math.pi / 6),
              endPoint.dy - arrowSize * math.sin(angle - math.pi / 6)
            );
            arrowPath.lineTo(
              endPoint.dx - arrowSize * math.cos(angle + math.pi / 6),
              endPoint.dy - arrowSize * math.sin(angle + math.pi / 6)
            );
            arrowPath.close();
            
            canvas.drawPath(arrowPath, arrowPaint);
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant TreePainter oldDelegate) {
    return traversalOrder != oldDelegate.traversalOrder || 
           searchedNode != oldDelegate.searchedNode ||
           isDarkMode != oldDelegate.isDarkMode;
  }
}
