import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';

class GraphTraversal extends StatelessWidget {
  const GraphTraversal({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Graph Traversal Visualizer',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      home: GraphTraversalScreen(),
    );
  }
}

class GraphTraversalScreen extends StatefulWidget {
  const GraphTraversalScreen({super.key});

  @override
  _GraphTraversalScreenState createState() => _GraphTraversalScreenState();
}

class _GraphTraversalScreenState extends State<GraphTraversalScreen> with TickerProviderStateMixin {
  Map<int, List<int>> graph = {};
  int selectedNode = -1;
  List<int> traversalOrder = [];
  bool isTraversing = false;
  final TextEditingController _nodeController = TextEditingController();
  final TextEditingController _edgeController = TextEditingController();
  late AnimationController _backgroundController;
  late AnimationController _particleController;
  String stepExplanation = "";
  List<Particle> particles = [];
  final int particleCount = 30;
  
  // Add animation controllers for buttons
  late AnimationController _addButtonController;
  late AnimationController _traversalButtonController;
  late Animation<Color?> _bfsColorAnimation;
  late Animation<Color?> _dfsColorAnimation;
  late Animation<Color?> _addNodeColorAnimation;
  late Animation<Color?> _addEdgeColorAnimation;

  @override
  void initState() {
    super.initState();
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    
    _particleController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
    
    // Add button animation controllers
    _addButtonController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    _traversalButtonController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);
    
    // Create color animations for buttons
    _addNodeColorAnimation = ColorTween(
      begin: Color(0xFF2E7D32),  // Green
      end: Color(0xFF00C853),    // Light Green
    ).animate(_addButtonController);
    
    _addEdgeColorAnimation = ColorTween(
      begin: Color(0xFF1565C0),  // Blue
      end: Color(0xFF00B0FF),    // Light Blue
    ).animate(_addButtonController);
    
    _bfsColorAnimation = ColorTween(
      begin: Color(0xFF6A1B9A),  // Purple
      end: Color(0xFFAA00FF),    // Light Purple
    ).animate(_traversalButtonController);
    
    _dfsColorAnimation = ColorTween(
      begin: Color(0xFFC62828),  // Red
      end: Color(0xFFFF5252),    // Light Red
    ).animate(_traversalButtonController);
    
