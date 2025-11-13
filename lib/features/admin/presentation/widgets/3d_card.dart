import 'package:flutter/material.dart';
import 'package:makan_mate/core/constants/ui_constants.dart';

/// 3D Card widget with tilt effect
class Card3D extends StatefulWidget {
  final Widget child;
  final double? height;
  final double? width;
  final VoidCallback? onTap;

  const Card3D({
    super.key,
    required this.child,
    this.height,
    this.width,
    this.onTap,
  });

  @override
  State<Card3D> createState() => _Card3DState();
}

class _Card3DState extends State<Card3D> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _xRotation = 0;
  double _yRotation = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final size = MediaQuery.of(context).size;
    final dx = details.localPosition.dx - (widget.width ?? size.width) / 2;
    final dy = details.localPosition.dy - (widget.height ?? 200) / 2;

    setState(() {
      _xRotation = (dy / (widget.height ?? 200)) * 0.1;
      _yRotation = -(dx / (widget.width ?? size.width)) * 0.1;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    _controller.forward().then((_) {
      _controller.reverse();
    });
    setState(() {
      _xRotation = 0;
      _yRotation = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      onTap: widget.onTap,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 200),
        builder: (context, value, child) {
          return Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateX(_xRotation * value)
              ..rotateY(_yRotation * value),
            alignment: FractionalOffset.center,
            child: Container(
              height: widget.height,
              width: widget.width,
              decoration: BoxDecoration(
                borderRadius: UIConstants.borderRadiusLg,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2 * value),
                    blurRadius: 20 * value,
                    offset: Offset(_yRotation * 20 * value, _xRotation * 20 * value),
                  ),
                ],
              ),
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}

/// Animated gradient background
class AnimatedGradientBackground extends StatefulWidget {
  final Widget child;
  final List<Color> colors;

  const AnimatedGradientBackground({
    super.key,
    required this.child,
    required this.colors,
  });

  @override
  State<AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState
    extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.colors,
              stops: [
                0.0 + (_controller.value * 0.3),
                0.5 + (_controller.value * 0.3),
                1.0 + (_controller.value * 0.3),
              ].map((e) => e.clamp(0.0, 1.0)).toList(),
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}

