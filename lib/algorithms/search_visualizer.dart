import 'package:flutter/material.dart';
import 'dart:math';

class SearchVisualizer extends StatefulWidget {
  const SearchVisualizer({super.key});

  @override
  _SearchVisualizerState createState() => _SearchVisualizerState();
}

class _SearchVisualizerState extends State<SearchVisualizer> {
  bool _isDarkMode = false;

  // Light theme colors
  final lightThemeColors = {
    'background1': Color(0xFFFFF8DC), // Cornsilk
    'background2': Color(0xFFFFE4B5), // Moccasin
    'appBar1': Color(0xFFDEB887), // BurlyWood
    'appBar2': Color(0xFFD2B48C), // Tan
    'circleColor': Color(0xFFDEB887).withOpacity(0.1), // BurlyWood with opacity
    'lineColor': Color(0xFFDEB887).withOpacity(0.05), // BurlyWood with lower opacity
    'textPrimary': Colors.black87,
    'textSecondary': Colors.black54,
    'textTertiary': Colors.black45,
  };

  // Dark theme colors
  final darkThemeColors = {
    'background1': Color(0xFF1E1E2E), // Dark blue-purple
    'background2': Color(0xFF2D2D44), // Slightly lighter purple
    'appBar1': Color(0xFF3C3C5C), // Medium purple
    'appBar2': Color(0xFF4A4A6A), // Lighter purple
    'circleColor': Color(0xFF6272A4).withOpacity(0.2), // Dracula purple with opacity
    'lineColor': Color(0xFF6272A4).withOpacity(0.1), // Dracula purple with lower opacity
    'textPrimary': Colors.white,
    'textSecondary': Colors.white70,
    'textTertiary': Colors.white54,
  };

  // Get current theme colors based on mode
  Map<String, Color> get themeColors => _isDarkMode ? darkThemeColors : lightThemeColors;

  void toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Search Algorithm Visualizer',
      theme: ThemeData(
        primarySwatch: _isDarkMode ? Colors.indigo : Colors.brown,
        brightness: _isDarkMode ? Brightness.dark : Brightness.light,
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(color: themeColors['textSecondary']),
          border: OutlineInputBorder(),
        ),
        sliderTheme: SliderThemeData(
          activeTrackColor: _isDarkMode ? Colors.purpleAccent : Colors.orangeAccent,
          thumbColor: _isDarkMode ? Colors.purpleAccent : Colors.orange,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: LayoutBuilder(
            builder: (context, constraints) {
              // Responsive title based on available width
              return Row(
                children: [
                  Icon(Icons.search, color: Colors.white),
                  SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      MediaQuery.of(context).size.width < 400 
                          ? 'Search Visualizer' 
                          : 'Search Algorithm Visualizer',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: MediaQuery.of(context).size.width < 400 ? 16 : 18,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              );
            },
          ),
          leadingWidth: 30,
          titleSpacing: 0,
          actions: [
            // Info Button
            IconButton(
              icon: Icon(Icons.info_outline, size: MediaQuery.of(context).size.width < 400 ? 20 : 24),
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.all(8),
              constraints: BoxConstraints(),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('About Search Algorithms'),
                      content: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Linear Search:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '• Searches each element one by one\n'
                              '• Time Complexity: O(n)\n'
                              '• Works on both sorted and unsorted arrays',
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Binary Search:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '• Requires sorted array\n'
                              '• Time Complexity: O(log n)\n'
                              '• More efficient for large sorted datasets',
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          child: Text('Close'),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            // Help Button
            IconButton(
              icon: Icon(Icons.help_outline, size: MediaQuery.of(context).size.width < 400 ? 20 : 24),
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.all(8),
              constraints: BoxConstraints(),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('How to Use'),
                      content: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '1. Enter numbers separated by commas to create an array\n'
                              '2. Click "Update Array" to visualize the array\n'
                              '3. Enter a number to search for\n'
                              '4. Choose either Linear or Binary Search\n'
                              '5. Use the slider to adjust animation speed\n'
                              '6. Click "Reset" to return to the default array',
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Note: Binary Search requires a sorted array!',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          child: Text('Got it'),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            // Theme Toggle Button
            if (MediaQuery.of(context).size.width >= 360)
              IconButton(
                icon: Icon(
                  _isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  size: MediaQuery.of(context).size.width < 400 ? 20 : 24,
                  color: Colors.white,
                ),
                tooltip: _isDarkMode ? 'Switch to Light Theme' : 'Switch to Dark Theme',
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.all(8),
                constraints: BoxConstraints(),
                onPressed: toggleTheme,
              ),
            SizedBox(width: 5),
          ],
          backgroundColor: themeColors['appBar1'],
          elevation: 0,
          toolbarHeight: 56, // Fixed height
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(15),
            ),
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  themeColors['appBar1']!,
                  themeColors['appBar2']!,
                ],
              ),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(15),
              ),
            ),
          ),
        ),
        body: AnimatedBackground(
          isDarkMode: _isDarkMode,
          themeColors: themeColors,
        ),
      ),
    );
  }
}

