import 'package:flutter/material.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

class SortingVisualizer extends StatelessWidget {
  const SortingVisualizer({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sorting Algorithm Visualizer',
      theme: ThemeData(
        primarySwatch: Colors.brown,
        brightness: Brightness.light,
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFFBF8F65),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFBF8F65),
            foregroundColor: Colors.white,
            textStyle: TextStyle(fontSize: 16),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: SortingVisualizerScreen(),
    );
  }
}

class AnimatedBubble {
  double x;
  double y;
  double size;
  double speed;
  double opacity;

  AnimatedBubble({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
  });

  void update(double maxHeight) {
    y -= speed;
    if (y < -size) {
      y = maxHeight + size;
    }
  }
}

class BubbleBackgroundPainter extends CustomPainter {
  final List<AnimatedBubble> bubbles;
  final Color topColor;
  final Color bottomColor;

  BubbleBackgroundPainter({
    required this.bubbles,
    required this.topColor,
    required this.bottomColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw gradient background
    Paint gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [topColor, bottomColor],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      gradientPaint,
    );

    // Draw bubbles
    for (var bubble in bubbles) {
      Paint bubblePaint = Paint()
        ..color = topColor.withOpacity(bubble.opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(bubble.x, bubble.y),
        bubble.size,
        bubblePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class SortingVisualizerScreen extends StatefulWidget {
  const SortingVisualizerScreen({super.key});

  @override
  _SortingVisualizerScreenState createState() =>
      _SortingVisualizerScreenState();
}

class _SortingVisualizerScreenState extends State<SortingVisualizerScreen>
    with SingleTickerProviderStateMixin {
  List<int> array = [64, 34, 25, 12, 22, 11, 90];
  int activeIndex = -1;
  int secondaryIndex = -1;
  bool isSorting = false;
  bool stopSorting = false;
  final TextEditingController _controller = TextEditingController();
  String selectedAlgorithm = 'Bubble Sort';
  double animationSpeed = 0.5;
  late AnimationController _animationController;
  String? _inputErrorText;
  final int maxArraySize = 20;
  String complexity = 'O(n^2)';
  String complexityDescription =
      'Bubble Sort has a time complexity of O(n^2), which means the time it takes to sort increases quadratically with the number of elements.';
  
  // Add a variable to track current step description
  String currentStepDescription = "Select an algorithm and press 'Sort' to begin.";

  // Background animation properties
  List<AnimatedBubble> bubbles = [];
  final Color topColor = Color(0xFFF5E1C0); // Creamy light color
  final Color bottomColor = Color(0xFFD3A887); // Warm creamy brown

  final Map<String, String> algorithmComplexities = {
    'Bubble Sort': 'O(n^2)',
    'Selection Sort': 'O(n^2)',
    'Insertion Sort': 'O(n^2)',
    'Quick Sort': 'O(n log n)',
  };

  final Map<String, String> algorithmComplexityDescriptions = {
    'Bubble Sort':
        'Bubble Sort has a time complexity of O(n^2), which means the time it takes to sort increases quadratically with the number of elements.',
    'Selection Sort':
        'Selection Sort has a time complexity of O(n^2), similar to Bubble Sort.',
    'Insertion Sort':
        'Insertion Sort also has a time complexity of O(n^2) in the worst case, but it can perform better with nearly sorted data.',
    'Quick Sort':
        'Quick Sort has an average time complexity of O(n log n), making it more efficient for larger datasets.',
  };

  final List<String> algorithms = [
    'Bubble Sort',
    'Selection Sort',
    'Insertion Sort',
    'Quick Sort',
  ];

  // Add a list to store operation history
  List<String> operationHistory = [];
  ScrollController operationScrollController = ScrollController();

  // Add a flag to track if info dialog is open
  bool isInfoDialogOpen = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 50),
      vsync: this,
    )..repeat();
    
    _animationController.addListener(_updateBubbles);
    
    // Initialize bubbles
    _initBubbles();
    
    _loadSettings();
    // Add memory management for the TextEditingController
    _controller.addListener(() {
      // Clear error text when user starts typing
      if (_inputErrorText != null && _controller.text.isNotEmpty) {
        setState(() {
          _inputErrorText = null;
        });
      }
    });
    
    // Add initial instruction to operation history
    operationHistory.add("Select an algorithm and press 'Sort' to begin.");
  }

  void _initBubbles() {
    final random = Random();
    
    // Create 15 bubbles with random properties
    for (int i = 0; i < 15; i++) {
      bubbles.add(AnimatedBubble(
        x: random.nextDouble() * 400, // Random x position
        y: random.nextDouble() * 800, // Random y position
        size: 20 + random.nextDouble() * 60, // Random size between 20-80
        speed: 0.2 + random.nextDouble() * 0.5, // Random speed
        opacity: 0.1 + random.nextDouble() * 0.2, // Random opacity
      ));
    }
  }

  void _updateBubbles() {
    for (var bubble in bubbles) {
      bubble.update(800); // Assume screen height is 800, will be constrained by actual size
    }
    setState(() {});
  }

  @override
  void dispose() {
    _animationController.dispose();
    _controller.dispose();
    operationScrollController.dispose(); // Dispose the scroll controller
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      animationSpeed = (prefs.getDouble('animationSpeed') ?? 0.5);
      selectedAlgorithm = (prefs.getString('selectedAlgorithm') ?? 'Bubble Sort');
      complexity = algorithmComplexities[selectedAlgorithm] ?? 'O(n^2)';
      complexityDescription = algorithmComplexityDescriptions[selectedAlgorithm] ??
          'Bubble Sort has a time complexity of O(n^2), which means the time it takes to sort increases quadratically with the number of elements.';
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('animationSpeed', animationSpeed);
    await prefs.setString('selectedAlgorithm', selectedAlgorithm);
  }

  // Update this method to add operations to history
  void _updateStepDescription(String description) {
    setState(() {
      currentStepDescription = description;
      operationHistory.add(description);
    });
    
    // Scroll to the bottom of the history list
    Future.delayed(Duration(milliseconds: 100), () {
      if (operationScrollController.hasClients) {
        operationScrollController.animateTo(
          operationScrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void sortArray() async {
    // Clear history when starting a new sort
    setState(() {
      operationHistory = [];
      isSorting = true;
      stopSorting = false;
    });
    
    _updateStepDescription("Starting $selectedAlgorithm...");

    switch (selectedAlgorithm) {
      case 'Bubble Sort':
        await bubbleSort();
        break;
      case 'Selection Sort':
        await selectionSort();
        break;
      case 'Insertion Sort':
        await insertionSort();
        break;
      case 'Quick Sort':
        await quickSort(0, array.length - 1);
        break;
    }

    setState(() {
      isSorting = false;
      activeIndex = -1;
      secondaryIndex = -1;
    });
    
    _updateStepDescription("Sorting complete!");
  }

  Future<void> bubbleSort() async {
    for (int i = 0; i < array.length - 1; i++) {
      _updateStepDescription("Bubble sort pass ${i + 1}: Moving largest unsorted element to the end");
      
      for (int j = 0; j < array.length - i - 1; j++) {
        if (stopSorting) return;
        
        setState(() {
          currentStepDescription = "Comparing ${array[j]} and ${array[j + 1]}";
          activeIndex = j;
          secondaryIndex = j + 1;
        });
        
        await Future.delayed(Duration(milliseconds: (500 * (1 - animationSpeed)).toInt()));
        
        if (array[j] > array[j + 1]) {
          int temp = array[j];
          array[j] = array[j + 1];
          array[j + 1] = temp;

          _updateStepDescription("Swapping ${array[j+1]} and ${array[j]} because ${array[j+1]} > ${array[j]}");
          setState(() {
            activeIndex = j;
            secondaryIndex = j + 1;
          });

          await Future.delayed(Duration(milliseconds: (500 * (1 - animationSpeed)).toInt()));
        }
      }
      
      _updateStepDescription("Pass ${i + 1} complete. Position ${array.length - i - 1} now has ${array[array.length - i - 1]}");
      await Future.delayed(Duration(milliseconds: (500 * (1 - animationSpeed)).toInt()));
    }
  }

  Future<void> selectionSort() async {
    for (int i = 0; i < array.length - 1; i++) {
      _updateStepDescription("Selection sort pass ${i + 1}: Finding minimum element to place at position $i");
      
      int minIndex = i;
      for (int j = i + 1; j < array.length; j++) {
        if (stopSorting) return;
        
        setState(() {
          currentStepDescription = "Checking if ${array[j]} is smaller than current minimum ${array[minIndex]}";
          activeIndex = minIndex;
          secondaryIndex = j;
        });

        await Future.delayed(Duration(milliseconds: (500 * (1 - animationSpeed)).toInt()));
        
        if (array[j] < array[minIndex]) {
          setState(() {
            currentStepDescription = "New minimum found: ${array[j]} at position $j";
            minIndex = j;
          });
        }
      }

      if (minIndex != i) {
        setState(() {
          currentStepDescription = "Swapping minimum value ${array[minIndex]} with ${array[i]}";
        });
        
        int temp = array[minIndex];
        array[minIndex] = array[i];
        array[i] = temp;

        setState(() {
          activeIndex = i;
          secondaryIndex = minIndex;
        });

        await Future.delayed(Duration(milliseconds: (500 * (1 - animationSpeed)).toInt()));
      } else {
        setState(() {
          currentStepDescription = "${array[i]} is already in the correct position";
        });
        
        await Future.delayed(Duration(milliseconds: (500 * (1 - animationSpeed)).toInt()));
      }
      
      _updateStepDescription("Position $i now has ${array[i]} - the ${i+1}${i==0?'st':i==1?'nd':i==2?'rd':'th'} smallest element");
    }
  }

  Future<void> insertionSort() async {
    _updateStepDescription("Starting Insertion Sort: Position 0 (${array[0]}) is already sorted");
    await Future.delayed(Duration(milliseconds: (500 * (1 - animationSpeed)).toInt()));
    
    for (int i = 1; i < array.length; i++) {
      int key = array[i];
      int j = i - 1;

      _updateStepDescription("Inserting $key into the sorted portion of the array");
      
      await Future.delayed(Duration(milliseconds: (500 * (1 - animationSpeed)).toInt()));

      while (j >= 0 && array[j] > key) {
        if (stopSorting) return;
        
        setState(() {
          currentStepDescription = "${array[j]} > $key, shifting ${array[j]} to the right";
          activeIndex = j + 1;
          secondaryIndex = j;
        });
        
        array[j + 1] = array[j];
        j--;

        await Future.delayed(Duration(milliseconds: (500 * (1 - animationSpeed)).toInt()));
      }

      if (j + 1 != i) {
        setState(() {
          currentStepDescription = "Placing $key at position ${j + 1}";
          array[j + 1] = key;
          activeIndex = j + 1;
        });
        
        await Future.delayed(Duration(milliseconds: (500 * (1 - animationSpeed)).toInt()));
      } else {
        setState(() {
          currentStepDescription = "$key is already in the correct position";
        });
        
        await Future.delayed(Duration(milliseconds: (500 * (1 - animationSpeed)).toInt()));
      }
      
      _updateStepDescription("Elements 0 through $i are now sorted");
      
      await Future.delayed(Duration(milliseconds: (500 * (1 - animationSpeed)).toInt()));
    }
  }

  Future<void> quickSort(int low, int high) async {
    if (low < high) {
      _updateStepDescription("Quicksort: Partitioning array from index $low to $high");
      
      int pivotIndex = await partition(low, high);
      
      _updateStepDescription("Pivot ${array[pivotIndex]} is now at the correct position $pivotIndex");
      
      await Future.delayed(Duration(milliseconds: (500 * (1 - animationSpeed)).toInt()));
      
      if (stopSorting) return;
      
      _updateStepDescription("Recursively sorting elements before pivot (index $low to ${pivotIndex - 1})");
      
      await quickSort(low, pivotIndex - 1);
      
      if (stopSorting) return;
      
      _updateStepDescription("Recursively sorting elements after pivot (index ${pivotIndex + 1} to $high)");
      
      await quickSort(pivotIndex + 1, high);
    } else if (low == high) {
      setState(() {
        currentStepDescription = "Subarray with single element ${array[low]} is already sorted";
        activeIndex = low;
      });
      
      await Future.delayed(Duration(milliseconds: (500 * (1 - animationSpeed)).toInt()));
    }
  }

  Future<int> partition(int low, int high) async {
    int pivot = array[high];
    
    setState(() {
      currentStepDescription = "Choosing pivot: $pivot (element at index $high)";
      activeIndex = high;
    });
    
    await Future.delayed(Duration(milliseconds: (500 * (1 - animationSpeed)).toInt()));
    
    int i = low - 1;

    for (int j = low; j < high; j++) {
      if (stopSorting) return low; // Return a valid index instead of 0
      
      setState(() {
        currentStepDescription = "Comparing ${array[j]} with pivot $pivot";
        secondaryIndex = j;
      });
      
      await Future.delayed(Duration(milliseconds: (500 * (1 - animationSpeed)).toInt()));
      
      if (array[j] < pivot) {
        i++;
        
        if (i != j) {
          setState(() {
            currentStepDescription = "${array[j]} < $pivot, swapping ${array[i]} and ${array[j]}";
          });
          
          int temp = array[i];
          array[i] = array[j];
          array[j] = temp;

          setState(() {
            activeIndex = i;
            secondaryIndex = j;
          });

          await Future.delayed(Duration(milliseconds: (500 * (1 - animationSpeed)).toInt()));
        } else {
          setState(() {
            currentStepDescription = "${array[j]} < $pivot, but no swap needed";
            activeIndex = i;
          });
          
          await Future.delayed(Duration(milliseconds: (500 * (1 - animationSpeed)).toInt()));
        }
      } else {
        setState(() {
          currentStepDescription = "${array[j]} >= $pivot, no action needed";
        });
        
        await Future.delayed(Duration(milliseconds: (300 * (1 - animationSpeed)).toInt()));
      }
    }

    setState(() {
      currentStepDescription = "Placing pivot $pivot in its correct position";
    });
    
    int temp = array[i + 1];
    array[i + 1] = array[high];
    array[high] = temp;

    setState(() {
      activeIndex = i + 1;
      secondaryIndex = high;
    });

    await Future.delayed(Duration(milliseconds: (500 * (1 - animationSpeed)).toInt()));

    return i + 1;
  }

  void resetArray() {
    setState(() {
      array = [64, 34, 25, 12, 22, 11, 90];
      activeIndex = -1;
      secondaryIndex = -1;
      currentStepDescription = "Array reset to default values.";
    });
  }

  void updateArray() {
    String input = _controller.text;

    // Input validation
    if (input.isEmpty) {
      setState(() {
        _inputErrorText = 'Please enter an array.';
      });
      return;
    }

    // Validate input format
    if (!RegExp(r'^[0-9,]+$').hasMatch(input)) {
      setState(() {
        _inputErrorText =
            'Invalid input. Please enter numbers separated by commas.';
      });
      return;
    }

    List<int> newArray =
        input.split(',').map((e) => int.tryParse(e.trim()) ?? 0).toList();

    if (newArray.length > maxArraySize) {
      setState(() {
        _inputErrorText =
            'Array size exceeds the maximum limit of $maxArraySize.';
      });
      return;
    }

    setState(() {
      array = newArray;
      activeIndex = -1;
      secondaryIndex = -1;
      _inputErrorText = null; // Clear any previous error
      currentStepDescription = "Array updated with user values.";
    });
    _controller.clear();
  }

  void randomizeArray() {
    final random = Random();
    List<int> newArray =
        List.generate(10, (_) => random.nextInt(100)); 
    setState(() {
      array = newArray;
      activeIndex = -1;
      secondaryIndex = -1;
      currentStepDescription = "Array filled with random values.";
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions to make UI adaptive
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360; // Check if it's a small screen
    final horizontalPadding = isSmallScreen ? 8.0 : 16.0;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sorting Algorithm Visualizer',
          style: TextStyle(
            fontSize: isSmallScreen ? 18 : 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: Color(0xFFAD8B73),
        elevation: 4,
        actions: [
          // Add info button before the other actions
          IconButton(
            icon: Icon(Icons.info_outline, color: Colors.white),
            onPressed: () => _showInfoDialog(context),
            tooltip: 'Algorithm Information',
          ),
          IconButton(
            icon: Icon(
              Icons.play_arrow, 
              color: isSorting ? Colors.grey[400] : Colors.white,
            ),
            onPressed: isSorting ? null : sortArray,
            tooltip: 'Sort',
          ),
          IconButton(
            icon: Icon(
              Icons.stop, 
              color: isSorting ? Colors.white : Colors.grey[400],
            ),
            onPressed: isSorting
                ? () {
                    setState(() {
                      stopSorting = true;
                      isSorting = false;
                      currentStepDescription = "Sorting stopped by user.";
                      operationHistory.add("Sorting stopped by user.");
                    });
                  }
                : null,
            tooltip: 'Stop',
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: resetArray,
            tooltip: 'Reset',
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          // Update bubble positions based on actual screen size
          for (var bubble in bubbles) {
            if (bubble.x > constraints.maxWidth) {
              bubble.x = constraints.maxWidth * Random().nextDouble();
            }
          }
          
          return Stack(
            children: [
              // Animated background with bubbles
              CustomPaint(
                painter: BubbleBackgroundPainter(
                  bubbles: bubbles,
                  topColor: topColor,
                  bottomColor: bottomColor,
                ),
                size: Size(constraints.maxWidth, constraints.maxHeight),
              ),
              
              // Content
              SingleChildScrollView(
                physics: BouncingScrollPhysics(), // Smoother scrolling
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding, 
                    vertical: 4.0
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Main control buttons at the top
                      Container(
                        margin: EdgeInsets.only(bottom: 12),
                        child: Wrap(
                          alignment: WrapAlignment.spaceEvenly,
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ElevatedButton.icon(
                              onPressed: isSorting ? null : sortArray,
                              icon: Icon(Icons.play_arrow),
                              label: Text(
                                'Sort',
                                style: TextStyle(fontSize: isSmallScreen ? 12 : 14),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFBF8F65),
                                foregroundColor: Colors.white,
                                shadowColor: Color(0xFFD6B894),
                                elevation: 5,
                                side: BorderSide(color: Colors.brown[200]!),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                disabledBackgroundColor: Color(0xFFD2B48C),
                                disabledForegroundColor: Colors.white70,
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: isSorting
                                  ? () {
                                      setState(() {
                                        stopSorting = true;
                                        isSorting = false;
                                        currentStepDescription = "Sorting stopped by user.";
                                        operationHistory.add("Sorting stopped by user.");
                                      });
                                    }
                                  : null,
                              icon: Icon(Icons.stop),
                              label: Text(
                                'Stop',
                                style: TextStyle(fontSize: isSmallScreen ? 12 : 14),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFE57373),
                                foregroundColor: Colors.white,
                                shadowColor: Color(0xFFFFCDD2),
                                elevation: 5,
                                side: BorderSide(color: Colors.red[200]!),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                disabledBackgroundColor: Color(0xFFE0E0E0),
                                disabledForegroundColor: Colors.grey[600],
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: resetArray, 
                              icon: Icon(Icons.refresh),
                              label: Text(
                                'Reset',
                                style: TextStyle(fontSize: isSmallScreen ? 12 : 14),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF90A4AE),
                                foregroundColor: Colors.white,
                                shadowColor: Color(0xFFCFD8DC),
                                elevation: 5,
                                side: BorderSide(color: Colors.blueGrey[200]!),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Input field for user array with creamy theme styling
                      TextField(
                        controller: _controller,
                        keyboardType: TextInputType.numberWithOptions(
                            decimal: false, signed: false),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9,]')),
                        ],
                        decoration: InputDecoration(
                          labelText: 'Enter array (comma-separated)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          labelStyle: TextStyle(
                            color: Color(0xFF7D5A44),
                            fontSize: isSmallScreen ? 14 : 16,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12, 
                            vertical: isSmallScreen ? 8 : 12
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFAD8B73)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF8D6E63), width: 2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          errorText: _inputErrorText,
                          fillColor: Color(0xFFF5E1C0).withOpacity(0.5),
                          filled: true,
                        ),
                        style: TextStyle(
                          color: Color(0xFF5D4037),
                          fontSize: isSmallScreen ? 14 : 16,
                        ),
                      ),
                      SizedBox(height: 8),
                      
                      // Action buttons for array with updated styling
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: updateArray,
                            icon: Icon(Icons.update),
                            label: Text(
                              'Update Array',
                              style: TextStyle(fontSize: isSmallScreen ? 12 : 14),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF9575CD),
                              foregroundColor: Colors.white,
                              shadowColor: Color(0xFFD1C4E9),
                              elevation: 5,
                              side: BorderSide(color: Color(0xFFB39DDB)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ), 
                            ),
                          ElevatedButton.icon(
                            onPressed: randomizeArray,
                            icon: Icon(Icons.shuffle),
                            label: Text(
                              'Randomize Array',
                              style: TextStyle(fontSize: isSmallScreen ? 12 : 14),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF80CBC4),
                              foregroundColor: Colors.white,
                              shadowColor: Color(0xFFB2DFDB),
                              elevation: 5,
                              side: BorderSide(color: Color(0xFF4DB6AC)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      
                      // Dropdown and speed controls in one row for better layout
                      Row(
                        children: [
                          // Algorithm selection dropdown with creamy styling
                          Expanded(
                            flex: 3,
                            child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12, 
                          vertical: isSmallScreen ? 2 : 4
                        ),
                        decoration: BoxDecoration(
                                color: Color(0xFFE6CCB2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Color(0xFFAD8B73)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFF7D5A44).withOpacity(0.2),
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: selectedAlgorithm,
                                  dropdownColor: Color(0xFFF5E1C0),
                                  icon: Icon(Icons.arrow_drop_down, color: Color(0xFF7D5A44)),
                            items: algorithms.map((String algorithm) {
                              return DropdownMenuItem<String>(
                                value: algorithm,
                                child: Text(
                                  algorithm,
                                  style: TextStyle(
                                          color: Color(0xFF5D4037),
                                    fontSize: isSmallScreen ? 12 : 14,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: isSorting
                                ? null
                                : (String? newValue) {
                                    setState(() {
                                      selectedAlgorithm = newValue!;
                                      complexity = algorithmComplexities[selectedAlgorithm] ?? 'O(n^2)';
                                      complexityDescription = algorithmComplexityDescriptions[selectedAlgorithm] ??
                                          'Bubble Sort has a time complexity of O(n^2), which means the time it takes to sort increases quadratically with the number of elements.';
                                    });
                                    _saveSettings();
                                  },
                          ),
                        ),
                      ),
                          ),
                          SizedBox(width: 8),
                          
                          // Speed control with creamy styling
                          Expanded(
                            flex: 2,
                            child: Container(
                              padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
                        decoration: BoxDecoration(
                                color: Color(0xFFE6CCB2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Color(0xFFAD8B73)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFF7D5A44).withOpacity(0.2),
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                        ),
                        child: Row(
                          children: [
                                  Icon(
                                    Icons.speed, 
                                    color: Color(0xFF7D5A44),
                                    size: isSmallScreen ? 16 : 18,
                            ),
                            Expanded(
                                    child: SliderTheme(
                                      data: SliderThemeData(
                                        activeTrackColor: Color(0xFF8D6E63),
                                        inactiveTrackColor: Color(0xFFCEB195),
                                        thumbColor: Color(0xFF5D4037),
                                        overlayColor: Color(0xFF8D6E63).withOpacity(0.3),
                                        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8),
                                        overlayShape: RoundSliderOverlayShape(overlayRadius: 16),
                                      ),
                              child: Slider(
                                value: animationSpeed,
                                min: 0.0,
                                max: 1.0,
                                onChanged: (value) {
                                  setState(() {
                                    animationSpeed = value;
                                  });
                                  _saveSettings();
                                },
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      
                      // Enhanced Current Operation panel with history and animations
                      Container(
                        height: isSmallScreen ? 180 : 200,
                        margin: EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFFF5E1C0),
                              Color(0xFFE6CCB2),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSorting ? Color(0xFF8D6E63) : Color(0xFFCEB195),
                            width: 2.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF8D6E63).withOpacity(0.3),
                              blurRadius: 10,
                              spreadRadius: isSorting ? 2 : 0,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header with animation
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Color(0xFFCEB195),
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(14),
                                ),
                              ),
                              child: Row(
                              children: [
                                  // Animated icon
                                  TweenAnimationBuilder<double>(
                                    tween: Tween<double>(begin: 0.0, end: isSorting ? 1.0 : 0.0),
                                    duration: Duration(milliseconds: 500),
                                    builder: (context, value, child) {
                                      return Transform.rotate(
                                        angle: value * 2 * 3.14159,
                                        child: Icon(
                                          Icons.auto_awesome,
                                          color: Color(0xFF5D4037),
                                          size: isSmallScreen ? 18 : 20,
                                        ),
                                      );
                                    },
                                  ),
                                  SizedBox(width: 8),
                                Text(
                                    'Sorting Operations:',
                                  style: TextStyle(
                                      color: Color(0xFF5D4037),
                                    fontWeight: FontWeight.bold,
                                      fontSize: isSmallScreen ? 14 : 16,
                                    ),
                                  ),
                                  Spacer(),
                                  if (isSorting)
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Color(0xFF8D6E63),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(
                                            width: 12,
                                            height: 12,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            ),
                                          ),
                                          SizedBox(width: 4),
                            Text(
                                            'Sorting...',
                              style: TextStyle(
                                color: Colors.white,
                                              fontSize: isSmallScreen ? 10 : 12,
                              ),
                                          ),
                                        ],
                                      ),
                            ),
                          ],
                        ),
                      ),
                      
                            // Scrollable history list
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Color(0xFFF5E1C0).withOpacity(0.7),
                                  borderRadius: BorderRadius.vertical(
                                    bottom: Radius.circular(14),
                                  ),
                                ),
                                child: ListView.builder(
                                  controller: operationScrollController,
                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  itemCount: operationHistory.length,
                                  itemBuilder: (context, index) {
                                    final isLatest = index == operationHistory.length - 1;
                                    return AnimatedContainer(
                                      duration: Duration(milliseconds: 300),
                                      margin: EdgeInsets.symmetric(vertical: 4),
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: isLatest 
                                            ? Color(0xFFDDB892).withOpacity(0.7)
                                            : Color(0xFFE6CCB2).withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: isLatest 
                                              ? Color(0xFF8D6E63) 
                                              : Color(0xFFCEB195).withOpacity(0.5),
                                          width: isLatest ? 1.0 : 0.5,
                                        ),
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            margin: EdgeInsets.only(top: 2, right: 8),
                                            padding: EdgeInsets.all(2),
                                            decoration: BoxDecoration(
                                              color: isLatest 
                                                  ? Color(0xFF8D6E63) 
                                                  : Color(0xFFAD8B73).withOpacity(0.7),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              isLatest ? Icons.check_circle : Icons.arrow_right,
                                              color: Colors.white,
                                              size: isSmallScreen ? 12 : 14,
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              operationHistory[index],
                                              style: TextStyle(
                                                color: Color(0xFF5D4037),
                                                fontSize: isSmallScreen ? 12 : 13,
                                                fontWeight: isLatest ? FontWeight.w500 : FontWeight.normal,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Visualization area with enhanced styling
                      Container(
                        height: isSmallScreen 
                            ? min(screenSize.height * 0.4, 300)
                            : min(screenSize.height * 0.45, 350),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFF5E1C0).withOpacity(0.8), Color(0xFFCEB195).withOpacity(0.9)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Color(0xFFAD8B73),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF7D5A44).withOpacity(0.25),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        padding: EdgeInsets.all(isSmallScreen ? 4 : 8),
                        child: array.length <= 15 
                            ? _buildBarVisualization(isSmallScreen) 
                            : _buildGridVisualization(isSmallScreen),
                      ),
                      SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBarVisualization(bool isSmallScreen) {
    // Find the maximum value for scaling
    int maxValue = array.isEmpty ? 1 : array.reduce((a, b) => a > b ? a : b);
    maxValue = maxValue > 0 ? maxValue : 1;
    
    // Calculate available height for bars
    final containerHeight = isSmallScreen 
        ? min(MediaQuery.of(context).size.height * 0.32, 240.0)
        : min(MediaQuery.of(context).size.height * 0.35, 280.0);
    
    // Calculate available width per bar
    final availableWidth = MediaQuery.of(context).size.width - 
        (isSmallScreen ? 32.0 : 48.0); // Account for screen padding
    final barWidth = (availableWidth / array.length) - 4; // 4px for padding
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(array.length, (index) {
        // Update colors to match creamy theme
        Color barColor = Color(0xFF8D6E63); // Default brown for bars
        
        if (index == activeIndex) {
          barColor = Color(0xFFFF8A65); // Orange for active
        } else if (index == secondaryIndex) {
          barColor = Color(0xFF66BB6A); // Green for secondary
        } else if (index < array.length - 1 &&
            array.sublist(0, index + 1).every((element) =>
                array.sublist(0, index + 1).indexOf(element) <= index)) {
          barColor = Color(0xFFAD8B73); // Light brown for sorted
        }
        
        // Calculate the normalized height (between 0.1 and 1.0)
        double normalizedHeight = 0.1 + (array[index] / maxValue) * 0.9;
        
        return Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Value label with improved styling
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${array[index]}',
                    style: TextStyle(
                      color: Color(0xFF5D4037), // Dark brown
                      fontSize: isSmallScreen ? 8 : 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 2),
                
                // Enhanced animated bar with shadow and shimmer effect
                TweenAnimationBuilder(
                  tween: Tween<double>(
                    begin: 0.0,
                    end: normalizedHeight * (containerHeight * 0.85),
                  ),
                  duration: Duration(milliseconds: 500),
                  curve: Curves.easeOutCubic,
                  builder: (context, double height, child) {
                    return Container(
                      height: height,
                      width: max(barWidth, 8.0),
                  decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            barColor.withOpacity(0.7),
                            barColor,
                          ],
                        ),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(6),
                    ),
                    boxShadow: [
                      BoxShadow(
                            color: barColor.withOpacity(0.4),
                            blurRadius: 4,
                            spreadRadius: 0.5,
                            offset: Offset(0, 2),
                      ),
                    ],
                    border: Border.all(
                          color: Colors.white.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                      child: (index == activeIndex || index == secondaryIndex)
                      ? ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                                colors: [Colors.white.withOpacity(0.3), barColor],
                            stops: [0.0, 0.7],
                          ).createShader(bounds),
                          child: Container(
                            color: Colors.white.withOpacity(0.2),
                          ),
                        )
                      : null,
                    );
                  },
                ),
                
                // Index indicator with improved styling
                Container(
                  margin: EdgeInsets.only(top: 2),
                  padding: EdgeInsets.symmetric(
                    horizontal: 3,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: Color(0xFF5D4037).withOpacity(0.7),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: FittedBox(
                    child: Text(
                      '$index',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isSmallScreen ? 6 : 8,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildGridVisualization(bool isSmallScreen) {
    // Calculate how many items per row based on screen size
    int crossAxisCount = isSmallScreen
        ? min(5, array.length) // Max 5 elements per row on small screens
        : min(8, array.length); // Max 8 elements per row on larger screens
        
    // For very large arrays, increase items per row
    if (array.length > 15) {
      crossAxisCount = isSmallScreen ? 5 : 8; 
    }
    
    return GridView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 2 : 4,
        vertical: isSmallScreen ? 4 : 8,
      ),
      physics: NeverScrollableScrollPhysics(), // Prevent nested scrolling
      shrinkWrap: true, // Important to prevent overflow
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 1,
        crossAxisSpacing: isSmallScreen ? 2 : 3,
        mainAxisSpacing: isSmallScreen ? 2 : 3,
      ),
      itemCount: array.length,
      itemBuilder: (context, index) {
        Color elementColor = Colors.blue.shade400;
        Color textColor = Colors.white;
        double scale = 1.0;

        if (index == activeIndex) {
          elementColor = Colors.redAccent;
          scale = 1.1; // Slightly reduced scale to prevent overflow
        } else if (index == secondaryIndex) {
          elementColor = Colors.greenAccent;
          textColor = Colors.black87;
          scale = 1.1; // Slightly reduced scale to prevent overflow
        } else if (index < array.length - 1 &&
            array.sublist(0, index + 1).every((element) =>
                array.sublist(0, index + 1).indexOf(element) <= index)) {
          elementColor = Colors.purpleAccent;
        }

        return AnimatedContainer(
          duration: Duration(milliseconds: 300),
          transform: Matrix4.identity()..scale(scale),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                elementColor,
                elementColor.withOpacity(0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: Colors.white54,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: elementColor.withOpacity(0.5),
                blurRadius: isSmallScreen ? 3 : 5, // Reduced blur
                spreadRadius: isSmallScreen ? 0.5 : 1, // Reduced spread
              ),
            ],
          ),
          child: Stack(
            children: [
              // Value display
              Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Padding(
                    padding: EdgeInsets.all(1),
                    child: Text(
                      '${array[index]}',
                      style: TextStyle(
                        color: textColor,
                        fontSize: isSmallScreen ? 12 : 14, // Slightly smaller font
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              // Index indicator - smaller and more compact
              Positioned(
                right: 1,
                bottom: 1,
                child: Container(
                  padding: EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Text(
                    '$index',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: isSmallScreen ? 6 : 8, // Smaller font
                    ),
                  ),
                ),
              ),
              // Pulse effect for active elements
              if (index == activeIndex || index == secondaryIndex)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: Colors.white,
                          width: 1, // Thinner border
                        ),
                      ),
                      child: Opacity(
                        opacity: 0.2, // More subtle effect
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // Add this method to show the info dialog
  void _showInfoDialog(BuildContext context) {
    if (isInfoDialogOpen) return; // Prevent multiple dialogs
    
    isInfoDialogOpen = true;
    
    showDialog(
      context: context,
      builder: (context) {
        final isSmallScreen = MediaQuery.of(context).size.width < 360;
        
        return Dialog(
          backgroundColor: Color(0xFFF5E1C0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Color(0xFFAD8B73), width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFFAD8B73),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.auto_awesome, color: Colors.white),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Sorting Algorithms Information',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: isSmallScreen ? 16 : 18,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.white),
                      onPressed: () {
                        isInfoDialogOpen = false;
                        Navigator.of(context).pop();
                      },
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                    ),
                  ],
                ),
              ),
              
              // Content - Scrollable
              Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                ),
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildAlgorithmInfoSection(
                          'Bubble Sort',
                          'O(n²)',
                          'Repeatedly steps through the list, compares adjacent elements, and swaps them if they are in the wrong order. The process is repeated until the list is sorted.',
                          'Best for educational purposes and small datasets.',
                          ['Simple to understand and implement', 'Works well for small datasets', 'In-place sorting (requires no extra space)'],
                          ['Very inefficient for large datasets', 'Has O(n²) time complexity in worst and average cases']
                        ),
                        
                        _buildAlgorithmInfoSection(
                          'Selection Sort',
                          'O(n²)',
                          'Divides the input list into a sorted and an unsorted region. It repeatedly finds the minimum element from the unsorted region and moves it to the beginning of the sorted region.',
                          'Best for small arrays or where memory usage is a concern.',
                          ['Simple implementation', 'Performs well on small datasets', 'Makes the minimum number of swaps (O(n))'],
                          ['Inefficient on large lists', 'O(n²) time complexity in all cases']
                        ),
                        
                        _buildAlgorithmInfoSection(
                          'Insertion Sort',
                          'O(n²)',
                          'Builds the sorted array one item at a time. It takes each element from the unsorted part and inserts it into its correct position in the sorted part.',
                          'Best for nearly sorted data and small datasets.',
                          ['Efficient for small datasets', 'Adaptive - efficient for datasets that are already substantially sorted', 'Stable sort algorithm'],
                          ['Inefficient for large datasets', 'O(n²) worst-case time complexity']
                        ),
                        
                        _buildAlgorithmInfoSection(
                          'Quick Sort',
                          'O(n log n)',
                          'Uses a divide-and-conquer strategy. It picks an element as a pivot and partitions the array around the pivot, then recursively sorts the sub-arrays.',
                          'Best for general-purpose sorting with large datasets.',
                          ['Efficient on large datasets with O(n log n) average time complexity', 'In-place sorting algorithm', 'Cache friendly'],
                          ['O(n²) worst-case time complexity (rare with good pivot selection)', 'Not stable by default']
                        ),
                        
                        Divider(color: Color(0xFFAD8B73)),
                        
                        // How to use the visualizer
                        Text(
                          'How to Use the Visualizer:',
                          style: TextStyle(
                            color: Color(0xFF5D4037),
                            fontWeight: FontWeight.bold,
                            fontSize: isSmallScreen ? 16 : 18,
                          ),
                        ),
                        SizedBox(height: 12),
                        
                        _buildInstructionItem(
                          '1. Select Algorithm', 
                          'Choose a sorting algorithm from the dropdown menu.'
                        ),
                        _buildInstructionItem(
                          '2. Adjust Speed', 
                          'Use the speed slider to control how fast the animation runs.'
                        ),
                        _buildInstructionItem(
                          '3. Customize Array', 
                          'Enter custom values or click "Randomize Array" to generate random numbers.'
                        ),
                        _buildInstructionItem(
                          '4. Start Sorting', 
                          'Click the "Sort" button to begin the visualization.'
                        ),
                        _buildInstructionItem(
                          '5. Track Operations', 
                          'The "Sorting Operations" panel shows each step of the algorithm.'
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Footer Button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: ElevatedButton(
                  onPressed: () {
                    isInfoDialogOpen = false;
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF8D6E63),
                    foregroundColor: Colors.white,
                    elevation: 3,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline),
                      SizedBox(width: 8),
                      Text(
                        'Got it!', 
                        style: TextStyle(
                          fontSize: 16, 
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ).then((_) => isInfoDialogOpen = false); // Ensure flag is reset
  }
  
  // Helper method to build algorithm info sections
  Widget _buildAlgorithmInfoSection(
    String name, 
    String complexity, 
    String description,
    String bestUse,
    List<String> advantages,
    List<String> disadvantages
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name,
              style: TextStyle(
                color: Color(0xFF5D4037),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Color(0xFFAD8B73),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                complexity,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Text(
          description,
          style: TextStyle(
            color: Color(0xFF5D4037),
            fontSize: 14,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Best use: $bestUse',
          style: TextStyle(
            color: Color(0xFF5D4037),
            fontStyle: FontStyle.italic,
            fontSize: 14,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Advantages:',
          style: TextStyle(
            color: Color(0xFF5D4037),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        ...advantages.map((advantage) => Padding(
          padding: EdgeInsets.only(left: 16, top: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 16),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  advantage,
                  style: TextStyle(
                    color: Color(0xFF5D4037),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        )).toList(),
        SizedBox(height: 8),
        Text(
          'Disadvantages:',
          style: TextStyle(
            color: Color(0xFF5D4037),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        ...disadvantages.map((disadvantage) => Padding(
          padding: EdgeInsets.only(left: 16, top: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.remove_circle, color: Colors.red, size: 16),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  disadvantage,
                  style: TextStyle(
                    color: Color(0xFF5D4037),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        )).toList(),
        Divider(color: Color(0xFFAD8B73), height: 32),
      ],
    );
  }
  
  // Helper method to build instruction items
  Widget _buildInstructionItem(String title, String description) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Color(0xFFCEB195),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.arrow_forward,
              color: Color(0xFF5D4037),
              size: 14,
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
                    color: Color(0xFF5D4037),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Color(0xFF5D4037),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
