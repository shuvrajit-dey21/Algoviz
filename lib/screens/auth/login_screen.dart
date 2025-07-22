import 'package:flutter/material.dart';
import 'dart:math';

class LoginScreen extends StatefulWidget {
  final Function onLoginSuccess;
  
  const LoginScreen({
    super.key,
    required this.onLoginSuccess,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _isRegisterMode = false;
  String? _errorMessage;
  
  // Animation controllers
  late final AnimationController _backgroundAnimationController;
  late final AnimationController _logoAnimationController;
  late final AnimationController _formAnimationController;
  late final AnimationController _buttonAnimationController;
  
  // Animations
  late final Animation<double> _logoScaleAnimation;
  late final Animation<double> _logoRotateAnimation;
  late final Animation<Offset> _formSlideAnimation;
  late final Animation<double> _formFadeAnimation;
  late final Animation<double> _buttonScaleAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // Background animation
    _backgroundAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
    
    // Logo animations
    _logoAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _logoScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _logoAnimationController,
        curve: Curves.elasticOut,
      ),
    );
    
    _logoRotateAnimation = Tween<double>(
      begin: -0.5,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _logoAnimationController,
        curve: Curves.elasticOut,
      ),
    );
    
    // Form animations
    _formAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _formSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _formAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );
    
    _formFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _formAnimationController,
        curve: Curves.easeIn,
      ),
    );
    
    // Button animation
    _buttonAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _buttonScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(
      CurvedAnimation(
        parent: _buttonAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    
    // Start animations after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _logoAnimationController.forward();
      Future.delayed(const Duration(milliseconds: 600), () {
        _formAnimationController.forward();
      });
    });
  }
  
  @override
  void dispose() {
    _backgroundAnimationController.dispose();
    _logoAnimationController.dispose();
    _formAnimationController.dispose();
    _buttonAnimationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  
  // Calculate a wave effect for UI elements
  double _calculateWaveEffect(int index) {
    return sin((index * 0.5) + _backgroundAnimationController.value * 2 * pi) * 0.03 + 1.0;
  }

  Future<void> _authenticate() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // Simulate authentication (replace with actual auth when implementing Appwrite)
      await Future.delayed(const Duration(seconds: 1));
      
      // Call the callback directly
      if (mounted) {
        widget.onLoginSuccess();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    
    return Scaffold(
      body: Stack(
        children: [
          // Animated background with particles
          AnimatedBuilder(
            animation: _backgroundAnimationController,
            builder: (context, child) {
              return CustomPaint(
                painter: LoginBackgroundPainter(
                  animation: _backgroundAnimationController.value,
                  isDarkMode: isDarkMode,
                  color: primaryColor,
                ),
                size: MediaQuery.of(context).size,
              );
            },
          ),
          
          // Floating Code Elements Animation
          AnimatedBuilder(
            animation: _backgroundAnimationController,
            builder: (context, child) {
              return CustomPaint(
                painter: CodeElementsPainter(
                  animation: _backgroundAnimationController.value,
                  isDarkMode: isDarkMode,
                  color: primaryColor,
                ),
                size: MediaQuery.of(context).size,
              );
            },
          ),
          
          // Main content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // App Logo with animation
                      AnimatedBuilder(
                        animation: _logoAnimationController,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _logoRotateAnimation.value * pi,
                            child: Transform.scale(
                              scale: _logoScaleAnimation.value,
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primaryColor.withOpacity(0.3),
                                      blurRadius: 15,
                                      spreadRadius: 3,
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Animated circle
                                    AnimatedBuilder(
                                      animation: _backgroundAnimationController,
                                      builder: (context, child) {
                                        return CustomPaint(
                                          painter: LogoCirclePainter(
                                            progress: _backgroundAnimationController.value,
                                            color: primaryColor,
                                          ),
                                          size: const Size(100, 100),
                                        );
                                      }
                                    ),
                                    // Main logo icon
                                    Icon(
                                      Icons.code,
                                      size: 60,
                                      color: primaryColor,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // App Name with animation
                      AnimatedBuilder(
                        animation: _backgroundAnimationController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _calculateWaveEffect(0),
                            child: Text(
                              'AlgoViz',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                foreground: Paint()
                                  ..shader = LinearGradient(
                                    colors: [
                                      primaryColor.withRed((primaryColor.red + 30).clamp(0, 255)),
                                      primaryColor,
                                      primaryColor.withBlue((primaryColor.blue + 40).clamp(0, 255)),
                                    ],
                                  ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
                              ),
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Tagline with animation
                      SlideTransition(
                        position: _formSlideAnimation,
                        child: FadeTransition(
                          opacity: _formFadeAnimation,
                          child: AnimatedBuilder(
                            animation: _backgroundAnimationController,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _calculateWaveEffect(1),
                                child: Text(
                                  'Visualize. Learn. Master.',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Login Form with animation
                      SlideTransition(
                        position: _formSlideAnimation,
                        child: FadeTransition(
                          opacity: _formFadeAnimation,
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.1),
                                  blurRadius: 20,
                                  spreadRadius: 1,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                              border: Border.all(
                                color: primaryColor.withOpacity(0.1),
                                width: 1.5,
                              ),
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Title with animation
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 400),
                                    transitionBuilder: (child, animation) {
                                      return SlideTransition(
                                        position: Tween<Offset>(
                                          begin: const Offset(0, -0.5),
                                          end: Offset.zero,
                                        ).animate(animation),
                                        child: FadeTransition(
                                          opacity: animation,
                                          child: child,
                                        ),
                                      );
                                    },
                                    child: Text(
                                      _isRegisterMode ? 'Create Account' : 'Welcome Back',
                                      key: ValueKey<bool>(_isRegisterMode),
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.onSurface,
                                      ),
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 8),
                                  
                                  // Subtitle with animation
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 400),
                                    transitionBuilder: (child, animation) {
                                      return SlideTransition(
                                        position: Tween<Offset>(
                                          begin: const Offset(0, 0.5),
                                          end: Offset.zero,
                                        ).animate(animation),
                                        child: FadeTransition(
                                          opacity: animation,
                                          child: child,
                                        ),
                                      );
                                    },
                                    child: Text(
                                      _isRegisterMode
                                          ? 'Create your account to start learning'
                                          : 'Sign in to continue your learning journey',
                                      key: ValueKey<bool>(_isRegisterMode),
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                      ),
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 24),
                                  
                                  // Email field with animation
                                  _buildAnimatedTextField(
                                    controller: _emailController,
                                    icon: Icons.email_outlined,
                                    label: 'Email',
                                    index: 2,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your email';
                                      }
                                      return null;
                                    },
                                  ),
                                  
                                  const SizedBox(height: 16),
                                  
                                  // Password field with animation
                                  _buildAnimatedTextField(
                                    controller: _passwordController,
                                    icon: Icons.lock_outline,
                                    label: 'Password',
                                    index: 3,
                                    isPassword: true,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your password';
                                      }
                                      return null;
                                    },
                                  ),
                                  
                                  const SizedBox(height: 16),
                                  
                                  // Forgot password link
                                  if (!_isRegisterMode)
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton(
                                        onPressed: () {
                                          // Implement password reset
                                        },
                                        style: TextButton.styleFrom(
                                          foregroundColor: primaryColor,
                                          padding: EdgeInsets.zero,
                                          minimumSize: const Size(50, 30),
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        child: const Text(
                                          'Forgot Password?',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  
                                  const SizedBox(height: 24),
                                  
                                  // Error message with animation
                                  AnimatedSize(
                                    duration: const Duration(milliseconds: 300),
                                    child: _errorMessage != null
                                        ? Container(
                                            margin: const EdgeInsets.only(bottom: 16),
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.red.shade50,
                                              borderRadius: BorderRadius.circular(10),
                                              border: Border.all(
                                                color: Colors.red.shade200,
                                                width: 1,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.error_outline,
                                                  color: Colors.red.shade400,
                                                  size: 20,
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    _errorMessage!,
                                                    style: TextStyle(
                                                      color: Colors.red.shade700,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        : const SizedBox(height: 0),
                                  ),
                                  
                                  // Login button with animation
                                  MouseRegion(
                                    onEnter: (_) => _buttonAnimationController.forward(),
                                    onExit: (_) => _buttonAnimationController.reverse(),
                                    child: GestureDetector(
                                      onTapDown: (_) => _buttonAnimationController.forward(),
                                      onTapUp: (_) => _buttonAnimationController.reverse(),
                                      onTapCancel: () => _buttonAnimationController.reverse(),
                                      child: AnimatedBuilder(
                                        animation: _buttonAnimationController,
                                        builder: (context, child) {
                                          return Transform.scale(
                                            scale: _buttonScaleAnimation.value,
                                            child: SizedBox(
                                              width: double.infinity,
                                              height: 56,
                                              child: ElevatedButton(
                                                onPressed: _isLoading ? null : _authenticate,
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: primaryColor,
                                                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(16),
                                                  ),
                                                  elevation: 4,
                                                  shadowColor: primaryColor.withOpacity(0.5),
                                                ),
                                                child: _isLoading
                                                    ? SizedBox(
                                                        width: 24,
                                                        height: 24,
                                                        child: CircularProgressIndicator(
                                                          color: Theme.of(context).colorScheme.onPrimary,
                                                          strokeWidth: 3,
                                                        ),
                                                      )
                                                    : AnimatedSwitcher(
                                                        duration: const Duration(milliseconds: 300),
                                                        transitionBuilder: (child, animation) {
                                                          return FadeTransition(
                                                            opacity: animation,
                                                            child: SlideTransition(
                                                              position: Tween<Offset>(
                                                                begin: const Offset(0, 0.3),
                                                                end: Offset.zero,
                                                              ).animate(animation),
                                                              child: child,
                                                            ),
                                                          );
                                                        },
                                                        child: Text(
                                                          _isRegisterMode ? 'Sign Up' : 'Sign In',
                                                          key: ValueKey<bool>(_isRegisterMode),
                                                          style: const TextStyle(
                                                            fontSize: 18,
                                                            fontWeight: FontWeight.bold,
                                                            letterSpacing: 0.5,
                                                          ),
                                                        ),
                                                      ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 24),
                                  
                                  // Divider "OR"
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Divider(
                                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        child: Text(
                                          'OR',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Divider(
                                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  const SizedBox(height: 24),
                                  
                                  // Social login buttons
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      _buildSocialLoginButton(
                                        icon: Icons.g_mobiledata_rounded,
                                        label: 'Google',
                                        color: Colors.red,
                                        index: 4,
                                        onPressed: () {
                                          // Implement Google login
                                        },
                                      ),
                                      const SizedBox(width: 16),
                                      _buildSocialLoginButton(
                                        icon: Icons.facebook_rounded,
                                        label: 'Facebook',
                                        color: Colors.blue,
                                        index: 5,
                                        onPressed: () {
                                          // Implement Facebook login
                                        },
                                      ),
                                    ],
                                  ),
                                  
                                  const SizedBox(height: 24),
                                  
                                  // Toggle login/register
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        _isRegisterMode
                                            ? 'Already have an account?'
                                            : 'Don\'t have an account?',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          setState(() {
                                            _isRegisterMode = !_isRegisterMode;
                                          });
                                        },
                                        style: TextButton.styleFrom(
                                          foregroundColor: primaryColor,
                                          padding: const EdgeInsets.symmetric(horizontal: 8),
                                        ),
                                        child: Text(
                                          _isRegisterMode ? 'Sign In' : 'Sign Up',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  // Debug button
                                  Align(
                                    alignment: Alignment.center,
                                    child: TextButton(
                                      onPressed: () {
                                        widget.onLoginSuccess();
                                      },
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.grey,
                                        padding: EdgeInsets.zero,
                                      ),
                                      child: const Text('DEBUG: Skip Login'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
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
  
  // Helper method to build text fields with animation
  Widget _buildAnimatedTextField({
    required TextEditingController controller,
    required IconData icon,
    required String label,
    required int index,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return AnimatedBuilder(
      animation: _backgroundAnimationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _calculateWaveEffect(index),
          child: TextFormField(
            controller: controller,
            obscureText: isPassword && !_isPasswordVisible,
            validator: validator,
            decoration: InputDecoration(
              labelText: label,
              prefixIcon: Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
              ),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
            ),
          ),
        );
      },
    );
  }
  
  // Helper method to build social login buttons with animation
  Widget _buildSocialLoginButton({
    required IconData icon,
    required String label,
    required Color color,
    required int index,
    required VoidCallback onPressed,
  }) {
    return AnimatedBuilder(
      animation: _backgroundAnimationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _calculateWaveEffect(index),
          child: ElevatedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon, size: 24),
            label: Text(label),
            style: ElevatedButton.styleFrom(
              backgroundColor: color.withOpacity(0.1),
              foregroundColor: color,
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: color.withOpacity(0.3),
                  width: 1,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Logo circle painter with animation
class LogoCirclePainter extends CustomPainter {
  final double progress;
  final Color color;
  
  LogoCirclePainter({
    required this.progress,
    required this.color,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.35;
    
    // Draw outer glow
    final outerGlowPaint = Paint()
      ..color = color.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12.0);
    
    canvas.drawCircle(center, radius * 1.2, outerGlowPaint);
    
    // Draw animated circles
    final circlePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    // Draw main circle
    canvas.drawCircle(center, radius, circlePaint);
    
    // Draw dots on the circle
    final dotCount = 8;
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    for (int i = 0; i < dotCount; i++) {
      final angle = (i / dotCount * 2 * pi) + (progress * 2 * pi);
      final dotRadius = 3.0 + sin(progress * 4 * pi + i) * 1.5; // Pulsing dot size
      
      final dotPosition = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
      
      canvas.drawCircle(dotPosition, dotRadius, dotPaint);
    }
    
    // Draw small algorithm symbols
    final symbols = ['[ ]', '{ }', '( )', '< >'];
    for (int i = 0; i < 4; i++) {
      final angle = (i / 4 * 2 * pi) + (progress * 2 * pi * 0.5);
      final symbolPos = Offset(
        center.dx + radius * 0.6 * cos(angle),
        center.dy + radius * 0.6 * sin(angle),
      );
      
      final textPainter = TextPainter(
        text: TextSpan(
          text: symbols[i % symbols.length],
          style: TextStyle(
            fontSize: 10,
            color: color.withOpacity(0.8),
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      
      textPainter.layout();
      textPainter.paint(
        canvas, 
        Offset(
          symbolPos.dx - textPainter.width / 2,
          symbolPos.dy - textPainter.height / 2,
        ),
      );
    }
    
    // Draw inner circle with pulse
    final innerCirclePaint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    canvas.drawCircle(
      center, 
      radius * (0.6 + 0.05 * sin(progress * 4 * pi)), 
      innerCirclePaint,
    );
  }
  
  @override
  bool shouldRepaint(covariant LogoCirclePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

// Animated code elements painter for floating coding symbols
class CodeElementsPainter extends CustomPainter {
  final double animation;
  final bool isDarkMode;
  final Color color;
  final Random random = Random(42); // Fixed seed for consistency
  
  CodeElementsPainter({
    required this.animation,
    required this.isDarkMode,
    required this.color,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    // Code elements like brackets, parentheses, etc.
    final codeSymbols = [
      '{ }', '[ ]', '( )', '< >', '//', '/*', '*/', '=', 
      '+', '-', '*', '/', '&&', '||', 
      'if', 'for', 'while', '++', '--'
    ];
    
    // Draw floating code elements
    final elementCount = 15; // Number of floating elements
    
    for (int i = 0; i < elementCount; i++) {
      // Calculate position with animation
      final baseX = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * size.height;
      
      // Create floating effect with sine/cosine
      final offsetX = 20 * sin(animation * 2 * pi + i);
      final offsetY = 15 * cos(animation * 2 * pi + i * 0.5);
      
      final x = baseX + offsetX;
      final y = baseY + offsetY;
      
      // Get a random code symbol
      final symbol = codeSymbols[i % codeSymbols.length];
      
      // Calculate opacity with pulsing effect
      final baseOpacity = 0.1 + (random.nextDouble() * 0.2);
      final pulsingOpacity = baseOpacity + 0.1 * sin(animation * 2 * pi + i);
      
      // Draw the code symbol
      final textPainter = TextPainter(
        text: TextSpan(
          text: symbol,
          style: TextStyle(
            color: color.withOpacity(pulsingOpacity),
            fontSize: 12 + random.nextDouble() * 8, // Random size
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      
      textPainter.layout();
      textPainter.paint(
        canvas, 
        Offset(
          x - textPainter.width / 2,
          y - textPainter.height / 2,
        ),
      );
      
      // Add connecting lines for some elements
      if (i % 3 == 0) {
        final nextIndex = (i + 1) % elementCount;
        final nextX = random.nextDouble() * size.width + 
                    20 * sin(animation * 2 * pi + nextIndex);
        final nextY = random.nextDouble() * size.height + 
                    15 * cos(animation * 2 * pi + nextIndex * 0.5);
        
        final linePaint = Paint()
          ..color = color.withOpacity(pulsingOpacity * 0.5)
          ..strokeWidth = 0.5;
        
        canvas.drawLine(
          Offset(x, y),
          Offset(nextX, nextY),
          linePaint,
        );
      }
    }
  }
  
  @override
  bool shouldRepaint(covariant CodeElementsPainter oldDelegate) {
    return oldDelegate.animation != animation ||
           oldDelegate.isDarkMode != isDarkMode ||
           oldDelegate.color != color;
  }
}

// Update the LoginBackgroundPainter class to ensure it works properly
class LoginBackgroundPainter extends CustomPainter {
  final double animation;
  final bool isDarkMode;
  final Color color;
  final Random random = Random(42); // Fixed seed for consistency
  
  LoginBackgroundPainter({
    required this.animation,
    required this.isDarkMode,
    required this.color,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    
    // Background gradient
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    paint.shader = LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      colors: isDarkMode
          ? [
              const Color(0xFF1E1E2E),
              const Color(0xFF1A1A29),
            ]
          : [
              const Color(0xFFF8F9FF),
              const Color(0xFFEEF1FF),
            ],
    ).createShader(rect);
    
    canvas.drawRect(rect, paint);
    
    // Draw subtle glow in one corner
    final glowPaint = Paint();
    glowPaint.shader = RadialGradient(
      center: const Alignment(-0.8, -0.8),
      radius: 1.5,
      colors: [
        color.withOpacity(isDarkMode ? 0.15 : 0.1),
        color.withOpacity(0.0),
      ],
    ).createShader(rect);
    
    canvas.drawRect(rect, glowPaint);
    
    // Draw grid
    final gridPaint = Paint()
      ..color = color.withOpacity(isDarkMode ? 0.08 : 0.05)
      ..strokeWidth = 0.5;
      
    final gridSize = 50.0;
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        gridPaint,
      );
    }
    
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }
    
    // Draw animated circles
    for (int i = 0; i < 5; i++) {
      final circleRadius = 50.0 + 20.0 * sin(animation * 2 * pi + i);
      final circlePaint = Paint()
        ..color = color.withOpacity(0.05)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
        
      final xPos = size.width * (0.2 + i * 0.15);
      final yPos = size.height * (0.3 + 0.1 * sin(animation * pi + i));
      
      canvas.drawCircle(
        Offset(xPos, yPos),
        circleRadius,
        circlePaint,
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant LoginBackgroundPainter oldDelegate) {
    return oldDelegate.animation != animation ||
           oldDelegate.isDarkMode != isDarkMode ||
           oldDelegate.color != color;
  }
} 