class AnimatedBackground extends StatefulWidget {
  final bool isDarkMode;
  final Map<String, Color> themeColors;
  
  const AnimatedBackground({
    super.key, 
    required this.isDarkMode,
    required this.themeColors,
  });

  @override
  _AnimatedBackgroundState createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  List<Offset> _circlePositions = [];
  final int _numCircles = 20; // Number of circles

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2), // Animation speed
    )..repeat();

    // Initialize circle positions randomly
    _generateRandomCirclePositions();
  }

  void _generateRandomCirclePositions() {
    _circlePositions = List.generate(
        _numCircles,
        (index) => Offset(
              Random().nextDouble(), // Random X position (0.0 to 1.0)
              Random().nextDouble(), // Random Y position (0.0 to 1.0)
            ));
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController!,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.themeColors['background1']!,
                widget.themeColors['background2']!,
              ],
            ),
          ),
          child: CustomPaint(
            painter: BackgroundPainter(
              animation: _animationController!.value,
              circlePositions: _circlePositions,
              circleColor: widget.themeColors['circleColor']!,
              lineColor: widget.themeColors['lineColor']!,
            ),
            child: Stack(
              children: [
                SearchVisualizerScreen(
                  isDarkMode: widget.isDarkMode,
                  themeColors: widget.themeColors,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class BackgroundPainter extends CustomPainter {
  final double animation;
  final List<Offset> circlePositions;
  final Color circleColor;
  final Color lineColor;

  BackgroundPainter({
    required this.animation, 
    required this.circlePositions,
    required this.circleColor,
    required this.lineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = circleColor
      ..style = PaintingStyle.fill;

    for (var position in circlePositions) {
      final x = position.dx * size.width;
      final y = position.dy * size.height;
      final radius = 20 + 15 * sin(animation * 2 * pi);
      
      canvas.drawCircle(
        Offset(x, y),
        radius,
        paint,
      );

      if (circlePositions.indexOf(position) > 0) {
        final previousPosition = circlePositions[circlePositions.indexOf(position) - 1];
        final linePaint = Paint()
          ..color = lineColor
          ..strokeWidth = 1;
        
        canvas.drawLine(
          Offset(previousPosition.dx * size.width, previousPosition.dy * size.height),
          Offset(x, y),
          linePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(BackgroundPainter oldDelegate) => true;
}

class SearchVisualizerScreen extends StatefulWidget {
  final bool isDarkMode;
  final Map<String, Color> themeColors;
  
  const SearchVisualizerScreen({
    super.key,
    required this.isDarkMode,
    required this.themeColors,
  });

  @override
  _SearchVisualizerScreenState createState() => _SearchVisualizerScreenState();
}

class _SearchVisualizerScreenState extends State<SearchVisualizerScreen> {
  List<int> array = [2, 5, 8, 12, 16, 23, 38, 56, 72, 91];
  int activeIndex = -1;
  bool isSearching = false;
  final TextEditingController _arrayController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String resultMessage = '';
  bool _isLinearSearchPressed = false;
  bool _isBinarySearchPressed = false;
  String stepDescription = '';
  String animationDescription = '';
  double animationSpeed = 0.5; // Default speed (0.0 to 1.0)

  void updateArray() {
    String input = _arrayController.text;
    List<int> newArray =
        input.split(',').map((e) => int.tryParse(e.trim()) ?? 0).toList();
    setState(() {
      array = newArray;
      activeIndex = -1;
      resultMessage = '';
    });
    _arrayController.clear();
  }

  void linearSearch(int target) async {
    setState(() {
      isSearching = true;
      resultMessage = '';
      stepDescription = 'Linear Search started. Looking for $target.';
      animationDescription = 'Preparing to search...';
    });

    await Future.delayed(Duration(milliseconds: (500 * (1 - animationSpeed)).round()));

    for (int i = 0; i < array.length; i++) {
      setState(() {
        activeIndex = i;
        stepDescription = 'Step $i: Checking if array[$i] (${array[i]}) == $target';
        animationDescription = 'Highlighting element at index $i';
      });

      await Future.delayed(Duration(milliseconds: (500 * (1 - animationSpeed)).round()));

      if (array[i] == target) {
        setState(() {
          resultMessage = 'Found $target at index $i';
          isSearching = false;
          stepDescription = 'Target found at index $i. Linear Search complete.';
          animationDescription = 'Target found at index $i';
        });
        return;
      }
    }

    setState(() {
      resultMessage = '$target not found in the array';
      isSearching = false;
      stepDescription = '$target not found in the array. Linear Search complete.';
      animationDescription = 'Target not found in the array';
    });
  }

  void binarySearch(int target) async {
    setState(() {
      isSearching = true;
      resultMessage = '';
      stepDescription = 'Binary Search started. Looking for $target.';
      animationDescription = 'Preparing to search...';
    });

    int low = 0;
    int high = array.length - 1;
    int step = 1;

    while (low <= high) {
      int mid = (low + high) ~/ 2;

      setState(() {
        activeIndex = mid;
        stepDescription = 'Step $step: Checking if array[$mid] (${array[mid]}) == $target.  Low: $low, High: $high';
        animationDescription = 'Highlighting element at index $mid';
      });

      await Future.delayed(Duration(milliseconds: (500 * (1 - animationSpeed)).round()));

      if (array[mid] == target) {
        setState(() {
          resultMessage = 'Found $target at index $mid';
          isSearching = false;
          stepDescription = 'Target found at index $mid. Binary Search complete.';
          animationDescription = 'Target found at index $mid';
        });
        return;
      } else if (array[mid] < target) {
        low = mid + 1;
        setState(() {
          stepDescription = 'Step $step: array[$mid] (${array[mid]}) < $target.  Setting Low to $low.';
          animationDescription = 'Moving low to mid + 1';
        });
      } else {
        high = mid - 1;
        setState(() {
          stepDescription = 'Step $step: array[$mid] (${array[mid]}) > $target. Setting High to $high.';
          animationDescription = 'Moving high to mid - 1';
        });
      }
      step++;
      await Future.delayed(Duration(milliseconds: (500 * (1 - animationSpeed)).round()));
    }

    setState(() {
      resultMessage = '$target not found in the array';
      isSearching = false;
      stepDescription = '$target not found in the array. Binary Search complete.';
      animationDescription = 'Target not found in the array';
    });
  }

  void reset() {
    setState(() {
      array = [2, 5, 8, 12, 16, 23, 38, 56, 72, 91];
      activeIndex = -1;
      resultMessage = '';
      _arrayController.clear();
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get bar colors based on theme
    final activeBarColors = widget.isDarkMode 
        ? [Colors.red.shade300, Colors.red.shade100] 
        : [Colors.red.shade400, Colors.red.shade200];
    
    final inactiveBarColors = widget.isDarkMode 
        ? [Color(0xFF8657e1), Color(0xFF6a89cc)] 
        : [Color(0xFF4A90E2), Color(0xFF357ABD)];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height - 100, // Account for AppBar
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Search Algorithm Visualizer',
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width < 600 ? 18 : 24,
                  fontWeight: FontWeight.bold,
                  color: widget.themeColors['textPrimary'],
                ),
              ),
              SizedBox(height: 10),
              // Input field for array with theme-aware styling
              TextField(
                controller: _arrayController,
                decoration: InputDecoration(
                  labelText: 'Enter array (comma-separated)',
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(color: widget.themeColors['textSecondary']),
                ),
                style: TextStyle(color: widget.themeColors['textPrimary']),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: updateArray,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.isDarkMode ? Colors.amber.shade700 : Colors.orange,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  textStyle: TextStyle(fontSize: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 5,
                  shadowColor: widget.isDarkMode ? Colors.amber.shade900 : Colors.orange.shade900,
                ),
                child: Text('Update Array')
              ),
              SizedBox(height: 20),
              // Input field for search target
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Enter number to search',
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(color: widget.themeColors['textSecondary']),
                ),
                keyboardType: TextInputType.number,
                style: TextStyle(color: widget.themeColors['textPrimary']),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isSearching
                          ? null
                          : () {
                            setState(() {
                              _isLinearSearchPressed = true;
                            });
                            int target = int.tryParse(_searchController.text) ?? 0;
                            linearSearch(target);
                            Future.delayed(Duration(milliseconds: 200), () {
                              setState(() {
                                _isLinearSearchPressed = false;
                              });
                            });
                          },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isLinearSearchPressed 
                            ? (widget.isDarkMode ? Colors.green.shade900 : Colors.green.shade700)
                            : (widget.isDarkMode ? Colors.green.shade700 : Colors.green),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                        textStyle: TextStyle(fontSize: MediaQuery.of(context).size.width < 600 ? 14 : 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 5,
                        shadowColor: Colors.green.shade900,
                      ),
                      child: Text('Linear Search'),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isSearching
                          ? null
                          : () {
                            setState(() {
                              _isBinarySearchPressed = true;
                            });
                            int target = int.tryParse(_searchController.text) ?? 0;
                            binarySearch(target);
                            Future.delayed(Duration(milliseconds: 200), () {
                              setState(() {
                                _isBinarySearchPressed = false;
                              });
                            });
                          },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isBinarySearchPressed 
                            ? (widget.isDarkMode ? Colors.purple.shade900 : Colors.purple.shade700)
                            : (widget.isDarkMode ? Colors.purple.shade700 : Colors.purple),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                        textStyle: TextStyle(fontSize: MediaQuery.of(context).size.width < 600 ? 14 : 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 5,
                        shadowColor: Colors.purple.shade900,
                      ),
                      child: Text('Binary Search'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              // Animation speed control
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Animation Speed:',
                    style: TextStyle(color: widget.themeColors['textSecondary']),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: animationSpeed,
                          min: 0.1,
                          max: 1.0,
                          activeColor: widget.isDarkMode ? Colors.purpleAccent : Colors.orangeAccent,
                          inactiveColor: widget.isDarkMode 
                              ? Colors.purpleAccent.withOpacity(0.3) 
                              : Colors.orangeAccent.withOpacity(0.3),
                          onChanged: (value) {
                            setState(() {
                              animationSpeed = value;
                            });
                          },
                        ),
                      ),
                      Text(
                        '${(animationSpeed * 100).round()}%',
                        style: TextStyle(color: widget.themeColors['textSecondary']),
                      ),
                    ],
                  ),
                  // Reset button in its own row
                  Center(
                    child: ElevatedButton(
                      onPressed: reset,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.isDarkMode ? Colors.redAccent.shade700 : Colors.red,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        textStyle: TextStyle(fontSize: MediaQuery.of(context).size.width < 600 ? 14 : 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 5,
                        shadowColor: Colors.red.shade900,
                      ),
                      child: Text('Reset')
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              // Array visualization
              Container(
                height: MediaQuery.of(context).size.height * 0.3,
                padding: EdgeInsets.symmetric(vertical: 10),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    double width = constraints.maxWidth;
                    double maxHeight = constraints.maxHeight * 0.8;
                    
                    int maxValue = array.isEmpty ? 1 : array.reduce((a, b) => a > b ? a : b);
                    maxValue = maxValue == 0 ? 1 : maxValue;
                    
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        width: max(width, array.length * 50.0), // Ensure minimum width
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: List.generate(
                            array.length,
                            (index) {
                              double barHeight = (array[index] / maxValue) * maxHeight;
                              barHeight = barHeight < 20 ? 20 : barHeight;
                              
                              return Padding(
                                padding: EdgeInsets.symmetric(horizontal: 2),
                                child: TweenAnimationBuilder(
                                  duration: Duration(milliseconds: 500),
                                  tween: Tween<double>(begin: 0, end: barHeight),
                                  builder: (context, double height, child) {
                                    return Container(
                                      width: 40, // Fixed width for consistency
                                      height: height,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                          colors: index == activeIndex
                                              ? activeBarColors
                                              : inactiveBarColors,
                                        ),
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(8),
                                          bottom: Radius.circular(4),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(widget.isDarkMode ? 0.4 : 0.2),
                                            spreadRadius: 1,
                                            blurRadius: 3,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${array[index]}',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 20),
              // Result message
              Text(
                resultMessage,
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width < 600 ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  color: widget.themeColors['textPrimary'],
                ),
              ),
              SizedBox(height: 5),
              // Step description
              Text(
                stepDescription,
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width < 600 ? 14 : 16,
                  color: widget.themeColors['textSecondary'],
                ),
              ),
              SizedBox(height: 5),
              // Animation description
              Text(
                animationDescription,
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width < 600 ? 14 : 16,
                  fontStyle: FontStyle.italic,
                  color: widget.themeColors['textTertiary'],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