    // Initialize particles
    final random = Random();
    for (int i = 0; i < particleCount; i++) {
      particles.add(Particle(
        position: Offset(
          random.nextDouble() * 400,
          random.nextDouble() * 800,
        ),
        speed: Offset(
          (random.nextDouble() - 0.5) * 2,
          (random.nextDouble() - 0.5) * 2,
        ),
        radius: random.nextDouble() * 3 + 1,
        opacity: random.nextDouble() * 0.6 + 0.2,
      ));
    }
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _particleController.dispose();
    _addButtonController.dispose();
    _traversalButtonController.dispose();
    _nodeController.dispose();
    _edgeController.dispose();
    super.dispose();
  }

  void addNode() {
    int node = int.tryParse(_nodeController.text) ?? 0;
    if (!graph.containsKey(node)) {
      setState(() {
        graph[node] = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Node $node added successfully'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 1),
        ),
      );
    } else {
      // Show message for duplicate node
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Node $node already exists!'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
    }
    _nodeController.clear();
  }

  void addEdge() {
    String input = _edgeController.text;
    List<String> nodes = input.split(',');
    if (nodes.length != 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Enter two nodes separated by a comma')),
      );
      return;
    }

    int node1 = int.tryParse(nodes[0].trim()) ?? 0;
    int node2 = int.tryParse(nodes[1].trim()) ?? 0;

    if (!graph.containsKey(node1)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Node $node1 does not exist')));
      return;
    }

    if (!graph.containsKey(node2)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Node $node2 does not exist')));
      return;
    }

    setState(() {
      graph[node1]!.add(node2);
      graph[node2]!.add(node1); // For undirected graph
    });
    _edgeController.clear();
  }

  void bfs(int startNode) async {
    setState(() {
      isTraversing = true;
      traversalOrder.clear();
      stepExplanation = "Starting BFS from node $startNode";
    });

    List<int> visited = [];
    Queue<int> queue = Queue();

    queue.add(startNode);
    visited.add(startNode);

    while (queue.isNotEmpty) {
      int currentNode = queue.removeFirst();
      
      setState(() {
        traversalOrder.add(currentNode);
        stepExplanation = "Visiting node $currentNode\n" "Queue: [${queue.join(', ')}]\n" +
            "Visited: [${visited.join(', ')}]";
      });

      await Future.delayed(Duration(milliseconds: 1000)); // Delay for animation

      List<int> newNeighbors = [];
      for (int neighbor in graph[currentNode]!) {
        if (!visited.contains(neighbor)) {
          visited.add(neighbor);
          queue.add(neighbor);
          newNeighbors.add(neighbor);
        }
      }
      
      if (newNeighbors.isNotEmpty) {
        setState(() {
          stepExplanation = "Adding neighbors of $currentNode to queue: [${newNeighbors.join(', ')}]\n" "Queue: [${queue.join(', ')}]\n" +
              "Visited: [${visited.join(', ')}]";
        });
        
        await Future.delayed(Duration(milliseconds: 500));
      }
    }

    setState(() {
      isTraversing = false;
      stepExplanation = "BFS traversal complete!\nFinal path: [${traversalOrder.join(' → ')}]";
    });
  }

  void dfs(int startNode) async {
    setState(() {
      isTraversing = true;
      traversalOrder.clear();
      stepExplanation = "Starting DFS from node $startNode";
    });

    List<int> visited = [];
    await _dfsHelper(startNode, visited);

    setState(() {
      isTraversing = false;
      stepExplanation = "DFS traversal complete!\nFinal path: [${traversalOrder.join(' → ')}]";
    });
  }

  Future<void> _dfsHelper(int node, List<int> visited) async {
    visited.add(node);
    setState(() {
      traversalOrder.add(node);
      stepExplanation = "Visiting node $node\n" "Visited: [${visited.join(', ')}]\n" +
          "Going as deep as possible before backtracking";
    });

    await Future.delayed(Duration(milliseconds: 1000)); // Delay for animation

    for (int neighbor in graph[node]!) {
      if (!visited.contains(neighbor)) {
        setState(() {
          stepExplanation = "Moving from node $node to unvisited neighbor $neighbor";
        });
        
        await Future.delayed(Duration(milliseconds: 500));
        await _dfsHelper(neighbor, visited);
      }
    }
    
    if (graph[node]!.every((neighbor) => visited.contains(neighbor))) {
      setState(() {
        stepExplanation = "All neighbors of node $node are visited, backtracking...";
      });
      
      await Future.delayed(Duration(milliseconds: 500));
    }
  }

  void resetGraph() {
    setState(() {
      graph.clear();
      traversalOrder.clear();
      selectedNode = -1;
      stepExplanation = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Graph Traversal Visualizer',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.blue.withOpacity(0.7),
        elevation: 4,
        shadowColor: Colors.black54,
        centerTitle: true,
      ),
      body: AnimatedBuilder(
        animation: Listenable.merge([_backgroundController, _particleController]),
        builder: (context, child) {
          // Update particle positions
          for (var particle in particles) {
            particle.position += particle.speed;
            
            // Wrap particles around screen
            if (particle.position.dx < 0) particle.position = Offset(400, particle.position.dy);
            if (particle.position.dx > 400) particle.position = Offset(0, particle.position.dy);
            if (particle.position.dy < 0) particle.position = Offset(particle.position.dx, 800);
            if (particle.position.dy > 800) particle.position = Offset(particle.position.dx, 0);
          }
          
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 20, 30, 48),
                  Color.fromARGB(255, 36, 59, 85),
                ],
                begin: Alignment.topLeft,
                end: Alignment(
                  cos(_backgroundController.value * 2 * pi) * 0.5 + 0.5,
                  sin(_backgroundController.value * 2 * pi) * 0.5 + 0.5,
                ),
              ),
            ),
            child: CustomPaint(
              painter: ParticlePainter(particles: particles),
              child: child,
            ),
          );
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(height: 70), // Space for the AppBar
              // Input Card
              Card(
                elevation: 8,
                shadowColor: Colors.black54,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: Colors.white.withOpacity(0.85),
                child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
                      Text('Add Graph Elements', 
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      SizedBox(height: 20),
            TextField(
              controller: _nodeController,
              decoration: InputDecoration(
                labelText: 'Enter node',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: Icon(Icons.add_circle_outline),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
                      // Animated Add Node button
                      AnimatedBuilder(
                        animation: _addNodeColorAnimation,
                        builder: (context, child) {
                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: _addNodeColorAnimation.value!.withOpacity(0.4),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ElevatedButton.icon(
                              icon: Icon(Icons.add_circle, color: Colors.white),
                              label: Text('Add Node', style: TextStyle(fontSize: 16)),
                              onPressed: addNode,
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                                backgroundColor: _addNodeColorAnimation.value,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          );
                        },
                      ),
            SizedBox(height: 20),
            TextField(
              controller: _edgeController,
              decoration: InputDecoration(
                labelText: 'Enter edge (node1,node2)',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: Icon(Icons.linear_scale),
              ),
            ),
            SizedBox(height: 10),
                      // Animated Add Edge button
                      AnimatedBuilder(
                        animation: _addEdgeColorAnimation,
                        builder: (context, child) {
                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: _addEdgeColorAnimation.value!.withOpacity(0.4),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ElevatedButton.icon(
                              icon: Icon(Icons.linear_scale, color: Colors.white),
                              label: Text('Add Edge', style: TextStyle(fontSize: 16)),
                              onPressed: addEdge,
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                                backgroundColor: _addEdgeColorAnimation.value,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Control Card
              Card(
                elevation: 8,
                shadowColor: Colors.black54,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: Colors.white.withOpacity(0.85),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text('Start Traversal', 
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            // Dropdown to select starting node
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButton<int>(
              value: selectedNode == -1 ? null : selectedNode,
              hint: Text('Select starting node'),
                          isExpanded: true,
                          underline: SizedBox(),
                          items: graph.keys.map((int node) {
                    return DropdownMenuItem<int>(
                      value: node,
                      child: Text('Node $node'),
                    );
                  }).toList(),
                          onChanged: isTraversing ? null : (int? newValue) {
                        setState(() {
                          selectedNode = newValue!;
                        });
                      },
                        ),
            ),
            SizedBox(height: 20),
                      // Buttons for BFS and DFS with animations
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                          // Animated BFS button
                          AnimatedBuilder(
                            animation: _bfsColorAnimation,
                            builder: (context, child) {
                              return Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: isTraversing || selectedNode == -1 ? [] : [
                                    BoxShadow(
                                      color: _bfsColorAnimation.value!.withOpacity(0.5),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton.icon(
                                  icon: Icon(Icons.grain, color: Colors.white),
                                  label: Text('BFS', style: TextStyle(fontSize: 16)),
                                  onPressed: isTraversing || selectedNode == -1
                          ? null
                          : () => bfs(selectedNode),
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                                    backgroundColor: isTraversing || selectedNode == -1 
                                        ? Colors.grey 
                                        : _bfsColorAnimation.value,
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor: Colors.grey.shade400,
                                    disabledForegroundColor: Colors.white70,
                                    elevation: isTraversing || selectedNode == -1 ? 0 : 4,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                              );
                            },
                ),
                SizedBox(width: 20),
                          // Animated DFS button
                          AnimatedBuilder(
                            animation: _dfsColorAnimation,
                            builder: (context, child) {
                              return Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: isTraversing || selectedNode == -1 ? [] : [
                                    BoxShadow(
                                      color: _dfsColorAnimation.value!.withOpacity(0.5),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton.icon(
                                  icon: Icon(Icons.account_tree, color: Colors.white),
                                  label: Text('DFS', style: TextStyle(fontSize: 16)),
                                  onPressed: isTraversing || selectedNode == -1
                          ? null
                          : () => dfs(selectedNode),
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                                    backgroundColor: isTraversing || selectedNode == -1 
                                        ? Colors.grey 
                                        : _dfsColorAnimation.value,
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor: Colors.grey.shade400,
                                    disabledForegroundColor: Colors.white70,
                                    elevation: isTraversing || selectedNode == -1 ? 0 : 4,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      
                      // Step explanation
                      if (stepExplanation.isNotEmpty) ...[
                        SizedBox(height: 20),
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue.withOpacity(0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Algorithm Steps',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.blue.shade800,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                stepExplanation,
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
            ),
            SizedBox(height: 20),
            // Graph visualization
              Card(
                elevation: 8,
                shadowColor: Colors.black54,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: Colors.white.withOpacity(0.85),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text('Graph Visualization', 
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      SizedBox(height: 16),
            Container(
                        height: 400,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 5,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
              child: CustomPaint(
                size: Size(double.infinity, 400),
                painter: GraphPainter(
                  graph: graph,
                  traversalOrder: traversalOrder,
                ),
              ),
            ),
                      ),
                      SizedBox(height: 16),
                      // Reset button with animation
                      AnimatedBuilder(
                        animation: _traversalButtonController,
                        builder: (context, child) {
                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.redAccent.withOpacity(0.3),
                                  blurRadius: 8,
                                  spreadRadius: 1 + _traversalButtonController.value * 2,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ElevatedButton.icon(
                              icon: Icon(Icons.refresh, color: Colors.white),
                              label: Text('Reset Graph', style: TextStyle(fontSize: 16)),
                              onPressed: resetGraph,
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                                backgroundColor: Colors.redAccent,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
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

// Particle class for background animation
class Particle {
  Offset position;
  Offset speed;
  double radius;
  double opacity;

  Particle({
    required this.position,
    required this.speed,
    required this.radius,
    required this.opacity,
  });
}

// Particle painter
class ParticlePainter extends CustomPainter {
  final List<Particle> particles;

  ParticlePainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final paint = Paint()
        ..color = Colors.white.withOpacity(particle.opacity)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(particle.position, particle.radius, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class GraphPainter extends CustomPainter {
  final Map<int, List<int>> graph;
  final List<int> traversalOrder;

  GraphPainter({required this.graph, required this.traversalOrder});

  @override
  void paint(Canvas canvas, Size size) {
    final nodePositions = _calculateNodePositions(size);

    // Draw background grid
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..strokeWidth = 1;
    
    final gridSpacing = 20.0;
    for (double x = 0; x < size.width; x += gridSpacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += gridSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Draw edges
    for (int node in graph.keys) {
      for (int neighbor in graph[node]!) {
        // Only draw each edge once to avoid duplicate for undirected graph
        if (node < neighbor) {
          final start = nodePositions[node]!;
          final end = nodePositions[neighbor]!;
          
          // Create path for animated edges
          final path = Path()
            ..moveTo(start.dx, start.dy)
            ..lineTo(end.dx, end.dy);
          
          // Draw edge background
          final edgePaint = Paint()
            ..color = Colors.grey.withOpacity(0.5)
            ..strokeWidth = 3
            ..style = PaintingStyle.stroke;
          canvas.drawPath(path, edgePaint);
          
          // Draw animated edge highlights for traversal
          if (traversalOrder.contains(node) && traversalOrder.contains(neighbor)) {
            // Get indices to determine if this edge was traversed
            final nodeIndex = traversalOrder.indexOf(node);
            final neighborIndex = traversalOrder.indexOf(neighbor);
            
            // Check if these nodes are adjacent in the traversal
            bool adjacent = (nodeIndex == neighborIndex + 1) || 
                          (neighborIndex == nodeIndex + 1);
            
            final traversedEdgePaint = Paint()
              ..color = adjacent ? Colors.greenAccent : Colors.greenAccent.withOpacity(0.3)
              ..strokeWidth = adjacent ? 4 : 3
              ..style = PaintingStyle.stroke;
            canvas.drawPath(path, traversedEdgePaint);
            
            // Draw direction arrow if adjacent in traversal
            if (adjacent) {
              // Determine direction
              final fromNode = nodeIndex > neighborIndex ? neighbor : node;
              final toNode = fromNode == node ? neighbor : node;
              
              final fromPos = nodePositions[fromNode]!;
              final toPos = nodePositions[toNode]!;
              
              // Calculate arrow position (70% along the path)
              final arrowPos = Offset(
                fromPos.dx + (toPos.dx - fromPos.dx) * 0.7,
                fromPos.dy + (toPos.dy - fromPos.dy) * 0.7,
              );
              
              // Calculate arrow direction
              final angle = atan2(toPos.dy - fromPos.dy, toPos.dx - fromPos.dx);
              
              // Draw arrow
              final arrowPath = Path();
              arrowPath.moveTo(
                arrowPos.dx - 8 * cos(angle - pi/6),
                arrowPos.dy - 8 * sin(angle - pi/6),
              );
              arrowPath.lineTo(
                arrowPos.dx,
                arrowPos.dy,
              );
              arrowPath.lineTo(
                arrowPos.dx - 8 * cos(angle + pi/6),
                arrowPos.dy - 8 * sin(angle + pi/6),
              );
              
              final arrowPaint = Paint()
                ..color = Colors.orange
                ..style = PaintingStyle.stroke
                ..strokeWidth = 2;
              canvas.drawPath(arrowPath, arrowPaint);
            }
          }
        }
      }
    }

    // Draw nodes with pulse effect for recently visited nodes
    for (int node in graph.keys) {
      final position = nodePositions[node]!;
      final isVisited = traversalOrder.contains(node);
      
      // Draw node shadow
      final shadowPaint = Paint()
        ..color = Colors.black.withOpacity(0.3)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(Offset(position.dx + 2, position.dy + 2), 22, shadowPaint);
      
      // Draw node background
      final nodeBgPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(position, 22, nodeBgPaint);
      
      // Draw node fill
      final nodePaint = Paint()
          ..style = PaintingStyle.fill;

      if (isVisited) {
        final index = traversalOrder.indexOf(node);
        final progress = index / (traversalOrder.length - 1);
        
        // Create gradient from blue to green for visited nodes
        nodePaint.color = Color.lerp(
          Colors.blue,
          Colors.green,
          progress.isNaN ? 0 : progress,
        )!;
        
        // Draw pulse effect for recently visited nodes
        if (index == traversalOrder.length - 1) {
          final pulsePaint = Paint()
            ..color = Colors.white.withOpacity(0.6)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3;
          
          for (int i = 0; i < 3; i++) {
            canvas.drawCircle(position, 22 + i * 6, pulsePaint);
          }
        }
      } else {
        nodePaint.color = Colors.blue.shade300;
      }
      
      canvas.drawCircle(position, 20, nodePaint);

      // Draw node border
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(position, 20, borderPaint);

      // Draw node text
      final textPainter = TextPainter(
        text: TextSpan(
        text: '$node',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          position.dx - textPainter.width / 2,
          position.dy - textPainter.height / 2,
        ),
      );
      
      // Add traversal order indicator
      if (isVisited) {
        final index = traversalOrder.indexOf(node);
        
        // Draw a more attractive indicator
        final indicatorPaint = Paint()
          ..color = Colors.orange;
        
        canvas.drawCircle(
          Offset(position.dx + 15, position.dy - 15),
          10,
          indicatorPaint
        );
        
        final orderPainter = TextPainter(
          text: TextSpan(
            text: '${index + 1}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
        );
        
        orderPainter.layout();
        orderPainter.paint(
          canvas,
          Offset(
            position.dx + 15 - orderPainter.width / 2,
            position.dy - 15 - orderPainter.height / 2,
          ),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  Map<int, Offset> _calculateNodePositions(Size size) {
    final nodePositions = <int, Offset>{};
    final nodeCount = graph.keys.length;
    if (nodeCount == 0) return nodePositions;
    
    final angleStep = (2 * 3.14159) / nodeCount;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 3;

    int index = 0;
    for (int node in graph.keys) {
      final angle = angleStep * index;
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);
      nodePositions[node] = Offset(x, y);
      index++;
    }

    return nodePositions;
  }
}
