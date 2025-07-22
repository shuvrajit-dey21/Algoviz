import 'package:flutter/material.dart';
import 'dart:math';

class LogoCirclePainter extends CustomPainter {
  final Color color;
  final double progress;

  LogoCirclePainter({required this.color, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.4;
    
    final paint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    // Draw animated circle
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(
      rect,
      0,
      progress * 2 * 3.14159,
      false,
      paint,
    );
    
    // Draw small dots at intervals
    final dotPaint = Paint()
      ..color = color.withOpacity(0.7)
      ..style = PaintingStyle.fill;
    
    for (int i = 0; i < 8; i++) {
      final angle = i * 3.14159 / 4;
      if (angle <= progress * 2 * 3.14159) {
        final dotPosition = Offset(
          center.dx + radius * cos(angle),
          center.dy + radius * sin(angle),
        );
        canvas.drawCircle(dotPosition, 1.5, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
} 