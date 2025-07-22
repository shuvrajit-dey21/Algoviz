import 'dart:math';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart'; // For HeapPriorityQueue
import 'package:vector_math/vector_math_64.dart' hide Colors; // For vector transformations

class MST extends StatelessWidget {
  const MST({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Minimum Spanning Tree Visualizer',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      home: MSTScreen(),
    );
  }
}

// Union-Find (Disjoint Set Union - DSU) data structure
class UnionFind {
  Map<int, int> parent = {};
  Map<int, int> rank = {};

  void makeSet(int node) {
    parent[node] = node;
    rank[node] = 0;
  }

  int find(int node) {
    if (parent[node] != node) {
      parent[node] = find(parent[node]!); // Path compression
    }
    return parent[node]!;
  }

  void union(int node1, int node2) {
    int root1 = find(node1);
    int root2 = find(node2);

    if (root1 != root2) {
      // Union by rank
      if (rank[root1]! > rank[root2]!) {
        parent[root2] = root1;
      } else if (rank[root1]! < rank[root2]!) {
        parent[root1] = root2;
      } else {
        parent[root2] = root1;
        rank[root1] = rank[root1]! + 1;
      }
    }
  }
}

class MSTScreen extends StatefulWidget {
  const MSTScreen({super.key});

  @override
  _MSTScreenState createState() => _MSTScreenState();
}

class _MSTScreenState extends State<MSTScreen> with SingleTickerProviderStateMixin {
  // Use late initialization where possible to avoid nullable types
  late Map<int, Map<int, int>> graph = {};
  late List<MapEntry<int, int>> mstEdges = [];
  late bool isFindingMST = false;
  late final TextEditingController _nodeController = TextEditingController();
  late final TextEditingController _edgeController = TextEditingController();
  late final TextEditingController _weightController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _backgroundAnimation;
  late List<Map<String, dynamic>> animationQueue = [];
  late bool isAnimating = false;
  late String currentAlgorithm = '';
  late String currentStepDescription = '';
  late int totalWeight = 0;
  Map<String, dynamic>? currentAnimationStep;
  
  // New variables for storing execution history
  late List<Map<String, dynamic>> completedSteps = [];
  late int currentStepIndex = -1;
  late bool showStepNavigation = false;
  
  // Constants for animation timing to make code more maintainable
  static const Duration stepAnimationDuration = Duration(milliseconds: 1200);
  static const Duration intermediatePauseDuration = Duration(milliseconds: 300);
  static const Duration initialStepDuration = Duration(milliseconds: 1000);
  
  // Add field to track custom node positions and node being dragged
  Map<int, Offset> customNodePositions = {};
  int? draggedNodeId;
  
