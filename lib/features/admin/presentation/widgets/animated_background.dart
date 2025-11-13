import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:makan_mate/core/theme/app_colors.dart';

/// Animated background with floating particles
class AnimatedBackground extends StatefulWidget {
  final Widget child;
  final int particleCount;

  const AnimatedBackground({
    super.key,
    required this.child,
    this.particleCount = 50,
  });

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    // Initialize particles
    final random = math.Random();
    for (int i = 0; i < widget.particleCount; i++) {
      _particles.add(Particle(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: random.nextDouble() * 3 + 1,
        speed: random.nextDouble() * 0.5 + 0.1,
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        // Animated gradient background
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          const Color(0xFF0A0E27),
                          const Color(0xFF1A1F3A),
                          const Color(0xFF121212),
                        ]
                      : [
                          AppColors.primary.withOpacity(0.03),
                          AppColors.secondary.withOpacity(0.03),
                          AppColors.background,
                        ],
                  stops: [
                    0.0 + (_controller.value * 0.2),
                    0.5 + (_controller.value * 0.2),
                    1.0 + (_controller.value * 0.2),
                  ].map((e) => e.clamp(0.0, 1.0)).toList(),
                ),
              ),
            );
          },
        ),
        // Floating particles
        CustomPaint(
          painter: ParticlePainter(
            particles: _particles,
            progress: _controller.value,
            isDark: isDark,
          ),
          child: Container(),
        ),
        // Content
        widget.child,
      ],
    );
  }
}

class Particle {
  double x;
  double y;
  double size;
  double speed;

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
  });
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double progress;
  final bool isDark;

  ParticlePainter({
    required this.particles,
    required this.progress,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDark ? Colors.white : AppColors.primary)
          .withOpacity(0.1)
      ..style = PaintingStyle.fill;

    for (final particle in particles) {
      final x = (particle.x + progress * particle.speed) % 1.0;
      final y = (particle.y + progress * particle.speed * 0.5) % 1.0;

      canvas.drawCircle(
        Offset(x * size.width, y * size.height),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}


