import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class DoublyLinkedListVisualization extends StatefulWidget {
  const DoublyLinkedListVisualization({super.key});

  @override
  State<DoublyLinkedListVisualization> createState() =>
      _DoublyLinkedListVisualizationState();
}

class _DoublyLinkedListVisualizationState
    extends State<DoublyLinkedListVisualization> {
  final DoublyLinkedList list = DoublyLinkedList();
  List<DLLNodeWidget> nodeWidgets = [];
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
  Color get prevPointerColor => isDarkMode ? Colors.purple.shade900 : Colors.purple.shade100;
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

  List<DLLNodeWidget> _buildNodeWidgets() {
    List<DLLNodeWidget> widgets = [];
    DLLNode? current = list.head;
    int index = 0;

    while (current != null) {
      widgets.add(
        DLLNodeWidget(
          value: current.value,
          nextPointer: current.next?.value,
          prevPointer: current.prev?.value,
          isHead: current == list.head,
          isTail: current == list.tail,
          isHighlighted: selectedValue == current.value,
          index: index,
          isDarkMode: isDarkMode,
          nodeBackgroundColor: nodeBackgroundColor,
          nodeHighlightColor: nodeHighlightColor,
          prevPointerColor: prevPointerColor,
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

    final double itemWidth = 160;
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
    if (list.head == null) {
      setState(() => operationText = "List is already empty!");
      return;
    }

    setState(() {
      isOperating = true;
      operationText = "Clearing the list";
      operationSteps.clear();
      _addStep("Starting to clear the list...");
    });

    while (list.head != null) {
      setState(() {
        selectedValue = list.head?.value;
        list.delete(list.head!.value);
        _updateNodeWidgets();
      });
      _addStep("Removed node with value ${selectedValue}");
      await Future.delayed(const Duration(milliseconds: 300));
    }

    setState(() {
      operationText = "List cleared successfully!";
      selectedValue = null;
      isOperating = false;
      _updateNodeWidgets();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doubly Linked List Visualizer'),
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
                      fontWeight: FontWeight.w600,
                      color: operationTextColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Steps Container
              Card(
                elevation: 3,
                color: cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  height: 120,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListView.builder(
                    controller: _stepsController,
                    itemCount: operationSteps.length,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          Icon(Icons.arrow_right, color: primaryColor),
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
              ),
              const SizedBox(height: 16),

              // Visualization Container
              Card(
                elevation: 4,
                color: cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Container(
                  height: 240,
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: nodeWidgets.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.info_outline, 
                                  size: 40, color: secondaryTextColor),
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
              const SizedBox(height: 24),

              // Input Fields
              Row(
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
                      label: 'Position',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Operation Buttons
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildOperationButton(
                      'Insert at Head',
                      _insertAtBeginning,
                      Colors.green.shade600,
                    ),
                    _buildOperationButton(
                      'Insert at Tail',
                      _insertAtEnd,
                      Colors.blue.shade600,
                    ),
                    _buildOperationButton(
                      'Insert at Position',
                      _insertAtPosition,
                      Colors.orange.shade600,
                    ),
                    _buildOperationButton(
                      'Delete Node',
                      _deleteNode,
                      Colors.red.shade600,
                    ),
                    _buildOperationButton(
                      'Search Node',
                      _searchNode,
                      Colors.purple.shade600,
                    ),
                    _buildOperationButton(
                      'Traverse List',
                      _traverseList,
                      Colors.teal.shade600,
                    ),
                    _buildOperationButton(
                      'Clear List',
                      _clearList,
                      Colors.deepOrange.shade600,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              Divider(thickness: 1, color: dividerColor),
              
              // List Information
              Card(
                elevation: 2,
                color: cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
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
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: cardColor,
        labelStyle: TextStyle(color: secondaryTextColor),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade300),
        ),
      ),
    );
  }

  Widget _buildOperationButton(String text, VoidCallback onPressed, Color color) {
    // Adjust color based on theme
    Color buttonColor = isDarkMode ? color.withOpacity(0.8) : color;
    
    return ElevatedButton(
      onPressed: isOperating ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
        shadowColor: buttonColor.withOpacity(0.4),
        disabledBackgroundColor: operationButtonDisabledColor,
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
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
              fontWeight: FontWeight.w600,
              color: primaryColor,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class DLLNodeWidget extends StatelessWidget {
  final int value;
  final int? nextPointer;
  final int? prevPointer;
  final bool isHead;
  final bool isTail;
  final bool isHighlighted;
  final int index;
  final bool isDarkMode;
  final Color nodeBackgroundColor;
  final Color nodeHighlightColor;
  final Color prevPointerColor;
  final Color dataColor;
  final Color nextPointerColor;
  final Color arrowColor;
  final Color textColor;

  const DLLNodeWidget({
    required this.value,
    required this.nextPointer,
    required this.prevPointer,
    required this.isHead,
    required this.isTail,
    required this.isHighlighted,
    required this.index,
    required this.isDarkMode,
    required this.nodeBackgroundColor,
    required this.nodeHighlightColor,
    required this.prevPointerColor,
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
          // Previous pointer arrow
          if (!isHead)
            Positioned(
              left: -20,
              top: 80,
              child: CustomPaint(
                size: const Size(40, 20),
                painter: _BackArrowPainter(arrowColor: arrowColor),
              ),
            ),

          // Next pointer arrow
          if (!isTail)
            Positioned(
              right: -20,
              top: 80,
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
                width: 140,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isHighlighted
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
                    // Previous pointer
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: prevPointerColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        children: [
                          Text('Prev', 
                            style: TextStyle(fontSize: 10, color: textColor)),
                          Text(
                            prevPointer != null ? '$prevPointer ←' : 'NULL',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Data
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

                    // Next pointer
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
                            nextPointer != null ? '→ $nextPointer' : 'NULL',
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

class _BackArrowPainter extends CustomPainter {
  final Color arrowColor;
  
  _BackArrowPainter({required this.arrowColor});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = arrowColor
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(size.width - 10, 10), const Offset(0, 10), paint);

    final path =
        Path()
          ..moveTo(10, 10)
          ..lineTo(20, 5)
          ..lineTo(20, 15)
          ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DoublyLinkedList {
  DLLNode? head;
  DLLNode? tail;
  int length = 0;

  void insertAtBeginning(int value) {
    DLLNode newNode = DLLNode(value);
    newNode.next = head;

    if (head != null) {
      head!.prev = newNode;
    } else {
      tail = newNode;
    }

    head = newNode;
    length++;
  }

  void insertAtEnd(int value) {
    DLLNode newNode = DLLNode(value);
    newNode.prev = tail;

    if (tail != null) {
      tail!.next = newNode;
    } else {
      head = newNode;
    }

    tail = newNode;
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

    DLLNode? current = head;
    for (int i = 0; i < position - 1; i++) {
      current = current!.next;
    }

    DLLNode newNode = DLLNode(value);
    newNode.next = current!.next;
    newNode.prev = current;

    if (current.next != null) {
      current.next!.prev = newNode;
    }

    current.next = newNode;
    length++;
  }

  void delete(int value) {
    if (head == null) return;

    // Case 1: Deleting head node
    if (head!.value == value) {
      head = head!.next;
      if (head != null) {
        head!.prev = null;
      } else {
        tail = null;
      }
      length--;
      return;
    }

    // Case 2: Deleting middle or tail node
    DLLNode? current = head;
    while (current != null && current.value != value) {
      current = current.next;
    }

    if (current == null) return;

    if (current.prev != null) {
      current.prev!.next = current.next;
    }

    if (current.next != null) {
      current.next!.prev = current.prev;
    } else {
      tail = current.prev;
    }

    length--;
  }

  bool contains(int value) {
    DLLNode? current = head;
    while (current != null) {
      if (current.value == value) return true;
      current = current.next;
    }
    return false;
  }

  Future<void> insertAtBeginningWithAnimation(
    int value,
    Function(DLLNode?, int?, String) onStep,
  ) async {
    DLLNode newNode = DLLNode(value);

    await onStep(newNode, 0, "Creating new node with value $value");
    await Future.delayed(const Duration(milliseconds: 800));

    newNode.next = head;
    await onStep(
      newNode,
      0,
      "Setting new node's next to current head (${head?.value ?? 'null'})",
    );
    await Future.delayed(const Duration(milliseconds: 800));

    if (head != null) {
      await onStep(
        head,
        1,
        "Setting current head's prev to new node (value: $value)",
      );
      head!.prev = newNode;
      await Future.delayed(const Duration(milliseconds: 800));
    } else {
      await onStep(newNode, 0, "List was empty, setting tail to new node");
      tail = newNode;
      await Future.delayed(const Duration(milliseconds: 800));
    }

    head = newNode;
    await onStep(newNode, 0, "Updating head to point to new node");
    length++;

    await onStep(newNode, 0, "Insertion complete. New length: $length");
  }

  Future<void> insertAtEndWithAnimation(
    int value,
    Function(DLLNode?, int?, String) onStep,
  ) async {
    DLLNode newNode = DLLNode(value);

    if (tail == null) {
      await onStep(newNode, 0, "List is empty, creating first node");
      head = tail = newNode;
      await onStep(newNode, 0, "Set both head and tail to new node");
      await Future.delayed(const Duration(milliseconds: 800));
    } else {
      await onStep(tail, length - 1, "Current tail node: ${tail!.value}");
      await Future.delayed(const Duration(milliseconds: 800));

      newNode.prev = tail;
      await onStep(
        newNode,
        length,
        "Setting new node's prev to current tail (${tail!.value})",
      );
      await Future.delayed(const Duration(milliseconds: 800));

      tail!.next = newNode;
      await onStep(
        tail,
        length - 1,
        "Setting current tail's next to new node (value: $value)",
      );
      await Future.delayed(const Duration(milliseconds: 800));

      tail = newNode;
      await onStep(tail, length, "Updated tail to new node");
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
    Function(DLLNode?, int?, String) onStep,
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

    DLLNode? current = head;
    for (int i = 0; i < position - 1; i++) {
      current = current!.next;
      await onStep(
        current,
        i + 1,
        "Traversing to node at position ${i + 1} (value: ${current!.value})",
      );
      await Future.delayed(const Duration(milliseconds: 500));
    }

    DLLNode newNode = DLLNode(value);
    await onStep(
      current,
      position - 1,
      "Found insertion point after node ${current!.value}",
    );
    await Future.delayed(const Duration(milliseconds: 800));

    newNode.next = current.next;
    newNode.prev = current;
    await onStep(
      newNode,
      position,
      "Setting new node's next to ${current.next?.value ?? 'null'} and prev to ${current.value}",
    );
    await Future.delayed(const Duration(milliseconds: 800));

    if (current.next != null) {
      await onStep(
        current.next,
        position + 1,
        "Setting next node's (${current.next!.value}) prev to new node ($value)",
      );
      current.next!.prev = newNode;
      await Future.delayed(const Duration(milliseconds: 800));
    }

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
    Function(DLLNode?, int?, String) onStep,
  ) async {
    if (head == null) {
      await onStep(null, null, "List is empty, nothing to delete");
      return;
    }

    // Case 1: Deleting head node
    if (head!.value == value) {
      await onStep(head, 0, "Found value $value at head node");
      await Future.delayed(const Duration(milliseconds: 800));

      head = head!.next;
      await onStep(head, 0, "Updated head to ${head?.value ?? 'null'}");
      await Future.delayed(const Duration(milliseconds: 800));

      if (head != null) {
        await onStep(
          head,
          0,
          "Setting new head's prev to null (was pointing to deleted node)",
        );
        head!.prev = null;
        await Future.delayed(const Duration(milliseconds: 800));
      } else {
        await onStep(null, null, "List is now empty, updated tail to null");
        tail = null;
      }
      length--;
      await onStep(null, null, "Deletion complete. New length: $length");
      return;
    }

    // Case 2: Deleting middle or tail node
    DLLNode? current = head;
    int index = 0;
    while (current != null && current.value != value) {
      current = current.next;
      index++;
      await onStep(
        current,
        index,
        "Traversing to node at position $index (value: ${current?.value})",
      );
      await Future.delayed(const Duration(milliseconds: 500));
    }

    if (current == null) {
      await onStep(null, null, "Value $value not found in the list");
      return;
    }

    await onStep(
      current,
      index,
      "Found node with value $value at position $index",
    );
    await Future.delayed(const Duration(milliseconds: 800));

    if (current.prev != null) {
      await onStep(
        current.prev,
        index - 1,
        "Setting previous node's (${current.prev!.value}) next to ${current.next?.value ?? 'null'}",
      );
      current.prev!.next = current.next;
      await Future.delayed(const Duration(milliseconds: 800));
    }

    if (current.next != null) {
      await onStep(
        current.next,
        index + 1,
        "Setting next node's (${current.next!.value}) prev to ${current.prev?.value ?? 'null'}",
      );
      current.next!.prev = current.prev;
      await Future.delayed(const Duration(milliseconds: 800));
    } else {
      await onStep(
        current.prev,
        index - 1,
        "Updating tail to previous node (${current.prev?.value ?? 'null'})",
      );
      tail = current.prev;
    }

    length--;
    await onStep(null, null, "Deletion complete. New length: $length");
  }

  Future<bool> searchWithAnimation(
    int value,
    Function(DLLNode?, int?, String) onStep,
  ) async {
    DLLNode? current = head;
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
    Function(DLLNode?, int?, String) onStep,
  ) async {
    DLLNode? current = head;
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
}

class DLLNode {
  int value;
  DLLNode? next;
  DLLNode? prev;

  DLLNode(this.value, [this.next, this.prev]);
}
