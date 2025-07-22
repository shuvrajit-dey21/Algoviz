import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class CircularLinkedListVisualization extends StatefulWidget {
  const CircularLinkedListVisualization({super.key});

  @override
  State<CircularLinkedListVisualization> createState() =>
      _CircularLinkedListVisualizationState();
}

class _CircularLinkedListVisualizationState
    extends State<CircularLinkedListVisualization> {
  final CircularLinkedList list = CircularLinkedList();
  List<NodeWidget> nodeWidgets = [];
  String operationText = "Select an operation to begin";
  List<String> operationSteps = [];
  bool isOperating = false;
  int? selectedValue;
  bool isDarkMode = false;
  final ScrollController _scrollController = ScrollController();
  final ScrollController _stepsController = ScrollController();
  final TextEditingController valueController = TextEditingController();
  final TextEditingController positionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    list.insertAtEnd(10);
    list.insertAtEnd(20);
    list.insertAtEnd(30);
    _updateNodeWidgets();
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  Future<void> _saveThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDarkMode);
  }

  void _toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
    _saveThemePreference();
  }

  // Get theme colors
  Color get primaryColor => isDarkMode ? Colors.blue.shade700 : Colors.blue.shade800;
  Color get secondaryColor => isDarkMode ? Colors.blue.shade900 : Colors.blue.shade600;
  Color get backgroundColor => isDarkMode ? Colors.grey.shade900 : Colors.white;
  Color get cardBackgroundColor => isDarkMode ? Colors.grey.shade800 : Colors.white;
  Color get textColor => isDarkMode ? Colors.white : Colors.grey.shade800;
  Color get subtleColor => isDarkMode ? Colors.grey.shade700 : Colors.blue.shade50;
  Color get highlightColor => isDarkMode ? Colors.amber.shade700 : Colors.amber.shade100;
  Color get borderColor => isDarkMode ? Colors.grey.shade600 : Colors.blue.shade100;

  // Define gradients
  LinearGradient get backgroundGradient => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          isDarkMode ? Colors.black : primaryColor,
          isDarkMode ? Colors.grey.shade900 : Colors.blue.shade50,
        ],
      );

  LinearGradient get cardGradient => LinearGradient(
        colors: isDarkMode
            ? [Colors.grey.shade800, Colors.grey.shade900]
            : [Colors.white, Colors.blue.shade50],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  LinearGradient get headerGradient => LinearGradient(
        colors: isDarkMode
            ? [Colors.blue.shade900, Colors.blue.shade800]
            : [Colors.blue.shade400, Colors.blue.shade700],
      );

  void _updateNodeWidgets() {
    setState(() {
      nodeWidgets = _buildNodeWidgets();
    });
  }

  List<NodeWidget> _buildNodeWidgets() {
    List<NodeWidget> widgets = [];

    if (list.head == null) return widgets;

    Node? current = list.head;
    int index = 0;

    do {
      widgets.add(
        NodeWidget(
          value: current!.value,
          pointer: current.next?.value,
          isHead: current == list.head,
          isTail: current.next == list.head,
          isHighlighted: selectedValue == current.value,
          index: index,
          isCircular: true,
          isDarkMode: isDarkMode,
        ),
      );
      current = current.next;
      index++;
    } while (current != list.head && current != null);

    return widgets;
  }

  Future<void> _scrollToNode(int? index) async {
    if (nodeWidgets.isEmpty || index == null) return;

    final double itemWidth = 140;
    final double scrollPosition = index * itemWidth;
    final double viewportWidth = _scrollController.position.viewportDimension;

    double targetPosition =
        scrollPosition - (viewportWidth / 2 - itemWidth / 2);
    targetPosition = targetPosition.clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );

    await _scrollController.animateTo(
      targetPosition,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _addStep(String step) {
    setState(() {
      operationSteps.add(step);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _stepsController.animateTo(
        _stepsController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _insertAtBeginning() async {
    if (valueController.text.isEmpty) return;
    final value = int.parse(valueController.text);

    setState(() {
      isOperating = true;
      operationText = "Inserting $value at beginning";
      operationSteps.clear();
      _addStep("Starting insertion at beginning...");
    });

    await list.insertAtBeginningWithAnimation(value, (node, index, step) async {
      _addStep(step);
      if (node != null) {
        setState(() {
          selectedValue = node.value;
          _updateNodeWidgets();
        });
        await _scrollToNode(0);
      }
    });

    setState(() {
      operationText = "Inserted $value at beginning";
      selectedValue = null;
      valueController.clear();
      isOperating = false;
      _updateNodeWidgets();
    });
  }

  Future<void> _insertAtEnd() async {
    if (valueController.text.isEmpty) return;
    final value = int.parse(valueController.text);

    setState(() {
      isOperating = true;
      operationText = "Inserting $value at end";
      operationSteps.clear();
      _addStep("Starting insertion at end...");
    });

    await list.insertAtEndWithAnimation(value, (node, index, step) async {
      _addStep(step);
      if (node != null) {
        setState(() {
          selectedValue = node.value;
          _updateNodeWidgets();
        });
        await _scrollToNode(index);
      }
    });

    setState(() {
      operationText = "Inserted $value at end";
      selectedValue = null;
      valueController.clear();
      isOperating = false;
      _updateNodeWidgets();
    });
  }

  Future<void> _insertAtPosition() async {
    if (valueController.text.isEmpty || positionController.text.isEmpty) return;
    final value = int.parse(valueController.text);
    final position = int.parse(positionController.text);

    if (position < 0 || position > list.length) {
      setState(() => operationText = "Invalid position!");
      return;
    }

    setState(() {
      isOperating = true;
      operationText = "Inserting $value at position $position";
      operationSteps.clear();
      _addStep("Starting insertion at position $position...");
    });

    await list.insertAtPositionWithAnimation(value, position, (
      node,
      index,
      step,
    ) async {
      _addStep(step);
      if (node != null) {
        setState(() {
          selectedValue = node.value;
          _updateNodeWidgets();
        });
        await _scrollToNode(index);
      }
    });

    setState(() {
      operationText = "Inserted $value at position $position";
      selectedValue = null;
      valueController.clear();
      positionController.clear();
      isOperating = false;
      _updateNodeWidgets();
    });
  }

  Future<void> _deleteNode() async {
    if (valueController.text.isEmpty) return;
    final value = int.parse(valueController.text);

    if (!list.contains(value)) {
      setState(() => operationText = "Value $value not found!");
      return;
    }

    setState(() {
      isOperating = true;
      operationText = "Deleting node with value $value";
      operationSteps.clear();
      _addStep("Starting deletion of node with value $value...");
    });

    await list.deleteWithAnimation(value, (node, index, step) async {
      _addStep(step);
      setState(() {
        selectedValue = node?.value;
        _updateNodeWidgets();
      });
      await _scrollToNode(index);
    });

    setState(() {
      operationText = "Deleted node with value $value";
      selectedValue = null;
      valueController.clear();
      isOperating = false;
      _updateNodeWidgets();
    });
  }

  Future<void> _searchNode() async {
    if (valueController.text.isEmpty) return;
    final value = int.parse(valueController.text);

    setState(() {
      isOperating = true;
      operationText = "Searching for value $value";
      operationSteps.clear();
      _addStep("Starting search for value $value...");
    });

    final found = await list.searchWithAnimation(value, (
      node,
      index,
      step,
    ) async {
      _addStep(step);
      setState(() {
        selectedValue = node?.value;
        _updateNodeWidgets();
      });
      await _scrollToNode(index);
    });

    setState(() {
      operationText = found ? "Found $value!" : "$value not found!";
      valueController.clear();
      isOperating = false;
    });

    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      selectedValue = null;
      _updateNodeWidgets();
    });
  }

  Future<void> _traverseList() async {
    setState(() {
      isOperating = true;
      operationText = "Traversing the list";
      operationSteps.clear();
      _addStep("Starting list traversal...");
    });

    await list.traverseWithAnimation((node, index, step) async {
      _addStep(step);
      if (node != null) {
        setState(() {
          selectedValue = node.value;
          _updateNodeWidgets();
        });
        await _scrollToNode(index);
      }
      await Future.delayed(const Duration(milliseconds: 500));
    });

    setState(() {
      operationText = "Traversal complete!";
      selectedValue = null;
      isOperating = false;
      _updateNodeWidgets();
    });
  }

  Future<void> _clearList() async {
    setState(() {
      isOperating = true;
      operationText = "Clearing the list";
      operationSteps.clear();
      _addStep("Starting to clear the list...");
    });

    await list.clearWithAnimation((node, index, step) async {
      _addStep(step);
      setState(() {
        selectedValue = node?.value;
        _updateNodeWidgets();
      });
      if (node != null) {
        await _scrollToNode(index);
      }
    });

    setState(() {
      operationText = "List cleared!";
      selectedValue = null;
      valueController.clear();
      positionController.clear();
      isOperating = false;
      _updateNodeWidgets();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      child: Scaffold(
      appBar: AppBar(
        title: const Text(
          'Circular Linked List Visualizer',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
          backgroundColor: primaryColor,
        foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
              onPressed: _toggleTheme,
              tooltip: isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            ),
          ],
      ),
      body: Container(
        decoration: BoxDecoration(
            gradient: backgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Operation Status Card
                Card(
                  elevation: 8,
                  shadowColor: Colors.black26,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                    color: cardBackgroundColor,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                        gradient: cardGradient,
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 20,
                          ),
                          decoration: BoxDecoration(
                              gradient: headerGradient,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                  color: isDarkMode 
                                      ? Colors.black38 
                                      : Colors.blue.shade200,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            operationText,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          height: 120,
                          decoration: BoxDecoration(
                              color: isDarkMode ? Colors.grey.shade900 : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: borderColor),
                            boxShadow: [
                              BoxShadow(
                                  color: isDarkMode 
                                      ? Colors.black38 
                                      : Colors.grey.shade200,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ListView.builder(
                            controller: _stepsController,
                            padding: const EdgeInsets.all(12),
                            itemCount: operationSteps.length,
                            itemBuilder: (context, index) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 3),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.arrow_right_rounded,
                                    size: 20,
                                      color: primaryColor,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      operationSteps[index],
                                      style: TextStyle(
                                        fontSize: 14,
                                          color: textColor,
                                        height: 1.3,
                                      ),
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
                ),
                const SizedBox(height: 20),

                // Visualization Card
                Card(
                  elevation: 8,
                  shadowColor: Colors.black26,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                    color: cardBackgroundColor,
                  child: Container(
                    height: 240,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                        gradient: cardGradient,
                    ),
                    child: nodeWidgets.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.account_tree_rounded,
                                  size: 56,
                                    color: isDarkMode 
                                        ? Colors.blue.shade700 
                                        : Colors.blue.shade200,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  "List is empty",
                                  style: TextStyle(
                                      color: textColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: nodeWidgets.length,
                            itemBuilder: (context, index) => nodeWidgets[index],
                          ),
                  ),
                ),
                const SizedBox(height: 20),

                // Controls Card
                Card(
                  elevation: 8,
                  shadowColor: Colors.black26,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                    color: cardBackgroundColor,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                        gradient: cardGradient,
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: valueController,
                                label: 'Value',
                                icon: Icons.input_rounded,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildTextField(
                                controller: positionController,
                                label: 'Position',
                                icon: Icons.format_list_numbered_rounded,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          alignment: WrapAlignment.center,
                          children: [
                            _buildOperationButton(
                              'Insert at Head',
                              Icons.add_circle_outline_rounded,
                              _insertAtBeginning,
                            ),
                            _buildOperationButton(
                              'Insert at Tail',
                              Icons.add_circle_rounded,
                              _insertAtEnd,
                            ),
                            _buildOperationButton(
                              'Insert at Position',
                              Icons.post_add_rounded,
                              _insertAtPosition,
                            ),
                            _buildOperationButton(
                              'Delete Node',
                              Icons.delete_outline_rounded,
                              _deleteNode,
                            ),
                            _buildOperationButton(
                              'Search Node',
                              Icons.search_rounded,
                              _searchNode,
                            ),
                            _buildOperationButton(
                              'Traverse List',
                              Icons.loop_rounded,
                              _traverseList,
                            ),
                            _buildOperationButton(
                              'Clear List',
                              Icons.clear_all_rounded,
                              _clearList,
                              color: Colors.red.shade600,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Info Card
                Card(
                  elevation: 8,
                  shadowColor: Colors.black26,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                    color: cardBackgroundColor,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                        gradient: cardGradient,
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          'List Information',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                              color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow('Length', '${list.length}'),
                        _buildInfoRow('Head', '${list.head?.value ?? "null"}'),
                        _buildInfoRow('Tail', '${list.tail?.value ?? "null"}'),
                        _buildInfoRow(
                          'Tail points to',
                          '${list.tail?.next?.value ?? "null"}',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        filled: true,
        fillColor: isDarkMode ? Colors.grey.shade900 : Colors.white,
        prefixIcon: Icon(icon, color: primaryColor),
      ),
    );
  }

  Widget _buildOperationButton(
    String text,
    IconData icon,
    VoidCallback onPressed, {
    Color? color,
  }) {
    return ElevatedButton.icon(
      onPressed: isOperating ? null : onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        backgroundColor: color ?? secondaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
      ),
      icon: Icon(icon),
      label: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: textColor,
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: primaryColor,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class NodeWidget extends StatelessWidget {
  final int value;
  final int? pointer;
  final bool isHead;
  final bool isTail;
  final bool isHighlighted;
  final int index;
  final bool isCircular;
  final bool isDarkMode;

  const NodeWidget({
    required this.value,
    required this.pointer,
    required this.isHead,
    required this.isTail,
    required this.isHighlighted,
    required this.index,
    this.isCircular = false,
    this.isDarkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final headColor = isHead ? Colors.green : null;
    final tailColor = isTail ? Colors.red : null;
    final regularColor = isDarkMode ? Colors.blue.shade600 : Colors.blue;
    final nodeColor = headColor ?? tailColor ?? regularColor;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (!isTail || isCircular)
            Positioned(
              right: -20,
              top: 50,
              child: CustomPaint(
                size: const Size(40, 20),
                painter: _ArrowPainter(isDarkMode),
              ),
            ),

          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Node [$index]',
                style: TextStyle(
                  fontSize: 12,
                  color: isHighlighted ? Colors.blue : isDarkMode ? Colors.grey.shade400 : Colors.grey,
                  fontWeight:
                      isHighlighted ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              const SizedBox(height: 8),

              Container(
                width: 120,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      isHighlighted
                          ? (isDarkMode ? Colors.amber.shade800 : Colors.amber.shade100)
                          : (isDarkMode ? Colors.grey.shade800 : Colors.grey.shade50),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: nodeColor,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.blue.shade900 : Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Data', 
                            style: TextStyle(
                              fontSize: 10,
                              color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade800,
                            ),
                          ),
                          Text(
                            '$value',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.green.shade900 : Colors.green.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Next', 
                            style: TextStyle(
                              fontSize: 10,
                              color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade800,
                            ),
                          ),
                          Text(
                            pointer != null ? '→ $pointer' : 'NULL',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black,
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
        ],
      ),
    );
  }
}

class _ArrowPainter extends CustomPainter {
  final bool isDarkMode;
  
  _ArrowPainter(this.isDarkMode);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = isDarkMode ? Colors.white.withOpacity(1.0) : Colors.black.withOpacity(1.0)
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round;

    canvas.drawLine(const Offset(0, 10), Offset(size.width - 10, 10), paint);

    final path =
        Path()
          ..moveTo(size.width - 10, 10)
          ..lineTo(size.width - 20, 5)
          ..lineTo(size.width - 20, 15)
          ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CircularLinkedList {
  Node? head;
  Node? tail;
  int length = 0;

  void insertAtBeginning(int value) {
    Node newNode = Node(value);
    if (head == null) {
      head = tail = newNode;
      tail!.next = head;
    } else {
      newNode.next = head;
      head = newNode;
      tail!.next = head;
    }
    length++;
  }

  void insertAtEnd(int value) {
    Node newNode = Node(value);
    if (tail == null) {
      head = tail = newNode;
      tail!.next = head;
    } else {
      tail!.next = newNode;
      tail = newNode;
      tail!.next = head;
    }
    length++;
  }

  void insertAtPosition(int value, int position) {
    if (position == 0) {
      insertAtBeginning(value);
      return;
    }
    if (position >= length) {
      insertAtEnd(value);
      return;
    }

    Node? current = head;
    for (int i = 0; i < position - 1; i++) {
      current = current!.next;
    }

    Node newNode = Node(value, current!.next);
    current.next = newNode;
    length++;
  }

  void delete(int value) {
    if (head == null) return;

    Node? current = head;
    Node? prev = tail;

    do {
      if (current!.value == value) {
        if (current == head) {
          head = head!.next;
          tail!.next = head;
          if (head == tail) {
            // Only one node left
            tail!.next = head;
          }
        } else if (current == tail) {
          prev!.next = head;
          tail = prev;
        } else {
          prev!.next = current.next;
        }
        length--;
        return;
      }
      prev = current;
      current = current.next;
    } while (current != head);
  }

  bool contains(int value) {
    if (head == null) return false;

    Node? current = head;
    do {
      if (current!.value == value) return true;
      current = current.next;
    } while (current != head);

    return false;
  }

  Future<void> insertAtBeginningWithAnimation(
    int value,
    Function(Node?, int?, String) onStep,
  ) async {
    Node newNode = Node(value);

    await onStep(newNode, 0, "Creating new node with value $value");
    await Future.delayed(const Duration(milliseconds: 800));

    if (head == null) {
      await onStep(newNode, 0, "List is empty, setting head and tail");
      head = tail = newNode;
      tail!.next = head;
      await onStep(newNode, 0, "Making list circular (tail points to head)");
    } else {
      await onStep(head, 0, "Current head node: ${head!.value}");
      await Future.delayed(const Duration(milliseconds: 800));

      newNode.next = head;
      await onStep(newNode, 0, "Set new node's next to current head");
      await Future.delayed(const Duration(milliseconds: 800));

      head = newNode;
      tail!.next = head;
      await onStep(head, 0, "Updated head and made tail point to new head");
    }
    length++;

    await onStep(newNode, 0, "Insertion complete. New length: $length");
  }

  Future<void> insertAtEndWithAnimation(
    int value,
    Function(Node?, int?, String) onStep,
  ) async {
    Node newNode = Node(value);

    if (tail == null) {
      await onStep(newNode, 0, "List is empty, creating first node");
      head = tail = newNode;
      tail!.next = head;
      await onStep(newNode, 0, "Set both head and tail to new node (circular)");
      await Future.delayed(const Duration(milliseconds: 800));
    } else {
      await onStep(tail, length - 1, "Current tail node: ${tail!.value}");
      await Future.delayed(const Duration(milliseconds: 800));

      tail!.next = newNode;
      await onStep(tail, length - 1, "Set current tail's next to new node");
      await Future.delayed(const Duration(milliseconds: 800));

      tail = newNode;
      tail!.next = head;
      await onStep(tail, length, "Updated tail and made it point to head");
      await Future.delayed(const Duration(milliseconds: 800));
    }
    length++;

    await onStep(
      newNode,
      length - 1,
      "Insertion complete. New length: $length",
    );
  }

  Future<void> insertAtPositionWithAnimation(
    int value,
    int position,
    Function(Node?, int?, String) onStep,
  ) async {
    if (position == 0) {
      await insertAtBeginningWithAnimation(value, onStep);
      return;
    }
    if (position >= length) {
      await insertAtEndWithAnimation(value, onStep);
      return;
    }

    await onStep(head, 0, "Starting insertion at position $position");
    await Future.delayed(const Duration(milliseconds: 500));

    Node? current = head;
    for (int i = 0; i < position - 1; i++) {
      current = current!.next;
      await onStep(
        current,
        i,
        "Traversing to node at position $i (value: ${current?.value})",
      );
      await Future.delayed(const Duration(milliseconds: 500));
    }

    Node newNode = Node(value, current!.next);
    await onStep(
      current,
      position - 1,
      "Found insertion point after node ${current.value}",
    );
    await Future.delayed(const Duration(milliseconds: 800));

    await onStep(newNode, position, "Creating new node with value $value");
    await Future.delayed(const Duration(milliseconds: 800));

    current.next = newNode;
    await onStep(
      newNode,
      position,
      "Inserted new node after node ${current.value}",
    );
    await Future.delayed(const Duration(milliseconds: 800));

    length++;
    await onStep(newNode, position, "Insertion complete. New length: $length");
  }

  Future<void> deleteWithAnimation(
    int value,
    Function(Node?, int?, String) onStep,
  ) async {
    if (head == null) {
      await onStep(null, null, "List is empty, nothing to delete");
      return;
    }

    Node? current = head;
    Node? prev = tail;
    int index = 0;

    do {
      if (current!.value == value) {
        await onStep(current, index, "Found value $value at position $index");
        await Future.delayed(const Duration(milliseconds: 800));

        if (current == head) {
          head = head!.next;
          tail!.next = head;
          await onStep(head, 0, "Updated head to ${head?.value}");
          await Future.delayed(const Duration(milliseconds: 800));

          if (head == tail) {
            await onStep(
              head,
              0,
              "Only one node left, maintaining circularity",
            );
          } else {
            await onStep(tail, length - 1, "Updated tail to point to new head");
          }
        } else if (current == tail) {
          prev!.next = head;
          tail = prev;
          await onStep(tail, length - 2, "Updated tail to ${tail!.value}");
          await Future.delayed(const Duration(milliseconds: 800));
          await onStep(tail, length - 2, "Tail now points back to head");
        } else {
          prev!.next = current.next;
          await onStep(prev, index - 1, "Bypassed node with value $value");
        }
        length--;
        await onStep(null, null, "Deletion complete. New length: $length");
        return;
      }
      prev = current;
      current = current.next;
      index++;
      await onStep(
        current,
        index,
        "Traversing to node at position $index (value: ${current?.value})",
      );
      await Future.delayed(const Duration(milliseconds: 500));
    } while (current != head);

    await onStep(null, null, "Value $value not found in the list");
  }

  Future<bool> searchWithAnimation(
    int value,
    Function(Node?, int?, String) onStep,
  ) async {
    if (head == null) {
      await onStep(null, null, "List is empty, value not found");
      return false;
    }

    Node? current = head;
    int index = 0;

    do {
      await onStep(
        current,
        index,
        "Checking node $index (value: ${current!.value})",
      );
      await Future.delayed(const Duration(milliseconds: 500));

      if (current.value == value) {
        await onStep(current, index, "Found value $value at position $index");
        return true;
      }
      current = current.next;
      index++;
    } while (current != head);

    await onStep(null, null, "Value $value not found in the list");
    return false;
  }

  Future<void> traverseWithAnimation(
    Function(Node?, int?, String) onStep,
  ) async {
    if (head == null) {
      await onStep(null, null, "List is empty");
      return;
    }

    Node? current = head;
    int index = 0;

    do {
      await onStep(
        current,
        index,
        "Visiting node $index (value: ${current!.value})",
      );
      await Future.delayed(const Duration(milliseconds: 500));
      current = current.next;
      index++;
    } while (current != head);

    await onStep(
      null,
      null,
      "Traversal complete. Visited $index nodes (circular back to head)",
    );
  }

  Future<void> clearWithAnimation(Function(Node?, int?, String) onStep) async {
    if (head == null) {
      await onStep(null, null, "List is already empty");
      return;
    }

    await onStep(head, 0, "Starting to clear the list...");
    await Future.delayed(const Duration(milliseconds: 500));

    Node? current = head;
    int index = 0;
    do {
      await onStep(current, index, "Removing node with value ${current!.value}");
      await Future.delayed(const Duration(milliseconds: 300));
      current = current.next;
      index++;
    } while (current != head);

    head = null;
    tail = null;
    length = 0;
    await onStep(null, null, "List cleared successfully");
  }
}

class Node {
  int value;
  Node? next;

  Node(this.value, [this.next]);
}
