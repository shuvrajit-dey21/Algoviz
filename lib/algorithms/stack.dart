import 'package:flutter/material.dart';
import 'dart:math' as math;

class StackAnimation extends StatelessWidget {
  const StackAnimation({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: const StackAnimationScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class StackAnimationScreen extends StatefulWidget {
  const StackAnimationScreen({super.key});

  @override
  _StackAnimationScreenState createState() => _StackAnimationScreenState();
}

class _StackAnimationScreenState extends State<StackAnimationScreen> with TickerProviderStateMixin {
  List<String> stack = [];
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final TextEditingController _textController = TextEditingController();
  late AnimationController _bounceController;
  late AnimationController _rotationController;
  bool _isShowingCode = false;
  String? _message;
  bool _showConfetti = false;
  
  // Store peek history for undo operation
  List<String> _peekHistory = [];
  
  // Add a stack size limit for a bounded stack operation
  int _stackSizeLimit = 10;
  bool _isBounded = false;
  
  // Add history for undo/redo operations
  List<List<String>> _stackHistory = [];
  int _historyIndex = -1;
  
  // Add search functionality
  String _searchQuery = '';
  bool _isSearching = false;
  List<int> _searchResults = [];
  int _currentSearchIndex = -1;

  // Gradient colors for card backgrounds
  final List<List<Color>> gradients = [
    [Colors.redAccent, Colors.red.shade900],
    [Colors.orangeAccent, Colors.deepOrange.shade900],
    [Colors.amberAccent, Colors.amber.shade900],
    [Colors.greenAccent, Colors.green.shade900],
    [Colors.blueAccent, Colors.blue.shade900],
    [Colors.purpleAccent, Colors.purple.shade900],
    [Colors.pinkAccent, Colors.pink.shade900],
  ];

  // Optimize confetti by reducing particles and using a more efficient approach
  final int _confettiParticleCount = 25; // Reduced from 50

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _rotationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    
    // Save initial state in history
    _saveStackState();
  }

  @override
  void dispose() {
    _textController.dispose();
    _bounceController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  // Add method to save current stack state to history
  void _saveStackState() {
    // Remove any forward history if we're in the middle of history
    if (_historyIndex < _stackHistory.length - 1) {
      _stackHistory = _stackHistory.sublist(0, _historyIndex + 1);
    }
    
    // Add current state to history
    _stackHistory.add(List.from(stack));
    _historyIndex = _stackHistory.length - 1;
    
    // Limit history size to prevent memory issues
    if (_stackHistory.length > 20) {
      _stackHistory.removeAt(0);
      _historyIndex--;
    }
  }

  void _push() {
    final value = _textController.text.trim();
    if (value.isNotEmpty) {
      // Check if stack is bounded and at capacity
      if (_isBounded && stack.length >= _stackSizeLimit) {
        setState(() {
          _message = "Stack overflow! Bounded to $_stackSizeLimit items.";
        });
        
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _message = null;
            });
          }
        });
        return;
      }
      
      _bounceController.reset();
      _bounceController.forward();
      
      // Optimize state updates by batching them
      setState(() {
        stack.insert(0, value);
        _textController.clear();
        _message = "Pushed: '$value'";
        _showConfetti = true;
      });
      
      // Save stack state to history
      _saveStackState();
      
      // Use a simpler animation for the list item insertion
      _listKey.currentState?.insertItem(0, duration: const Duration(milliseconds: 300));
      
