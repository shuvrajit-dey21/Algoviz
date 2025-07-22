import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class SinglyLinkedListVisualization extends StatefulWidget {
  const SinglyLinkedListVisualization({super.key});

  @override
  State<SinglyLinkedListVisualization> createState() =>
      _SinglyLinkedListVisualizationState();
}

class _SinglyLinkedListVisualizationState
    extends State<SinglyLinkedListVisualization> {
  final LinkedList list = LinkedList();
  List<NodeWidget> nodeWidgets = [];
  String operationText = "Select an operation to begin";
  List<String> operationSteps = [];
  bool isOperating = false;
  int? selectedValue;
  final ScrollController _scrollController = ScrollController();
  final ScrollController _stepsController = ScrollController();
  final TextEditingController valueController = TextEditingController();
  final TextEditingController positionController = TextEditingController();
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    list.insertAtEnd(10);
    list.insertAtEnd(20);
    list.insertAtEnd(30);
    _loadThemePreference();
    _updateNodeWidgets();
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
    _updateNodeWidgets();
  }

  // Custom color getters based on theme
  Color get primaryColor => isDarkMode ? Colors.indigo.shade300 : Colors.indigo;
  Color get scaffoldBackgroundColor => isDarkMode ? Colors.grey.shade900 : Colors.white;
  Color get cardColor => isDarkMode ? Colors.grey.shade800 : Colors.white;
  Color get textColor => isDarkMode ? Colors.white : Colors.grey.shade800;
  Color get secondaryTextColor => isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700;
  Color get operationCardGradient1 => isDarkMode ? Colors.indigo.shade900 : Colors.blue.shade100;
  Color get operationCardGradient2 => isDarkMode ? Colors.indigo.shade800 : Colors.indigo.shade100;
  Color get operationTextColor => isDarkMode ? Colors.white : Colors.indigo;
  Color get operationButtonDisabledColor => isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300;
  Color get nodeBackgroundColor => isDarkMode ? Colors.grey.shade800 : Colors.grey.shade50;
  Color get nodeHighlightColor => isDarkMode ? Colors.amber.shade900 : Colors.amber.shade100;
  Color get dataColor => isDarkMode ? Colors.blue.shade900 : Colors.blue.shade100;
  Color get nextPointerColor => isDarkMode ? Colors.green.shade900 : Colors.green.shade100;
  Color get shadowColor => isDarkMode ? Colors.black54 : Colors.black12;
  Color get dividerColor => isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300;
  Color get arrowColor => isDarkMode ? Colors.white70 : Colors.black;
  
  // Background gradient colors
  List<Color> get backgroundGradient => isDarkMode 
      ? [Colors.grey.shade900, Colors.grey.shade900]
      : [Colors.indigo.shade50, Colors.white];

  void _updateNodeWidgets() {
    setState(() {
      nodeWidgets = _buildNodeWidgets();
    });
  }

  List<NodeWidget> _buildNodeWidgets() {
    List<NodeWidget> widgets = [];
    Node? current = list.head;
    int index = 0;

    while (current != null) {
      widgets.add(
        NodeWidget(
          value: current.value,
          pointer: current.next?.value,
          isHead: current == list.head,
          isTail: current.next == null,
          isHighlighted: selectedValue == current.value,
          index: index,
          isDarkMode: isDarkMode,
          nodeBackgroundColor: nodeBackgroundColor,
          nodeHighlightColor: nodeHighlightColor,
          dataColor: dataColor,
          nextPointerColor: nextPointerColor,
          arrowColor: arrowColor,
          textColor: textColor,
        ),
      );
      current = current.next;
      index++;
    }

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
    });

    setState(() {
      operationText = "List cleared!";
      selectedValue = null;
      isOperating = false;
      _updateNodeWidgets();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Linked List Visualizer',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: _toggleTheme,
            tooltip: isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
          ),
        ],
      ),
      backgroundColor: scaffoldBackgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: backgroundGradient,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Operation Status Card
              Card(
                elevation: 4,
                color: cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [operationCardGradient1, operationCardGradient2],
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    operationText,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: operationTextColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Operation Steps Card
              Card(
                elevation: 4,
                color: cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Container(
                  height: 120,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Operation Steps:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView.builder(
                          controller: _stepsController,
                          itemCount: operationSteps.length,
                          itemBuilder: (context, index) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: [
                                Icon(Icons.arrow_right, 
                                  color: primaryColor,
                                  size: 20,
                                ),
                                Expanded(
                                  child: Text(
                                    operationSteps[index],
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: textColor,
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
              const SizedBox(height: 16),

              // Linked List Visualization Card
              Card(
                elevation: 4,
                color: cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Container(
                  height: 240,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: nodeWidgets.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.list_alt,
                                size: 48,
                                color: secondaryTextColor,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "List is empty",
                                style: TextStyle(
                                  color: secondaryTextColor,
                                  fontSize: 16,
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

              // Input Fields Card
              Card(
                elevation: 4,
                color: cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: valueController,
                          label: 'Value',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          controller: positionController,
                          label: 'Position (for insert)',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Operations Buttons Card
              Card(
                elevation: 4,
                color: cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildOperationButton(
                        'Insert at Head',
                        _insertAtBeginning,
                        icon: Icons.add_circle_outline,
                        color: Colors.green,
                      ),
                      _buildOperationButton(
                        'Insert at Tail',
                        _insertAtEnd,
                        icon: Icons.add_circle,
                        color: Colors.blue,
                      ),
                      _buildOperationButton(
                        'Insert at Position',
                        _insertAtPosition,
                        icon: Icons.add_box_outlined,
                        color: Colors.orange,
                      ),
                      _buildOperationButton(
                        'Delete Node',
                        _deleteNode,
                        icon: Icons.remove_circle_outline,
                        color: Colors.red,
                      ),
                      _buildOperationButton(
                        'Search Node',
                        _searchNode,
                        icon: Icons.search,
                        color: Colors.purple,
                      ),
                      _buildOperationButton(
                        'Traverse List',
                        _traverseList,
                        icon: Icons.loop,
                        color: Colors.teal,
                      ),
                      _buildOperationButton(
                        'Clear List',
                        _clearList,
                        icon: Icons.clear_all,
                        color: Colors.red.shade700,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // List Information Card
              Card(
                elevation: 4,
                color: cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'List Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow('Length', '${list.length}'),
                      _buildInfoRow('Head', '${list.head?.value ?? "null"}'),
                      _buildInfoRow('Tail', '${list.tail?.value ?? "null"}'),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade50,
        labelStyle: TextStyle(color: secondaryTextColor),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade300),
        ),
      ),
    );
  }

  Widget _buildOperationButton(
    String text,
    VoidCallback onPressed, {
    IconData? icon,
    Color? color,
  }) {
    // Adjust color based on theme
    Color buttonColor = isDarkMode ? (color?.withOpacity(0.8) ?? Colors.indigo) : (color ?? Colors.indigo);
    
    return ElevatedButton.icon(
      onPressed: isOperating ? null : onPressed,
      icon: Icon(icon ?? Icons.add),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        disabledBackgroundColor: operationButtonDisabledColor,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: primaryColor,
              fontWeight: FontWeight.bold,
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
  final bool isDarkMode;
  final Color nodeBackgroundColor;
  final Color nodeHighlightColor;
  final Color dataColor;
  final Color nextPointerColor;
  final Color arrowColor;
  final Color textColor;

  const NodeWidget({
    required this.value,
    required this.pointer,
    required this.isHead,
    required this.isTail,
    required this.isHighlighted,
    required this.index,
    required this.isDarkMode,
    required this.nodeBackgroundColor,
    required this.nodeHighlightColor,
    required this.dataColor,
    required this.nextPointerColor,
    required this.arrowColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (!isTail)
            Positioned(
              right: -20,
              top: 50,
              child: CustomPaint(
                size: const Size(40, 20),
                painter: _ArrowPainter(arrowColor: arrowColor),
              ),
            ),

          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Node [$index]',
                style: TextStyle(
                  fontSize: 12,
                  color: isHighlighted 
                      ? (isDarkMode ? Colors.blue.shade300 : Colors.blue) 
                      : (isDarkMode ? Colors.grey.shade400 : Colors.grey),
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
                          ? nodeHighlightColor
                          : nodeBackgroundColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                        isHead
                            ? (isDarkMode ? Colors.green.shade400 : Colors.green)
                            : isTail
                                ? (isDarkMode ? Colors.red.shade400 : Colors.red)
                                : (isDarkMode ? Colors.blue.shade400 : Colors.blue),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDarkMode 
                          ? Colors.black.withOpacity(0.3)
                          : Colors.black.withOpacity(0.1),
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
                        color: dataColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        children: [
                          Text('Data', 
                               style: TextStyle(fontSize: 10, color: textColor)),
                          Text(
                            '$value',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: nextPointerColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        children: [
                          Text('Next', 
                               style: TextStyle(fontSize: 10, color: textColor)),
                          Text(
                            pointer != null ? '→ $pointer' : 'NULL',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: textColor,
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
  final Color arrowColor;
  
  _ArrowPainter({required this.arrowColor});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = arrowColor
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

class LinkedList {
  Node? head;
  Node? tail;
  int length = 0;

  void insertAtBeginning(int value) {
    Node newNode = Node(value, head);
    head = newNode;
    if (tail == null) {
      tail = newNode;
    }
    length++;
  }

  void insertAtEnd(int value) {
    Node newNode = Node(value);
    if (tail == null) {
      head = tail = newNode;
    } else {
      tail!.next = newNode;
      tail = newNode;
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

    if (head!.value == value) {
      head = head!.next;
      if (head == null) tail = null;
      length--;
      return;
    }

    Node? current = head;
    while (current!.next != null && current.next!.value != value) {
      current = current.next;
    }

    if (current.next != null) {
      current.next = current.next!.next;
      if (current.next == null) {
        tail = current;
      }
      length--;
    }
  }

  bool contains(int value) {
    Node? current = head;
    while (current != null) {
      if (current.value == value) return true;
      current = current.next;
    }
    return false;
  }

  Future<void> insertAtBeginningWithAnimation(
    int value,
    Function(Node?, int?, String) onStep,
  ) async {
    Node newNode = Node(value, head);

    await onStep(newNode, 0, "Creating new node with value $value");
    await Future.delayed(const Duration(milliseconds: 800));

    await onStep(
      newNode,
      0,
      "Setting new node's next to current head (${head?.value ?? 'null'})",
    );
    await Future.delayed(const Duration(milliseconds: 800));

    head = newNode;
    if (tail == null) {
      await onStep(newNode, 0, "List was empty, setting tail to new node");
      tail = newNode;
    } else {
      await onStep(newNode, 0, "Updating head to point to new node");
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
      await onStep(newNode, 0, "Set both head and tail to new node");
      await Future.delayed(const Duration(milliseconds: 800));
    } else {
      await onStep(tail!, length - 1, "Current tail node: ${tail!.value}");
      await Future.delayed(const Duration(milliseconds: 800));

      tail!.next = newNode;
      await onStep(tail!, length - 1, "Set current tail's next to new node");
      await Future.delayed(const Duration(milliseconds: 800));

      tail = newNode;
      await onStep(tail!, length, "Updated tail to new node");
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
        i + 1,
        "Traversing to node at position ${i + 1} (value: ${current!.value})",
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

    if (head!.value == value) {
      await onStep(head!, 0, "Found value $value at head node");
      await Future.delayed(const Duration(milliseconds: 800));

      head = head!.next;
      await onStep(head, 0, "Updated head to ${head?.value ?? 'null'}");
      await Future.delayed(const Duration(milliseconds: 800));

      if (head == null) {
        tail = null;
        await onStep(null, null, "List is now empty, updated tail to null");
      }
      length--;
      await onStep(null, null, "Deletion complete. New length: $length");
      return;
    }

    Node? current = head;
    int index = 0;
    while (current!.next != null && current.next!.value != value) {
      current = current.next;
      index++;
      await onStep(
        current,
        index,
        "Traversing to node at position $index (value: ${current?.value ?? 'unknown'})",
      );
      await Future.delayed(const Duration(milliseconds: 500));
    }

    if (current.next != null) {
      await onStep(
        current.next!,
        index + 1,
        "Found node with value $value at position ${index + 1}",
      );
      await Future.delayed(const Duration(milliseconds: 800));

      current.next = current.next!.next;
      await onStep(
        current,
        index,
        "Updated node $index's next to ${current.next?.value ?? 'null'}",
      );
      await Future.delayed(const Duration(milliseconds: 800));

      if (current.next == null) {
        tail = current;
        await onStep(
          tail,
          index,
          "Updated tail to node $index (value: ${tail!.value})",
        );
      }
      length--;
      await onStep(null, null, "Deletion complete. New length: $length");
    } else {
      await onStep(null, null, "Value $value not found in the list");
    }
  }

  Future<bool> searchWithAnimation(
    int value,
    Function(Node?, int?, String) onStep,
  ) async {
    Node? current = head;
    int index = 0;

    if (current == null) {
      await onStep(null, null, "List is empty, value not found");
      return false;
    }

    while (current != null) {
      await onStep(
        current,
        index,
        "Checking node $index (value: ${current.value})",
      );
      await Future.delayed(const Duration(milliseconds: 500));

      if (current.value == value) {
        await onStep(current, index, "Found value $value at position $index");
        return true;
      }
      current = current.next;
      index++;
    }

    await onStep(null, null, "Value $value not found in the list");
    return false;
  }

  Future<void> traverseWithAnimation(
    Function(Node?, int?, String) onStep,
  ) async {
    Node? current = head;
    int index = 0;

    if (current == null) {
      await onStep(null, null, "List is empty");
      return;
    }

    while (current != null) {
      await onStep(
        current,
        index,
        "Visiting node $index (value: ${current.value})",
      );
      await Future.delayed(const Duration(milliseconds: 500));
      current = current.next;
      index++;
    }

    await onStep(null, null, "Traversal complete. Visited $index nodes");
  }

  Future<void> clearWithAnimation(Function(Node?, int?, String) onStep) async {
    if (head == null) {
      await onStep(null, null, "List is already empty");
      return;
    }

    await onStep(head, 0, "Starting to clear the list...");
    await Future.delayed(const Duration(milliseconds: 500));

    while (head != null) {
      Node temp = head!;
      await onStep(temp, 0, "Removing node with value ${temp.value}");
      await Future.delayed(const Duration(milliseconds: 300));
      
      head = head!.next;
    }

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
