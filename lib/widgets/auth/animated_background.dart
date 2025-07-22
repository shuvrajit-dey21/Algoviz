import 'package:flutter/material.dart';
import 'dart:math';

class AnimatedLoginBackground extends StatelessWidget {
  final Animation<double> animation;
  final bool isDarkMode;

  const AnimatedLoginBackground({
    super.key,
    required this.animation,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return CustomPaint(
          painter: LoginBackgroundPainter(
            animation: animation.value,
            isDarkMode: isDarkMode,
            mainColor: Theme.of(context).colorScheme.primary,
          ),
          child: Container(),
        );
      },
    );
  }
}

class LoginBackgroundPainter extends CustomPainter {
  final double animation;
  final bool isDarkMode;
  final Color mainColor;
  final Random random = Random();

  LoginBackgroundPainter({
    required this.animation,
    required this.isDarkMode,
    required this.mainColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Background gradient
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()
      ..shader = LinearGradient(
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

    // Draw subtle grid lines
    final gridPaint = Paint()
      ..color = isDarkMode
          ? mainColor.withOpacity(0.08)
          : mainColor.withOpacity(0.05)
      ..strokeWidth = 0.5;

    // Larger grid size for cleaner look
    final gridSize = 80.0;
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

    // Draw floating elements
    _drawFloatingElements(canvas, size);
    
    // Draw glowing area at the top
    final glowPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.2, -0.8),
        radius: 0.8,
        colors: [
          mainColor.withOpacity(isDarkMode ? 0.2 : 0.1),
          mainColor.withOpacity(0.0),
        ],
      ).createShader(rect);
      
    canvas.drawRect(rect, glowPaint);
    
    // Draw subtle circles
    final circlePaint = Paint()
      ..color = mainColor.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
      
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.2),
      100 + 20 * sin(animation * 2 * pi),
      circlePaint,
    );
    
    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.8),
      80 + 15 * cos(animation * 2 * pi + 1),
      circlePaint,
    );
  }
  
  void _drawFloatingElements(Canvas canvas, Size size) {
    final elementCount = 12;
    final seed = 42; // Fixed seed for consistent randomness
    final rand = Random(seed);
    
    for (int i = 0; i < elementCount; i++) {
      final x = rand.nextDouble() * size.width;
      final baseY = rand.nextDouble() * size.height;
      // Animate Y position with sine wave
      final y = baseY + 20 * sin(animation * 2 * pi + i);
      
      // Determine element type (0: dot, 1: small circle, 2: code symbol)
      final elementType = rand.nextInt(3);
      final opacity = 0.1 + 0.1 * sin(animation * 2 * pi + i * 0.5);
      final elementColor = mainColor.withOpacity(opacity);
      
      switch (elementType) {
        case 0:
          // Draw dot
          canvas.drawCircle(
            Offset(x, y),
            3 + rand.nextDouble() * 2,
            Paint()..color = elementColor,
          );
          break;
        case 1:
          // Draw small circle
          canvas.drawCircle(
            Offset(x, y),
            10 + rand.nextDouble() * 8,
            Paint()
              ..color = elementColor
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.0,
          );
          break;
        case 2:
          // Draw code symbol
          final symbols = ['{}', '[]', '()', '<>', '//'];
          final symbol = symbols[rand.nextInt(symbols.length)];
          
          final textPainter = TextPainter(
            text: TextSpan(
              text: symbol,
              style: TextStyle(
                color: elementColor,
                fontSize: 14 + rand.nextDouble() * 6,
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
          break;
      }
    }
  }

  @override
  bool shouldRepaint(covariant LoginBackgroundPainter oldDelegate) {
    return oldDelegate.animation != animation || 
           oldDelegate.isDarkMode != isDarkMode ||
           oldDelegate.mainColor != mainColor;
  }
} 