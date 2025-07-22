import 'package:flutter/material.dart';
import 'dart:math';

class AnimatedParticleBackgroundPainter extends CustomPainter {
  final Color color;
  final Animation<double> animation;
  final List<AnimatedParticle> particles = [];
  final Random random = Random();
  final int particleCount;

  AnimatedParticleBackgroundPainter({
    required this.color,
    required this.animation,
    this.particleCount = 30,
  }) : super(repaint: animation) {
    // Initialize particles
    for (int i = 0; i < particleCount; i++) {
      particles.add(AnimatedParticle(
        position: Offset(
          random.nextDouble() * 400,
          random.nextDouble() * 800,
        ),
        speed: Offset(
          (random.nextDouble() - 0.5) * 1.5,
          (random.nextDouble() - 0.5) * 1.5,
        ),
        radius: 1 + random.nextDouble() * 3,
        color: color.withOpacity(0.05 + random.nextDouble() * 0.1),
      ));
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Update and draw particles
    for (var particle in particles) {
      // Update position based on animation value
      final currentPosition = Offset(
        (particle.position.dx + particle.speed.dx * animation.value * 30) % size.width,
        (particle.position.dy + particle.speed.dy * animation.value * 30) % size.height,
      );
      
      final paint = Paint()
        ..color = particle.color
        ..style = PaintingStyle.fill;
      
      // Use anti-aliasing for smoother circles
      canvas.drawCircle(
        currentPosition,
        particle.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class AnimatedParticle {
  Offset position;
  Offset speed;
  double radius;
  Color color;

  AnimatedParticle({
    required this.position,
    required this.speed,
    required this.radius,
    required this.color,
  });
} 