  // Add a TransformationController to track zoom and pan
  late final TransformationController _transformationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    
    _backgroundAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(_animationController);
    _transformationController = TransformationController(); // Initialize the controller
    // Use a separate method for animation listener to keep initState clean
    _setupAnimationListener();
  }
  
  void _setupAnimationListener() {
    _animationController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    // Properly dispose all controllers
    _animationController.dispose();
    _nodeController.dispose();
    _edgeController.dispose();
    _weightController.dispose();
    _transformationController.dispose(); // Dispose the transformation controller
    super.dispose();
  }

  // Optimize node addition with better validation
  void addNode() {
    final nodeText = _nodeController.text.trim();
    if (nodeText.isEmpty) {
      _showErrorSnackBar('Please enter a node ID');
      return;
    }
    
    final node = int.tryParse(nodeText);
    if (node == null) {
      _showErrorSnackBar('Node ID must be a valid number');
      return;
    }
    
    if (!graph.containsKey(node)) {
      setState(() {
        graph[node] = {};
      });
    _nodeController.clear();
    } else {
      _showErrorSnackBar('Node $node already exists');
    }
  }

  // Extract reusable snackbar method
  void _showErrorSnackBar(String message) {
      ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Optimize edge addition with better validation
  void addEdge() {
    final input = _edgeController.text.trim();
    var weightText = _weightController.text.trim();
    
    if (input.isEmpty) {
      _showErrorSnackBar('Please enter edge nodes');
      return;
    }

    // Set default weight to 1 if no weight is provided
    if (weightText.isEmpty) {
      weightText = "1";
      // Auto-fill the weight field with default value
      _weightController.text = "1";
    }
    
    final weight = int.tryParse(weightText);
    if (weight == null || weight <= 0) {
      _showErrorSnackBar('Weight must be a positive number');
      return;
    }
    
    final nodes = input.split(',');
    if (nodes.length != 2) {
      _showErrorSnackBar('Enter two nodes separated by a comma');
      return;
    }

    final node1 = int.tryParse(nodes[0].trim());
    final node2 = int.tryParse(nodes[1].trim());
    
    if (node1 == null || node2 == null) {
      _showErrorSnackBar('Node IDs must be valid numbers');
      return;
    }
    
    if (node1 == node2) {
      _showErrorSnackBar('Self-loops are not allowed');
      return;
    }

    if (!graph.containsKey(node1)) {
      _showErrorSnackBar('Node $node1 does not exist');
      return;
    }

    if (!graph.containsKey(node2)) {
      _showErrorSnackBar('Node $node2 does not exist');
      return;
    }

    setState(() {
      graph[node1]![node2] = weight;
      graph[node2]![node1] = weight; // For undirected graph
    });
    
    _edgeController.clear();
    _weightController.clear();
  }

  // Optimize Kruskal's algorithm with extracted utility methods
  Future<void> kruskal() async {
    if (!_canStartAlgorithm()) return;
    
    _initializeAlgorithm('Kruskal');

    // Get all edges sorted by weight
    final edges = _getAllEdgesSorted();

    setState(() {
      currentStepDescription = 'Sorting all edges by weight...';
    });
    await Future.delayed(initialStepDuration);

    final uf = UnionFind();
    for (int node in graph.keys) {
      uf.makeSet(node);
    }

    setState(() {
      currentStepDescription = 'Creating disjoint sets for each node...';
    });
    await Future.delayed(initialStepDuration);

    // Queue animation steps
    for (var edge in edges) {
      int node1 = edge[0];
      int node2 = edge[1];
      int weight = edge[2];

      _addConsiderationStep(node1, node2, weight);

      if (uf.find(node1) != uf.find(node2)) {
        uf.union(node1, node2);
        totalWeight += weight;
        _addEdgeToMstStep(node1, node2, weight);
      } else {
        _addRejectionStep(node1, node2, weight, 'as it would form a cycle');
      }
    }

    // Start the animation
    await _processAnimationQueue();

    _finalizeAlgorithm();
  }

  // Extracted method to get sorted edges
  List<List<int>> _getAllEdgesSorted() {
    List<List<int>> edges = [];
    for (int node in graph.keys) {
      for (int neighbor in graph[node]!.keys) {
        if (node < neighbor) { // Avoid duplicates
          edges.add([node, neighbor, graph[node]![neighbor]!]);
        }
      }
    }
    edges.sort((a, b) => a[2].compareTo(b[2]));
    return edges;
  }

  // Extract common animation step methods
  void _addConsiderationStep(int node1, int node2, int weight) {
    animationQueue.add({
      'type': 'consider',
      'edge': [node1, node2, weight],
      'description': 'Considering edge ($node1, $node2) with weight $weight',
    });
  }

  void _addEdgeToMstStep(int node1, int node2, int weight) {
    animationQueue.add({
      'type': 'add',
      'edge': [node1, node2, weight],
      'description': 'Adding edge ($node1, $node2) to MST. Total weight: $totalWeight',
      'totalWeight': totalWeight,
    });
  }

  void _addRejectionStep(int node1, int node2, int weight, String reason) {
    animationQueue.add({
      'type': 'reject',
      'edge': [node1, node2, weight],
      'description': 'Rejecting edge ($node1, $node2) $reason',
    });
  }

  void _addVisitNodeStep(int node, String description) {
    animationQueue.add({
      'type': 'visit',
      'node': node,
      'description': description,
    });
  }

  // Optimize Prim's algorithm with extracted utility methods
  Future<void> prim() async {
    if (!_canStartAlgorithm()) return;
    
    _initializeAlgorithm('Prim');
    await Future.delayed(initialStepDuration);

    var pq = HeapPriorityQueue<List<int>>((a, b) => a[2].compareTo(b[2]));
    Set<int> visited = {};

    // Start with the first node
    int startNode = graph.keys.first;
    visited.add(startNode);

    setState(() {
      currentStepDescription = 'Starting from node $startNode...';
    });
    await Future.delayed(initialStepDuration);
    
    _addVisitNodeStep(startNode, 'Visiting the starting node $startNode');

    // Add all edges from startNode to priority queue
    _addEdgesToPriorityQueue(pq, startNode, visited);

    while (pq.isNotEmpty) {
      var edge = pq.removeFirst();
      int node1 = edge[0];
      int node2 = edge[1];
      int weight = edge[2];

      if (!visited.contains(node2)) {
        visited.add(node2);
        totalWeight += weight;
        _addEdgeToMstStep(node1, node2, weight);
        _addVisitNodeStep(node2, 'Visiting node $node2 and exploring its edges');

        // Add all edges from node2 to priority queue
        _addEdgesToPriorityQueue(pq, node2, visited);
      } else {
        _addRejectionStep(node1, node2, weight, 'as node $node2 is already visited');
      }
    }

    // Start the animation
    await _processAnimationQueue();

    _finalizeAlgorithm();
  }

  // Helper method for Prim's algorithm
  void _addEdgesToPriorityQueue(HeapPriorityQueue<List<int>> pq, int node, Set<int> visited) {
    for (int neighbor in graph[node]!.keys) {
          if (!visited.contains(neighbor)) {
        pq.add([node, neighbor, graph[node]![neighbor]!]);
        _addConsiderationStep(node, neighbor, graph[node]![neighbor]!);
      }
    }
  }

  // Check if algorithm can be started
  bool _canStartAlgorithm() {
    if (graph.isEmpty) {
      _showErrorSnackBar('Please add nodes and edges to the graph first');
      return false;
    }
    
    if (isFindingMST) {
      _showErrorSnackBar('An algorithm is already running');
      return false;
    }
    
    return true;
  }

  // Initialize common algorithm state
  void _initializeAlgorithm(String algorithm) {
    setState(() {
      isFindingMST = true;
      mstEdges.clear();
      currentAlgorithm = algorithm;
      animationQueue.clear();
      totalWeight = 0;
      currentStepDescription = 'Starting $algorithm\'s Algorithm...';
    });
  }

  // Finalize common algorithm state
  void _finalizeAlgorithm() {
    setState(() {
      currentStepDescription = '$currentAlgorithm\'s Algorithm completed! Total MST weight: $totalWeight';
      isFindingMST = false;
      // Show step navigation controls after algorithm finishes
      showStepNavigation = true;
      // Make the last step visible
      if (completedSteps.isNotEmpty) {
        currentStepIndex = completedSteps.length - 1;
      }
    });
  }

  // Optimized animation processing with error handling
  Future<void> _processAnimationQueue() async {
    setState(() {
      isAnimating = true;
      // Clear previous completed steps when starting a new algorithm
      completedSteps.clear();
      currentStepIndex = -1;
    });

    try {
      for (var step in animationQueue) {
        setState(() {
          currentStepDescription = step['description'];
          currentAnimationStep = step;
        });
        
        if (step['type'] == 'add') {
          setState(() {
            mstEdges.add(MapEntry(step['edge'][0], step['edge'][1]));
          });
        }
        
        // Store each step for later review
        completedSteps.add(Map<String, dynamic>.from(step));
        currentStepIndex = completedSteps.length - 1;
        
        await Future.delayed(stepAnimationDuration);
        
        if (step['type'] == 'consider' || step['type'] == 'reject') {
          setState(() {
            currentAnimationStep = null;
          });
          await Future.delayed(intermediatePauseDuration);
        }
      }
    } catch (e) {
      _showErrorSnackBar('Error during animation: $e');
    } finally {
      setState(() {
        isAnimating = false;
        currentAnimationStep = null;
      });
    }
  }
  
  // New method to go to a specific step
  void _goToStep(int index) {
    if (index < 0 || index >= completedSteps.length) return;
    
    setState(() {
      currentStepIndex = index;
      currentStepDescription = completedSteps[index]['description'];
      
      // If this is an "add" step, we need to rebuild the MST up to this point
      if (index == 0) {
        mstEdges.clear();
      }
      
      // Update MST edges based on the current step
      _updateMSTEdgesForStep(index);
      
      // Show the current animation step
      currentAnimationStep = completedSteps[index];
    });
  }
  
  // Helper method to update MST edges for a given step index
  void _updateMSTEdgesForStep(int index) {
    // Clear existing MST edges
    mstEdges.clear();
    
    // Add all edges that should be in the MST up to this step
    for (int i = 0; i <= index; i++) {
      var step = completedSteps[i];
      if (step['type'] == 'add') {
        mstEdges.add(MapEntry(step['edge'][0], step['edge'][1]));
      }
    }
  }
  
  // New method to navigate to the next step
  void _nextStep() {
    if (currentStepIndex < completedSteps.length - 1) {
      _goToStep(currentStepIndex + 1);
    }
  }
  
  // New method to navigate to the previous step
  void _previousStep() {
    if (currentStepIndex > 0) {
      _goToStep(currentStepIndex - 1);
    }
  }

  // Reset graph with confirmation
  void resetGraph() {
    // If an algorithm is running, show a confirmation dialog
    if (isFindingMST) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Algorithm in Progress'),
          content: Text('An algorithm is currently running. Are you sure you want to reset?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _performReset();
              },
              child: Text('Reset'),
            ),
          ],
        ),
      );
    } else {
      _performReset();
    }
  }
  
  void _performReset() {
    setState(() {
      graph.clear();
      mstEdges.clear();
      currentAlgorithm = '';
      currentStepDescription = '';
      currentAnimationStep = null;
      animationQueue.clear();
      completedSteps.clear();
      currentStepIndex = -1;
      showStepNavigation = false;
      isAnimating = false;
      isFindingMST = false;
      totalWeight = 0;
      customNodePositions.clear(); // Clear custom positions when resetting
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Minimum Spanning Tree Visualizer',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF5E4B3E),
            fontSize: 20,
          ),
        ),
        backgroundColor: Color(0xFFF8F3E6).withOpacity(0.95),
        elevation: 2,
        shadowColor: Color(0xFF8D7B68).withOpacity(0.3),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Color(0xFF8D7B68)),
            onPressed: resetGraph,
            tooltip: 'Reset Graph',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Animated creamy background
          AnimatedBuilder(
            animation: _backgroundAnimation,
            builder: (context, child) {
              return CustomPaint(
                size: Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height),
                painter: BackgroundPainter(_backgroundAnimation.value),
              );
            },
          ),
          
          _buildGraphVisualizerWithCollapsiblePanel(isSmallScreen),
        ],
      ),
      floatingActionButton: isSmallScreen ? FloatingActionButton(
        onPressed: _togglePanel,
        backgroundColor: Color(0xFF8D7B68),
        child: Icon(
          _isPanelExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
          color: Colors.white,
        ),
        tooltip: _isPanelExpanded ? 'Collapse input panel' : 'Expand input panel',
      ) : null,
    );
  }
  
  // State for panel expansion
  bool _isPanelExpanded = false;
  
  void _togglePanel() {
    setState(() {
      _isPanelExpanded = !_isPanelExpanded;
    });
  }
  
  Widget _buildGraphVisualizerWithCollapsiblePanel(bool isSmallScreen) {
    return SafeArea(
            child: Column(
              children: [
                // Step description card with navigation controls
                Container(
                  margin: EdgeInsets.fromLTRB(16, 16, 16, 8),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF8D7B68).withOpacity(0.2),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                    border: Border.all(color: Color(0xFFDBC8AF), width: 1),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            _getStepIcon(),
                            color: _getStepColor(),
                            size: 24,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: AnimatedSwitcher(
                              duration: Duration(milliseconds: 300),
                              child: Text(
                                currentStepDescription,
                                key: ValueKey(currentStepDescription),
                                style: TextStyle(
                                  color: Color(0xFF5E4B3E),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      // Show navigation controls only after algorithm completion
                      if (showStepNavigation && completedSteps.isNotEmpty) ...[
                        SizedBox(height: 12),
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          decoration: BoxDecoration(
                            color: Color(0xFFE6D7C3).withOpacity(0.8),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Color(0xFFDBC8AF), width: 1),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: Icon(Icons.skip_previous),
                                onPressed: currentStepIndex > 0 ? _previousStep : null,
                                tooltip: 'Previous Step',
                                color: currentStepIndex > 0 ? Color(0xFF8D7B68) : Color(0xFFBFB0A0),
                              ),
                              Text(
                                'Step ${currentStepIndex + 1}/${completedSteps.length}',
                                style: TextStyle(
                                  color: Color(0xFF5E4B3E), 
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.skip_next),
                                onPressed: currentStepIndex < completedSteps.length - 1 ? _nextStep : null,
                                tooltip: 'Next Step',
                                color: currentStepIndex < completedSteps.length - 1 ? Color(0xFF8D7B68) : Color(0xFFBFB0A0),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Graph visualization (takes most of the screen)
                Expanded(
                  flex: 5,
            child: Stack(
              children: [
                // First, update the InteractiveViewer setup to properly handle the drag transformations
                // InteractiveViewer for zoom and pan functionality
                InteractiveViewer(
                  boundaryMargin: EdgeInsets.zero,
                  minScale: 0.5,
                  maxScale: 2.0,
                  transformationController: _transformationController,
                  constrained: true,
                  panEnabled: false, // Disable panning to fix the view
                  scaleEnabled: true, // Keep zoom functionality
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return _buildDraggableGraph(
                        isSmallScreen, 
                        Size(constraints.maxWidth, constraints.maxHeight)
                      );
                    },
                  ),
                ),
                
                // Zoom controls overlay
                Positioned(
                  bottom: isSmallScreen ? 16 : 24,
                  left: isSmallScreen ? 16 : 24,
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Zoom:',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 11 : 13,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF5E4B3E),
                              ),
                            ),
                            SizedBox(width: 4),
                            Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Color(0xFF8D7B68).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  _buildZoomButton(
                                    Icons.zoom_out,
                                    'Pinch to zoom out',
                                    isSmallScreen,
                                  ),
                                  SizedBox(width: 2),
                                  _buildZoomButton(
                                    Icons.zoom_in,
                                    'Pinch to zoom in',
                                    isSmallScreen,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        // New reset positions button
                        if (customNodePositions.isNotEmpty)
                          TextButton.icon(
                            onPressed: _resetNodePositions,
                            icon: Icon(Icons.refresh, size: 14, color: Color(0xFF5E4B3E)),
                            label: Text(
                              'Reset Positions',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 11 : 12,
                                color: Color(0xFF5E4B3E),
                              ),
                            ),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              backgroundColor: Color(0xFFE6D7C3).withOpacity(0.8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                
                // Graph info overlay (only shown when algorithm is running)
                if (isFindingMST && currentStepDescription.isNotEmpty)
                  Positioned(
                    top: isSmallScreen ? 16 : 32,
                    right: isSmallScreen ? 16 : 32, 
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 8 : 12, 
                        vertical: isSmallScreen ? 6 : 8
                      ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 12),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black26,
                            blurRadius: isSmallScreen ? 3 : 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                        border: Border.all(
                          color: _getStepColor().withOpacity(0.7), 
                          width: isSmallScreen ? 1.5 : 2
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_getStepIcon(), 
                            size: isSmallScreen ? 16 : 18, 
                            color: _getStepColor()
                          ),
                          SizedBox(width: 6),
                          Text(
                            totalWeight > 0 ? 'Weight: $totalWeight' : '',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF5E4B3E),
                              fontSize: isSmallScreen ? 12 : 14,
                            ),
                          ),
                        ],
                    ),
                  ),
                ),
                
                // Zoom instructions for users (not needed on small screens)
                if (!isSmallScreen && graph.isNotEmpty && !isFindingMST) 
                  Positioned(
                    bottom: 80,
                    right: 30,
                    child: AnimatedOpacity(
                      opacity: 0.7,
                      duration: Duration(milliseconds: 500),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Color(0xFF8D7B68).withOpacity(0.7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.touch_app, color: Colors.white, size: 16),
                            SizedBox(width: 6),
                            Text(
                              'Pinch & drag to interact',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // Collapsible input panel for small screens
          if (!isSmallScreen || _isPanelExpanded)
            _buildInputControlPanel(isSmallScreen),
        ],
      ),
    );
  }
  
  // Helper method to build zoom button
  Widget _buildZoomButton(IconData icon, String tooltip, bool isSmallScreen) {
    return Tooltip(
      message: tooltip,
      child: Container(
        padding: EdgeInsets.all(isSmallScreen ? 4 : 6),
        decoration: BoxDecoration(
          color: Color(0xFF8D7B68).withOpacity(0.2),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          size: isSmallScreen ? 16 : 20,
          color: Color(0xFF5E4B3E),
        ),
      ),
    );
  }
  
  Widget _buildInputControlPanel(bool isSmallScreen) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: isSmallScreen ? 250 : null,
                  margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF8D7B68).withOpacity(0.2),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: Color(0xFFDBC8AF), width: 1),
                  ),
      child: isSmallScreen 
          ? _buildScrollablePanel() 
          : _buildRegularPanel(isSmallScreen),
    );
  }
  
  Widget _buildScrollablePanel() {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
                  child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle indicator for draggable sheet
          Container(
            margin: EdgeInsets.only(bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Color(0xFF8D7B68).withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Fixed-height input fields
          _buildInputControls(true),
          
          SizedBox(height: 12),
          
          // Compact algorithm buttons
          _buildCompactAlgorithmButtons(true),
          
          // Legend (only show when an algorithm is running or completed)
          if (currentAlgorithm.isNotEmpty) ...[
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
              decoration: BoxDecoration(
                color: Color(0xFFE6D7C3).withOpacity(0.8),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Color(0xFFDBC8AF), width: 1),
              ),
              child: _buildLegendColumnLayout(),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildRegularPanel(bool isSmallScreen) {
    return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Fixed-height input fields
                      _buildInputControls(isSmallScreen),
                      
                      SizedBox(height: 12),
                      
                      // Compact algorithm buttons
                      _buildCompactAlgorithmButtons(isSmallScreen),
                      
                      // Legend (only show when an algorithm is running or completed)
                      if (currentAlgorithm.isNotEmpty) ...[
                        SizedBox(height: 8),
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                          decoration: BoxDecoration(
                            color: Color(0xFFE6D7C3).withOpacity(0.8),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Color(0xFFDBC8AF), width: 1),
                          ),
                          child: isSmallScreen
                              ? _buildLegendColumnLayout()
                              : _buildLegendRowLayout(),
                        ),
                      ],
                    ],
    );
  }
  
  // New method for fixed-height input controls
  Widget _buildInputControls(bool isSmallScreen) {
    return SizedBox(
      height: isSmallScreen ? 210 : 80, // Reduced height for more compact appearance
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: title for the input section
          Row(
            children: [
              Icon(Icons.edit, color: Color(0xFF5E4B3E), size: 16),
              SizedBox(width: 4),
              Text(
                'Graph Inputs',
                style: TextStyle(
                  color: Color(0xFF5E4B3E),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          SizedBox(height: 6), // Smaller spacing
          
          // Input fields in a more compact layout
          Expanded(
            child: isSmallScreen
                ? _buildCompactInputsColumn()
                : _buildCompactInputsRow(),
          ),
        ],
      ),
    );
  }
  
  // New compact row layout for inputs with separated fields
  Widget _buildCompactInputsRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Node input
        Expanded(
          flex: 3,
          child: Container(
            height: 60, // Fixed compact height
            decoration: BoxDecoration(
              color: Color(0xFFF8F3E6),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Color(0xFFDBC8AF), width: 1),
            ),
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: TextField(
                    controller: _nodeController,
                    decoration: InputDecoration(
                      labelText: 'Node ID',
                      labelStyle: TextStyle(color: Color(0xFF8D7B68), fontSize: 13, fontWeight: FontWeight.w500),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 6),
                    ),
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: Color(0xFF5E4B3E), fontWeight: FontWeight.bold),
                  ),
                ),
                _CompactButton(
                  onPressed: isFindingMST ? null : addNode,
                  label: 'Add',
                  icon: Icons.add_circle,
                  color: Color(0xFF8D7B68),
                ),
              ],
            ),
          ),
        ),
        
        SizedBox(width: 8),
        
        // Edge input (separated from weight)
        Expanded(
          flex: 3,
          child: Container(
            height: 60, // Fixed compact height
            decoration: BoxDecoration(
              color: Color(0xFFF8F3E6),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Color(0xFFDBC8AF), width: 1),
            ),
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: TextField(
              controller: _edgeController,
              decoration: InputDecoration(
                labelText: 'Edge (node1,node2)',
                labelStyle: TextStyle(color: Color(0xFF8D7B68), fontSize: 13, fontWeight: FontWeight.w500),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 6),
              ),
              style: TextStyle(color: Color(0xFF5E4B3E), fontWeight: FontWeight.bold),
            ),
          ),
        ),
        
        SizedBox(width: 8),
        
        // Weight input with default hint
        Expanded(
          flex: 2,
          child: Container(
            height: 60, // Fixed compact height
            decoration: BoxDecoration(
              color: Color(0xFFF8F3E6),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Color(0xFFDBC8AF), width: 1),
            ),
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _weightController,
                    decoration: InputDecoration(
                      labelText: 'Weight',
                      hintText: 'Default: 1',
                      hintStyle: TextStyle(color: Color(0xFFC1B39E), fontSize: 11),
                      labelStyle: TextStyle(color: Color(0xFF8D7B68), fontSize: 13, fontWeight: FontWeight.w500),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 6),
                    ),
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: Color(0xFF5E4B3E), fontWeight: FontWeight.bold),
                  ),
                ),
                _CompactButton(
                  onPressed: isFindingMST ? null : addEdge,
                  label: 'Add',
                  icon: Icons.linear_scale,
                  color: Color(0xFFE6945F),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  // New compact column layout for inputs on small screens with separated fields
  Widget _buildCompactInputsColumn() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Node input in a row with smaller sizing
        Container(
          height: 50, // Fixed compact height
          decoration: BoxDecoration(
            color: Color(0xFFF8F3E6),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Color(0xFFDBC8AF), width: 1),
          ),
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: TextField(
                  controller: _nodeController,
                  decoration: InputDecoration(
                    labelText: 'Node ID',
                    labelStyle: TextStyle(color: Color(0xFF8D7B68), fontSize: 13, fontWeight: FontWeight.w500),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 6),
                  ),
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: Color(0xFF5E4B3E), fontWeight: FontWeight.bold),
                ),
              ),
              _CompactButton(
                onPressed: isFindingMST ? null : addNode,
                label: 'Add',
                icon: Icons.add_circle,
                color: Color(0xFF8D7B68),
              ),
            ],
          ),
        ),
        
        SizedBox(height: 8),
        
        // Edge input field (more compact)
        Container(
          height: 50, // Fixed compact height
          decoration: BoxDecoration(
            color: Color(0xFFF8F3E6),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Color(0xFFDBC8AF), width: 1),
          ),
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: TextField(
            controller: _edgeController,
            decoration: InputDecoration(
              labelText: 'Edge (node1,node2)',
              labelStyle: TextStyle(color: Color(0xFF8D7B68), fontSize: 13, fontWeight: FontWeight.w500),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 6),
            ),
            style: TextStyle(color: Color(0xFF5E4B3E), fontWeight: FontWeight.bold),
          ),
        ),
        
        SizedBox(height: 8),
        
        // Weight field (more compact)
        Container(
          height: 50, // Fixed compact height
          decoration: BoxDecoration(
            color: Color(0xFFF8F3E6),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Color(0xFFDBC8AF), width: 1),
          ),
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: TextField(
                  controller: _weightController,
                  decoration: InputDecoration(
                    labelText: 'Weight',
                    hintText: 'Default: 1',
                    hintStyle: TextStyle(color: Color(0xFFC1B39E), fontSize: 11),
                    labelStyle: TextStyle(color: Color(0xFF8D7B68), fontSize: 13, fontWeight: FontWeight.w500),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 6),
                  ),
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: Color(0xFF5E4B3E), fontWeight: FontWeight.bold),
                ),
              ),
              _CompactButton(
                onPressed: isFindingMST ? null : addEdge,
                label: 'Add',
                icon: Icons.linear_scale,
                color: Color(0xFFE6945F),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  // New compact algorithm buttons
  Widget _buildCompactAlgorithmButtons(bool isSmallScreen) {
    if (isSmallScreen) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.play_circle_outline, color: Color(0xFF8D7B68), size: 16),
              SizedBox(width: 4),
              Text(
                'Run Algorithm',
                style: TextStyle(
                  color: Color(0xFF5E4B3E),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _AlgorithmButton(
                  onPressed: isFindingMST || graph.isEmpty ? null : kruskal,
                  label: "Kruskal's",
                  color: Color(0xFF70A288), // Soft green
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _AlgorithmButton(
                  onPressed: isFindingMST || graph.isEmpty ? null : prim,
                  label: "Prim's",
                  color: Color(0xFF8D7B68), // Soft brown
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Icon(Icons.play_circle_outline, color: Color(0xFF8D7B68), size: 16),
          SizedBox(width: 8),
          Text(
            'Run:',
            style: TextStyle(
              color: Color(0xFF5E4B3E),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: _AlgorithmButton(
              onPressed: isFindingMST || graph.isEmpty ? null : kruskal,
              label: "Kruskal's Algorithm",
              color: Color(0xFF70A288), // Soft green
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _AlgorithmButton(
              onPressed: isFindingMST || graph.isEmpty ? null : prim,
              label: "Prim's Algorithm",
              color: Color(0xFF8D7B68), // Soft brown
            ),
          ),
        ],
      );
    }
  }
  
  // Responsive layouts for legend
  Widget _buildLegendRowLayout() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _LegendItem(
          color: Color(0xFFEFC050), // Warm yellow
          label: 'Considering',
        ),
        _LegendItem(
          color: Color(0xFF70A288), // Soft green
          label: 'Added to MST',
        ),
        _LegendItem(
          color: Color(0xFFBD4B4B), // Soft red
          label: 'Rejected',
        ),
        _LegendItem(
          color: Color(0xFFE6945F), // Soft orange
          label: 'Visited Node',
        ),
      ],
    );
  }
  
  Widget _buildLegendColumnLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _LegendItem(
                color: Color(0xFFEFC050), // Warm yellow
                label: 'Considering',
              ),
            ),
            Expanded(
              child: _LegendItem(
                color: Color(0xFF70A288), // Soft green
                label: 'Added to MST',
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: _LegendItem(
                color: Color(0xFFBD4B4B), // Soft red
                label: 'Rejected',
              ),
            ),
            Expanded(
              child: _LegendItem(
                color: Color(0xFFE6945F), // Soft orange
                label: 'Visited Node',
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  IconData _getStepIcon() {
    if (currentAnimationStep == null) {
      return Icons.info_outline;
    }
    
    switch (currentAnimationStep!['type']) {
      case 'consider':
        return Icons.search;
      case 'add':
        return Icons.check_circle_outline;
      case 'reject':
        return Icons.cancel_outlined;
      case 'visit':
        return Icons.location_on_outlined;
      default:
        return Icons.info_outline;
    }
  }
  
  Color _getStepColor() {
    if (currentAnimationStep == null) {
      return Color(0xFF5E4B3E);
    }
    
    switch (currentAnimationStep!['type']) {
      case 'consider':
        return Color(0xFFEFC050); // Warm yellow
      case 'add':
        return Color(0xFF70A288); // Soft green
      case 'reject':
        return Color(0xFFBD4B4B); // Soft red
      case 'visit':
        return Color(0xFFE6945F); // Soft orange
      default:
        return Color(0xFF5E4B3E);
    }
  }
  
  // Add method to handle node dragging
  void _handleNodeDrag(int nodeId, Offset dragOffset, Size boardSize) {
    // Make sure the node stays within the visible board area
    final nodeRadius = 20.0; // Approximate radius to ensure nodes stay in view
    final constrainedOffset = Offset(
      dragOffset.dx.clamp(nodeRadius, boardSize.width - nodeRadius),
      dragOffset.dy.clamp(nodeRadius, boardSize.height - nodeRadius),
    );
    
    setState(() {
      customNodePositions[nodeId] = constrainedOffset;
    });
  }
  
  // Add method to detect which node was tapped
  int? _findTappedNode(Offset tapPosition, Map<int, Offset> nodePositions, double nodeRadius) {
    for (var entry in nodePositions.entries) {
      final distance = (entry.value - tapPosition).distance;
      if (distance <= nodeRadius * 1.5) { // A bit larger hit area for easier selection
        return entry.key;
      }
    }
    return null;
  }
  
  // Add reset of custom positions to the overall reset
  void _resetNodePositions() {
    setState(() {
      customNodePositions.clear();
    });
  }

  // Create a new method to build the draggable graph with proper coordinate handling
  Widget _buildDraggableGraph(bool isSmallScreen, Size viewportSize) {
    return GestureDetector(
      // Handle long press and drag for node movement
      onLongPressMoveUpdate: (details) {
        if (draggedNodeId != null) {
          // Convert the local position to the container's coordinate space
          final Matrix4 matrix = _transformationController.value.clone();
          // Invert the transformation to get coordinates in the original space
          final Matrix4 inverseMatrix = Matrix4.inverted(matrix);
          final Vector3 untransformedPoint = inverseMatrix.transform3(
            Vector3(details.localPosition.dx, details.localPosition.dy, 0)
          );
          
          // Update node position with transformed coordinates
          _handleNodeDrag(
            draggedNodeId!, 
            Offset(untransformedPoint.x, untransformedPoint.y),
            viewportSize
          );
        }
      },
      onLongPressStart: (details) {
        // Convert the tap position using the inverse transformation
        final Matrix4 matrix = _transformationController.value.clone();
        final Matrix4 inverseMatrix = Matrix4.inverted(matrix);
        final Vector3 untransformedPoint = inverseMatrix.transform3(
          Vector3(details.localPosition.dx, details.localPosition.dy, 0)
        );
        final untransformedOffset = Offset(untransformedPoint.x, untransformedPoint.y);
        
        // Find which node was tapped using the untransformed coordinates
        final graphPainter = GraphPainter(
          graph: graph,
          mstEdges: mstEdges,
          currentAnimationStep: currentAnimationStep,
          spacing: isSmallScreen ? 1.1 : 1.2,
          isSmallScreen: isSmallScreen,
          customNodePositions: customNodePositions,
        );
        
        final nodePositions = graphPainter._calculateNodePositions(
          viewportSize,
          isSmallScreen ? 12.0 : 20.0
        );
        
        // Find the tapped node using untransformed coordinates
        final tappedNode = _findTappedNode(
          untransformedOffset,
          nodePositions,
          isSmallScreen ? 12.0 : 20.0
        );
        
        // If a node was tapped, start dragging it
        if (tappedNode != null) {
          setState(() {
            draggedNodeId = tappedNode;
          });
          // Show a feedback message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Dragging node $tappedNode - move to reposition'),
              backgroundColor: Color(0xFF8D7B68),
              duration: Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      onLongPressEnd: (_) {
        setState(() {
          draggedNodeId = null;
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        margin: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 8 : 16,
          vertical: isSmallScreen ? 8 : 16,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF8D7B68).withOpacity(isSmallScreen ? 0.2 : 0.3),
              blurRadius: isSmallScreen ? 10 : 15,
              offset: Offset(0, isSmallScreen ? 3 : 5),
              spreadRadius: isSmallScreen ? 0 : 1,
            ),
          ],
          border: Border.all(color: Color(0xFFDBC8AF), width: isSmallScreen ? 1 : 1.5),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.95),
              Color(0xFFF8F3E6).withOpacity(0.9),
            ],
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
          child: Stack(
            children: [
              // Skip grid pattern on small screens for better performance
              if (!isSmallScreen) CustomPaint(
                size: Size.infinite,
                painter: GridPatternPainter(),
              ),
              // Main graph visualization with optimized performance for mobile
              CustomPaint(
                size: Size.infinite,
                painter: GraphPainter(
                  graph: graph,
                  mstEdges: mstEdges,
                  currentAnimationStep: currentAnimationStep,
                  spacing: isSmallScreen ? 1.1 : 1.2, // Tighter spacing on mobile
                  isSmallScreen: isSmallScreen, // Pass screen size info
                  customNodePositions: customNodePositions, // Pass custom positions
                ),
              ),
              // Dragging indicator text
              if (draggedNodeId != null)
                Positioned(
                  top: 16,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Dragging Node $draggedNodeId',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
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
}

// New simple compact button for input fields
class _CompactButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String label;
  final IconData icon;
  final Color color;

  const _CompactButton({
    super.key,
    required this.onPressed,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  _CompactButtonState createState() => _CompactButtonState();
}

class _CompactButtonState extends State<_CompactButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: isDisabled 
                ? Color(0xFFBFB0A0).withOpacity(0.3) 
                : (_isHovered ? widget.color : widget.color.withOpacity(0.8)),
            borderRadius: BorderRadius.circular(8),
            boxShadow: _isHovered && !isDisabled ? [
              BoxShadow(
                color: widget.color.withOpacity(0.4),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ] : [],
            border: Border.all(
              color: isDisabled ? Colors.transparent : Colors.white.withOpacity(0.4),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                color: Colors.white,
                size: 16,
              ),
              SizedBox(width: 4),
              Text(
                widget.label,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      offset: Offset(0, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// New algorithm button with animated background
class _AlgorithmButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String label;
  final Color color;

  const _AlgorithmButton({
    super.key,
    required this.onPressed,
    required this.label,
    required this.color,
  });

  @override
  _AlgorithmButtonState createState() => _AlgorithmButtonState();
}

class _AlgorithmButtonState extends State<_AlgorithmButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Container(
              height: 45,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDisabled
                      ? [Color(0xFFBFB0A0), Color(0xFFBFB0A0).withOpacity(0.8)]
                      : [
                          widget.color,
                          Color.lerp(
                            widget.color,
                            widget.color.withOpacity(0.7),
                            _pulseAnimation.value,
                          )!,
                        ],
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: isDisabled || !_isHovered ? [] : [
                  BoxShadow(
                    color: widget.color.withOpacity(0.4),
                    blurRadius: 8,
                    spreadRadius: 1,
                    offset: Offset(0, 3),
                  ),
                ],
                border: Border.all(
                  color: isDisabled 
                      ? Colors.transparent 
                      : Colors.white.withOpacity(_isHovered ? 0.4 : 0.3),
                  width: 1,
                ),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 18,
                    ),
                    SizedBox(width: 6),
                    Text(
                      widget.label,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        letterSpacing: 0.5,
                        shadows: [
                          Shadow(
                            color: Colors.black38,
                            offset: Offset(0, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class BackgroundPainter extends CustomPainter {
  final double animationValue;
  
  BackgroundPainter(this.animationValue);
  
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    
    // Create a softer, creamier gradient that gently animates - with more subtle animation
    final gradient = LinearGradient(
      begin: Alignment(
        cos(animationValue * 0.3) * 0.2, 
        sin(animationValue * 0.3) * 0.2,
      ),
      end: Alignment(
        -cos(animationValue * 0.3) * 0.2, 
        -sin(animationValue * 0.3) * 0.2,
      ),
      colors: const [
        Color(0xFFF8F3E6), // Light creamy color
        Color(0xFFF0E6D8), // Soft beige
        Color(0xFFE6D7C3), // Warm cream
        Color(0xFFDBC8AF), // Soft tan
      ],
      stops: const [0.0, 0.3, 0.6, 1.0],
    );
    
    final paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);
    
    // Draw even more subtle geometric patterns
    final patternPaint = Paint()
      ..color = Color(0xFF8D7B68).withOpacity(0.03)
      ..style = PaintingStyle.fill;
    
    // Fewer, more subtle patterns
    final patternCount = (size.width / 250).ceil().clamp(3, 5);
    for (int i = 0; i < patternCount; i++) {
      double x = size.width * (0.2 + 0.6 * i / patternCount + 0.015 * sin(animationValue * 0.5 + i));
      double y = size.height * (0.2 + 0.6 * i / patternCount + 0.015 * cos(animationValue * 0.5 + i));
      double radius = size.width * 0.04 * (1 + 0.08 * sin(animationValue * 0.8 + i));
      
      // Draw subtle circles
      canvas.drawCircle(Offset(x, y), radius, patternPaint);
      
      // Draw gentle curves with even less opacity
      if (i % 2 == 0) {
        final path = Path();
        path.moveTo(0, size.height * (0.3 + 0.08 * sin(animationValue * 0.3 + i * 0.7)));
        
        for (int j = 0; j <= 10; j++) {
          final dx = size.width * j / 10;
          final phase = animationValue * 0.3 + j * 0.2 + i;
          final dy = size.height * (0.3 + 0.04 * sin(phase));
          path.lineTo(dx, dy);
        }
        
        final wavePaint = Paint()
          ..color = Color(0xFF8D7B68).withOpacity(0.015)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;
        
        canvas.drawPath(path, wavePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant BackgroundPainter oldDelegate) => 
      oldDelegate.animationValue != animationValue;
}

class GridPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color(0xFF8D7B68).withOpacity(0.04)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;
    
    // Draw a subtle grid pattern
    final gridSpacing = 20.0;
    for (double x = 0; x <= size.width; x += gridSpacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    
    for (double y = 0; y <= size.height; y += gridSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    
    // Add some decorative elements
    final decorPaint = Paint()
      ..color = Color(0xFF8D7B68).withOpacity(0.02)
      ..style = PaintingStyle.fill;
      
    // Draw subtle decorative circles
    canvas.drawCircle(Offset(size.width * 0.15, size.height * 0.15), 40, decorPaint);
    canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.85), 55, decorPaint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class GraphPainter extends CustomPainter {
  final Map<int, Map<int, int>> graph;
  final List<MapEntry<int, int>> mstEdges;
  final Map<String, dynamic>? currentAnimationStep;
  final double spacing; // Spacing factor
  final bool isSmallScreen; // Add screen size info
  final Map<int, Offset> customNodePositions; // Track custom positions from user drag

  GraphPainter({
    required this.graph, 
    required this.mstEdges,
    this.currentAnimationStep,
    this.spacing = 1.0,
    this.isSmallScreen = false, // Default to larger screen
    this.customNodePositions = const {}, // Empty by default
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (graph.isEmpty) return;
    
    // Optimize node size for different screen sizes and node counts
    final nodeCount = graph.keys.length;
    final nodeRadius = isSmallScreen 
        ? (nodeCount > 8 ? 10.0 : nodeCount > 5 ? 12.0 : 14.0) // More gradual sizing for mobile
        : (nodeCount > 12 ? 18.0 : 22.0); // Slightly smaller on desktop with many nodes
    
    final nodePositions = _calculateNodePositions(size, nodeRadius);

    // Draw elements in correct order
    _drawAllEdges(canvas, nodePositions, isSmallScreen);
    _drawMSTEdges(canvas, nodePositions);
    _drawAnimationStep(canvas, nodePositions, nodeRadius);
    _drawAllNodes(canvas, nodePositions, nodeRadius, isSmallScreen);
  }
  
  // Modified to use custom positions when available
  Map<int, Offset> _calculateNodePositions(Size size, double nodeRadius) {
    final nodePositions = <int, Offset>{};
    final nodeCount = graph.keys.length;
    if (nodeCount == 0) return nodePositions;
    
    final center = Offset(size.width / 2, size.height / 2);
    
    // First calculate default positions
    if (isSmallScreen) {
      // For mobile, use more optimized layouts
      if (nodeCount <= 3) {
        // Very few nodes - simple line or triangle
        _calculateSimpleCircularLayout(nodePositions, nodeCount, center, size, nodeRadius);
      } 
      else if (nodeCount <= 6) {
        // Medium number - optimized circular layout with smaller radius
        _calculateOptimizedCircularLayout(nodePositions, nodeCount, center, size, nodeRadius);
      }
      else {
        // Many nodes - use compact grid layout
        _calculateGridLayout(nodePositions, nodeCount, center, size, nodeRadius);
      }
    } else {
      if (nodeCount <= 12) {
        // On larger screens with fewer nodes, circular layout works well
        final baseRadius = min(size.width, size.height) * 0.35 * spacing;
        final angleStep = (2 * pi) / nodeCount;
        _calculateCircularLayout(nodePositions, nodeCount, center, baseRadius, angleStep);
      } else {
        // For many nodes even on large screens, use grid layout
        _calculateSpacedGridLayout(nodePositions, nodeCount, center, size, nodeRadius);
      }
    }

    // Then override with custom positions when available
    for (var nodeId in customNodePositions.keys) {
      if (graph.containsKey(nodeId)) {
        nodePositions[nodeId] = customNodePositions[nodeId]!;
      }
    }

    return nodePositions;
  }

  // Optimize simple layout for very small screens or few nodes
  void _calculateSimpleCircularLayout(
    Map<int, Offset> nodePositions, 
    int nodeCount, 
    Offset center,
    Size size,
    double nodeRadius
  ) {
    // Use even smaller radius on mobile
    final radius = min(size.width, size.height) * 0.22 * spacing;
    final angleStep = (2 * pi) / max(nodeCount, 3); // At least 3 positions for stability
    
    int index = 0;
    for (int node in graph.keys) {
      final angle = angleStep * index;
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);
      nodePositions[node] = Offset(x, y);
      index++;
    }
  }
  
  // More compact layout for small screens
  void _calculateOptimizedCircularLayout(
    Map<int, Offset> nodePositions, 
    int nodeCount, 
    Offset center,
    Size size,
    double nodeRadius
  ) {
    // Use smaller radius on mobile
    final radius = min(size.width, size.height) * 0.25 * spacing;
    final angleStep = (2 * pi) / nodeCount;
    
    int index = 0;
    for (int node in graph.keys) {
      // Add slight variation to radius to avoid perfect circle
      final nodeRadius = radius * (0.9 + 0.2 * (index % 3) / 3);
      
      final angle = angleStep * index;
      final x = center.dx + nodeRadius * cos(angle);
      final y = center.dy + nodeRadius * sin(angle);
      nodePositions[node] = Offset(x, y);
      index++;
    }
  }
  
  // New optimized grid layout for many nodes on larger screens
  void _calculateSpacedGridLayout(
    Map<int, Offset> nodePositions, 
    int nodeCount, 
    Offset center,
    Size size,
    double nodeRadius
  ) {
    // Use more screen space on larger displays
    final effectiveWidth = size.width * 0.9;
    final effectiveHeight = size.height * 0.85;
    
    // Calculate optimal number of columns
    final optimalColumns = sqrt(nodeCount).ceil();
    
    // Ensure we have enough rows and columns
    final columns = max(optimalColumns, 3);
    final rows = (nodeCount / columns).ceil();
    
    // Calculate spacing between nodes
    final horizontalSpacing = effectiveWidth / columns;
    final verticalSpacing = effectiveHeight / rows;
    
    // Starting position (top-left corner of our layout grid)
    final startX = center.dx - (horizontalSpacing * (columns - 1) / 2);
    final startY = center.dy - (verticalSpacing * (rows - 1) / 2);
    
    // Add nodes with a small random offset to avoid perfect alignment
    final random = Random(42); // Fixed seed for consistent layout
    int index = 0;
    
    for (int node in graph.keys) {
      final row = index ~/ columns;
      final col = index % columns;
      
      // Small random offset for more natural layout
      final offsetX = (random.nextDouble() - 0.5) * horizontalSpacing * 0.2;
      final offsetY = (random.nextDouble() - 0.5) * verticalSpacing * 0.2;
      
      final x = startX + col * horizontalSpacing + offsetX;
      final y = startY + row * verticalSpacing + offsetY;
      
      nodePositions[node] = Offset(x, y);
      index++;
    }
  }
  
  // Original circular layout (kept for larger screens)
  void _calculateCircularLayout(
    Map<int, Offset> nodePositions, 
    int nodeCount, 
    Offset center,
    double radius, 
    double angleStep
  ) {
    int index = 0;
    for (int node in graph.keys) {
      final angle = angleStep * index;
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);
      nodePositions[node] = Offset(x, y);
      index++;
    }
  }
  
  // Grid layout for mobile screens with many nodes
  void _calculateGridLayout(
    Map<int, Offset> nodePositions, 
    int nodeCount, 
    Offset center,
    Size size,
    double nodeRadius
  ) {
    // More compact grid for mobile
    final effectiveWidth = size.width * 0.8;
    final effectiveHeight = size.height * 0.7;
    
    // Determine grid dimensions for mobile
    final columns = min(sqrt(nodeCount).ceil(), 4); // Max 4 columns on mobile
    final rows = (nodeCount / columns).ceil();
    
    // Calculate spacing
    final horizontalSpacing = effectiveWidth / max(columns, 2) * spacing;
    final verticalSpacing = effectiveHeight / max(rows, 2) * spacing;
    
    // Calculate starting position (top-left of grid)
    final startX = center.dx - (horizontalSpacing * (columns - 1) / 2);
    final startY = center.dy - (verticalSpacing * (rows - 1) / 2);
    
    // Add a slight random offset for more natural appearance
    final random = Random(42); // Fixed seed for consistent layout
    
    int index = 0;
    for (int node in graph.keys) {
      final row = index ~/ columns;
      final col = index % columns;
      
      // Add small random offset to avoid perfect grid alignment
      final offsetX = random.nextDouble() * horizontalSpacing * 0.1; // Smaller offsets on mobile
      final offsetY = random.nextDouble() * verticalSpacing * 0.1;
      
      final x = startX + col * horizontalSpacing + offsetX;
      final y = startY + row * verticalSpacing + offsetY;
      
      nodePositions[node] = Offset(x, y);
      index++;
    }
  }
  
  void _drawAllEdges(Canvas canvas, Map<int, Offset> nodePositions, bool isSmallScreen) {
    final nodeCount = graph.keys.length;
    
    // Enhanced edge appearance
    final edgePaint = Paint()
      ..color = Color(0xFF8D7B68).withOpacity(0.7)
      ..strokeWidth = isSmallScreen ? 2.0 : 3.0 // Slightly thinner for better mobile view
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round; // Rounded line caps for smoother appearance
      
    // Add subtle glow to edges
    final edgeGlowPaint = Paint()
      ..color = Color(0xFF8D7B68).withOpacity(0.2)
      ..strokeWidth = isSmallScreen ? 3.5 : 5.0 // Reduced glow for cleaner look
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 2.0);
      
    // Smaller text size for weights to avoid overlapping
    final textSize = isSmallScreen 
        ? (nodeCount > 8 ? 8.0 : 9.0) // Even smaller text on mobile
        : (nodeCount > 10 ? 10.0 : 12.0); // Smaller text for dense graphs
    
    final textStyle = TextStyle(
      color: Colors.white, 
      fontSize: textSize, 
      fontWeight: FontWeight.bold,
      shadows: [  
        Shadow(
          offset: Offset(0.5, 0.5),
          blurRadius: 2.0,
          color: Colors.black.withOpacity(0.5),
        ),
      ],
    );

    for (int node in graph.keys) {
      for (int neighbor in graph[node]!.keys) {
        if (node < neighbor) {  // To avoid drawing edges twice
          final startPoint = nodePositions[node]!;
          final endPoint = nodePositions[neighbor]!;
          
          // Draw subtle glow for each edge
          canvas.drawLine(startPoint, endPoint, edgeGlowPaint);
          
          // Draw edge with improved visibility
          canvas.drawLine(startPoint, endPoint, edgePaint);

          // Draw edge weights with improved visibility
          final weight = '${graph[node]![neighbor]}';
          final textSpan = TextSpan(text: weight, style: textStyle);
          final textPainter = TextPainter(
            text: textSpan,
            textDirection: TextDirection.ltr,
          );
          
          textPainter.layout();
          
          // Calculate edge midpoint
          final midpoint = Offset(
            (startPoint.dx + endPoint.dx) / 2,
            (startPoint.dy + endPoint.dy) / 2,
          );
          
          // Calculate edge direction vector (normalized)
          final dx = endPoint.dx - startPoint.dx;
          final dy = endPoint.dy - startPoint.dy;
          final edgeLength = sqrt(dx * dx + dy * dy);
          final dirX = dx / edgeLength;
          final dirY = dy / edgeLength;
          
          // Perpendicular vector for weight offset
          final perpX = -dirY;
          final perpY = dirX;
          
          // Increase offset distance to move weights further from edge
          final offsetDistance = isSmallScreen ? 10.0 : 12.0; // Increased for better separation
          final offsetMidpoint = Offset(
            midpoint.dx + perpX * offsetDistance, 
            midpoint.dy + perpY * offsetDistance
          );
          
          // Enhanced weight bubbles - deeper color for better visibility
          final bgPaint = Paint()
            ..color = Color(0xFF1B2631).withOpacity(0.95) // Darker, more visible
            ..style = PaintingStyle.fill;

          // Draw outer white glow first for better contrast with edges
          final weightOutlineGlow = Paint()
            ..color = Colors.white.withOpacity(0.8)
            ..style = PaintingStyle.fill
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3.0);
          
          // Slightly larger radius for white background
          final outerRadius = max(textPainter.width * 0.7, 
              isSmallScreen ? 10.0 : 12.0);
              
          canvas.drawCircle(offsetMidpoint, outerRadius, weightOutlineGlow);
          
          // Even smaller weight bubbles but with clear white outline
          final weightRadius = max(textPainter.width * 0.55, 
              isSmallScreen ? 8.0 : 10.0);
          
          // Draw weight bubble
          canvas.drawCircle(offsetMidpoint, weightRadius, bgPaint);
          
          // Add thicker white border around weight circle for more visibility
          final circleBorderPaint = Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = isSmallScreen ? 1.5 : 2.0;
            
          canvas.drawCircle(offsetMidpoint, weightRadius, circleBorderPaint);
          
          textPainter.paint(
            canvas, 
            offsetMidpoint.translate(-textPainter.width / 2, -textPainter.height / 2)
          );
        }
      }
    }
  }
  
  void _drawAllNodes(Canvas canvas, Map<int, Offset> nodePositions, double nodeRadius, bool isSmallScreen) {
    final nodeCount = graph.keys.length;
    
    // Adjust text size based on node count
    final fontSize = isSmallScreen 
        ? (nodeCount > 8 ? 10.0 : 11.0)
        : (nodeCount > 12 ? 14.0 : 15.0);
        
    // Enhanced shadow effect
    final shadowPaint = Paint()
      ..color = Colors.black26
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 2.5);
    
    // Get node colors based on node ID for better differentiation
    final Map<int, Paint> nodeColors = {};
    final List<List<int>> colorPalettes = [
      // Bolder color palette with higher contrast
      [0xFF1A5276, 0xFF2E86C1], // Deep blue shades 
      [0xFF148F77, 0xFF1ABC9C], // Emerald green shades
      [0xFF7D3C98, 0xFF9B59B6], // Purple shades
      [0xFFBA4A00, 0xFFE67E22], // Orange shades
      [0xFF922B21, 0xFFE74C3C], // Red shades
      [0xFF0E6655, 0xFF26C281], // Turquoise shades
    ];
    
    for (int node in graph.keys) {
      // Distribute node colors from the palette based on node value
      final paletteIndex = node % colorPalettes.length;
      final colorPair = colorPalettes[paletteIndex];
      
      // Create gradient for this node
      nodeColors[node] = Paint()
        ..shader = RadialGradient(
          colors: [
            Color(colorPair[1]),  // Lighter center
            Color(colorPair[0]),  // Darker edges
          ],
          stops: [0.1, 1.0],
        ).createShader(Rect.fromCircle(
          center: Offset(nodeRadius / 2, nodeRadius / 2),
          radius: nodeRadius * 2,
        ));
    }

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = isSmallScreen ? 1.5 : 2.0;
    
    final textStyle = TextStyle(
      color: Colors.white, 
      fontSize: fontSize, 
      fontWeight: FontWeight.bold,
      shadows: [
        Shadow(
          offset: Offset(0.5, 0.5),
          blurRadius: 1.0,
          color: Colors.black54,
        ),
      ],
    );

    for (int node in graph.keys) {
      final position = nodePositions[node]!;
      
      // Draw shadow with offset
      canvas.drawCircle(position.translate(1.0, 1.0), nodeRadius + 1, shadowPaint);
      
      // Draw node fill with unique color from palette
      canvas.drawCircle(position, nodeRadius, nodeColors[node]!);
      
      // Draw node border
      canvas.drawCircle(position, nodeRadius, borderPaint);

      // Draw node label
      final textSpan = TextSpan(text: '$node', style: textStyle);
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      
      textPainter.layout();
      textPainter.paint(
        canvas,
        position.translate(-textPainter.width / 2, -textPainter.height / 2),
      );
    }
  }
  
  void _drawAnimationStep(Canvas canvas, Map<int, Offset> nodePositions, double nodeRadius) {
    if (currentAnimationStep == null) return;
    
    switch (currentAnimationStep!['type']) {
      case 'consider':
        final consideredEdge = currentAnimationStep!['edge'];
        // Enhanced glow effect
        final glowPaint = Paint()
          ..color = Color(0xFFEFC050).withOpacity(0.4)
          ..strokeWidth = 8
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4);
          
        canvas.drawLine(
          nodePositions[consideredEdge[0]]!,
          nodePositions[consideredEdge[1]]!,
          glowPaint,
        );
        
        // Animated dashed line effect
        final considerPaint = Paint()
          ..color = Color(0xFFEFC050)
          ..strokeWidth = 4
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;
          
        _drawAnimatedDashedLine(
          canvas,
          nodePositions[consideredEdge[0]]!,
          nodePositions[consideredEdge[1]]!,
          considerPaint,
          dashLength: 10,
          dashGap: 5,
        );
        break;
        
      case 'reject':
        final rejectedEdge = currentAnimationStep!['edge'];
        // Enhanced glow effect
        final glowPaint = Paint()
          ..color = Color(0xFFBD4B4B).withOpacity(0.5)
          ..strokeWidth = 8
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4);
          
        canvas.drawLine(
          nodePositions[rejectedEdge[0]]!,
          nodePositions[rejectedEdge[1]]!,
          glowPaint,
        );
        
        // Add X mark at midpoint to indicate rejection
        final midpoint = Offset(
          (nodePositions[rejectedEdge[0]]!.dx + nodePositions[rejectedEdge[1]]!.dx) / 2,
          (nodePositions[rejectedEdge[0]]!.dy + nodePositions[rejectedEdge[1]]!.dy) / 2,
        );
        
        final xSize = 10.0;
        final xPaint = Paint()
          ..color = Color(0xFFBD4B4B)
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;
          
        canvas.drawLine(
          midpoint.translate(-xSize, -xSize),
          midpoint.translate(xSize, xSize),
          xPaint,
        );
        canvas.drawLine(
          midpoint.translate(xSize, -xSize),
          midpoint.translate(-xSize, xSize),
          xPaint,
        );
        
        final rejectPaint = Paint()
          ..color = Color(0xFFBD4B4B)
          ..strokeWidth = 4
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;
          
        canvas.drawLine(
          nodePositions[rejectedEdge[0]]!,
          nodePositions[rejectedEdge[1]]!,
          rejectPaint,
        );
        break;
        
      case 'visit':
        final visitedNode = currentAnimationStep!['node'];
        
        // Pulsating effect
        final pulseFactor = 1.0 + 0.2 * sin(DateTime.now().millisecondsSinceEpoch * 0.005);
        
        // Enhanced glow effect
        final glowPaint = Paint()
          ..color = Color(0xFFE6945F).withOpacity(0.4)
          ..style = PaintingStyle.fill
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4);
          
        canvas.drawCircle(
          nodePositions[visitedNode]!, 
          nodeRadius * 1.8 * pulseFactor, 
          glowPaint
        );
        
        // Draw ripple effect
        final ripplePaint = Paint()
          ..color = Color(0xFFE6945F).withOpacity(0.2)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
        
        final rippleFactor = 1.0 + 0.6 * sin(DateTime.now().millisecondsSinceEpoch * 0.003);
        canvas.drawCircle(
          nodePositions[visitedNode]!, 
          nodeRadius * 2.5 * rippleFactor, 
          ripplePaint
        );
        
        final visitPaint = Paint()
          ..color = Color(0xFFE6945F)
          ..style = PaintingStyle.fill;
          
        canvas.drawCircle(nodePositions[visitedNode]!, nodeRadius * 1.4, visitPaint);
        
        // Add white border to highlight
        final visitBorderPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
          
        canvas.drawCircle(nodePositions[visitedNode]!, nodeRadius * 1.4, visitBorderPaint);
        break;
    }
  }
  
  // New method to draw animated dashed lines
  void _drawAnimatedDashedLine(Canvas canvas, Offset start, Offset end, Paint paint, {double dashLength = 10, double dashGap = 5}) {
    // Calculate total length and direction vector
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final distance = sqrt(dx * dx + dy * dy);
    
    // Calculate normalized direction
    final dirX = dx / distance;
    final dirY = dy / distance;
    
    // Animation offset based on current time (creates movement effect)
    final animOffset = (DateTime.now().millisecondsSinceEpoch / 200) % (dashLength + dashGap);
    
    // Draw dashes
    double currentDist = animOffset;
    
    while (currentDist < distance) {
      // Calculate start point of current dash
      final startX = start.dx + dirX * currentDist;
      final startY = start.dy + dirY * currentDist;
      
      // Calculate end point of current dash (capped by total distance)
      final endDist = min(currentDist + dashLength, distance);
      final endX = start.dx + dirX * endDist;
      final endY = start.dy + dirY * endDist;
      
      // Draw this dash
      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        paint,
      );
      
      // Move to the next dash
      currentDist += dashLength + dashGap;
    }
  }
  
  void _drawMSTEdges(Canvas canvas, Map<int, Offset> nodePositions) {
    final nodeCount = graph.keys.length;
    
    // Enhanced MST edge style
    final mstPaint = Paint()
      ..color = Color(0xFF70A288)
      ..strokeWidth = nodeCount > 8 ? 4.5 : 6.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    // Enhanced glow effect
      final glowPaint = Paint()
      ..color = Color(0xFF70A288).withOpacity(0.4)
      ..strokeWidth = (nodeCount > 8 ? 4.5 : 6.0) + 4
        ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4);
        
    for (var edge in mstEdges) {
      // Draw stronger glow for MST edges
      canvas.drawLine(
        nodePositions[edge.key]!,
        nodePositions[edge.value]!,
        glowPaint
      );
      
      canvas.drawLine(
        nodePositions[edge.key]!,
        nodePositions[edge.value]!,
        mstPaint,
      );
      
      // Draw direction indicator (subtle arrow in middle of edge)
      final startPoint = nodePositions[edge.key]!;
      final endPoint = nodePositions[edge.value]!;
      final midpoint = Offset(
        (startPoint.dx + endPoint.dx) / 2,
        (startPoint.dy + endPoint.dy) / 2,
      );
      
      // Calculate direction vector
      final dirX = endPoint.dx - startPoint.dx;
      final dirY = endPoint.dy - startPoint.dy;
      final length = sqrt(dirX * dirX + dirY * dirY);
      final normDirX = dirX / length;
      final normDirY = dirY / length;
      
      // Calculate perpendicular vector
      final perpDirX = -normDirY;
      final perpDirY = normDirX;
      
      // Small arrow size
      final arrowSize = nodeCount > 8 ? 6.0 : 8.0;
      
      // Draw small arrow indicator
      final arrowPath = Path();
      arrowPath.moveTo(
        midpoint.dx - normDirX * arrowSize, 
        midpoint.dy - normDirY * arrowSize
      );
      arrowPath.lineTo(
        midpoint.dx + normDirX * arrowSize,
        midpoint.dy + normDirY * arrowSize
      );
      arrowPath.lineTo(
        midpoint.dx + perpDirX * arrowSize, 
        midpoint.dy + perpDirY * arrowSize
      );
      arrowPath.close();
      
      final arrowPaint = Paint()
        ..color = Color(0xFF70A288)
        ..style = PaintingStyle.fill;
        
      canvas.drawPath(arrowPath, arrowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant GraphPainter oldDelegate) {
    return oldDelegate.graph != graph ||
           oldDelegate.mstEdges != mstEdges ||
           oldDelegate.currentAnimationStep != currentAnimationStep ||
           oldDelegate.spacing != spacing;
  }
}

// Legend item widget with updated style
class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({
    super.key,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 1),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF8D7B68).withOpacity(0.3),
                blurRadius: 2,
                spreadRadius: 0,
                offset: Offset(0, 1),
              ),
            ],
          ),
        ),
        SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: Color(0xFF5E4B3E),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
