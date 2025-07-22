import 'package:flutter/material.dart';

class DataStructuresHelpPage extends StatefulWidget {
  const DataStructuresHelpPage({Key? key}) : super(key: key);

  @override
  State<DataStructuresHelpPage> createState() => _DataStructuresHelpPageState();
}

class _DataStructuresHelpPageState extends State<DataStructuresHelpPage> {
  bool isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Data Structures',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: Colors.white,
            ),
          ),
          backgroundColor: isDarkMode 
              ? const Color(0xFF1F1F1F)
              : const Color(0xFF2196F3),
          elevation: 4.0,
          shadowColor: isDarkMode 
              ? Colors.black 
              : Colors.black26,
          actions: [
            IconButton(
              icon: Icon(
                isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: Colors.white,
              ),
              tooltip: isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
              onPressed: () {
                setState(() {
                  isDarkMode = !isDarkMode;
                });
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildHeaderSection(),
            const SizedBox(height: 16),
            _buildDataStructureSection(
              'Arrays and Lists',
              'Fundamental sequential data structures:',
              [
                'Arrays: Fixed-size sequential collection of elements',
                'Dynamic Arrays: Resizable arrays (ArrayList/Vector)',
                'Linked Lists: Sequential elements with pointers',
                'Common operations and time complexities',
                'Real-world applications and use cases',
              ],
              Icons.format_list_numbered,
            ),
            _buildDataStructureSection(
              'Trees',
              'Hierarchical data structures:',
              [
                'Binary Trees: Basic tree structure with two children',
                'Binary Search Trees (BST): Ordered tree structure',
                'AVL Trees: Self-balancing BST',
                'Red-Black Trees: Balanced search trees',
                'B-Trees: Multi-way search trees for databases',
                'Tree traversal algorithms and applications',
              ],
              Icons.account_tree,
            ),
            _buildDataStructureSection(
              'Graphs',
              'Network-based data structures:',
              [
                'Directed vs Undirected Graphs',
                'Weighted vs Unweighted Graphs',
                'Graph Representations: Adjacency Matrix/List',
                'Graph Traversal: BFS and DFS',
                'Shortest Path Algorithms',
                'Real-world graph applications',
              ],
              Icons.hub,
            ),
            _buildDataStructureSection(
              'Hash Tables',
              'Key-value data structures:',
              [
                'Hash Functions and Their Properties',
                'Collision Resolution Techniques',
                'Open Addressing vs Chaining',
                'Load Factor and Rehashing',
                'Common Hash Table Operations',
                'Applications in Caching and Databases',
              ],
              Icons.table_chart,
            ),
            _buildDataStructureSection(
              'Stacks and Queues',
              'Linear data structures with specific access patterns:',
              [
                'Stack: LIFO (Last In First Out) structure',
                'Queue: FIFO (First In First Out) structure',
                'Priority Queues and Heap Implementation',
                'Circular Queues and Deques',
                'Applications in Programming and Algorithms',
              ],
              Icons.storage,
            ),
            _buildDataStructureSection(
              'Advanced Data Structures',
              'Specialized data structures:',
              [
                'Trie: Efficient String Storage and Retrieval',
                'Segment Trees: Range Query Operations',
                'Disjoint Sets: Union-Find Operations',
                'Bloom Filters: Probabilistic Data Structure',
                'Skip Lists: Probabilistic Alternative to BST',
              ],
              Icons.psychology,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode 
            ? Colors.blue.withOpacity(0.2)
            : Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Data Structures Guide',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.blue[300] : Colors.blue[900],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Explore different data structures, their implementations, and use cases. Each section provides detailed information and examples.',
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

  Widget _buildDataStructureSection(String title, String subtitle, List<String> details, IconData icon) {
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
                      Icons.arrow_right,
                      size: 20,
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