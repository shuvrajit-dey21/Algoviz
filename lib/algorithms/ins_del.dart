import 'package:flutter/material.dart';
import 'dart:math' as math;

class ArrayOperations extends StatelessWidget {
  const ArrayOperations({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Array Operations Visualizer',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith<Color>((
              Set<WidgetState> states,
            ) {
              if (states.contains(WidgetState.pressed)) {
                return Colors.deepPurple.shade700;
              }
              return Colors.deepPurple;
            }),
            foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            padding: WidgetStateProperty.all<EdgeInsets>(
              EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            textStyle: WidgetStateProperty.all<TextStyle>(
              TextStyle(fontSize: 16),
            ),
            elevation: WidgetStateProperty.all<double>(3),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: ArrayOperationsScreen(),
    );
  }
}

class ArrayOperationsScreen extends StatefulWidget {
  const ArrayOperationsScreen({super.key});

  @override
  _ArrayOperationsScreenState createState() => _ArrayOperationsScreenState();
}

class _ArrayOperationsScreenState extends State<ArrayOperationsScreen>
    with TickerProviderStateMixin {
  List<int> array = [64, 34, 25, 12, 22, 11, 90];
  int activeIndex = -1;
  final TextEditingController _arrayController = TextEditingController();
  final TextEditingController _insertController = TextEditingController();
  final TextEditingController _indexController = TextEditingController();

  // Animation controllers
  late AnimationController _gradientAnimationController;
  late AnimationController _floatingParticlesController;
  late Animation<double> _gradientAnimation;

  // List of colors for array elements
  final List<Color> _elementColors = [
    Colors.deepPurple,
    Colors.teal,
    Colors.indigo,
    Colors.deepOrange,
    Colors.pink,
    Colors.green,
    Colors.blue,
  ];

  // Generated positions for floating particles
  final List<Offset> _particlePositions = List.generate(20, (index) {
    return Offset(
      math.Random().nextDouble() * 300,
      math.Random().nextDouble() * 700,
    );
  });

  // Add these new animation controllers
  late AnimationController _bubblesAnimationController;
  late AnimationController _pulseAnimationController;
  late Animation<double> _pulseAnimation;
  
  // Add this for storing bubble positions
  final List<BubbleData> _bubbles = List.generate(15, (index) {
    return BubbleData(
      position: Offset(
        math.Random().nextDouble() * 400,
        math.Random().nextDouble() * 800,
      ),
      size: 10 + math.Random().nextDouble() * 30,
      speed: 0.5 + math.Random().nextDouble() * 1.5,
    );
  });
  
  // Add this for theme switching
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();

    // Initialize the gradient animation controller
    _gradientAnimationController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat(reverse: true);

    // Create the gradient animation
    _gradientAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_gradientAnimationController);

    // Initialize the floating particles animation controller
    _floatingParticlesController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat();

    // Initialize bubble animation controller
    _bubblesAnimationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    
    // Initialize pulse animation for AppBar
    _pulseAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(_pulseAnimationController);
  }

  @override
  void dispose() {
    _gradientAnimationController.dispose();
    _floatingParticlesController.dispose();
    _bubblesAnimationController.dispose();
    _pulseAnimationController.dispose();
    _arrayController.dispose();
    _insertController.dispose();
    _indexController.dispose();
    super.dispose();
  }

  // Get a color for an array element based on its index
  Color _getElementColor(int index) {
    return _elementColors[index % _elementColors.length];
  }

  void updateArray() {
    String input = _arrayController.text;
    
    if (input.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.amber),
              SizedBox(width: 10),
              Text(
                'Please enter array values',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: _isDarkMode ? Color(0xFF2C1E66) : Colors.deepPurple,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    
    List<int> newArray =
        input.split(',').map((e) => int.tryParse(e.trim()) ?? 0).toList();
        
    setState(() {
      array = newArray;
      activeIndex = -1;
    });
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.greenAccent),
            SizedBox(width: 10),
            Text(
              'Array updated successfully with ${newArray.length} elements',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: _isDarkMode ? Color(0xFF2F4570) : Colors.indigo,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: Duration(seconds: 2),
      ),
    );
    
    _arrayController.clear();
  }

  void insertElement() {
    String value = _insertController.text;
    String index = _indexController.text;

    if (value.isEmpty || index.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.amber),
              SizedBox(width: 10),
              Text(
                'Please enter both value and index',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: _isDarkMode ? Color(0xFF2C1E66) : Colors.deepPurple,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    int newValue = int.tryParse(value) ?? 0;
    int insertIndex = int.tryParse(index) ?? 0;

    if (insertIndex < 0 || insertIndex > array.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.redAccent),
              SizedBox(width: 10),
              Text(
                'Invalid index: must be between 0 and ${array.length}',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: _isDarkMode ? Colors.red[900] : Colors.red,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      array.insert(insertIndex, newValue);
      activeIndex = insertIndex;
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.greenAccent),
            SizedBox(width: 10),
            Text(
              'Successfully inserted $newValue at index $insertIndex',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: _isDarkMode ? Color(0xFF0E5E6F) : Colors.teal,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: Duration(seconds: 2),
        action: SnackBarAction(
          label: 'DISMISS',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );

    _insertController.clear();
    _indexController.clear();
  }

  void deleteElement() {
    String index = _indexController.text;

    if (index.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.amber),
              SizedBox(width: 10),
              Text(
                'Please enter an index',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: _isDarkMode ? Color(0xFF2C1E66) : Colors.deepPurple,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    int deleteIndex = int.tryParse(index) ?? 0;

    if (deleteIndex < 0 || deleteIndex >= array.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.redAccent),
              SizedBox(width: 10),
              Text(
                'Invalid index: must be between 0 and ${array.length - 1}',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: _isDarkMode ? Colors.red[900] : Colors.red,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Store the deleted value for the message
    int deletedValue = array[deleteIndex];
    
    setState(() {
      array.removeAt(deleteIndex);
      activeIndex = -1;
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.greenAccent),
            SizedBox(width: 10),
            Text(
              'Successfully deleted $deletedValue from index $deleteIndex',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: _isDarkMode ? Color(0xFF5E3B50) : Colors.deepPurple[700],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: Duration(seconds: 2),
        action: SnackBarAction(
          label: 'DISMISS',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );

    _indexController.clear();
  }

  void resetArray() {
    setState(() {
      array = [64, 34, 25, 12, 22, 11, 90];
      activeIndex = -1;
    });
  }

  // Add this method to toggle theme
  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }
  
  // Add this method to share the array
  void _shareArray() {
    final String arrayString = array.join(', ');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Array copied to clipboard: $arrayString',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: _isDarkMode ? Color(0xFF2C1E66) : Colors.deepPurple,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
    // Here you would typically use a package like share_plus to actually share
  }
  
  // Add this method for info dialog
  void _showInfo() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Array Operations Info',
            style: TextStyle(
              color: _isDarkMode ? Colors.purpleAccent : Colors.deepPurple,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'This visualizer demonstrates insertion and deletion operations on an array.',
                  style: TextStyle(
                    color: _isDarkMode ? Colors.white : Colors.black87,
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 15),
                Text(
                  '• Enter comma-separated numbers to create a custom array',
                  style: TextStyle(
                    color: _isDarkMode ? Colors.grey[300] : Colors.black87,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  '• Enter a value and index to insert at that position',
                  style: TextStyle(
                    color: _isDarkMode ? Colors.grey[300] : Colors.black87,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  '• Enter an index to delete the element at that position',
                  style: TextStyle(
                    color: _isDarkMode ? Colors.grey[300] : Colors.black87,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  '• The active element is highlighted in red',
                  style: TextStyle(
                    color: _isDarkMode ? Colors.grey[300] : Colors.black87,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Got it!',
                style: TextStyle(
                  color: _isDarkMode ? Colors.purpleAccent : Colors.deepPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor: _isDarkMode 
              ? Color(0xFF2A2A3A) // Use a darker but distinguishable color
              : Colors.white,
          elevation: 10,
          shadowColor: _isDarkMode ? Colors.purpleAccent.withOpacity(0.3) : Colors.black38,
          // Add a border to improve visibility in dark mode
          insetPadding: EdgeInsets.symmetric(horizontal: 20),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Text(
                'Array Operations Visualizer',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 5.0,
                      color: Colors.black45,
                      offset: Offset(1.0, 1.0),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        backgroundColor: _isDarkMode 
            ? Color(0xFF2C1E66).withOpacity(0.85)
            : Colors.deepPurple.withOpacity(0.7),
        elevation: 4,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: _showInfo,
            tooltip: 'Info',
          ),
          IconButton(
            icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: _toggleTheme,
            tooltip: 'Toggle Theme',
          ),
          IconButton(
            icon: Icon(Icons.share),
            onPressed: _shareArray,
            tooltip: 'Share Array',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Animated gradient background with enhanced version
          AnimatedBuilder(
            animation: _gradientAnimation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _isDarkMode
                        ? [
                            Color.lerp(
                              Color(0xFF1A1A2E),
                              Color(0xFF2C1E66),
                              _gradientAnimation.value,
                            )!, 
                            Color.lerp(
                              Color(0xFF2C1E66),
                              Color(0xFF25274D),
                              _gradientAnimation.value,
                            )!,
                            Color.lerp(
                              Color(0xFF25274D),
                              Color(0xFF464B8C),
                              _gradientAnimation.value,
                            )!,
                          ]
                        : [
                            Color.lerp(
                              Color(0xFF87CEEB),
                              Color(0xFFFFC87C),
                              _gradientAnimation.value,
                            )!,
                            Color.lerp(
                              Color(0xFFFFC87C),
                              Color(0xFFFFA07A),
                              _gradientAnimation.value,
                            )!,
                            Color.lerp(
                              Color(0xFFFFA07A),
                              Color(0xFFE6A8D7),
                              _gradientAnimation.value,
                            )!,
                            Color.lerp(
                              Color(0xFFE6A8D7),
                              Color(0xFF9370DB),
                              _gradientAnimation.value,
                            )!,
                          ],
                    stops: _isDarkMode ? [0.0, 0.5, 1.0] : [0.0, 0.3, 0.6, 1.0],
                  ),
                ),
              );
            },
          ),

          // Add animated bubbles background
          AnimatedBuilder(
            animation: _bubblesAnimationController,
            builder: (context, child) {
              return CustomPaint(
                size: Size(
                  MediaQuery.of(context).size.width,
                  MediaQuery.of(context).size.height,
                ),
                painter: BubblesPainter(
                  _bubbles,
                  _bubblesAnimationController.value,
                  isDarkMode: _isDarkMode,
                ),
              );
            },
          ),

          // Keep existing floating particles
          AnimatedBuilder(
            animation: _floatingParticlesController,
            builder: (context, child) {
              return CustomPaint(
                size: Size(
                  MediaQuery.of(context).size.width,
                  MediaQuery.of(context).size.height,
                ),
                painter: ParticlesPainter(
                  _particlePositions,
                  _floatingParticlesController.value,
                  isDarkMode: _isDarkMode,
                ),
              );
            },
          ),

          // Main content - update the card appearance and text colors for dark theme
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 5,
                color: _isDarkMode 
                    ? Color(0xFF2A2A3A).withOpacity(0.95) // Darker but more visible
                    : Colors.white.withOpacity(0.85),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Input field for user array with dark theme adjustments
                      TextField(
                        controller: _arrayController,
                        decoration: InputDecoration(
                          labelText: 'Enter array (comma-separated)',
                          labelStyle: TextStyle(
                            color: _isDarkMode ? Colors.grey[300] : null,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: _isDarkMode ? Colors.purpleAccent : Colors.deepPurple,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: _isDarkMode ? Colors.grey[600]! : Colors.grey[400]!,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        style: TextStyle(
                          color: _isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: updateArray,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isDarkMode ? Colors.deepPurple[300] : Colors.deepPurple,
                        ),
                        child: Text('Update Array'),
                      ),
                      SizedBox(height: 20),
                      // Input fields for insertion with dark theme adjustments
                      TextField(
                        controller: _insertController,
                        decoration: InputDecoration(
                          labelText: 'Enter value to insert',
                          labelStyle: TextStyle(
                            color: _isDarkMode ? Colors.grey[300] : null,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: _isDarkMode ? Colors.purpleAccent : Colors.deepPurple,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: _isDarkMode ? Colors.grey[600]! : Colors.grey[400]!,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        style: TextStyle(
                          color: _isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: _indexController,
                        decoration: InputDecoration(
                          labelText: 'Enter index for insertion/deletion',
                          labelStyle: TextStyle(
                            color: _isDarkMode ? Colors.grey[300] : null,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: _isDarkMode ? Colors.purpleAccent : Colors.deepPurple,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: _isDarkMode ? Colors.grey[600]! : Colors.grey[400]!,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        style: TextStyle(
                          color: _isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: insertElement,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isDarkMode ? Colors.teal[300] : Colors.teal,
                            ),
                            child: Text('Insert'),
                          ),
                          SizedBox(width: 20),
                          ElevatedButton(
                            onPressed: deleteElement,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isDarkMode ? Colors.red[300] : Colors.red,
                            ),
                            child: Text('Delete'),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      // Array visualization with improved dark theme visibility
                      Expanded(
                        child: Column(
                          children: [
                            Expanded(
                              child: GridView.builder(
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount:
                                          array.length > 10 ? 10 : array.length,
                                      childAspectRatio: 1,
                                    ),
                                itemCount: array.length,
                                itemBuilder: (context, index) {
                                  return Stack(
                                    clipBehavior: Clip.none,
                                    alignment: Alignment.center,
                                    children: [
                                      // Array element box with enhanced visibility
                                      AnimatedContainer(
                                        duration: Duration(milliseconds: 400),
                                        curve: Curves.easeInOut,
                                        margin: EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: index == activeIndex
                                              ? (_isDarkMode ? Colors.red[400] : Colors.red)
                                              : (_isDarkMode 
                                                  ? _elementColors[index % _elementColors.length].withOpacity(0.8)
                                                  : _getElementColor(index)),
                                          border: Border.all(
                                            color: _isDarkMode ? Colors.grey[300]! : Colors.black,
                                            width: _isDarkMode ? 1.5 : 1.0,
                                          ),
                                          borderRadius: BorderRadius.circular(8),
                                          boxShadow: [
                                            BoxShadow(
                                              color: _isDarkMode 
                                                  ? Colors.black87
                                                  : Colors.black26,
                                              offset: Offset(0, 2),
                                              blurRadius: 4.0,
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${array[index]}',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              shadows: [
                                                Shadow(
                                                  color: Colors.black45,
                                                  blurRadius: 2,
                                                  offset: Offset(1, 1),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Index label with better dark theme visibility
                                      Positioned(
                                        bottom: -12,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 1,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _isDarkMode 
                                                ? Colors.grey[200]
                                                : Colors.white,
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                              color: _isDarkMode
                                                  ? Colors.purpleAccent.withOpacity(0.5)
                                                  : Colors.deepPurple.withOpacity(0.3),
                                              width: _isDarkMode ? 1.2 : 1.0,
                                            ),
                                          ),
                                          child: Text(
                                            '$index',
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                              color: _isDarkMode 
                                                  ? Colors.deepPurple[900]
                                                  : Colors.deepPurple,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      // Reset button with dark theme adjustments
                      ElevatedButton(
                        onPressed: resetArray,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isDarkMode 
                              ? Colors.blueGrey[400]
                              : Colors.blueGrey,
                        ),
                        child: Text('Reset'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Add this class for bubble data
class BubbleData {
  Offset position;
  final double size;
  final double speed;

  BubbleData({required this.position, required this.size, required this.speed});
}

// Update the BubblesPainter class for better dark mode visibility
class BubblesPainter extends CustomPainter {
  final List<BubbleData> bubbles;
  final double animation;
  final bool isDarkMode;

  BubblesPainter(this.bubbles, this.animation, {this.isDarkMode = false});

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < bubbles.length; i++) {
      // Make bubbles float upward
      final yOffset = (bubbles[i].position.dy - bubbles[i].speed * 50) % size.height;
      bubbles[i].position = Offset(
        (bubbles[i].position.dx + math.sin(animation * 2 * math.pi + i) * 2) % size.width,
        yOffset < 0 ? size.height : yOffset,
      );

      // Create gradient for each bubble with enhanced visibility in dark mode
      final shader = RadialGradient(
        colors: isDarkMode
            ? [Colors.purpleAccent.withOpacity(0.5), Colors.deepPurple.withOpacity(0.2)]
            : [Colors.white.withOpacity(0.7), Colors.lightBlue.withOpacity(0.2)],
        stops: [0.0, 1.0],
      ).createShader(
        Rect.fromCircle(center: bubbles[i].position, radius: bubbles[i].size),
      );

      final paint = Paint()
        ..shader = shader
        ..style = PaintingStyle.fill;

      canvas.drawCircle(bubbles[i].position, bubbles[i].size, paint);
      
      // Add a more visible outline to the bubble in dark mode
      final outlinePaint = Paint()
        ..color = isDarkMode 
            ? Colors.purpleAccent.withOpacity(0.6)
            : Colors.white.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = isDarkMode ? 1.5 : 1.0;
        
      canvas.drawCircle(bubbles[i].position, bubbles[i].size, outlinePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Update the ParticlesPainter for better dark mode visibility
class ParticlesPainter extends CustomPainter {
  final List<Offset> positions;
  final double animation;
  final bool isDarkMode;

  ParticlesPainter(this.positions, this.animation, {this.isDarkMode = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDarkMode
          ? Colors.purpleAccent.withOpacity(0.6) // More visible in dark mode
          : Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    // Draw particles
    for (int i = 0; i < positions.length; i++) {
      // Calculate particle movement with animation
      final offset = Offset(
        (positions[i].dx + 100 * math.sin((animation * 2 * math.pi) + i)) %
            size.width,
        (positions[i].dy + 50 * math.cos((animation * 2 * math.pi) + i * 0.5)) %
            size.height,
      );

      // Vary the size and opacity of particles with increased size for dark mode
      final particleSize = isDarkMode
          ? (2.5 + 3.5 * math.sin((animation * 2 * math.pi) + i * 0.8))
          : (2.0 + 3.0 * math.sin((animation * 2 * math.pi) + i * 0.8));
          
      paint.color = isDarkMode
          ? Colors.purpleAccent.withOpacity(0.5 + 0.4 * math.sin((animation * 2 * math.pi) + i))
          : Colors.white.withOpacity(0.3 + 0.3 * math.sin((animation * 2 * math.pi) + i));

      canvas.drawCircle(offset, particleSize, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
