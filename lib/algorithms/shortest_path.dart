import 'dart:math';

import 'package:flutter/material.dart';
import 'package:collection/collection.dart'; // Import the collection library

class ShortestPath extends StatelessWidget {
  const ShortestPath({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shortest Path Visualizer',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      home: ShortestPathScreen(),
    );
  }
}

class ShortestPathScreen extends StatefulWidget {
  const ShortestPathScreen({super.key});

  @override
  _ShortestPathScreenState createState() => _ShortestPathScreenState();
}

class _ShortestPathScreenState extends State<ShortestPathScreen> with SingleTickerProviderStateMixin {
  Map<int, Map<int, int>> graph = {}; // Adjacency list with weights
  int startNode = -1;
  int endNode = -1;
  List<int> shortestPath = [];
  bool isFindingPath = false;
  TextEditingController _nodeController = TextEditingController();
  TextEditingController _edgeController = TextEditingController();
  TextEditingController _weightController = TextEditingController();
  late AnimationController _backgroundAnimationController;
  late Animation<double> _backgroundAnimation;
  
  // Add variables for algorithm explanation
  List<String> algorithmSteps = [];
  int currentStepIndex = 0;
  Map<int, int> currentDistances = {};
  Map<int, int> currentPreviousNodes = {};
  int? currentNode;
  int? currentNeighbor;
  Set<int> visitedNodes = {};
  
  // Performance optimization options
  bool fastMode = false;
  bool disableAnimation = false;
  double animationSpeed = 1.0;
  
