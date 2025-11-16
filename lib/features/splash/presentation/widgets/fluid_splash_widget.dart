import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Fluid animated blob widget for splash screen
class FluidSplashWidget extends StatefulWidget {
  final Widget child;
  final Color color1;
  final Color color2;
  final Color color3;

  const FluidSplashWidget({
    required this.child,
    this.color1 = const Color(0xFFFF9800),
    this.color2 = const Color(0xFFFF5722),
    this.color3 = const Color(0xFF9C27B0),
    super.key,
  });

  @override
  State<FluidSplashWidget> createState() => _FluidSplashWidgetState();
}

class _FluidSplashWidgetState extends State<FluidSplashWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller1;
  late AnimationController _controller2;
  late AnimationController _controller3;
  late AnimationController _scaleController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();

    _controller1 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _controller2 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    _controller3 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    // Start scale animation
    _scaleController.forward();
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    _scaleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            widget.color1.withAlpha(76),
            widget.color2.withAlpha(76),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Animated blob 1
          AnimatedBuilder(
            animation: _controller1,
            builder: (context, child) {
              return Positioned(
                top: 100 + math.sin(_controller1.value * 2 * math.pi) * 40,
                left: 50 + math.cos(_controller1.value * 2 * math.pi) * 30,
                child: _FluidBlob(
                  size: 220,
                  color: widget.color1.withAlpha(76),
                  animation: _controller1,
                ),
              );
            },
          ),

          // Animated blob 2
          AnimatedBuilder(
            animation: _controller2,
            builder: (context, child) {
              return Positioned(
                bottom: 150 + math.cos(_controller2.value * 2 * math.pi) * 50,
                right: 30 + math.sin(_controller2.value * 2 * math.pi) * 35,
                child: _FluidBlob(
                  size: 280,
                  color: widget.color2.withAlpha(76),
                  animation: _controller2,
                ),
              );
            },
          ),

          // Animated blob 3
          AnimatedBuilder(
            animation: _controller3,
            builder: (context, child) {
              return Positioned(
                top: 300 + math.sin(_controller3.value * 2 * math.pi) * 60,
                right: 100 + math.cos(_controller3.value * 2 * math.pi) * 40,
                child: _FluidBlob(
                  size: 200,
                  color: widget.color3.withAlpha(64),
                  animation: _controller3,
                ),
              );
            },
          ),

          // Center content with scale and pulse animations
          Center(
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + (_pulseController.value * 0.05),
                  child: ScaleTransition(
                    scale: CurvedAnimation(
                      parent: _scaleController,
                      curve: Curves.elasticOut,
                    ),
                    child: widget.child,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual fluid blob widget
class _FluidBlob extends StatelessWidget {
  final double size;
  final Color color;
  final Animation<double> animation;

  const _FluidBlob({
    required this.size,
    required this.color,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                color,
                color.withAlpha(0),
              ],
            ),
          ),
        );
      },
    );
  }
}

