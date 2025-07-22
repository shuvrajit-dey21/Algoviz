import 'package:flutter/material.dart';

class BinaryTreeVisualization extends StatelessWidget {
  const BinaryTreeVisualization({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        brightness: Brightness.light,
        useMaterial3: true,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 4,
            shadowColor: Colors.indigo.withOpacity(0.4),
          ),
        ),
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.indigo,
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: Color(0xFF1A1A1A),
        cardColor: Color(0xFF2D2D2D),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 4,
            shadowColor: Colors.indigo.withOpacity(0.4),
          ),
        ),
      ),
      home: BinaryTreeVisualizationScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class BinaryTreeVisualizationScreen extends StatefulWidget {
  const BinaryTreeVisualizationScreen({super.key});

  @override
  _BinaryTreeVisualizationScreenState createState() =>
      _BinaryTreeVisualizationScreenState();
}

class _BinaryTreeVisualizationScreenState extends State<BinaryTreeVisualizationScreen> with SingleTickerProviderStateMixin {
  final List<int> traversalOrder = [];
  final Map<int, Offset> nodePositions = {};
  bool showDFSOptions = false;
  final Map<int, List<int>> tree = {};
  final TextEditingController _parentController = TextEditingController();
  final TextEditingController _childController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  double minX = 0;
  double maxX = 0;
  double maxY = 0;
  int? searchedNode;
  List<String> processLog = []; // Store process logs
  late TabController _tabController;
  bool isTraversing = false; // Add this variable to track traversal state
  bool isDarkMode = false;

  // Add new variables for animation effects
  final Map<int, double> _nodeGlowIntensities = {};
  final Map<int, Color> _nodeColors = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    tree.addAll({
      1: [2, 3],
      2: [4, 5],
      3: [6, 7],
      4: [],
      5: [],
      6: [],
      7: [],
    });
    // Initialize node colors with a gradient
    final List<Color> colorGradient = [
      Colors.indigo[400]!,
      Colors.blue[400]!,
      Colors.cyan[400]!,
    ];
    int colorIndex = 0;
    for (int node in tree.keys) {
      _nodeColors[node] = colorGradient[colorIndex % colorGradient.length];
      colorIndex++;
    }
    addToLog('Initial tree created with 7 nodes');
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void addToLog(String message) {
    setState(() {
      processLog.insert(0, '${DateTime.now().toString().split('.')[0]} - $message');
    });
  }

  // Update reset functionality
  void _resetTraversal() {
    setState(() {
      traversalOrder.clear();
      searchedNode = null;
      isTraversing = false;
      addToLog('Reset visualization state');
    });
  }

  // Update start traversal method
  Future<void> _startTraversal(String type) async {
    if (isTraversing) {
      addToLog('Cancelled previous traversal');
      isTraversing = false;
      await Future.delayed(Duration(milliseconds: 100));
    }

    traversalOrder.clear();
    searchedNode = null;
    isTraversing = true;
    addToLog('Starting $type traversal');
    setState(() {});

    try {
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
      if (isTraversing) { // Only log completion if not reset
        addToLog('Completed $type traversal: ${traversalOrder.join(" → ")}');
      }
    } finally {
      isTraversing = false;
      setState(() {});
    }
  }

  // Update traversal methods to check isTraversing
  Future<void> _preOrderTraversal(int node) async {
    if (!isTraversing) return;
    traversalOrder.add(node);
    setState(() {});
    await Future.delayed(Duration(milliseconds: 500));
    if (!isTraversing) return;
    if (tree[node] != null && tree[node]!.isNotEmpty) {
      await _preOrderTraversal(tree[node]![0]);
      if (!isTraversing) return;
      if (tree[node]!.length > 1) {
        await _preOrderTraversal(tree[node]![1]);
      }
    }
  }

  Future<void> _inOrderTraversal(int node) async {
    if (!isTraversing) return;
    if (tree[node] != null && tree[node]!.isNotEmpty) {
      await _inOrderTraversal(tree[node]![0]);
    }
    if (!isTraversing) return;
    traversalOrder.add(node);
    setState(() {});
    await Future.delayed(Duration(milliseconds: 500));
    if (!isTraversing) return;
    if (tree[node] != null && tree[node]!.isNotEmpty && tree[node]!.length > 1) {
      await _inOrderTraversal(tree[node]![1]);
    }
  }

  Future<void> _postOrderTraversal(int node) async {
    if (!isTraversing) return;
    if (tree[node] != null && tree[node]!.isNotEmpty) {
      await _postOrderTraversal(tree[node]![0]);
      if (!isTraversing) return;
      if (tree[node]!.length > 1) {
        await _postOrderTraversal(tree[node]![1]);
      }
    }
    if (!isTraversing) return;
    traversalOrder.add(node);
    setState(() {});
    await Future.delayed(Duration(milliseconds: 500));
  }

