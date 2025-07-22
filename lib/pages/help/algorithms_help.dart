import 'package:flutter/material.dart';

class AlgorithmsHelpPage extends StatefulWidget {
  const AlgorithmsHelpPage({Key? key}) : super(key: key);

  @override
  State<AlgorithmsHelpPage> createState() => _AlgorithmsHelpPageState();
}

class _AlgorithmsHelpPageState extends State<AlgorithmsHelpPage> {
  bool isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Algorithms',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: Colors.white,
            ),
          ),
          backgroundColor: isDarkMode 
              ? const Color(0xFF1565C0) // Dark blue
              : const Color(0xFF2196F3), // Light blue
          elevation: 4.0,
          shadowColor: isDarkMode ? Colors.black : Colors.black26,
          actions: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: isDarkMode 
                    ? Colors.white.withOpacity(0.2) 
                    : Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: Icon(
                  isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  color: Colors.white,
                  size: 22,
                ),
                tooltip: isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                onPressed: () {
                  setState(() {
                    isDarkMode = !isDarkMode;
                  });
                },
              ),
            ),
          ],
        ),
        body: Container(
          color: isDarkMode ? const Color(0xFF121212) : const Color(0xFFF5F5F5),
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildHeaderSection(),
              const SizedBox(height: 16),
              _buildAlgorithmSection(
                'Sorting Algorithms',
                'Common algorithms for arranging data:',
                [
                  'Bubble Sort: Simple comparison-based sorting (O(n²))',
                  'Quick Sort: Efficient divide-and-conquer sorting (O(n log n))',
                  'Merge Sort: Stable divide-and-conquer sorting (O(n log n))',
                  'Heap Sort: Comparison-based sorting using binary heap (O(n log n))',
                  'Insertion Sort: Simple sorting good for small data (O(n²))',
                  'Selection Sort: Simple in-place comparison sort (O(n²))',
                ],
                Icons.sort,
              ),
              _buildAlgorithmSection(
                'Searching Algorithms',
                'Efficient data lookup techniques:',
                [
                  'Linear Search: Simple sequential search (O(n))',
                  'Binary Search: Efficient search for sorted arrays (O(log n))',
                  'Depth-First Search: Graph/tree traversal technique',
                  'Breadth-First Search: Level-order traversal method',
                  'A* Search: Path finding with heuristics',
                  'Jump Search: Block-based searching (O(√n))',
                ],
                Icons.search,
              ),
              _buildAlgorithmSection(
                'Graph Algorithms',
                'Network and path finding solutions:',
                [
                  'Dijkstra\'s Algorithm: Shortest path in weighted graphs',
                  'Bellman-Ford: Shortest path with negative weights',
                  'Floyd-Warshall: All-pairs shortest paths',
                  'Kruskal\'s Algorithm: Minimum spanning tree',
                  'Prim\'s Algorithm: Minimum spanning tree',
                  'Topological Sort: DAG ordering',
                ],
                Icons.account_tree,
              ),
              _buildAlgorithmSection(
                'Dynamic Programming',
                'Optimization through subproblem solutions:',
                [
                  'Fibonacci Sequence: Classic DP example',
                  'Knapsack Problem: Resource optimization',
                  'Longest Common Subsequence',
                  'Matrix Chain Multiplication',
                  'Edit Distance: String transformation',
                  'Coin Change: Combination problems',
                ],
                Icons.auto_awesome,
              ),
              _buildAlgorithmSection(
                'String Algorithms',
                'Text processing and pattern matching:',
                [
                  'KMP Algorithm: Pattern matching',
                  'Rabin-Karp: String searching',
                  'Z Algorithm: Pattern matching',
                  'Suffix Arrays: String indexing',
                  'Trie Implementation: Prefix tree',
                  'Aho-Corasick: Multiple pattern matching',
                ],
                Icons.text_fields,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode 
            ? const Color(0xFF1565C0).withOpacity(0.2)
            : const Color(0xFF2196F3).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode 
              ? Colors.blue.withOpacity(0.3)
              : Colors.blue.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Algorithm Guide',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.blue[300] : Colors.blue[900],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Explore various algorithms and their implementations. Each section provides detailed information about time complexity and use cases.',
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlgorithmSection(String title, String subtitle, List<String> details, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: isDarkMode ? Colors.grey[800] : Colors.white,
      child: ExpansionTile(
        leading: Icon(
          icon,
          color: isDarkMode ? Colors.blue[300] : Colors.blue,
          size: 28,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: details.map((detail) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.code,
                      size: 18,
                      color: isDarkMode ? Colors.blue[300] : Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        detail,
                        style: TextStyle(
                          height: 1.5,
                          fontSize: 14,
                          color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
                        ),
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }
} 