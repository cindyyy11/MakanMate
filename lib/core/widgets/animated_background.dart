import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:makan_mate/core/theme/app_colors.dart';

/// Animated background with floating particles - reusable across the app
class AnimatedBackground extends StatefulWidget {
  final Widget child;
  final int particleCount;

  const AnimatedBackground({
    Key? key,
    required this.child,
    this.particleCount = 20,
  }) : super(key: key);

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with TickerProviderStateMixin {
  late List<Particle> _particles;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _particles = List.generate(
      widget.particleCount,
      (index) => Particle.random(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _ParticlePainter(
            particles: _particles,
            progress: _controller.value,
            isDark: isDark,
          ),
          child: widget.child,
        );
      },
    );
  }
}

class Particle {
  final double x;
  final double y;
  final double size;
  final Color color;
  final double speed;

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.color,
    required this.speed,
  });

  factory Particle.random() {
    final random = math.Random();
    return Particle(
      x: random.nextDouble(),
      y: random.nextDouble(),
      size: 2 + random.nextDouble() * 3,
      color: AppColors.primary.withValues(
        alpha: 0.1 + random.nextDouble() * 0.2,
      ),
      speed: 0.3 + random.nextDouble() * 0.5,
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double progress;
  final bool isDark;

  _ParticlePainter({
    required this.particles,
    required this.progress,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final x = (particle.x + progress * particle.speed) % 1.0;
      final y = (particle.y + progress * particle.speed * 0.5) % 1.0;

      final paint = Paint()
        ..color = isDark
            ? particle.color.withValues(alpha: 0.15)
            : particle.color
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(x * size.width, y * size.height),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isDark != isDark;
  }
}