  Future<void> _breadthFirstTraversal() async {
    final queue = [1];
    while (queue.isNotEmpty && isTraversing) {
      final node = queue.removeAt(0);
      traversalOrder.add(node);
      setState(() {});
      await Future.delayed(Duration(milliseconds: 500));
      if (!isTraversing) return;
      if (tree[node] != null && tree[node]!.isNotEmpty) {
        queue.add(tree[node]![0]);
        if (tree[node]!.length > 1) {
          queue.add(tree[node]![1]);
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

    if (tree[node] != null && tree[node]!.isNotEmpty) {
      // Calculate positions for left and right children
      _calculateNodePositions(
        tree[node]![0],
        Offset(offset.dx - horizontalGap, offset.dy + 80),
        horizontalGap / 2,
      );
      if (tree[node]!.length > 1) {
        _calculateNodePositions(
          tree[node]![1],
          Offset(offset.dx + horizontalGap, offset.dy + 80),
          horizontalGap / 2,
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
        _calculateNodePositions(1, Offset(0, 50), MediaQuery.of(context).size.width / 4);
        searchedNode = null;
        addToLog('Added node $child as child of node $parent');
      });
      _parentController.clear();
      _childController.clear();
    }
  }

  // Search for a node in the tree
  void _searchNode(int value) {
    setState(() {
      traversalOrder.clear();
      searchedNode = _searchTree(1, value);
      addToLog(searchedNode != null 
          ? 'Found node $value in the tree' 
          : 'Node $value not found in the tree');
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
      tree.clear();
      nodePositions.clear();
      traversalOrder.clear();
      minX = 0;
      maxX = 0;
      maxY = 0;
      searchedNode = null;
      addToLog('Tree cleared');
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    _calculateNodePositions(1, Offset(0, 50), screenWidth / 4);
    final requiredWidth = maxX - minX + screenWidth;
    final requiredHeight = maxY + 100;

    final isDark = isDarkMode;
    final backgroundColor = isDark ? Color(0xFF1A1A1A) : Colors.grey[100];
    final cardColor = isDark ? Color(0xFF2D2D2D) : Colors.white;
    final borderColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final textColor = isDark ? Colors.white : Colors.grey[800]!;
    final secondaryTextColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;

    return Theme(
      data: isDark ? ThemeData.dark() : ThemeData.light(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Binary Tree',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          backgroundColor: Colors.indigo[700],
          elevation: 8,
          shadowColor: Colors.black26,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(48),
            child: Container(
              color: Colors.indigo[700],
              child: TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                indicatorWeight: 3,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                labelStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                tabs: [
                  Tab(
                    icon: Icon(Icons.account_tree, size: 20),
                    text: 'Visualization',
                  ),
                  Tab(
                    icon: Icon(Icons.list_alt, size: 20),
                    text: 'Process Log',
                  ),
                ],
              ),
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                setState(() => isDarkMode = !isDarkMode);
              },
              icon: Icon(
                isDarkMode ? Icons.light_mode : Icons.dark_mode,
                color: Colors.white,
              ),
              tooltip: '${isDarkMode ? "Light" : "Dark"} Mode',
            ),
            if (isTraversing)
              IconButton(
                onPressed: _resetTraversal,
                icon: Icon(Icons.stop_circle, color: Colors.white),
                tooltip: 'Stop Traversal',
              ),
            if (!isTraversing)
              IconButton(
                onPressed: _resetTraversal,
                icon: Icon(Icons.refresh, color: Colors.white),
                tooltip: 'Reset Visualization',
              ),
            IconButton(
              onPressed: () => _showHelpDialog(context),
              icon: Icon(Icons.help_outline, color: Colors.white),
              tooltip: 'Help',
            ),
          ],
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
                      color: backgroundColor,
                      border: Border.all(color: borderColor),
                    ),
                    child: Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                          child: Container(
                            width: requiredWidth,
                            height: requiredHeight,
                            padding: EdgeInsets.all(20),
                  child: CustomPaint(
                              size: Size(requiredWidth, requiredHeight),
                    painter: TreePainter(
                      nodePositions,
                      tree,
                      traversalOrder,
                      screenWidth,
                      minX,
                      searchedNode,
                                isDark,
                    ),
                    child: Stack(
                                children: nodePositions.entries.map((entry) {
                            final node = entry.key;
                            final offset = entry.value;
                                  final isTraversed = traversalOrder.contains(node);
                                  final isSearched = searchedNode == node;
                                  
                            return Positioned(
                                    left: offset.dx - minX + (screenWidth / 2) - 30,
                                    top: offset.dy - 30,
                                    child: TweenAnimationBuilder<double>(
                                      duration: Duration(milliseconds: 300),
                                      tween: Tween(begin: 0.8, end: isTraversed ? 1.2 : 1.0),
                                      builder: (context, scale, child) {
                                        return Transform.scale(
                                          scale: scale,
                              child: Container(
                                            width: 60,
                                            height: 60,
                                decoration: BoxDecoration(
                                              gradient: RadialGradient(
                                                colors: [
                                                  isSearched
                                                      ? Colors.green[400]!
                                                      : isTraversed
                                                          ? Colors.blue[400]!
                                                          : isDark
                                                              ? _nodeColors[node]!.withOpacity(0.8)
                                                              : _nodeColors[node]!,
                                                  isSearched
                                                      ? Colors.green[700]!
                                                      : isTraversed
                                                          ? Colors.blue[700]!
                                                          : isDark
                                                              ? _nodeColors[node]!.withOpacity(0.6)
                                                              : _nodeColors[node]!.withOpacity(0.7),
                                                ],
                                                center: Alignment(0.2, -0.3),
                                              ),
                                  shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: (isSearched || isTraversed)
                                                      ? (isSearched ? Colors.green[400]! : Colors.blue[400]!).withOpacity(isDark ? 0.4 : 0.6)
                                                      : _nodeColors[node]!.withOpacity(isDark ? 0.3 : 0.4),
                                                  blurRadius: isTraversed ? 15 : 8,
                                                  spreadRadius: isTraversed ? 2 : 0,
                                                ),
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.2),
                                                  blurRadius: 4,
                                                  offset: Offset(2, 2),
                                                ),
                                              ],
                                              border: Border.all(
                                                color: Colors.white.withOpacity(isDark ? 0.6 : 0.8),
                                                width: 2,
                                              ),
                                ),
                                child: Center(
                                              child: Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  if (isTraversed || isSearched)
                                                    Container(
                                                      width: 50,
                                                      height: 50,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        gradient: RadialGradient(
                                                          colors: [
                                                            (isSearched ? Colors.green : Colors.blue)[300]!.withOpacity(isDark ? 0.3 : 0.5),
                                                            Colors.transparent,
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  Text(
                                    '$node',
                                    style: TextStyle(
                                      color: Colors.white,
                                                      fontSize: 24,
                                                      fontWeight: FontWeight.bold,
                                                      shadows: [
                                                        Shadow(
                                                          color: Colors.black38,
                                                          blurRadius: 3,
                                                          offset: Offset(1, 1),
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
                Container(
                  constraints: BoxConstraints(maxHeight: screenHeight * 0.4),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
            child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildActionButton('DFS', () {
                                setState(() => showDFSOptions = !showDFSOptions);
                              }, Icons.account_tree, isActive: showDFSOptions),
                              SizedBox(width: 8),
                              _buildActionButton('BFS', () => _startTraversal('BFS'), Icons.waves),
                              SizedBox(width: 8),
                              _buildActionButton('Clear', _clearTree, Icons.clear_all, isDanger: true),
                            ],
                          ),
                        ),
                        if (showDFSOptions)
                          AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            padding: EdgeInsets.only(top: 16),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildActionButton('Pre-order', () => _startTraversal('Pre-order'), Icons.arrow_forward),
                                  SizedBox(width: 8),
                                  _buildActionButton('In-order', () => _startTraversal('In-order'), Icons.swap_horiz),
                                  SizedBox(width: 8),
                                  _buildActionButton('Post-order', () => _startTraversal('Post-order'), Icons.arrow_back),
                                ],
                              ),
                            ),
                          ),
                        SizedBox(height: 16),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            return constraints.maxWidth > 600
                                ? Row(
                                    children: [
                                      Expanded(child: _buildTextField(_parentController, 'Parent Node')),
                                      SizedBox(width: 8),
                                      Expanded(child: _buildTextField(_childController, 'Child Node')),
                                    ],
                                  )
                                : Column(
                                    children: [
                                      _buildTextField(_parentController, 'Parent Node'),
                                      SizedBox(height: 8),
                                      _buildTextField(_childController, 'Child Node'),
                                    ],
                                  );
                          },
                        ),
                        SizedBox(height: 8),
                        _buildActionButton('Add Node', _addNode, Icons.add_circle_outline, fullWidth: true, isPrimary: true),
                        SizedBox(height: 8),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            return constraints.maxWidth > 400
                                ? Row(
              children: [
                                      Expanded(child: _buildTextField(_searchController, 'Search Node')),
                                      SizedBox(width: 8),
                                      _buildActionButton('Search', () {
                                        final value = int.tryParse(_searchController.text);
                                        if (value != null) _searchNode(value);
                                      }, Icons.search, isSuccess: true),
                                    ],
                                  )
                                : Column(
                  children: [
                                      _buildTextField(_searchController, 'Search Node'),
                                      SizedBox(height: 8),
                                      _buildActionButton('Search', () {
                                        final value = int.tryParse(_searchController.text);
                                        if (value != null) _searchNode(value);
                                      }, Icons.search, isSuccess: true, fullWidth: true),
                                    ],
                                  );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Process Log Tab
            Container(
              color: backgroundColor,
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.indigo,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.indigo.withOpacity(0.3),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                    ),
                  ],
                ),
                    child: Row(
                      children: [
                        Icon(Icons.history, color: Colors.white, size: 24),
                        SizedBox(width: 12),
                        Text(
                          'Process Log',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Spacer(),
                        IconButton(
                          onPressed: () {
                            setState(() => processLog.clear());
                          },
                          icon: Icon(Icons.clear_all, color: Colors.white),
                          tooltip: 'Clear Log',
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: processLog.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.info_outline, size: 48, color: secondaryTextColor),
                                SizedBox(height: 16),
                                Text(
                                  'No operations performed yet',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: secondaryTextColor,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.all(8),
                            itemCount: processLog.length,
                            itemBuilder: (context, index) {
                              final logEntry = processLog[index];
                              final isTraversal = logEntry.contains('traversal');
                              final isSearch = logEntry.contains('Found') || logEntry.contains('not found');
                              final isAdd = logEntry.contains('Added');
                              final isClear = logEntry.contains('cleared');
                              
                              return Container(
                                margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isTraversal
                                        ? Colors.blue[isDark ? 900 : 200]!
                                        : isSearch
                                            ? Colors.green[isDark ? 900 : 200]!
                                            : isAdd
                                                ? Colors.purple[isDark ? 900 : 200]!
                                                : isClear
                                                    ? Colors.red[isDark ? 900 : 200]!
                                                    : isDark ? Colors.grey[800]! : Colors.grey[300]!,
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: isTraversal
                                            ? Colors.blue[isDark ? 900 : 50]
                                            : isSearch
                                                ? Colors.green[isDark ? 900 : 50]
                                                : isAdd
                                                    ? Colors.purple[isDark ? 900 : 50]
                                                    : isClear
                                                        ? Colors.red[isDark ? 900 : 50]
                                                        : isDark ? Colors.grey[800] : Colors.grey[50],
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        isTraversal
                                            ? Icons.account_tree
                                            : isSearch
                                                ? Icons.search
                                                : isAdd
                                                    ? Icons.add_circle_outline
                                                    : isClear
                                                        ? Icons.clear_all
                                                        : Icons.info_outline,
                                        color: isTraversal
                                            ? Colors.blue[isDark ? 100 : 700]
                                            : isSearch
                                                ? Colors.green[isDark ? 100 : 700]
                                                : isAdd
                                                    ? Colors.purple[isDark ? 100 : 700]
                                                    : isClear
                                                        ? Colors.red[isDark ? 100 : 700]
                                                        : isDark ? Colors.grey[100] : Colors.grey[700],
                                        size: 20,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            logEntry.split(' - ')[1],
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: textColor,
                                              height: 1.4,
                                            ),
                                          ),
                                          Text(
                                            logEntry.split(' - ')[0],
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: secondaryTextColor,
                                            ),
                                          ),
                                        ],
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
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Theme(
        data: Theme.of(context).copyWith(
          dialogBackgroundColor: Colors.white,
        ),
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: [
              Icon(Icons.help_outline, color: Colors.indigo, size: 24),
              SizedBox(width: 8),
              Text(
                'Help',
                style: TextStyle(
                  color: Colors.indigo,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHelpSection(
                  'Traversal Options',
                  'DFS (Depth-First Search):\n• Pre-order: Root → Left → Right\n• In-order: Left → Root → Right\n• Post-order: Left → Right → Root\n\nBFS (Breadth-First Search):\nLevel by level traversal',
                  Icons.account_tree,
                ),
                Divider(height: 32),
                _buildHelpSection(
                  'Node Operations',
                  'Add Node:\n• Enter parent node number\n• Enter child node number\n• Click Add Node button\n\nSearch:\n• Enter node number to find\n• Click Search button',
                  Icons.edit,
                ),
                Divider(height: 32),
                _buildHelpSection(
                  'Color Guide',
                  'Blue: Currently traversed nodes\nGreen: Search result\nGrey: Unvisited nodes',
                  Icons.palette,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Close',
                style: TextStyle(
                  color: Colors.indigo,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.indigo),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.indigo),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.indigo, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        prefixIcon: Icon(Icons.input, color: Colors.indigo),
      ),
      keyboardType: TextInputType.number,
    );
  }

  Widget _buildHelpSection(String title, String content, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Colors.indigo),
            SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(
            fontSize: 14,
            height: 1.5,
            ),
          ),
        ],
    );
  }

  Widget _buildActionButton(String label, VoidCallback onPressed, IconData icon, {
    bool fullWidth = false,
    bool isPrimary = false,
    bool isDanger = false,
    bool isSuccess = false,
    bool isActive = false,
  }) {
    final baseColor = isDanger
        ? Colors.red
        : isSuccess
            ? Colors.green
            : isPrimary
                ? Colors.indigo
                : Colors.blue;

    return Tooltip(
      message: label,
      child: SizedBox(
        width: fullWidth ? double.infinity : null,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon),
          label: Text(label),
          style: ElevatedButton.styleFrom(
            backgroundColor: isActive ? baseColor : baseColor[600],
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(
              horizontal: fullWidth ? 24 : 16,
              vertical: fullWidth ? 16 : 12,
            ),
            elevation: isActive ? 8 : 4,
            shadowColor: baseColor.withOpacity(0.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }
}

// Update TreePainter for dark mode support
class TreePainter extends CustomPainter {
  final Map<int, Offset> nodePositions;
  final Map<int, List<int>> tree;
  final List<int> traversalOrder;
  final double screenWidth;
  final double minX;
  final int? searchedNode;
  final bool isDark;

  TreePainter(
    this.nodePositions,
    this.tree,
    this.traversalOrder,
    this.screenWidth,
    this.minX,
    this.searchedNode,
    this.isDark,
  );

  @override
  void paint(Canvas canvas, Size size) {
    for (final entry in tree.entries) {
      final parent = entry.key;
      final children = entry.value;

      if (nodePositions.containsKey(parent)) {
        final parentOffset = nodePositions[parent]!;

        for (final child in children) {
          if (nodePositions.containsKey(child)) {
            final childOffset = nodePositions[child]!;
            
            final isTraversedEdge = traversalOrder.contains(parent) && traversalOrder.contains(child);
            
            final path = Path();
            final startPoint = Offset(
                parentOffset.dx - minX + (screenWidth / 2),
              parentOffset.dy + 25,
            );
            final endPoint = Offset(
                childOffset.dx - minX + (screenWidth / 2),
              childOffset.dy - 25,
            );
            
            final controlPoint1 = Offset(
              startPoint.dx,
              startPoint.dy + (endPoint.dy - startPoint.dy) / 3,
            );
            final controlPoint2 = Offset(
              endPoint.dx,
              startPoint.dy + (endPoint.dy - startPoint.dy) * 2 / 3,
            );
            
            path.moveTo(startPoint.dx, startPoint.dy);
            path.cubicTo(
              controlPoint1.dx, controlPoint1.dy,
              controlPoint2.dx, controlPoint2.dy,
              endPoint.dx, endPoint.dy,
            );

            // Draw edge shadow with adjusted opacity for dark mode
            final shadowPaint = Paint()
              ..color = Colors.black.withOpacity(isDark ? 0.4 : 0.2)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 6
              ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3)
              ..strokeCap = StrokeCap.round;
            
            canvas.drawPath(path, shadowPaint);

            // Draw edge gradient with adjusted colors for dark mode
            final gradientPaint = Paint()
              ..shader = LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isTraversedEdge
                    ? [Colors.blue[400]!, Colors.blue[600]!]
                    : isDark
                        ? [Colors.grey[600]!, Colors.grey[800]!]
                        : [Colors.grey[400]!, Colors.grey[600]!],
              ).createShader(Rect.fromPoints(startPoint, endPoint))
              ..style = PaintingStyle.stroke
              ..strokeWidth = 4
              ..strokeCap = StrokeCap.round;

            canvas.drawPath(path, gradientPaint);

            // Draw glow effect for traversed edges with adjusted opacity for dark mode
            if (isTraversedEdge) {
              final glowPaint = Paint()
                ..color = Colors.blue[400]!.withOpacity(isDark ? 0.2 : 0.3)
                ..style = PaintingStyle.stroke
                ..strokeWidth = 8
                ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4)
                ..strokeCap = StrokeCap.round;
              
              canvas.drawPath(path, glowPaint);
            }
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