      // Hide confetti sooner to reduce resource usage
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          setState(() {
            _showConfetti = false;
          });
        }
      });
      
      // Clean up message
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _message = null;
          });
        }
      });
    }
  }

  void _pop() {
    if (stack.isNotEmpty) {
      String removedValue = stack[0];
      
      setState(() {
        stack.removeAt(0);
        _listKey.currentState?.removeItem(
          0,
          (context, animation) => _buildItem(removedValue, 0, animation),
          duration: const Duration(milliseconds: 500),
        );
        
        _message = "Popped: '$removedValue'";
      });
      
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _message = null;
        });
      });
    } else {
      _showEmptyStackMessage();
    }
  }

  void _peek() {
    if (stack.isNotEmpty) {
      _peekHistory.add(stack[0]);
      setState(() {
        _message = "Peek: '${stack[0]}'";
      });
      
      // Start enhanced peek animation
      _rotationController.reset();
      _rotationController.forward();
      
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _message = null;
          });
          _rotationController.stop();
        }
      });
    } else {
      _showEmptyStackMessage();
    }
  }
  
  void _undoOperation() {
    if (_historyIndex > 0) {
      _historyIndex--;
      _applyHistoryState();
    } else {
      setState(() {
        _message = "Nothing to undo!";
      });
      
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _message = null;
          });
        }
      });
    }
  }
  
  void _redoOperation() {
    if (_historyIndex < _stackHistory.length - 1) {
      _historyIndex++;
      _applyHistoryState();
    } else {
      setState(() {
        _message = "Nothing to redo!";
      });
      
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _message = null;
          });
        }
      });
    }
  }
  
  void _applyHistoryState() {
    final newStack = _stackHistory[_historyIndex];
    
    // First handle removals
    for (int i = stack.length - 1; i >= 0; i--) {
      if (!newStack.contains(stack[i]) || 
          newStack.indexOf(stack[i]) != stack.indexOf(stack[i])) {
        final removedValue = stack[i];
        final removedIndex = i;
        
        setState(() {
          stack.removeAt(removedIndex);
          _listKey.currentState?.removeItem(
            removedIndex,
            (context, animation) => _buildItem(removedValue, removedIndex, animation),
            duration: const Duration(milliseconds: 300),
          );
        });
      }
    }
    
    // Then handle additions
    for (int i = 0; i < newStack.length; i++) {
      if (i >= stack.length || stack[i] != newStack[i]) {
        final String newValue = newStack[i];
        setState(() {
          if (i >= stack.length) {
            stack.add(newValue);
          } else {
            stack.insert(i, newValue);
          }
          _listKey.currentState?.insertItem(i, duration: const Duration(milliseconds: 300));
        });
      }
    }
    
    setState(() {
      _message = "Operation ${_historyIndex > 0 ? "undone" : "redone"}";
    });
    
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _message = null;
        });
      }
    });
  }
  
  void _toggleBoundedStack() {
    setState(() {
      _isBounded = !_isBounded;
      _message = _isBounded 
          ? "Stack bounded to $_stackSizeLimit items" 
          : "Stack is now unbounded";
    });
    
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _message = null;
        });
      }
    });
  }
  
  void _searchStack() {
    if (_searchQuery.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
        _currentSearchIndex = -1;
      });
      return;
    }
    
    setState(() {
      _isSearching = true;
      _searchResults = [];
      _currentSearchIndex = -1;
      
      // Find all matching indices
      for (int i = 0; i < stack.length; i++) {
        if (stack[i].toLowerCase().contains(_searchQuery.toLowerCase())) {
          _searchResults.add(i);
        }
      }
      
      if (_searchResults.isNotEmpty) {
        _currentSearchIndex = 0;
        _message = "Found ${_searchResults.length} matches";
      } else {
        _message = "No matches found";
      }
    });
    
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _message = null;
        });
      }
    });
  }
  
  void _nextSearchResult() {
    if (_searchResults.isEmpty) return;
    
    setState(() {
      _currentSearchIndex = (_currentSearchIndex + 1) % _searchResults.length;
      _message = "Match ${_currentSearchIndex + 1} of ${_searchResults.length}";
    });
    
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _message = null;
        });
      }
    });
  }

  void _clearStack() {
    if (stack.isNotEmpty) {
      // Create a copy of the stack to avoid modification issues during animation
      final List<String> stackCopy = List.from(stack);
      final int stackSize = stackCopy.length;
      
      // First clear the actual data
      setState(() {
        _message = "Stack cleared!";
      });
      
      // Then animate the removals
      for (int i = 0; i < stackSize; i++) {
        Future.delayed(Duration(milliseconds: 50 * i), () {
          if (mounted) {
            // Make a local copy of the item being removed for animation
            final String itemToRemove = i < stackCopy.length ? stackCopy[i] : "";
            
            if (_listKey.currentState != null && stack.isNotEmpty) {
              _listKey.currentState!.removeItem(
                0,
                (context, animation) => _buildItem(itemToRemove, 0, animation),
                duration: const Duration(milliseconds: 200),
              );
              
              // Only remove from actual stack if there's something to remove
              if (stack.isNotEmpty) {
                setState(() {
                  stack.removeAt(0);
                });
              }
            }
          }
        });
      }
      
      // Clean up message
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
        setState(() {
            _message = null;
          });
        }
      });
    } else {
      _showEmptyStackMessage();
    }
  }
  
  void _showEmptyStackMessage() {
    setState(() {
      _message = "Stack is empty!";
    });
    
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _message = null;
      });
    });
  }
  
  void _toggleCodeView() {
    setState(() {
      _isShowingCode = !_isShowingCode;
    });
  }

  // Update _buildItem to remove the memory hash and enhance peek animation
  Widget _buildItem(String value, int index, Animation<double> animation) {
    final int colorIndex = index % gradients.length;
    
    // Animations for entry/exit
    Animation<Offset> slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutBack,
    ));
    
    Animation<double> scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animation, 
      curve: Curves.easeOutCubic,
    ));
    
    Animation<double> fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: Curves.easeOut,
    ));
    
    // Modified card with removed hash and enhanced design
    Widget card = Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 8,
      shadowColor: gradients[colorIndex][0].withOpacity(0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: gradients[colorIndex],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          title: Row(
            children: [
              // Memory block index indicator
              Container(
                width: 30,
                height: 30,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: Colors.white24,
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    index.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              // Value
              Expanded(
                child: Text(
            value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        blurRadius: 2.0,
                        color: Colors.black45,
                        offset: Offset(1.0, 1.0),
                      ),
                    ],
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          // Data type icon instead of memory address
          trailing: Icon(
            Icons.data_object,
            color: Colors.white.withOpacity(0.8),
            size: 24,
          ),
        ),
      ),
    );
    
    // Enhanced peek animation for the top item
    if (index == 0) {
      card = AnimatedBuilder(
        animation: _rotationController,
        builder: (context, child) {
          // Calculate animation values based on rotation progress
          final progress = _rotationController.value;
          final peekPhase = progress < 0.5 ? progress * 2 : (1 - progress) * 2;
          
          // Create 3D-like perspective effect
          final perspective = Matrix4.identity()
            ..setEntry(3, 2, 0.001) // Add perspective
            ..rotateY(peekPhase * 0.5 * math.pi); // Partial rotation
            
          // Scale up slightly during peek
          final scale = 1.0 + peekPhase * 0.15;
          
          // Add elevation during peek
          final elevation = peekPhase * 24.0;
          
          // Create glow effect at peek maximum
          final glowAmount = math.sin(progress * math.pi);
          final glowRadius = 16.0 * glowAmount;
          
          return Transform(
            alignment: Alignment.center,
            transform: perspective..scale(scale),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withOpacity(glowAmount * 0.6),
                    blurRadius: glowRadius,
                    spreadRadius: glowRadius * 0.3,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                elevation: elevation,
                borderRadius: BorderRadius.circular(12),
                child: child,
              ),
            ),
          );
        },
        child: card,
      );
    }
    
    // Combine all animations for smooth entry/exit
    return FadeTransition(
      opacity: fadeAnimation,
      child: SlideTransition(
        position: slideAnimation,
        child: ScaleTransition(
          scale: scaleAnimation,
          child: card,
        ),
      ),
    );
  }

  // More efficient confetti implementation
  Widget _buildConfetti() {
    if (!_showConfetti) return const SizedBox.shrink();
    
    return Positioned.fill(
      top: 0,
      bottom: MediaQuery.of(context).size.height * 0.5, // Only show in top half
      child: IgnorePointer(
        child: RepaintBoundary( // Add RepaintBoundary to isolate repainting
          child: CustomPaint(
            painter: ConfettiPainter(_confettiParticleCount),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stack Data Structure', 
          style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          // Add search button
          IconButton(
            icon: Icon(_isSearching ? Icons.search_off : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchQuery = '';
                  _searchResults = [];
                  _currentSearchIndex = -1;
                }
              });
            },
            tooltip: 'Search in Stack',
          ),
          IconButton(
            icon: Icon(_isShowingCode ? Icons.code_off : Icons.code),
            onPressed: _toggleCodeView,
            tooltip: 'Toggle Code View',
          ),
        ],
        elevation: 0,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Add search bar when searching is active
              if (_isSearching)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Enter search term',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      setState(() {
                                        _searchQuery = '';
                                        _searchResults = [];
                                        _currentSearchIndex = -1;
                                      });
                                    },
                                  )
                                : null,
                          ),
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                            _searchStack();
                          },
                        ),
                      ),
                      if (_searchResults.isNotEmpty)
                        Row(
                          children: [
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: _nextSearchResult,
                              icon: const Icon(Icons.arrow_downward),
                              label: Text("${_currentSearchIndex + 1}/${_searchResults.length}"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber,
                                foregroundColor: Colors.black,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              
              // Input section with animations
              AnimatedBuilder(
                animation: _bounceController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + 0.05 * _bounceController.value * (1 - _bounceController.value) * 4,
                    child: child,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Make input row more responsive
          Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            // For very small screens, stack the input and button
                            if (constraints.maxWidth < 380) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  TextFormField(
                                    controller: _textController,
                                    decoration: InputDecoration(
                                      labelText: 'Enter value',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      filled: true,
                                      fillColor: Theme.of(context).colorScheme.surface,
                                      prefixIcon: const Icon(Icons.edit),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    ),
                                    onFieldSubmitted: (_) => _push(),
                                  ),
                                  const SizedBox(height: 8),
                                  ElevatedButton.icon(
                                    onPressed: _push,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    icon: const Icon(Icons.add),
                                    label: const Text('Push'),
                                  ),
                                ],
                              );
                            } else {
                              // For normal screens, keep row layout
                              return Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _textController,
                    decoration: InputDecoration(
                      labelText: 'Enter a value',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        filled: true,
                                        fillColor: Theme.of(context).colorScheme.surface,
                                        prefixIcon: const Icon(Icons.edit),
                                      ),
                                      onFieldSubmitted: (_) => _push(),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  ElevatedButton.icon(
                                    onPressed: _push,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    icon: const Icon(Icons.add),
                                    label: const Text('Push'),
                                  ),
                                ],
                              );
                            }
                          },
                        ),
                      ),
                      
                      // Message display
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: _message != null
                            ? Container(
                                key: ValueKey<String?>(_message),
                                margin: const EdgeInsets.only(top: 12),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _message!,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              )
                            : const SizedBox(height: 0),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Stack Visualization with Container
              Expanded(
                child: _isShowingCode
                    ? _buildCodeView()
                    : _buildStackVisualization(),
              ),
              
              // Operations panel with responsive layout
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 14.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      "Stack Operations",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        // For narrow screens, use wrapped rows
                        if (constraints.maxWidth < 600) {
                          return Column(
                            children: [
                              Wrap(
                                alignment: WrapAlignment.center,
                                spacing: 8.0,
                                runSpacing: 8.0,
                                children: [
                                  _buildOperationButton(
                                    label: 'Pop',
                                    icon: Icons.arrow_upward,
                                    color: Colors.redAccent,
                                    onPressed: _pop,
                                    compact: true,
                                  ),
                                  _buildOperationButton(
                                    label: 'Peek',
                                    icon: Icons.visibility,
                                    color: Colors.amberAccent,
                                    onPressed: _peek,
                                    compact: true,
                                  ),
                                  _buildOperationButton(
                                    label: 'Undo',
                                    icon: Icons.undo,
                                    color: Colors.purpleAccent,
                                    onPressed: _undoOperation,
                                    compact: true,
                                  ),
                                  _buildOperationButton(
                                    label: 'Clear',
                                    icon: Icons.clear_all,
                                    color: Colors.blueAccent,
                                    onPressed: _clearStack,
                                    compact: true,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                alignment: WrapAlignment.center,
                                spacing: 8.0,
                                runSpacing: 8.0,
                                children: [
                                  _buildOperationButton(
                                    label: 'Redo',
                                    icon: Icons.redo,
                                    color: Colors.teal,
                                    onPressed: _redoOperation,
                                    compact: true,
                                  ),
                                  _buildOperationButton(
                                    label: _isBounded ? 'Unbounded' : 'Bounded',
                                    icon: _isBounded ? Icons.height : Icons.height_rounded,
                                    color: Colors.deepOrange,
                                    onPressed: _toggleBoundedStack,
                                    compact: true,
                                  ),
                                ],
                              ),
                            ],
                          );
                        } else {
                          // For wider screens, use rows
                          return Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildOperationButton(
                                    label: 'Pop',
                                    icon: Icons.arrow_upward,
                                    color: Colors.redAccent,
                                    onPressed: _pop,
                                  ),
                                  _buildOperationButton(
                                    label: 'Peek',
                                    icon: Icons.visibility,
                                    color: Colors.amberAccent,
                                    onPressed: _peek,
                                  ),
                                  _buildOperationButton(
                                    label: 'Undo',
                                    icon: Icons.undo,
                                    color: Colors.purpleAccent,
                                    onPressed: _undoOperation,
                                  ),
                                  _buildOperationButton(
                                    label: 'Clear',
                                    icon: Icons.clear_all,
                                    color: Colors.blueAccent,
                                    onPressed: _clearStack,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildOperationButton(
                                    label: 'Redo',
                                    icon: Icons.redo,
                                    color: Colors.teal,
                                    onPressed: _redoOperation,
                                  ),
                                  const SizedBox(width: 16),
                                  _buildOperationButton(
                                    label: _isBounded ? 'Unbounded' : 'Bounded',
                                    icon: _isBounded ? Icons.height : Icons.height_rounded,
                                    color: Colors.deepOrange,
                                    onPressed: _toggleBoundedStack,
                                  ),
                                ],
                              ),
                            ],
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // Highlight search results
          if (_isSearching && _searchResults.isNotEmpty && _currentSearchIndex >= 0)
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: SearchHighlightPainter(
                    index: _searchResults[_currentSearchIndex],
                    itemCount: stack.length,
                  ),
                ),
              ),
            ),
          
          // Overlay confetti effect
          _buildConfetti(),
        ],
      ),
    );
  }

  Widget _buildOperationButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    bool compact = false,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: compact 
            ? const EdgeInsets.symmetric(horizontal: 12, vertical: 10)
            : const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      icon: Icon(icon, size: compact ? 18 : 24),
      label: Text(
        label,
        style: TextStyle(fontSize: compact ? 12 : 14),
      ),
    );
  }

  // More efficient code view with animations
  Widget _buildCodeView() {
    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Animated title with typewriter effect
              _buildAnimatedCodeHeader("// Stack Implementation in Pseudocode"),
              const SizedBox(height: 12),
              
              // Updated code block with new operations
              _buildAnimatedCodeBlock(
                "class Stack {\n"
                "  private data = []\n"
                "  private sizeLimit = 10\n"
                "  private bounded = false\n\n"
                "  push(item) {\n"
                "    if (bounded && data.length >= sizeLimit) {\n"
                "      throw StackOverflowError\n"
                "    }\n"
                "    data.insert(0, item)  // Add to front\n"
                "  }\n\n"
                "  pop() {\n"
                "    if (isEmpty()) return null\n"
                "    return data.removeAt(0)  // Remove from front\n"
                "  }\n\n"
                "  peek() {\n"
                "    if (isEmpty()) return null\n"
                "    return data[0]  // Look at front item\n"
                "  }\n\n"
                "  search(term) {\n"
                "    return data.findIndices(item => item.contains(term))\n"
                "  }\n\n"
                "  setBounded(value) {\n"
                "    bounded = value\n"
                "  }\n\n"
                "  isEmpty() {\n"
                "    return data.length === 0\n"
                "  }\n\n"
                "  clear() {\n"
                "    data = []\n"
                "  }\n"
                "}",
              ),
              const SizedBox(height: 20),
              
              // Animated title for the complexity section
              _buildAnimatedCodeHeader("// Stack Time Complexity"),
              const SizedBox(height: 12),
              
              // Updated complexity table with new operations
              _buildAnimatedComplexityTable(
                "Operation | Time Complexity\n"
                "-----------|-----------------\n"
                "Push      | O(1)\n"
                "Pop       | O(1)\n"
                "Peek      | O(1)\n"
                "Search    | O(n)\n"
                "isEmpty   | O(1)\n"
                "Clear     | O(1)",
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Animated header with typewriter effect
  Widget _buildAnimatedCodeHeader(String text) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: text.length),
      duration: const Duration(milliseconds: 800),
      builder: (context, value, child) {
        return Text(
          text.substring(0, value),
          style: TextStyle(
            color: Colors.green[300],
            fontSize: 16,
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
          ),
        );
      },
    );
  }

  // Animated code block with line-by-line fade in
  Widget _buildAnimatedCodeBlock(String code) {
    final lines = code.split('\n');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(lines.length, (index) {
        return AnimatedOpacity(
          opacity: 1.0,
          duration: Duration(milliseconds: 100 + index * 50),
          curve: Curves.easeInOut,
          // Adding a small delay for each line to create a cascade effect
          child: Transform.translate(
            offset: Offset(0, (1 - 1.0) * 20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 1),
              decoration: BoxDecoration(
                color: index % 2 == 0 
                    ? Colors.grey[800]?.withOpacity(0.3) 
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
              ),
              child: _buildSyntaxHighlightedText(lines[index]),
            ),
          ),
        );
      }),
    );
  }

  // Syntax highlighting for code
  Widget _buildSyntaxHighlightedText(String line) {
    // Apply basic syntax highlighting
    TextSpan buildSpan() {
      if (line.trim().startsWith('//')) {
        // Comments
        return TextSpan(
          text: line,
          style: TextStyle(color: Colors.green[300], fontFamily: 'monospace'),
        );
      } else if (line.contains('class ') || line.contains('function ')) {
        // Class or function declarations
        final parts = line.split(' ');
        return TextSpan(
          children: [
            TextSpan(text: parts[0] + ' ', style: TextStyle(color: Colors.blue[300], fontFamily: 'monospace')),
            TextSpan(text: parts.length > 1 ? parts.sublist(1).join(' ') : '', style: const TextStyle(color: Colors.orange, fontFamily: 'monospace')),
          ],
        );
      } else if (line.contains('if') || line.contains('return')) {
        // Control flow
        return TextSpan(
          text: line,
          style: TextStyle(color: Colors.purple[200], fontFamily: 'monospace'),
        );
      } else if (line.contains('private') || line.contains('data')) {
        // Properties
        return TextSpan(
          text: line,
          style: TextStyle(color: Colors.cyan[200], fontFamily: 'monospace'),
        );
      } else {
        // Default text
        return TextSpan(
          text: line,
          style: const TextStyle(color: Colors.white, fontFamily: 'monospace'),
        );
      }
    }

    return RichText(
      text: buildSpan(),
      softWrap: true,
      overflow: TextOverflow.visible,
    );
  }

  // Animated complexity table with pulse effect
  Widget _buildAnimatedComplexityTable(String tableText) {
    return AnimatedBuilder(
      animation: _rotationController, // Reuse existing animation controller
      builder: (context, child) {
        // Create a subtle pulse effect
        final scale = 1.0 + 0.01 * math.sin(_rotationController.value * 2 * math.pi);
        
        return Transform.scale(
          scale: scale,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue.shade900.withOpacity(0.6),
                  Colors.purple.shade900.withOpacity(0.6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.2),
                  blurRadius: 5,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: _buildTableWithAnimatedRows(tableText),
            ),
          ),
        );
      },
    );
  }

  // Helper for building animated table rows
  Widget _buildTableWithAnimatedRows(String tableText) {
    final lines = tableText.split('\n');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(lines.length, (index) {
        // Add staggered animation for each row
        return AnimatedOpacity(
          opacity: 1.0,
          duration: Duration(milliseconds: 300 + index * 150),
          curve: Curves.easeInOut,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: lines[index].split('|').map((cell) {
                return Container(
                  width: cell.contains('Complexity') ? 150 : 100,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    cell.trim(),
                    style: TextStyle(
                      color: index == 0 ? Colors.amber[300] : 
                             (cell.trim().startsWith('O(') ? Colors.greenAccent : Colors.white),
                      fontWeight: index <= 1 ? FontWeight.bold : FontWeight.normal,
                      fontFamily: 'monospace',
                      fontSize: 14,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      }),
    );
  }

  // New method to build stack visualization with enhanced animations
  Widget _buildStackVisualization() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // Animated title with glow effect
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.5, end: 1.0),
            duration: const Duration(seconds: 2),
            curve: Curves.easeInOut,
            builder: (context, value, child) {
              return AnimatedBuilder(
                animation: _rotationController,
                builder: (context, _) {
                  final pulseValue = 1.0 + 0.05 * math.sin(_rotationController.value * 4 * math.pi);
                  return Transform.scale(
                    scale: value * pulseValue,
                    child: Text(
                      "Stack Memory",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                        shadows: [
                          Shadow(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                            blurRadius: 8 * pulseValue,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
          
          const SizedBox(height: 4),
          
          // Stack container visualization with enhanced animations
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Animated container background
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Container(
                        margin: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.indigo.shade900,
                              Colors.blueGrey.shade900,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.indigo.withOpacity(0.3),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                          border: Border.all(
                            color: Colors.indigo.shade400.withOpacity(0.7),
                            width: 2.0,
                          ),
                        ),
                        // Repeating grid pattern
                        child: CustomPaint(
                          painter: GridPainter(),
                          child: Stack(
                            children: [
                              // Top label (latest elements)
                              Positioned(
                                top: 8,
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: _buildFloatingLabel("TOP", Colors.amber),
                                ),
                              ),
                              // Bottom label
                              Positioned(
                                bottom: 8,
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: _buildFloatingLabel("BOTTOM", Colors.grey),
                                ),
                              ),
                              // Digital circuitry effect
                              CustomPaint(
                                painter: CircuitryPainter(),
                                size: Size.infinite,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                
                // Empty state message with animation
                if (stack.isEmpty)
                  AnimatedBuilder(
                    animation: _rotationController,
                    builder: (context, child) {
                      final float = math.sin(_rotationController.value * 2 * math.pi) * 8;
                      return Transform.translate(
                        offset: Offset(0, float),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.indigo.withOpacity(0.3),
                                blurRadius: 15,
                                spreadRadius: 1,
                              ),
                            ],
                            border: Border.all(
                              color: Colors.indigo.shade400.withOpacity(0.3),
                              width: 1.0,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.inventory_2_outlined,
                                color: Colors.indigo,
                                size: 64,
                              ),
                              const SizedBox(height: 16),
                              ShaderMask(
                                shaderCallback: (bounds) => LinearGradient(
                                  colors: [Colors.blue.shade300, Colors.purple.shade300],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ).createShader(bounds),
                                child: const Text(
                                  "Stack is Empty",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Use PUSH to add elements",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                
                // Animated Stack items with improved transitions
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
                    child: AnimatedList(
                      key: _listKey,
                      initialItemCount: stack.length,
                      itemBuilder: (context, index, animation) {
                        return _buildItem(stack[index], index, animation);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Animated floating label for TOP/BOTTOM indicators
  Widget _buildFloatingLabel(String text, Color baseColor) {
    return AnimatedBuilder(
      animation: _rotationController,
      builder: (context, child) {
        final pulseValue = 1.0 + 0.1 * math.sin(_rotationController.value * 4 * math.pi);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: baseColor.withOpacity(0.7 * pulseValue),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: baseColor.withOpacity(0.5 * pulseValue),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: 12 + pulseValue,
            ),
          ),
        );
      },
    );
  }
}

// Optimized confetti painter for better performance
class ConfettiPainter extends CustomPainter {
  final int particleCount;
  final List<_Particle> particles = [];
  
  ConfettiPainter(this.particleCount) {
    final random = math.Random();
    
    // Pre-generate particles once instead of recreating them on every paint
    for (int i = 0; i < particleCount; i++) {
      particles.add(_Particle(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: random.nextDouble() * 8 + 4,
        color: Color.fromARGB(
          random.nextInt(150) + 105, // Higher alpha for better visibility with fewer particles
          random.nextInt(255),
          random.nextInt(255),
          random.nextInt(255),
        ),
        isCircle: random.nextBool(),
      ));
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    
    for (final particle in particles) {
      paint.color = particle.color;
      
      final x = particle.x * size.width;
      final y = particle.y * size.height;
      
      if (particle.isCircle) {
        canvas.drawCircle(
          Offset(x, y),
          particle.size / 2,
          paint,
        );
      } else {
        canvas.drawRect(
          Rect.fromLTWH(x, y, particle.size, particle.size),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) => false; // Set to false for better performance
}

// Class to pre-calculate confetti particles
class _Particle {
  final double x;
  final double y;
  final double size;
  final Color color;
  final bool isCircle;
  
  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.color,
    required this.isCircle,
  });
}

// Grid pattern painter for container background
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1;
    
    // Draw horizontal grid lines
    double y = 0;
    while (y < size.height) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
      y += 20;
    }
    
    // Draw vertical grid lines
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
      x += 20;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Digital circuitry effect painter
class CircuitryPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.2)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    
    final random = math.Random(42); // Fixed seed for consistent pattern
    
    // Draw circuit lines
    for (int i = 0; i < 10; i++) {
      final path = Path();
      double x = random.nextDouble() * size.width;
      double y = random.nextDouble() * size.height;
      
      path.moveTo(x, y);
      
      for (int j = 0; j < 5; j++) {
        // Decide direction - horizontal or vertical
        if (random.nextBool()) {
          x = random.nextDouble() * size.width;
          path.lineTo(x, y);
        } else {
          y = random.nextDouble() * size.height;
          path.lineTo(x, y);
        }
      }
      
      canvas.drawPath(path, paint);
      
      // Add circuit node
      final nodePaint = Paint()
        ..color = Colors.blue.withOpacity(0.3)
        ..style = PaintingStyle.fill;
        
      canvas.drawCircle(
        Offset(x, y),
        3,
        nodePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Add a painter to highlight search results
class SearchHighlightPainter extends CustomPainter {
  final int index;
  final int itemCount;
  
  SearchHighlightPainter({
    required this.index,
    required this.itemCount,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    if (index < 0 || index >= itemCount) return;
    
    // Calculate the approximate position of the item
    final itemHeight = 80.0; // Approximate height of each item
    final topPadding = 100.0; // Approximate padding at the top
    final verticalSpacing = 6.0; // Vertical spacing between items
    
    final y = topPadding + (index * (itemHeight + verticalSpacing));
    
    // Draw highlight rectangle
    final paint = Paint()
      ..color = Colors.amber.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    
    final rect = Rect.fromLTWH(
      size.width * 0.1,  // 10% from left
      y,
      size.width * 0.8,  // 80% width
      itemHeight,
    );
    
    final rrect = RRect.fromRectAndRadius(
      rect,
      const Radius.circular(12),
    );
    
    canvas.drawRRect(rrect, paint);
    
    // Draw border
    final borderPaint = Paint()
      ..color = Colors.amber
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    canvas.drawRRect(rrect, borderPaint);
    
    // Draw attention arrows
    final arrowPaint = Paint()
      ..color = Colors.amber
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    
    // Left arrow
    final leftPath = Path();
    leftPath.moveTo(size.width * 0.05, y + itemHeight / 2);
    leftPath.lineTo(size.width * 0.09, y + itemHeight / 2);
    leftPath.moveTo(size.width * 0.07, y + itemHeight / 2 - 10);
    leftPath.lineTo(size.width * 0.05, y + itemHeight / 2);
    leftPath.lineTo(size.width * 0.07, y + itemHeight / 2 + 10);
    
    // Right arrow
    final rightPath = Path();
    rightPath.moveTo(size.width * 0.95, y + itemHeight / 2);
    rightPath.lineTo(size.width * 0.91, y + itemHeight / 2);
    rightPath.moveTo(size.width * 0.93, y + itemHeight / 2 - 10);
    rightPath.lineTo(size.width * 0.95, y + itemHeight / 2);
    rightPath.lineTo(size.width * 0.93, y + itemHeight / 2 + 10);
    
    canvas.drawPath(leftPath, arrowPaint);
    canvas.drawPath(rightPath, arrowPaint);
  }
  
  @override
  bool shouldRepaint(covariant SearchHighlightPainter oldDelegate) => 
    oldDelegate.index != index || oldDelegate.itemCount != itemCount;
}