  // Scaffold key to access the drawer
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  // Scroll controller for algorithm steps
  ScrollController _stepsScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _backgroundAnimationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
    _backgroundAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(_backgroundAnimationController);
  }

  @override
  void dispose() {
    _backgroundAnimationController.dispose();
    _nodeController.dispose();
    _edgeController.dispose();
    _weightController.dispose();
    _stepsScrollController.dispose();
    super.dispose();
  }

  void addNode() {
    int node = int.tryParse(_nodeController.text) ?? 0;
    if (!graph.containsKey(node)) {
      setState(() {
        graph[node] = {};
      });
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
    int weight = int.tryParse(_weightController.text) ?? 1;

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
      graph[node1]![node2] = weight;
      graph[node2]![node1] = weight; // For undirected graph
    });
    _edgeController.clear();
    _weightController.clear();
  }

  void dijkstra() async {
    setState(() {
      isFindingPath = true;
      shortestPath.clear();
      algorithmSteps = [];
      currentStepIndex = 0;
      visitedNodes = {};
      currentNode = null;
    });

    Map<int, int> distances = {};
    Map<int, int> previousNodes = {};
    var queue = HeapPriorityQueue<int>(
      (a, b) => distances[a]!.compareTo(distances[b]!),
    );

    // Add explanation
    algorithmSteps.add("Initializing Dijkstra's algorithm: Set distance to start node as 0, and all other distances as infinity");

    for (int node in graph.keys) {
      distances[node] = node == startNode ? 0 : double.maxFinite.toInt();
      queue.add(node);
    }
    
    setState(() {
      currentDistances = Map.from(distances);
      currentPreviousNodes = {};
    });
    
    await Future.delayed(getDelay(Duration(milliseconds: 700)));

    while (queue.isNotEmpty) {
      int currentNode = queue.removeFirst();
      
      // Skip processing if we're in fast mode and this node is unreachable
      if (fastMode && distances[currentNode] == double.maxFinite.toInt()) {
        continue;
      }

      setState(() {
        this.currentNode = currentNode;
        visitedNodes.add(currentNode);
        algorithmSteps.add("Processing node $currentNode: Current distance = ${distances[currentNode] == double.maxFinite.toInt() ? '∞' : distances[currentNode]}");
        currentStepIndex = algorithmSteps.length - 1;
      });
      
      await Future.delayed(getDelay(Duration(milliseconds: 700)));

      if (currentNode == endNode) {
        setState(() {
          algorithmSteps.add("Reached end node $endNode, algorithm complete!");
          currentStepIndex = algorithmSteps.length - 1;
        });
        break;
      }

      for (int neighbor in graph[currentNode]!.keys) {
        int newDistance = distances[currentNode]! + graph[currentNode]![neighbor]!;
        
        setState(() {
          algorithmSteps.add("Checking edge from $currentNode to $neighbor: New potential distance = ${distances[currentNode]} + ${graph[currentNode]![neighbor]} = $newDistance");
          currentStepIndex = algorithmSteps.length - 1;
          // Set current neighbor for edge highlighting
          this.currentNeighbor = neighbor;
        });
        
        await Future.delayed(getDelay(Duration(milliseconds: 500)));
        
        if (newDistance < distances[neighbor]!) {
          distances[neighbor] = newDistance;
          previousNodes[neighbor] = currentNode;
          queue.add(neighbor);
          
          setState(() {
            algorithmSteps.add("Update: Node $neighbor has a shorter path via $currentNode. New distance = $newDistance");
            currentDistances = Map.from(distances);
            currentPreviousNodes = Map.from(previousNodes);
            currentStepIndex = algorithmSteps.length - 1;
          });
          
          await Future.delayed(getDelay(Duration(milliseconds: 700)));
        } else {
          setState(() {
            algorithmSteps.add("No update needed: Path to $neighbor is already optimal");
            currentStepIndex = algorithmSteps.length - 1;
          });
          
          await Future.delayed(getDelay(Duration(milliseconds: 400)));
        }
        
        // Clear current neighbor after processing
        setState(() {
          this.currentNeighbor = null;
        });
      }
    }

    _reconstructPath(previousNodes);
  }

  void bellmanFord() async {
    setState(() {
      isFindingPath = true;
      shortestPath.clear();
      algorithmSteps = [];
      currentStepIndex = 0;
      visitedNodes = {};
      currentNode = null;
      currentNeighbor = null;
    });

    Map<int, int> distances = {};
    Map<int, int> previousNodes = {};

    // Add explanation
    algorithmSteps.add("Initializing Bellman-Ford algorithm: Set distance to start node as 0, and all other distances as infinity");

    for (int node in graph.keys) {
      distances[node] = node == startNode ? 0 : double.maxFinite.toInt();
    }
    
    setState(() {
      currentDistances = Map.from(distances);
      currentPreviousNodes = {};
    });
    
    await Future.delayed(getDelay(Duration(milliseconds: 700)));

    // Optimization: Track if any updates were made in the last iteration
    bool updatedInLastPass = true;
    
    // Maximum number of iterations for Bellman-Ford is |V|-1
    int maxIterations = fastMode ? min(graph.length - 1, 15) : graph.length - 1;
    
    for (int i = 0; i < maxIterations && updatedInLastPass; i++) {
      setState(() {
        algorithmSteps.add("Starting iteration ${i+1} of $maxIterations");
        currentStepIndex = algorithmSteps.length - 1;
      });
      
      await Future.delayed(getDelay(Duration(milliseconds: 700)));
      
      updatedInLastPass = false;
      
      // In fast mode, only process nodes that are reachable
      List<int> nodesToProcess = graph.keys.toList();
      if (fastMode) {
        nodesToProcess = graph.keys.where((node) => 
          distances[node] != double.maxFinite.toInt() || node == startNode
        ).toList();
      }
      
      for (int node in nodesToProcess) {
        setState(() {
          this.currentNode = node;
          visitedNodes.add(node);
        });
        
        for (int neighbor in graph[node]!.keys) {
          if (distances[node] == double.maxFinite.toInt()) {
            continue; // Optimization: Skip unreachable nodes
          }
          
          int newDistance = distances[node]! + graph[node]![neighbor]!;
          
          setState(() {
            algorithmSteps.add("Checking edge from $node to $neighbor: New potential distance = ${distances[node] == double.maxFinite.toInt() ? '∞' : distances[node]} + ${graph[node]![neighbor]} = ${distances[node] == double.maxFinite.toInt() ? '∞' : newDistance}");
            currentStepIndex = algorithmSteps.length - 1;
            currentNeighbor = neighbor;
          });
          
          await Future.delayed(getDelay(Duration(milliseconds: 300)));
          
          if (newDistance < distances[neighbor]!) {
            distances[neighbor] = newDistance;
            previousNodes[neighbor] = node;
            updatedInLastPass = true;
            
            setState(() {
              algorithmSteps.add("Update: Node $neighbor has a shorter path via $node. New distance = $newDistance");
              currentDistances = Map.from(distances);
              currentPreviousNodes = Map.from(previousNodes);
              currentStepIndex = algorithmSteps.length - 1;
            });
            
            await Future.delayed(getDelay(Duration(milliseconds: 500)));
          }
          
          // Clear current neighbor
          setState(() {
            currentNeighbor = null;
          });
        }
      }
      
      if (!updatedInLastPass) {
        setState(() {
          algorithmSteps.add("No updates in this iteration, early termination");
          currentStepIndex = algorithmSteps.length - 1;
        });
      }
    }
    
    setState(() {
      algorithmSteps.add("Bellman-Ford algorithm complete!");
      currentStepIndex = algorithmSteps.length - 1;
      currentNode = null;
    });

    _reconstructPath(previousNodes);
  }

  void aStar() async {
    setState(() {
      isFindingPath = true;
      shortestPath.clear();
      algorithmSteps = [];
      currentStepIndex = 0;
      visitedNodes = {};
      currentNode = null;
      currentNeighbor = null;
    });

    Map<int, int> gScores = {};
    Map<int, int> fScores = {};
    Map<int, int> previousNodes = {};
    Set<int> openSet = {};
    Set<int> closedSet = {};
    
    // Use PriorityQueue for better performance with larger graphs
    var openQueue = HeapPriorityQueue<int>(
      (a, b) => fScores[a]!.compareTo(fScores[b]!),
    );

    // Add explanation
    algorithmSteps.add("Initializing A* algorithm: g(n) = path cost from start, h(n) = heuristic to goal, f(n) = g(n) + h(n)");

    // Initialize costs
    for (int node in graph.keys) {
      gScores[node] = double.maxFinite.toInt();
      fScores[node] = double.maxFinite.toInt();
    }
    
    // Set start node scores
    gScores[startNode] = 0;
    fScores[startNode] = _heuristic(startNode, endNode);
    openSet.add(startNode);
    openQueue.add(startNode);
    
    setState(() {
      currentDistances = Map.from(gScores);
      currentPreviousNodes = {};
    });
    
    await Future.delayed(getDelay(Duration(milliseconds: 700)));

    while (openQueue.isNotEmpty) {
      // Get node with lowest f score
      int current = openQueue.removeFirst();
      openSet.remove(current);
      
      setState(() {
        this.currentNode = current;
        visitedNodes.add(current);
        algorithmSteps.add("Processing node $current: g(n) = ${gScores[current]}, h(n) = ${_heuristic(current, endNode)}, f(n) = ${fScores[current]}");
        currentStepIndex = algorithmSteps.length - 1;
      });
      
      await Future.delayed(getDelay(Duration(milliseconds: 700)));

      // If we reached the goal
      if (current == endNode) {
        setState(() {
          algorithmSteps.add("Reached end node $endNode, algorithm complete!");
          currentStepIndex = algorithmSteps.length - 1;
        });
        break;
      }
      
      // Add to closed set
      closedSet.add(current);

      // Check neighbors
      for (int neighbor in graph[current]!.keys) {
        // Skip if neighbor is in closed set
        if (closedSet.contains(neighbor)) {
          continue;
        }
        
        setState(() {
          currentNeighbor = neighbor;
          algorithmSteps.add("Checking edge from $current to $neighbor");
          currentStepIndex = algorithmSteps.length - 1;
        });
        
        await Future.delayed(getDelay(Duration(milliseconds: 300)));
        
        // Calculate tentative g score
        int tentativeGScore = gScores[current]! + graph[current]![neighbor]!;
        
        setState(() {
          algorithmSteps.add("New potential g(n) = ${gScores[current]} + ${graph[current]![neighbor]} = $tentativeGScore");
          currentStepIndex = algorithmSteps.length - 1;
        });
        
        await Future.delayed(getDelay(Duration(milliseconds: 300)));
        
        // If this path is better than any previous one
        if (tentativeGScore < gScores[neighbor]!) {
          // Update path info
          previousNodes[neighbor] = current;
          gScores[neighbor] = tentativeGScore;
          fScores[neighbor] = tentativeGScore + _heuristic(neighbor, endNode);
          
          setState(() {
            algorithmSteps.add("Update: Node $neighbor has a shorter path via $current. New g(n) = $tentativeGScore, h(n) = ${_heuristic(neighbor, endNode)}, f(n) = ${fScores[neighbor]}");
            currentDistances = Map.from(gScores);
            currentPreviousNodes = Map.from(previousNodes);
            currentStepIndex = algorithmSteps.length - 1;
          });
          
          // Add to open set if not already there
          if (!openSet.contains(neighbor)) {
            openSet.add(neighbor);
            openQueue.add(neighbor);
            
            setState(() {
              algorithmSteps.add("Adding node $neighbor to the open set");
              currentStepIndex = algorithmSteps.length - 1;
            });
          }
          
          await Future.delayed(getDelay(Duration(milliseconds: 500)));
        } else {
          setState(() {
            algorithmSteps.add("No update needed: Path to $neighbor is already optimal");
            currentStepIndex = algorithmSteps.length - 1;
          });
          
          await Future.delayed(getDelay(Duration(milliseconds: 300)));
        }
        
        // Clear current neighbor
        setState(() {
          currentNeighbor = null;
        });
      }
    }
    
    // If we exited without finding a path
    if (!previousNodes.containsKey(endNode) && endNode != startNode) {
      setState(() {
        algorithmSteps.add("No path exists between start and end nodes");
        currentStepIndex = algorithmSteps.length - 1;
        isFindingPath = false;
      });
      return;
    }

    _reconstructPath(previousNodes);
  }

  int _heuristic(int node, int endNode) {
    // Simple heuristic: absolute difference between node values
    return (node - endNode).abs();
  }

  void _reconstructPath(Map<int, int> previousNodes) async {
    setState(() {
      algorithmSteps.add("Reconstructing the shortest path from start to end");
      currentStepIndex = algorithmSteps.length - 1;
      currentNode = null;
      currentNeighbor = null;
    });
    
    await Future.delayed(getDelay(Duration(milliseconds: 700)));
    
    List<int> path = [];
    
    // Check if there's a path to end node
    if (!previousNodes.containsKey(endNode) && endNode != startNode) {
      setState(() {
        shortestPath = [];
        isFindingPath = false;
        algorithmSteps.add("No path exists between start and end nodes");
        currentStepIndex = algorithmSteps.length - 1;
      });
      return;
    }
    
    // If start and end are the same
    if (endNode == startNode) {
      setState(() {
        shortestPath = [startNode];
        algorithmSteps.add("Start and end nodes are the same");
        currentStepIndex = algorithmSteps.length - 1;
        isFindingPath = false;
      });
      return;
    }
    
    int currentPathNode = endNode;

    while (currentPathNode != startNode) {
      path.add(currentPathNode);
      
      int prevNode = previousNodes[currentPathNode]!;
      
      setState(() {
        this.currentNode = currentPathNode;
        this.currentNeighbor = prevNode;
        algorithmSteps.add("Going backward: From node $currentPathNode to $prevNode");
        currentStepIndex = algorithmSteps.length - 1;
      });
      
      await Future.delayed(getDelay(Duration(milliseconds: 500)));
      currentPathNode = prevNode;
    }
    path.add(startNode);
    path = path.reversed.toList();

    setState(() {
      algorithmSteps.add("Final shortest path: ${path.join(' → ')}");
      currentStepIndex = algorithmSteps.length - 1;
      currentNode = null;
      currentNeighbor = null;
    });
    
    await Future.delayed(getDelay(Duration(milliseconds: 500)));

    // Show path one node at a time
    List<int> animatedPath = [];
    for (int i = 0; i < path.length; i++) {
      int node = path[i];
      animatedPath.add(node);
      
      setState(() {
        shortestPath = List.from(animatedPath);
        this.currentNode = node;
        algorithmSteps.add("Adding node $node to the path visualization");
        currentStepIndex = algorithmSteps.length - 1;
      });
      
      // If not the last node, animate the edge too
      if (i < path.length - 1) {
        await Future.delayed(getDelay(Duration(milliseconds: 300))); 
        
        setState(() {
          this.currentNeighbor = path[i+1];
        });
        
        await Future.delayed(getDelay(Duration(milliseconds: 300)));
        
        setState(() {
          this.currentNeighbor = null;
        });
      }
    }

    // Calculate total path weight
    int totalWeight = 0;
    for (int i = 0; i < path.length - 1; i++) {
      totalWeight += graph[path[i]]![path[i + 1]]!;
    }

    setState(() {
      algorithmSteps.add("Path complete! Total path weight: $totalWeight");
      currentStepIndex = algorithmSteps.length - 1;
      isFindingPath = false;
      currentNode = null;
    });
  }

  void resetGraph() {
    setState(() {
      graph.clear();
      shortestPath.clear();
      startNode = -1;
      endNode = -1;
      
      // Also clear algorithm steps when resetting
      algorithmSteps.clear();
      currentDistances.clear();
      currentPreviousNodes.clear();
      visitedNodes.clear();
      currentNode = null;
    });
  }

  // Helper method to build settings sections
  Widget _buildSettingsSection({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            spreadRadius: 1,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.indigo.shade50,
                  Colors.white,
                ],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.indigo.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon, 
                    color: Colors.indigo.shade700,
                    size: 24,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.indigo.shade800,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            color: Colors.indigo.shade100,
            thickness: 1,
            height: 1,
          ),
          // Section content
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }

  // Helper method to build info items
  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.indigo.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 18,
            color: Colors.indigo.shade700,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.indigo.shade800,
                ),
              ),
              SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper method to build custom switch tiles
  Widget _buildCustomSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          // Icon container
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: value ? Colors.indigo.withOpacity(0.1) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: value ? Colors.indigo.shade600 : Colors.grey.shade600,
              size: 20,
            ),
          ),
          SizedBox(width: 14),
          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: value ? Colors.indigo.shade900 : Colors.grey.shade800,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: value ? Colors.indigo.shade700 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          // Custom switch
          GestureDetector(
            onTap: () => onChanged(!value),
            child: Container(
              width: 50,
              height: 30,
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: value ? Colors.indigo.shade400 : Colors.grey.shade300,
              ),
              child: Stack(
                children: [
                  AnimatedPositioned(
                    duration: Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    left: value ? 22 : 2,
                    right: value ? 2 : 22,
                    top: 2,
                    bottom: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            spreadRadius: 0.5,
                          )
                        ],
                      ),
                      child: value
                          ? Icon(Icons.check, size: 14, color: Colors.indigo.shade500)
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build speed preset buttons
  Widget _buildSpeedPresetButton(double speed, String label) {
    final isSelected = (animationSpeed - speed).abs() < 0.1;
    
    return InkWell(
      onTap: () {
        setState(() {
          animationSpeed = speed;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.indigo.shade100 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.indigo.shade400 : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.indigo.shade800 : Colors.grey.shade700,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  // Utility function to get delay duration based on animation settings
  Duration getDelay(Duration baseDuration) {
    if (disableAnimation) {
      return Duration(milliseconds: 10);
    }
    return Duration(milliseconds: (baseDuration.inMilliseconds / animationSpeed).toInt());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      // Add drawer for performance settings
      drawer: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Colors.transparent,
        ),
        child: Drawer(
          width: MediaQuery.of(context).size.width * 0.85,
          elevation: 10,
          child: SafeArea(
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Drawer header
                  Container(
                    height: 150,
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
                      ),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Settings',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Material(
                              color: Colors.transparent,
                              shape: CircleBorder(),
                              clipBehavior: Clip.antiAlias,
                              child: IconButton(
                                icon: Icon(Icons.close, color: Colors.white, size: 26),
                                splashColor: Colors.white24,
                                onPressed: () => Navigator.pop(context),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Performance Options',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: 20),
                        // Animated indicator
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0, end: 1),
                          duration: Duration(seconds: 1),
                          builder: (context, value, child) {
                            return LinearProgressIndicator(
                              value: value,
                              backgroundColor: Colors.white24,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              minHeight: 5,
                              borderRadius: BorderRadius.circular(3),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  // Settings content
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.all(16),
                      physics: BouncingScrollPhysics(),
                      children: [
                        // Animation speed slider
                        _buildSettingsSection(
                          icon: Icons.speed,
                          title: 'Animation Speed',
                          child: Column(
                            children: [
                              // Speed indicator with color gradient
                              Container(
                                height: 36,
                                margin: EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  gradient: LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      Colors.blue.shade700,
                                      Colors.indigo.shade700,
                                      Colors.purple.shade700,
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 4,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Stack(
                                    children: [
                                      // Speed indicator fill
                                      FractionallySizedBox(
                                        widthFactor: (animationSpeed - 0.5) / 4.5,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.3),
                                          ),
                                        ),
                                      ),
                                      // Speed labels
                                      Center(
                                        child: LayoutBuilder(
                                          builder: (context, constraints) {
                                            return Container(
                                              width: constraints.maxWidth,
                                              padding: const EdgeInsets.symmetric(horizontal: 12),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text('Slow', 
                                                    style: TextStyle(
                                                      fontSize: 12, 
                                                      color: Colors.white, 
                                                      fontWeight: FontWeight.w500,
                                                      shadows: [
                                                        Shadow(
                                                          blurRadius: 2.0,
                                                          color: Colors.black38,
                                                          offset: Offset(1, 1),
                                                        ),
                                                      ],
                                                    )
                                                  ),
                                                  Text('${animationSpeed.toStringAsFixed(1)}x', 
                                                    style: TextStyle(
                                                      fontSize: 14, 
                                                      color: Colors.white, 
                                                      fontWeight: FontWeight.bold,
                                                      shadows: [
                                                        Shadow(
                                                          blurRadius: 2.0,
                                                          color: Colors.black38,
                                                          offset: Offset(1, 1),
                                                        ),
                                                      ],
                                                    )
                                                  ),
                                                  Text('Fast', 
                                                    style: TextStyle(
                                                      fontSize: 12, 
                                                      color: Colors.white, 
                                                      fontWeight: FontWeight.w500,
                                                      shadows: [
                                                        Shadow(
                                                          blurRadius: 2.0,
                                                          color: Colors.black38,
                                                          offset: Offset(1, 1),
                                                        ),
                                                      ],
                                                    )
                                                  ),
                                                ],
                                              ),
                                            );
                                          }
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  activeTrackColor: Colors.indigo.shade600,
                                  inactiveTrackColor: Colors.indigo.withOpacity(0.15),
                                  thumbColor: Colors.indigo.shade700,
                                  overlayColor: Colors.indigo.withOpacity(0.2),
                                  thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12),
                                  overlayShape: RoundSliderOverlayShape(overlayRadius: 24),
                                  trackHeight: 6,
                                  valueIndicatorShape: PaddleSliderValueIndicatorShape(),
                                  valueIndicatorColor: Colors.indigo.shade800,
                                  valueIndicatorTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                                child: Slider(
                                  value: animationSpeed,
                                  min: 0.5,
                                  max: 5.0,
                                  divisions: 9,
                                  label: '${animationSpeed.toStringAsFixed(1)}x',
                                  onChanged: (value) {
                                    setState(() {
                                      animationSpeed = value;
                                    });
                                  },
                                ),
                              ),
                              // Speed presets
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildSpeedPresetButton(1.0, 'Normal'),
                                    _buildSpeedPresetButton(2.5, 'Fast'),
                                    _buildSpeedPresetButton(5.0, 'Super Fast'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        SizedBox(height: 16),
                        
                        // Optimization options
                        _buildSettingsSection(
                          icon: Icons.tune,
                          title: 'Optimization Options',
                          child: Column(
                            children: [
                              // Disable animation switch
                              _buildCustomSwitchTile(
                                title: 'Disable Animation',
                                subtitle: 'For larger graphs',
                                icon: Icons.speed_outlined,
                                value: disableAnimation,
                                onChanged: (value) {
                                  setState(() {
                                    disableAnimation = value;
                                  });
                                },
                              ),
                              
                              Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
                              
                              // Fast mode for large graphs
                              _buildCustomSwitchTile(
                                title: 'Fast Mode',
                                subtitle: 'Optimize algorithms',
                                icon: Icons.flash_on_outlined,
                                value: fastMode,
                                onChanged: (value) {
                                  setState(() {
                                    fastMode = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        
                        SizedBox(height: 16),
                        
                        // Information section
                        _buildSettingsSection(
                          icon: Icons.info_outline,
                          title: 'About Optimization',
                          child: Column(
                            children: [
                              _buildInfoItem(
                                icon: Icons.speed_outlined,
                                title: 'Disable Animation',
                                description: 'Significantly speeds up visualization by removing delay between steps. You\'ll only see the final result.',
                              ),
                              SizedBox(height: 12),
                              _buildInfoItem(
                                icon: Icons.flash_on_outlined,
                                title: 'Fast Mode',
                                description: 'Skips unnecessary calculations and optimizes algorithms for larger graphs. Recommended for graphs with 50+ nodes.',
                              ),
                              SizedBox(height: 12),
                              _buildInfoItem(
                                icon: Icons.tune_outlined,
                                title: 'Animation Speed',
                                description: 'Controls how fast the algorithm visualization plays. Higher speeds may skip visual details but complete faster.',
                              ),
                              // Tips container
                              Container(
                                margin: EdgeInsets.only(top: 16),
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade50,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.amber.shade200),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.lightbulb_outline, color: Colors.amber.shade800),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'For optimal performance on larger graphs, enable both Fast Mode and Disable Animation options.',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.amber.shade900,
                                        ),
                                      ),
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
                ],
              ),
            ),
          ),
        ),
      ),
      
      // Move the app bar to a proper AppBar widget
      appBar: AppBar(
        backgroundColor: Colors.indigo.withOpacity(0.7),
        elevation: 4,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.white, size: 28),
          onPressed: () {
            _scaffoldKey.currentState!.openDrawer();
          },
        ),
        title: Text(
          'Shortest Path Visualizer',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          // Settings button to open drawer
          Container(
            margin: EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white24,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.settings, color: Colors.white, size: 26),
              tooltip: 'Performance Settings',
              onPressed: () {
                _scaffoldKey.currentState!.openDrawer();
              },
            ),
          ),
        ],
      ),
      
      // Add floating action button for settings
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _scaffoldKey.currentState!.openDrawer();
        },
        backgroundColor: Colors.orange.shade700,
        foregroundColor: Colors.white,
        elevation: 6,
        child: Icon(Icons.tune, size: 28),
        tooltip: 'Performance Settings',
      ),
      
      body: AnimatedBuilder(
        animation: _backgroundAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1A237E),
                  Color(0xFF3949AB),
                  Color(0xFF1A237E),
                ],
                stops: [
                  0,
                  0.5 + 0.5 * sin(_backgroundAnimation.value),
                  1,
                ],
              ),
            ),
            child: child,
          );
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Input Section Card
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  color: Colors.white.withOpacity(0.9),
                  margin: EdgeInsets.symmetric(vertical: 10),
                  child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
                        Text('Add Graph Elements', 
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                        ),
                        SizedBox(height: 15),
                        
                        // Node Input
            TextField(
              controller: _nodeController,
              decoration: InputDecoration(
                labelText: 'Enter node',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                            prefixIcon: Icon(Icons.circle, size: 20),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: addNode, 
                          icon: Icon(Icons.add_circle), 
                          label: Text('Add Node'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
            SizedBox(height: 20),
                        
                        // Edge Input
            TextField(
              controller: _edgeController,
              decoration: InputDecoration(
                labelText: 'Enter edge (node1,node2)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                            prefixIcon: Icon(Icons.linear_scale),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _weightController,
              decoration: InputDecoration(
                labelText: 'Enter edge weight',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                            prefixIcon: Icon(Icons.line_weight),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: addEdge, 
                          icon: Icon(Icons.add_link), 
                          label: Text('Add Edge'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Selection Card
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  color: Colors.white.withOpacity(0.9),
                  margin: EdgeInsets.symmetric(vertical: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text('Select Nodes', 
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                        ),
                        SizedBox(height: 15),
            // Dropdowns to select start and end nodes
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.green[100],
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.green),
                              ),
                              child: DropdownButton<int>(
                  value: startNode == -1 ? null : startNode,
                  hint: Text('Start Node'),
                                icon: Icon(Icons.play_arrow, color: Colors.green),
                                underline: SizedBox(),
                                items: graph.keys.map((int node) {
                        return DropdownMenuItem<int>(
                          value: node,
                          child: Text('Node $node'),
                        );
                      }).toList(),
                                onChanged: isFindingPath ? null : (int? newValue) {
                            setState(() {
                              startNode = newValue!;
                              // Check if same node is selected for start and end
                              if (startNode == endNode && endNode != -1) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        Icon(Icons.warning_amber_rounded, color: Colors.white),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: Text('Start and end nodes are the same!'),
                                        ),
                                      ],
                                    ),
                                    backgroundColor: Colors.amber.shade700,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    duration: Duration(seconds: 3),
                                  ),
                                );
                              }
                            });
                          },
                ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.red[100],
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.red),
                              ),
                              child: DropdownButton<int>(
                  value: endNode == -1 ? null : endNode,
                  hint: Text('End Node'),
                                icon: Icon(Icons.flag, color: Colors.red),
                                underline: SizedBox(),
                                items: graph.keys.map((int node) {
                        return DropdownMenuItem<int>(
                          value: node,
                          child: Text('Node $node'),
                        );
                      }).toList(),
                                onChanged: isFindingPath ? null : (int? newValue) {
                            setState(() {
                              endNode = newValue!;
                              // Check if same node is selected for start and end
                              if (startNode == endNode && startNode != -1) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        Icon(Icons.warning_amber_rounded, color: Colors.white),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: Text('Start and end nodes are the same!'),
                                        ),
                                      ],
                                    ),
                                    backgroundColor: Colors.amber.shade700,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    duration: Duration(seconds: 3),
                                  ),
                                );
                              }
                            });
                          },
                              ),
                            ),
                          ],
                ),
              ],
            ),
                  ),
                ),
                
                // Algorithm buttons
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  color: Colors.white.withOpacity(0.9),
                  margin: EdgeInsets.symmetric(vertical: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text('Choose Algorithm', 
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                        ),
                        SizedBox(height: 15),
            // Buttons for algorithms
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          alignment: WrapAlignment.center,
              children: [
                            ElevatedButton.icon(
                              onPressed: isFindingPath || startNode == -1 || endNode == -1 ? null : () {
                                // Show a warning but still allow the algorithm to run if start and end nodes are the same
                                if (startNode == endNode) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          Icon(Icons.info_outline, color: Colors.white),
                                          SizedBox(width: 10),
                                          Expanded(
                                            child: Text('Start and end nodes are the same. The shortest path is 0.'),
                                          ),
                                        ],
                                      ),
                                      backgroundColor: Colors.blue.shade700,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      duration: Duration(seconds: 3),
                                    ),
                                  );
                                }
                                dijkstra();
                              },
                              icon: Icon(Icons.route),
                              label: Text('Dijkstra'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: isFindingPath || startNode == -1 || endNode == -1 ? null : () {
                                // Show a warning but still allow the algorithm to run if start and end nodes are the same
                                if (startNode == endNode) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          Icon(Icons.info_outline, color: Colors.white),
                                          SizedBox(width: 10),
                                          Expanded(
                                            child: Text('Start and end nodes are the same. The shortest path is 0.'),
                                          ),
                                        ],
                                      ),
                                      backgroundColor: Colors.blue.shade700,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      duration: Duration(seconds: 3),
                                    ),
                                  );
                                }
                                bellmanFord();
                              },
                              icon: Icon(Icons.alt_route),
                              label: Text('Bellman-Ford'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: isFindingPath || startNode == -1 || endNode == -1 ? null : () {
                                // Show a warning but still allow the algorithm to run if start and end nodes are the same
                                if (startNode == endNode) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          Icon(Icons.info_outline, color: Colors.white),
                                          SizedBox(width: 10),
                                          Expanded(
                                            child: Text('Start and end nodes are the same. The shortest path is 0.'),
                                          ),
                                        ],
                                      ),
                                      backgroundColor: Colors.blue.shade700,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      duration: Duration(seconds: 3),
                                    ),
                                  );
                                }
                                aStar();
                              },
                              icon: Icon(Icons.star),
                              label: Text('A*'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Loading Indicator when finding path
                if (isFindingPath)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                        SizedBox(height: 10),
                        Text('Calculating shortest path...',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                
                // Graph visualization
                Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  margin: EdgeInsets.symmetric(vertical: 10),
                  child: Container(
                    width: double.infinity,
                    height: 400,
                    padding: EdgeInsets.all(8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CustomPaint(
                        size: Size(double.infinity, 400),
                        painter: GraphPainter(
                          graph: graph, 
                          shortestPath: shortestPath,
                          startNode: startNode,
                          endNode: endNode,
                          currentNode: currentNode,
                          currentNeighbor: currentNeighbor,
                          visitedNodes: visitedNodes,
                          currentDistances: currentDistances,
                          currentPreviousNodes: currentPreviousNodes,
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Add Algorithm Explanation Panel after the graph visualization
                if (algorithmSteps.isNotEmpty)
                  Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    color: Colors.white.withOpacity(0.9),
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Algorithm steps title with animated icon
                          Row(
                            children: [
                          Text(
                            'Algorithm Steps',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(width: 8),
                              TweenAnimationBuilder<double>(
                                tween: Tween<double>(begin: 0, end: 1),
                                duration: Duration(seconds: 1),
                                builder: (context, value, child) {
                                  return Transform.rotate(
                                    angle: value * 2 * pi,
                                    child: child,
                                  );
                                },
                                child: Icon(
                                  Icons.analytics,
                                  color: Colors.indigo,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.indigo.withOpacity(0.3)),
                            ),
                            padding: EdgeInsets.all(10),
                            constraints: BoxConstraints(
                              maxHeight: 200,
                              minHeight: 100,
                            ),
                            child: ListView.builder(
                              controller: _stepsScrollController,
                              itemCount: algorithmSteps.length,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                // Check if this is the current step
                                bool isCurrentStep = index == currentStepIndex;
                                
                                // Scroll to the current step
                                if (isCurrentStep) {
                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    if (_stepsScrollController.hasClients) {
                                      _stepsScrollController.animateTo(
                                        index * 50.0, // Approximate height of each item
                                        duration: Duration(milliseconds: 300),
                                        curve: Curves.easeOut,
                                      );
                                    }
                                  });
                                }
                                
                                // Return an animated container for each step
                                return AnimatedContainer(
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  margin: EdgeInsets.only(
                                    bottom: 8, 
                                    left: isCurrentStep ? 8 : 0,
                                  ),
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isCurrentStep 
                                      ? Colors.blue.withOpacity(0.2) 
                                      : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                    border: isCurrentStep 
                                      ? Border.all(color: Colors.blue.shade300) 
                                      : null,
                                    boxShadow: isCurrentStep
                                      ? [
                                          BoxShadow(
                                            color: Colors.blue.withOpacity(0.2),
                                            blurRadius: 4,
                                            spreadRadius: 1,
                                          )
                                        ]
                                      : null,
                                  ),
                                  child: AnimatedDefaultTextStyle(
                                    duration: Duration(milliseconds: 300),
                                    style: TextStyle(
                                      fontSize: isCurrentStep ? 15 : 14,
                                      fontWeight: isCurrentStep ? FontWeight.bold : FontWeight.normal,
                                      color: isCurrentStep ? Colors.black : Colors.black87,
                                    ),
                                    child: Row(
                                children: [
                                        // Animated icon for the current step
                                        if (isCurrentStep)
                                          TweenAnimationBuilder(
                                            tween: Tween<double>(begin: 0, end: 1),
                                            duration: Duration(milliseconds: 500),
                                            builder: (context, double value, child) {
                                              return Opacity(
                                                opacity: value,
                                                child: Padding(
                                                  padding: EdgeInsets.only(right: 8 * value),
                                                  child: Icon(
                                                    Icons.arrow_right,
                                                    color: Colors.blue,
                                                    size: 20,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        Expanded(
                                          child: Text(algorithmSteps[index]),
                                        ),
                                      ],
        ),
      ),
    );
                              },
                            ),
                          ),
                          
                          // Current state visualization with animations
                          if (currentDistances.isNotEmpty)
                            AnimatedSlide(
                              offset: Offset(0, 0),
                              duration: Duration(milliseconds: 500),
                              curve: Curves.easeOutBack,
                              child: AnimatedOpacity(
                                opacity: 1.0,
                                duration: Duration(milliseconds: 800),
                                curve: Curves.easeInOut,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Title with animation
                                      TweenAnimationBuilder(
                                        tween: Tween<double>(begin: 0, end: 1),
                                        duration: Duration(milliseconds: 800),
                                        builder: (context, double value, child) {
                                          return Opacity(
                                            opacity: value,
                                            child: Transform.translate(
                                              offset: Offset(20 * (1 - value), 0),
                                              child: child,
                                            ),
                                          );
                                        },
                                        child: Text(
                                          'Current State:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.indigo.shade800,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      // Node state cards with staggered animation
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: graph.keys.map((node) {
                                          bool isCurrentNode = node == currentNode;
                                          bool isVisited = visitedNodes.contains(node);
                                          bool isInPath = currentPreviousNodes.containsValue(node) || 
                                                          currentPreviousNodes.containsKey(node);
                                          
                                          // Determine color based on node state
                                          Color bgColor;
                                          if (isCurrentNode) {
                                            bgColor = Colors.yellow;
                                          } else if (node == startNode) {
                                            bgColor = Colors.green.shade100;
                                          } else if (node == endNode) {
                                            bgColor = Colors.red.shade100;
                                          } else if (isVisited) {
                                            bgColor = Colors.grey.shade200;
                                          } else {
                                            bgColor = Colors.white;
                                          }
                                          
                                          // Calculate a delay based on node index for staggered effect
                                          int nodeIndex = graph.keys.toList().indexOf(node);
                                          
                                          return TweenAnimationBuilder(
                                            tween: Tween<double>(begin: 0, end: 1),
                                            duration: Duration(milliseconds: 400),
                                            // Add a staggered delay based on node index
                                            curve: Interval(
                                              nodeIndex * 0.05, // staggered start
                                              1.0,
                                              curve: Curves.easeOut,
                                            ),
                                            builder: (context, double value, child) {
                                              return Opacity(
                                                opacity: value,
                                                child: Transform.translate(
                                                  offset: Offset(0, 20 * (1 - value)),
                                                  child: child,
                                                ),
                                              );
                                            },
                                            child: AnimatedContainer(
                                              duration: Duration(milliseconds: 300),
                                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                              decoration: BoxDecoration(
                                                color: bgColor,
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: isCurrentNode 
                                                    ? Colors.orange 
                                                    : isInPath 
                                                      ? Colors.blue 
                                                      : Colors.grey,
                                                  width: isCurrentNode ? 2 : 1,
                                                ),
                                                boxShadow: isCurrentNode
                                                  ? [
                                                      BoxShadow(
                                                        color: Colors.orange.withOpacity(0.4),
                                                        blurRadius: 8,
                                                        spreadRadius: 1,
                                                      )
                                                    ]
                                                  : null,
                                              ),
                                              child: Column(
                                                children: [
                                                  Text(
                                                    "Node $node", 
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      color: isCurrentNode 
                                                        ? Colors.black 
                                                        : Colors.black87,
                                                    ),
                                                  ),
                                                  SizedBox(height: 4),
                                                  Text(
                                                    "Dist: ${currentDistances[node] == double.maxFinite.toInt() ? '∞' : currentDistances[node]}",
                                                    style: TextStyle(fontSize: 12),
                                                  ),
                                                  if (currentPreviousNodes.containsKey(node))
                                                    AnimatedOpacity(
                                                      opacity: 1.0,
                                                      duration: Duration(milliseconds: 500),
                                                      child: Text(
                                                        "Prev: ${currentPreviousNodes[node]}",
                                                        style: TextStyle(fontSize: 12),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                
                // Reset button
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: ElevatedButton.icon(
                    onPressed: resetGraph,
                    icon: Icon(Icons.refresh),
                    label: Text('Reset Graph'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
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
}

class GraphPainter extends CustomPainter {
  final Map<int, Map<int, int>> graph;
  final List<int> shortestPath;
  final int startNode;
  final int endNode;
  final int? currentNode;
  final int? currentNeighbor;
  final Set<int> visitedNodes;
  final Map<int, int> currentDistances;
  final Map<int, int> currentPreviousNodes;

  GraphPainter({
    required this.graph, 
    required this.shortestPath,
    required this.startNode,
    required this.endNode,
    this.currentNode,
    this.currentNeighbor,
    this.visitedNodes = const {},
    this.currentDistances = const {},
    this.currentPreviousNodes = const {},
  });

  @override
  void paint(Canvas canvas, Size size) {
    final nodePositions = _calculateNodePositions(size);
    
    // Draw background
    final backgroundGradient = RadialGradient(
      center: Alignment.center,
      radius: 0.8,
      colors: [Colors.white, Color(0xFFE3F2FD)],
    );
    
    final backgroundRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final backgroundPaint = Paint()..shader = backgroundGradient.createShader(backgroundRect);
    canvas.drawRect(backgroundRect, backgroundPaint);
    
    // Draw grid lines
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..strokeWidth = 1;
      
    for (double i = 0; i <= size.width; i += 30) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), gridPaint);
    }
    
    for (double i = 0; i <= size.height; i += 30) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), gridPaint);
    }

    // Draw edges
    final edgePaint = Paint()
      ..color = Colors.grey.shade600
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    for (int node in graph.keys) {
      for (int neighbor in graph[node]!.keys) {
        // Only draw each edge once (for undirected graph)
        if (node < neighbor) {
          // Highlight current edge being examined
          bool isCurrentEdge = (node == currentNode && neighbor == currentNeighbor) || 
                              (neighbor == currentNode && node == currentNeighbor);
          
          // Edge paint based on state
          Paint linePaint = Paint()
            ..strokeWidth = isCurrentEdge ? 4 : 3
            ..style = PaintingStyle.stroke;
          
          if (isCurrentEdge) {
            linePaint.color = Colors.purple;
            linePaint.strokeWidth = 5;
          } else if ((visitedNodes.contains(node) && visitedNodes.contains(neighbor)) ||
                    (currentPreviousNodes.containsKey(neighbor) && currentPreviousNodes[neighbor] == node) ||
                    (currentPreviousNodes.containsKey(node) && currentPreviousNodes[node] == neighbor)) {
            linePaint.color = Colors.blue.shade400;
          } else {
            linePaint.color = Colors.grey.shade600;
          }
          
          // Draw the edge line
          canvas.drawLine(
            nodePositions[node]!,
            nodePositions[neighbor]!,
            linePaint,
          );

          // Draw edge weights with better styling
          final textPainter = TextPainter(
            text: TextSpan(
              text: '${graph[node]![neighbor]}',
              style: TextStyle(
                color: isCurrentEdge ? Colors.purple : Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                backgroundColor: Colors.white.withOpacity(isCurrentEdge ? 0.9 : 0.7),
              ),
            ),
            textDirection: TextDirection.ltr,
          );
          textPainter.layout();
          
          // Calculate midpoint position for the weight
          final midpoint = Offset(
            (nodePositions[node]!.dx + nodePositions[neighbor]!.dx) / 2,
            (nodePositions[node]!.dy + nodePositions[neighbor]!.dy) / 2,
          );
          
          // Draw a background for the weight text
          final textBgRect = Rect.fromCenter(
            center: midpoint,
            width: textPainter.width + 8,
            height: textPainter.height + 4,
          );
          canvas.drawRRect(
            RRect.fromRectAndRadius(textBgRect, Radius.circular(4)),
            Paint()..color = isCurrentEdge ? Colors.purple.withOpacity(0.2) : Colors.white.withOpacity(0.7),
          );
          
          // Draw the text
          textPainter.paint(
            canvas, 
            Offset(
              midpoint.dx - textPainter.width / 2,
              midpoint.dy - textPainter.height / 2,
            ),
          );
        }
      }
    }

    // Highlight shortest path with animation effect
    if (shortestPath.isNotEmpty) {
      final pathPaint = Paint()
        ..color = Colors.red
        ..strokeWidth = 6
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      for (int i = 0; i < shortestPath.length - 1; i++) {
        canvas.drawLine(
          nodePositions[shortestPath[i]]!,
          nodePositions[shortestPath[i + 1]]!,
          pathPaint,
        );
      }
      
      // Draw direction arrows on the path
      if (shortestPath.length > 1) {
        for (int i = 0; i < shortestPath.length - 1; i++) {
          _drawArrow(
            canvas, 
            nodePositions[shortestPath[i]]!, 
            nodePositions[shortestPath[i + 1]]!, 
            Colors.red,
          );
        }
      }
    }

    // Draw nodes
    for (int node in graph.keys) {
      final position = nodePositions[node]!;
      
      // Node fill color logic
      Color nodeColor;
      if (node == startNode) {
        nodeColor = Colors.green;
      } else if (node == endNode) {
        nodeColor = Colors.red;
      } else if (node == currentNode) {
        nodeColor = Colors.purple;
      } else if (shortestPath.contains(node)) {
        nodeColor = Colors.orange;
      } else if (visitedNodes.contains(node)) {
        nodeColor = Colors.blue.shade300;
      } else {
        nodeColor = Colors.blue;
      }
      
      // Draw drop shadow
      canvas.drawCircle(
        Offset(position.dx + 2, position.dy + 2),
        22,
        Paint()..color = Colors.black.withOpacity(0.3),
      );
      
      // Draw outer circle (border)
      canvas.drawCircle(
        position,
        22,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill,
      );
      
      // Draw inner circle
      canvas.drawCircle(
        position,
        20,
        Paint()
          ..color = nodeColor
          ..style = PaintingStyle.fill,
      );

      // Show distance if available
      if (currentDistances.containsKey(node) && node != startNode) {
        final dist = currentDistances[node];
        final String distText = dist == double.maxFinite.toInt() ? "∞" : "$dist";
        
        final distPainter = TextPainter(
          text: TextSpan(
            text: distText,
            style: TextStyle(
              color: Colors.black,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              backgroundColor: Colors.white.withOpacity(0.7),
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        distPainter.layout();
        
        final distBgRect = Rect.fromCenter(
          center: Offset(position.dx, position.dy - 28),
          width: distPainter.width + 6,
          height: distPainter.height + 4,
        );
        
        canvas.drawRRect(
          RRect.fromRectAndRadius(distBgRect, Radius.circular(4)),
          Paint()..color = Colors.white.withOpacity(0.7),
        );
        
        distPainter.paint(
          canvas, 
          Offset(
            position.dx - distPainter.width / 2,
            position.dy - 28 - distPainter.height / 2,
          ),
        );
      }

      // Draw node label
      final textPainter = TextPainter(
        text: TextSpan(
          text: '$node',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
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
    }
  }

  void _drawArrow(Canvas canvas, Offset start, Offset end, Color color) {
    final arrowPaint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.fill;
      
    // Calculate arrow direction - fix the normalize method issue
    final vector = end - start;
    final distance = vector.distance;
    final direction = distance > 0 
        ? Offset(vector.dx / distance, vector.dy / distance)
        : Offset(0, 0);
    
    // Calculate arrow position (midpoint of the line)
    final position = start + direction * (distance / 2);
    
    // Calculate perpendicular direction for arrow wings
    final perpendicular = Offset(-direction.dy, direction.dx);
    
    // Draw arrow head
    final path = Path();
    path.moveTo(position.dx + direction.dx * 8, position.dy + direction.dy * 8);
    path.lineTo(
      position.dx + perpendicular.dx * 4 - direction.dx * 4,
      position.dy + perpendicular.dy * 4 - direction.dy * 4,
    );
    path.lineTo(
      position.dx - perpendicular.dx * 4 - direction.dx * 4,
      position.dy - perpendicular.dy * 4 - direction.dy * 4,
    );
    path.close();
    
    canvas.drawPath(path, arrowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  Map<int, Offset> _calculateNodePositions(Size size) {
    final nodePositions = <int, Offset>{};
    final nodeCount = graph.keys.length;
    
    if (nodeCount == 0) return nodePositions;
    
    final angleStep = (2 * pi) / nodeCount;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) * 0.35;

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
