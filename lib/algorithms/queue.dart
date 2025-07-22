import 'package:flutter/material.dart';
import 'dart:math' as math;

class QueueAnimation extends StatelessWidget {
  const QueueAnimation({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: QueueAnimationScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class QueueAnimationScreen extends StatefulWidget {
  const QueueAnimationScreen({super.key});

  @override
  _QueueAnimationScreenState createState() => _QueueAnimationScreenState();
}

class _QueueAnimationScreenState extends State<QueueAnimationScreen> with TickerProviderStateMixin {
  List<QueueItem> queue = [];
  final TextEditingController _textController = TextEditingController();
  late AnimationController _slideController;
  late AnimationController _bounceController;
  late AnimationController _shakeController;
  late AnimationController _peekController;
  int? itemToRemove;
  bool _isDarkMode = false;
  bool _isAutoMode = false;
  int _queueCapacity = 10;
  String _peekValue = "";
  bool _showHelp = false;
  bool _isExpandedLayout = true;
  late Map<String, Color> themeColors;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _drawerOpen = false;
  
  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _peekController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _slideController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          if (queue.isNotEmpty) {
            queue.removeAt(0);
          }
          itemToRemove = null;
        });
        _slideController.reset();
      }
    });
  }
  
  @override
  void dispose() {
    _slideController.dispose();
    _bounceController.dispose();
    _shakeController.dispose();
    _peekController.dispose();
    _textController.dispose();
    super.dispose();
  }

  // Generate a random color for queue items
  Color _getRandomColor() {
    final colors = [
      Colors.blue,
      Colors.teal,
      Colors.green,
      Colors.amber,
      Colors.deepPurple,
      Colors.indigo,
      Colors.pink,
    ];
    return colors[math.Random().nextInt(colors.length)];
  }

  void _enqueue() {
    final value = _textController.text.trim();
    if (value.isNotEmpty) {
      if (queue.length >= _queueCapacity) {
        _showQueueFullError();
        return;
      }
      
      _bounceController.reset();
      _bounceController.forward();
      
      setState(() {
        queue.add(QueueItem(
          value: value,
          color: _getRandomColor(),
          timestamp: DateTime.now(),
        ));
        _textController.clear();
      });
    }
  }

  void _showQueueFullError() {
    _shakeController.reset();
    _shakeController.forward();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Queue is full! Maximum capacity is $_queueCapacity items.'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Increase Capacity',
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              _queueCapacity += 5;
            });
          },
        ),
      ),
    );
  }

  void _autoEnqueue() {
    if (queue.length >= _queueCapacity) {
      _showQueueFullError();
      return;
    }
    
    final randomValue = (math.Random().nextInt(100) + 1).toString();
    _bounceController.reset();
    _bounceController.forward();
    
      setState(() {
      queue.add(QueueItem(
        value: randomValue,
        color: _getRandomColor(),
        timestamp: DateTime.now(),
      ));
    });
  }

  void _dequeue() {
    if (queue.isNotEmpty && itemToRemove == null) {
      setState(() {
        itemToRemove = 0; // Mark the first item for removal
      });
      _slideController.forward(from: 0.0);
    }
  }

  void _clearQueue() {
    setState(() {
      queue.clear(); // Clear the entire queue
      _peekValue = "";
    });
  }
  
  void _peek() {
    if (queue.isNotEmpty) {
      _peekController.reset();
      _peekController.forward();
      setState(() {
        _peekValue = queue[0].value;
      });
    } else {
      setState(() {
        _peekValue = "Queue is empty";
      });
      _peekController.reset();
      _peekController.forward();
    }
  }
  
  void _toggleAutoMode() {
    setState(() {
      _isAutoMode = !_isAutoMode;
    });
    
    if (_isAutoMode) {
      Future.delayed(Duration(seconds: 2), () {
        if (_isAutoMode && mounted) {
          _autoEnqueue();
          _toggleAutoMode(); // Turn it off after one operation
        }
      });
    }
  }
  
  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  void _toggleHelp() {
    setState(() {
      _showHelp = !_showHelp;
    });
  }

  void _toggleEnqueueLayout() {
    setState(() {
      _isExpandedLayout = !_isExpandedLayout;
    });
  }

  void _increaseCapacity(int amount) {
    setState(() {
      _queueCapacity = math.max(1, _queueCapacity + amount);
    });
  }
  
  void _decreaseCapacity(int amount) {
    final newCapacity = _queueCapacity - amount;
    if (newCapacity < queue.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cannot reduce capacity below current queue size (${queue.length})'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    
    setState(() {
      _queueCapacity = math.max(1, newCapacity);
    });
  }

  String _formatTimestamp(DateTime timestamp) {
    return "${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}";
  }

  Widget _buildQueueItem(QueueItem item, int index) {
    // Special styling for front and rear elements
    Color itemColor = item.color;
    String label = '';
    
    if (index == 0 && queue.length > 0) {
      label = 'FRONT';
      // Brighten purple in dark mode for visibility
      if (_isDarkMode) {
        itemColor = Colors.purple.shade300;
      } else {
        itemColor = Colors.purple;
      }
    } else if (index == queue.length - 1 && queue.length > 0) {
      label = 'REAR';
      // Brighten teal in dark mode for visibility
      if (_isDarkMode) {
        itemColor = Colors.teal.shade300;
      } else {
        itemColor = Colors.teal;
      }
    } else if (_isDarkMode) {
      // Brighten standard colors in dark mode
      itemColor = _brightenColorForDarkMode(item.color);
    }
    
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 500),
      curve: Curves.elasticOut,
      builder: (context, animValue, child) {
        return Transform.scale(
          scale: animValue,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (label.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _isDarkMode ? Colors.black54 : Colors.white70,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      label, 
                      style: TextStyle(
                        color: _isDarkMode ? Colors.white : itemColor, 
                        fontSize: 12, 
                        fontWeight: FontWeight.bold
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ),
              AnimatedContainer(
                duration: Duration(milliseconds: 300),
                margin: EdgeInsets.symmetric(horizontal: 5),
                padding: EdgeInsets.all(15), // Increased padding for better appearance
                width: 100,
                decoration: BoxDecoration(
                  color: _peekValue == item.value && index == 0 
                      ? (_isDarkMode ? Colors.amber.shade600 : Colors.amber) 
                      : itemColor,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: _isDarkMode 
                          ? Colors.black.withOpacity(0.5) 
                          : itemColor.withOpacity(0.4),
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                  border: _isDarkMode ? Border.all(
                    color: Colors.grey.shade700,
                    width: 1,
                  ) : null,
                ),
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      item.value,
                      style: TextStyle(
                        color: Colors.white, 
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        shadows: _isDarkMode ? [
                          Shadow(
                            color: Colors.black54,
                            blurRadius: 2,
                            offset: Offset(0, 1),
                          )
                        ] : null,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 4),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: _isDarkMode ? Colors.black54 : Colors.white70,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  "Index: $index",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: _isDarkMode ? Colors.white70 : Colors.grey.shade700,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Method to toggle drawer with animation
  void _toggleDrawer() {
    setState(() {
      _drawerOpen = !_drawerOpen;
    });
    if (_drawerOpen) {
      _scaffoldKey.currentState?.openEndDrawer();
    }
  }

  // Method to build queue capacity settings drawer
  Widget _buildCapacitySettingsDrawer() {
    return Drawer(
      width: math.min(MediaQuery.of(context).size.width * 0.85, 400),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              color: _isDarkMode 
                  ? Colors.blueGrey.shade800 // More visible in dark mode
                  : Colors.blue.shade700,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Queue Settings',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      )
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Adjust queue capacity and behavior',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9), // Higher contrast
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: _isDarkMode ? Colors.grey.shade800 : Colors.white,
                padding: EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CAPACITY MANAGEMENT',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _isDarkMode ? Colors.grey.shade300 : Colors.blue.shade800,
                          letterSpacing: 1.2,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Queue Size: $_queueCapacity',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _isDarkMode ? Colors.white : Colors.blue.shade900,
                        ),
                      ),
                      SizedBox(height: 12),
                      SliderTheme(
                        data: SliderThemeData(
                          activeTrackColor: Colors.blue,
                          inactiveTrackColor: _isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                          thumbColor: Colors.blue,
                          overlayColor: Colors.blue.withOpacity(0.2),
                          valueIndicatorColor: Colors.blue,
                          valueIndicatorTextStyle: TextStyle(color: Colors.white),
                        ),
                        child: Slider(
                          value: _queueCapacity.toDouble(),
                          min: math.max(queue.length.toDouble(), 1),
                          max: 50,
                          divisions: 49,
                          label: _queueCapacity.toString(),
                          onChanged: (value) {
                            setState(() {
                              _queueCapacity = value.toInt();
                            });
                          },
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Min: ${math.max(queue.length, 1)}',
                            style: TextStyle(
                              color: _isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                            ),
                          ),
                          Text(
                            'Max: 50',
                            style: TextStyle(
                              color: _isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24),
                      Text(
                        'Quick Adjustments',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _isDarkMode ? Colors.white : Colors.blue.shade900,
                        ),
                      ),
                      SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildCapacityButton('-10', () => _decreaseCapacity(10)),
                          _buildCapacityButton('-5', () => _decreaseCapacity(5)),
                          _buildCapacityButton('-1', () => _decreaseCapacity(1)),
                          _buildCapacityButton('+1', () => _increaseCapacity(1)),
                          _buildCapacityButton('+5', () => _increaseCapacity(5)),
                          _buildCapacityButton('+10', () => _increaseCapacity(10)),
                        ],
                      ),
                      Divider(height: 32),
                      Text(
                        'QUEUE STATUS',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _isDarkMode ? Colors.grey.shade300 : Colors.blue.shade800,
                          letterSpacing: 1.2,
                        ),
                      ),
                      SizedBox(height: 16),
                      _buildStatusCard(
                        icon: Icons.analytics,
                        title: 'Current Usage',
                        content: '${queue.length} / $_queueCapacity elements',
                        subtitle: '${queue.isEmpty ? 0 : (queue.length / _queueCapacity * 100).toStringAsFixed(0)}% used',
                        color: queue.length < _queueCapacity * 0.7 
                            ? Colors.green 
                            : queue.length < _queueCapacity 
                                ? Colors.orange 
                                : Colors.red,
                      ),
                      SizedBox(height: 16),
                      _buildStatusCard(
                        icon: Icons.info_outline,
                        title: 'Remaining Space',
                        content: '${_queueCapacity - queue.length} elements available',
                        subtitle: queue.isEmpty 
                            ? 'Queue is empty' 
                            : queue.length == _queueCapacity 
                                ? 'Queue is full' 
                                : 'Queue has space',
                        color: _isDarkMode ? Colors.blue.shade700 : Colors.blue.shade400,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build status cards in the drawer
  Widget _buildStatusCard({
    required IconData icon,
    required String title,
    required String content,
    required String subtitle,
    required Color color,
  }) {
    // Adjust colors for dark mode if needed
    Color textColor = _isDarkMode ? Colors.white : Colors.grey.shade800;
    Color subtitleColor = _isDarkMode ? Colors.grey.shade300 : Colors.grey.shade600;
    
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(_isDarkMode ? 0.7 : 0.5), // Brighter in dark mode
          width: _isDarkMode ? 1.5 : 1, // Thicker in dark mode for visibility
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(_isDarkMode ? 0.3 : 0.2), // Adjusted for dark mode
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: _isDarkMode ? color.withOpacity(0.9) : color, // Brighter in dark mode
              size: 24,
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
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: textColor,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  content,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: _isDarkMode ? color.withOpacity(0.9) : color,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: subtitleColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    themeColors = _isDarkMode 
      ? {
          'background': Colors.grey.shade900,
          'cardBg': Colors.grey.shade800,
          'textColor': Colors.white,
          'secondaryTextColor': Colors.grey.shade300,
          'guideLineColor': Colors.grey.shade600, // Brightened for visibility
          'appBarColor': Colors.black87, // Slightly lighter than pure black
          'appBarTextColor': Colors.white, // Ensure contrast
          'buttonTextColor': Colors.white, // Ensure visibility on buttons
          'statusTextColor': Colors.white.withOpacity(0.9), // Higher contrast
          'borderColor': Colors.grey.shade600, // More visible borders
        }
      : {
          'background': Colors.white,
          'cardBg': Colors.blue.shade100,
          'textColor': Colors.blue.shade800,
          'secondaryTextColor': Colors.blue.shade600,
          'guideLineColor': Colors.grey.shade300,
          'appBarColor': Colors.blue.shade700,
          'appBarTextColor': Colors.white,
          'buttonTextColor': Colors.white,
          'statusTextColor': Colors.black87,
          'borderColor': Colors.blue.shade200,
        };
        
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          'Queue Animation', 
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white, // Always white for contrast
            fontSize: 20, // Slightly larger for visibility
          )
        ),
        backgroundColor: themeColors['appBarColor'] as Color,
        iconTheme: IconThemeData(color: Colors.white), // Ensure icon visibility
        elevation: 8,
        actions: [
          IconButton(
            icon: Icon(_isExpandedLayout ? Icons.view_compact : Icons.view_agenda),
            onPressed: _toggleEnqueueLayout,
            tooltip: 'Toggle input layout',
            color: Colors.white, // Explicitly white for visibility
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: _toggleDrawer,
            tooltip: 'Queue settings',
            color: Colors.white,
          ),
          IconButton(
            icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: _toggleTheme,
            tooltip: 'Toggle theme',
            color: Colors.white,
          ),
          IconButton(
            icon: Icon(Icons.help_outline),
            onPressed: _toggleHelp,
            tooltip: 'Help',
            color: Colors.white,
          ),
        ],
      ),
      endDrawer: _buildCapacitySettingsDrawer(),
      backgroundColor: themeColors['background'] as Color,
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 
                         kToolbarHeight - MediaQuery.of(context).padding.top,
            ),
            child: Column(
        children: [
                if (_showHelp)
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.all(16),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _isDarkMode ? Colors.amber.shade800 : Colors.amber.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.lightbulb, color: Colors.amber),
                            SizedBox(width: 8),
                Expanded(
                              child: Text(
                                "Queue Operations Guide",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: _isDarkMode ? Colors.white : Colors.black87,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.close),
                              onPressed: _toggleHelp,
                              color: _isDarkMode ? Colors.white : Colors.black87,
                              padding: EdgeInsets.zero,
                              constraints: BoxConstraints(),
                            )
                          ],
                        ),
                        SizedBox(height: 8),
                        Text("• Enqueue: Add an element to the back of the queue", 
                          style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black87)),
                        SizedBox(height: 4),
                        Text("• Dequeue: Remove an element from the front of the queue", 
                          style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black87)),
                        SizedBox(height: 4),
                        Text("• Peek: View the front element without removing it", 
                          style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black87)),
                        SizedBox(height: 4),
                        Text("• Auto: Automatically add a random element", 
                          style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black87)),
                      ],
                    ),
                  ),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _isDarkMode
                          ? [Colors.grey.shade800, Colors.black]
                          : [Colors.blue.shade100, Colors.white],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 5,
                        spreadRadius: 1,
                      )
                    ],
                  ),
            padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Queue Data Structure',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: themeColors['textColor'] as Color,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'FIFO - First In, First Out',
                        style: TextStyle(
                          fontSize: 16,
                          color: themeColors['secondaryTextColor'] as Color,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      SizedBox(height: 16),
                      
                      // Queue usage indicator - simplified version for main view
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _isDarkMode ? Colors.grey.shade800.withOpacity(0.6) : Colors.white.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _isDarkMode ? Colors.grey.shade700 : Colors.blue.shade200,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Queue Usage',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: themeColors['textColor'] as Color,
                                  ),
                                ),
                                InkWell(
                                  onTap: _toggleDrawer,
            child: Row(
                                    children: [
                                      Text(
                                        'Capacity: $_queueCapacity',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: themeColors['textColor'] as Color,
                                        ),
                                      ),
                                      Icon(
                                        Icons.settings,
                                        size: 16,
                                        color: themeColors['secondaryTextColor'] as Color,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Stack(
                              children: [
                                Container(
                                  height: 12,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: _isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                FractionallySizedBox(
                                  widthFactor: queue.isEmpty ? 0 : math.min(1.0, queue.length / _queueCapacity),
                                  child: AnimatedContainer(
                                    duration: Duration(milliseconds: 300),
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: queue.length < _queueCapacity * 0.7 
                                          ? Colors.green 
                                          : queue.length < _queueCapacity 
                                              ? Colors.orange 
                                              : Colors.red,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 6),
                            Text(
                              queue.isEmpty 
                                ? "Empty queue (0%)" 
                                : "${queue.length}/${_queueCapacity} elements (${(queue.length / _queueCapacity * 100).toStringAsFixed(0)}%)",
                              style: TextStyle(
                                fontSize: 12,
                                color: themeColors['secondaryTextColor'] as Color,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: 20),
                      
                      // Fixed enqueue section with proper spacing for larger displays
                      _isExpandedLayout
                        ? Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _isDarkMode ? Colors.grey.shade800.withOpacity(0.6) : Colors.white.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _isDarkMode ? Colors.grey.shade700 : Colors.blue.shade200,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.add_box,
                                      size: 18, 
                                      color: _isDarkMode ? Colors.grey.shade300 : Colors.green.shade700
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'Add Items to Queue',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: themeColors['textColor'] as Color,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12),
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    // Use vertical layout for small widths, horizontal for larger
                                    final isWide = constraints.maxWidth >= 500;
                                    
                                    if (isWide) {
                                      // Horizontal layout for wide screens
                                      return Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                                            flex: 3,
                                            child: ShakeTransition(
                                              animation: _shakeController,
                  child: TextFormField(
                    controller: _textController,
                                                style: TextStyle(
                                                  color: _isDarkMode ? Colors.white : Colors.black87,
                                                ),
                    decoration: InputDecoration(
                      labelText: 'Enter a value',
                                                  hintText: 'Type value and press Enter',
                                                  labelStyle: TextStyle(
                                                    color: _isDarkMode ? Colors.grey.shade400 : Colors.blue.shade700,
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  filled: true,
                                                  fillColor: _isDarkMode ? Colors.grey.shade800 : Colors.white,
                                                  prefixIcon: Icon(
                                                    Icons.input,
                                                    color: _isDarkMode ? Colors.grey.shade400 : Colors.blue.shade700,
                                                  ),
                                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                                ),
                                                onFieldSubmitted: (_) => _enqueue(),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                                          Container(
                                            width: 130,
                                            child: ScaleTransition(
                                              scale: Tween<double>(begin: 1.0, end: 1.1).animate(
                                                CurvedAnimation(
                                                  parent: _bounceController,
                                                  curve: Curves.elasticOut,
                                                ),
                                              ),
                                              child: SizedBox(
                                                width: double.infinity,
                                                child: ElevatedButton.icon(
                                                  icon: Icon(Icons.add_circle_outline, size: 18),
                                                  label: Text('Enqueue', style: TextStyle(fontWeight: FontWeight.bold)),
                                                  onPressed: _enqueue,
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.green,
                                                    foregroundColor: Colors.white,
                                                    padding: EdgeInsets.symmetric(vertical: 12),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    } else {
                                      // Vertical layout for narrow screens
                                      return Column(
                                        children: [
                                          ShakeTransition(
                                            animation: _shakeController,
                                            child: TextFormField(
                                              controller: _textController,
                                              style: TextStyle(
                                                color: _isDarkMode ? Colors.white : Colors.black87,
                                              ),
                                              decoration: InputDecoration(
                                                labelText: 'Enter a value',
                                                hintText: 'Type value and press Enter',
                                                labelStyle: TextStyle(
                                                  color: _isDarkMode ? Colors.grey.shade400 : Colors.blue.shade700,
                                                ),
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                filled: true,
                                                fillColor: _isDarkMode ? Colors.grey.shade800 : Colors.white,
                                                prefixIcon: Icon(
                                                  Icons.input,
                                                  color: _isDarkMode ? Colors.grey.shade400 : Colors.blue.shade700,
                                                ),
                                                suffixIcon: IconButton(
                                                  icon: Icon(Icons.send),
                                                  onPressed: _enqueue,
                                                  color: Colors.green,
                                                ),
                                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                              ),
                                              onFieldSubmitted: (_) => _enqueue(),
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          ScaleTransition(
                                            scale: Tween<double>(begin: 1.0, end: 1.1).animate(
                                              CurvedAnimation(
                                                parent: _bounceController,
                                                curve: Curves.elasticOut,
                                              ),
                                            ),
                                            child: Container(
                                              width: double.infinity,
                                              child: ElevatedButton.icon(
                                                icon: Icon(Icons.add_circle_outline, size: 16),
                                                label: Text('Enqueue', style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: _enqueue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                                                  foregroundColor: Colors.white,
                                                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          )
                        : _buildCompactEnqueueLayout(),
                    ],
                  ),
                ),
                
                // Peek Results
                if (_peekValue.isNotEmpty)
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(top: 16, left: 16, right: 16),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _isDarkMode ? Colors.amber.shade800 : Colors.amber.shade100,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 3,
                          spreadRadius: 1,
                        )
                      ],
                    ),
                    child: FadeTransition(
                      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                        CurvedAnimation(
                          parent: _peekController,
                          curve: Interval(0.0, 0.5, curve: Curves.easeIn),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.visibility, 
                            color: _isDarkMode ? Colors.white : Colors.amber.shade800),
                          SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Peek Result:", 
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _isDarkMode ? Colors.white : Colors.amber.shade900,
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  child: Text(
                                    _peekValue,
                                    style: TextStyle(
                                      color: _isDarkMode ? Colors.white70 : Colors.amber.shade900,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close, size: 20),
                            onPressed: () => setState(() => _peekValue = ""),
                            color: _isDarkMode ? Colors.white70 : Colors.amber.shade900,
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(
                              minWidth: 36,
                              minHeight: 36,
                            ),
                ),
              ],
            ),
          ),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: Text(
                    queue.isEmpty 
                        ? "Queue is empty. Add elements with 'Enqueue'."
                        : "Queue contains ${queue.length} element${queue.length > 1 ? 's' : ''}",
                    style: TextStyle(
                      fontSize: 16, 
                      fontStyle: FontStyle.italic,
                      color: _isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  height: 220,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: queue.isEmpty 
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.queue, 
                              size: 60, 
                              color: _isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300),
                            SizedBox(height: 8),
                            Text(
                              "Queue is Empty",
                              style: TextStyle(
                                fontSize: 18, 
                                color: _isDarkMode ? Colors.grey.shade400 : Colors.grey.shade500
                              ),
                            ),
                          ],
                        ),
                      )
                    : Stack(
                        children: [
                          Positioned.fill(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 30),
                              child: Container(
                                height: 2,
                                color: themeColors['guideLineColor'] as Color,
                              ),
                            ),
                          ),
                          ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: queue.length,
                            padding: EdgeInsets.symmetric(horizontal: 20),
              itemBuilder: (context, index) {
                              if (index == itemToRemove) {
                                return SlideTransition(
                                  position: Tween<Offset>(
                                    begin: Offset.zero,
                                    end: Offset(-3.0, 0),
                                  ).animate(CurvedAnimation(
                                    parent: _slideController,
                                    curve: Curves.easeInOut,
                                  )),
                                  child: _buildQueueItem(queue[index], index),
                                );
                              } else {
                                if (itemToRemove != null && index > itemToRemove!) {
                                  return SlideTransition(
                                    position: Tween<Offset>(
                                      begin: Offset(1.0, 0),
                                      end: Offset.zero,
                                    ).animate(CurvedAnimation(
                                      parent: _slideController,
                                      curve: Curves.easeInOut,
                                    )),
                                    child: _buildQueueItem(queue[index], index),
                                  );
                                } else {
                                  return _buildQueueItem(queue[index], index);
                                }
                              }
                            },
                          ),
                        ],
                      ),
                ),
                Container(
            padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: _isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 5,
                        spreadRadius: 1,
                        offset: Offset(0, -3),
                      )
                    ],
                  ),
                  child: Column(
              children: [
                      Row(
              children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: Icon(Icons.remove_circle_outline),
                              label: Text('Dequeue', style: TextStyle(fontWeight: FontWeight.bold)),
                              onPressed: queue.isEmpty ? null : _dequeue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 5,
                                disabledBackgroundColor: _isDarkMode ? Colors.grey.shade700 : Colors.grey.shade400,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: Icon(Icons.visibility),
                              label: Text('Peek', style: TextStyle(fontWeight: FontWeight.bold)),
                              onPressed: queue.isEmpty ? null : _peek,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 5,
                                disabledBackgroundColor: _isDarkMode ? Colors.grey.shade700 : Colors.grey.shade400,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: Icon(Icons.delete_sweep),
                              label: Text('Clear Queue', style: TextStyle(fontWeight: FontWeight.bold)),
                              onPressed: queue.isEmpty ? null : _clearQueue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 5,
                                disabledBackgroundColor: _isDarkMode ? Colors.grey.shade700 : Colors.grey.shade400,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: Icon(Icons.casino),
                              label: Text('Random', style: TextStyle(fontWeight: FontWeight.bold)),
                              onPressed: queue.length >= _queueCapacity ? null : _autoEnqueue,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 5,
                                disabledBackgroundColor: _isDarkMode ? Colors.grey.shade700 : Colors.grey.shade400,
                              ),
                            ),
                          ),
                        ],
                ),
              ],
            ),
          ),
        ],
      ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildCapacityButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: _isDarkMode 
            ? (label.startsWith('+') ? Colors.green.shade800 : Colors.red.shade800)
            : (label.startsWith('+') ? Colors.green.shade50 : Colors.red.shade50),
        foregroundColor: _isDarkMode 
            ? Colors.white
            : (label.startsWith('+') ? Colors.green.shade800 : Colors.red.shade800),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        textStyle: TextStyle(fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: BorderSide(
            color: label.startsWith('+') 
                ? (_isDarkMode ? Colors.green.shade600 : Colors.green.shade300)
                : (_isDarkMode ? Colors.red.shade600 : Colors.red.shade300),
            width: 1,
          ),
        ),
        elevation: _isDarkMode ? 2 : 0, // Add elevation in dark mode
      ),
      child: Text(
        label, 
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }
  
  Widget _buildCompactEnqueueLayout() {
    return Column(
      children: [
        ShakeTransition(
          animation: _shakeController,
          child: TextFormField(
            controller: _textController,
            style: TextStyle(
              color: _isDarkMode ? Colors.white : Colors.black87,
            ),
            decoration: InputDecoration(
              labelText: 'Enter a value',
              labelStyle: TextStyle(
                color: _isDarkMode ? Colors.grey.shade400 : Colors.blue.shade700,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: _isDarkMode ? Colors.grey.shade800 : Colors.white,
              prefixIcon: Icon(
                Icons.input,
                color: _isDarkMode ? Colors.grey.shade400 : Colors.blue.shade700,
              ),
              suffixIcon: IconButton(
                icon: Icon(Icons.send),
                onPressed: _enqueue,
                color: Colors.green,
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            ),
            onFieldSubmitted: (_) => _enqueue(),
          ),
        ),
        SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            // Adapt button size based on screen width
            final isVerySmall = constraints.maxWidth < 300;
            
            return ScaleTransition(
              scale: Tween<double>(begin: 1.0, end: 1.1).animate(
                CurvedAnimation(
                  parent: _bounceController,
                  curve: Curves.elasticOut,
                ),
              ),
              child: Container(
                width: isVerySmall ? constraints.maxWidth * 0.8 : double.infinity,
                alignment: Alignment.center,
                child: ElevatedButton.icon(
                  icon: Icon(Icons.add_circle_outline, size: isVerySmall ? 16 : 18),
                  label: Text(
                    'Enqueue', 
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isVerySmall ? 14 : 16,
                    )
                  ),
                  onPressed: _enqueue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      vertical: isVerySmall ? 10 : 12, 
                      horizontal: isVerySmall ? 16 : 24
                    ),
                    minimumSize: Size(isVerySmall ? 120 : 140, 0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
  
  // Helper to brighten colors for dark mode
  Color _brightenColorForDarkMode(Color color) {
    if (color.computeLuminance() > 0.5) return color;
    
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness + 0.2).clamp(0.0, 1.0)).toColor();
  }
}

// Queue Item class to store additional properties
class QueueItem {
  final String value;
  final Color color;
  final DateTime timestamp;
  
  QueueItem({
    required this.value, 
    required this.color, 
    required this.timestamp,
  });
}

// Custom Shake Animation Widget
class ShakeTransition extends StatelessWidget {
  final Widget child;
  final Animation<double> animation;

  const ShakeTransition({
    Key? key,
    required this.child,
    required this.animation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final sineValue = math.sin(animation.value * math.pi * 5);
        return Transform.translate(
          offset: Offset(sineValue * 10, 0),
          child: this.child,
        );
      },
    );
  }
}
