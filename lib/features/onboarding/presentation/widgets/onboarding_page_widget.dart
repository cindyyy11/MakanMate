import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:makan_mate/core/theme/app_colors.dart';
import 'package:makan_mate/features/onboarding/domain/entities/onboarding_page_entity.dart';
import 'package:flutter/services.dart';

/// Individual onboarding page widget with Lottie animations and fluid background
class OnboardingPageWidget extends StatefulWidget {
  final OnboardingPageEntity page;
  final int pageIndex;

  const OnboardingPageWidget({
    required this.page,
    required this.pageIndex,
    super.key,
  });

  @override
  State<OnboardingPageWidget> createState() => _OnboardingPageWidgetState();
}

class _OnboardingPageWidgetState extends State<OnboardingPageWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _fluidController1;
  late AnimationController _fluidController2;
  late AnimationController _fluidController3;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Main content animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Fluid blob animations
    _fluidController1 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _fluidController2 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    _fluidController3 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _fluidController1.dispose();
    _fluidController2.dispose();
    _fluidController3.dispose();
    super.dispose();
  }

  Color _getPageColor(int index) {
    final colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.aiPrimary,
      AppColors.info,
    ];
    return colors[index % colors.length];
  }

  Color _getSecondaryPageColor(int index) {
    final colors = [
      AppColors.primaryLight,
      AppColors.secondaryLight,
      AppColors.aiAccent,
      AppColors.infoLight,
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final pageColor = _getPageColor(widget.pageIndex);
    final pageColor2 = _getSecondaryPageColor(widget.pageIndex);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            pageColor.withAlpha(40),
            pageColor2.withAlpha(30),
            Colors.white,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Fluid animated blobs in background
          _buildFluidBackground(pageColor, pageColor2),
          
          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40),
              child: Column(
            children: [
              // Animated Lottie or Emoji icon
              Expanded(
                flex: 2,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: _buildAnimation(),
                  ),
                ),
              ),

              // Content
              Expanded(
                flex: 3,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Title
                        Text(
                          widget.page.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Description
                        Text(
                          widget.page.description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Features list with animated items
                        ...widget.page.features.asMap().entries.map((entry) {
                          return TweenAnimationBuilder<double>(
                            duration: Duration(milliseconds: 500 + (entry.key * 100)),
                            tween: Tween(begin: 0.0, end: 1.0),
                            builder: (context, value, child) {
                              return Opacity(
                                opacity: value,
                                child: Transform.translate(
                                  offset: Offset(0, 20 * (1 - value)),
                                  child: child,
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: pageColor,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: pageColor.withAlpha(76),
                                          blurRadius: 4,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      entry.value,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
        ],
      ),
    );
  }

  Widget _buildFluidBackground(Color color1, Color color2) {
    return Stack(
      children: [
        AnimatedBuilder(
          animation: _fluidController1,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(
                math.sin(_fluidController1.value * 2 * math.pi) * 50,
                math.cos(_fluidController1.value * 2 * math.pi) * 40,
              ),
              child: CustomPaint(
                painter: BlobPainter(
                  color: color1.withOpacity(0.2),
                  radius: 150 + math.sin(_fluidController1.value * 2 * math.pi) * 20,
                  offset: const Offset(0.2, 0.3),
                ),
                child: Container(),
              ),
            );
          },
        ),
        AnimatedBuilder(
          animation: _fluidController2,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(
                math.cos(_fluidController2.value * 2 * math.pi) * 60,
                math.sin(_fluidController2.value * 2 * math.pi) * 50,
              ),
              child: CustomPaint(
                painter: BlobPainter(
                  color: color2.withOpacity(0.15),
                  radius: 180 + math.cos(_fluidController2.value * 2 * math.pi) * 25,
                  offset: const Offset(0.8, 0.7),
                ),
                child: Container(),
              ),
            );
          },
        ),
        AnimatedBuilder(
          animation: _fluidController3,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(
                math.sin(_fluidController3.value * 2 * math.pi) * 70,
                math.cos(_fluidController3.value * 2 * math.pi) * 60,
              ),
              child: CustomPaint(
                painter: BlobPainter(
                  color: color1.withOpacity(0.1),
                  radius: 120 + math.sin(_fluidController3.value * 2 * math.pi) * 15,
                  offset: const Offset(0.5, 0.1),
                ),
                child: Container(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAnimation() {
    // Try to load Lottie animation if asset path is provided
    if (widget.page.lottieAsset != null && widget.page.lottieAsset!.isNotEmpty) {
      return FutureBuilder(
        future: rootBundle.load(widget.page.lottieAsset!).catchError((_) => throw Exception()),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done && 
              snapshot.hasData && 
              !snapshot.hasError) {
            // Lottie file exists, show it
            return Lottie.asset(
              widget.page.lottieAsset!,
              width: 300,
              height: 300,
              fit: BoxFit.contain,
              repeat: true,
              errorBuilder: (context, error, stackTrace) {
                // Fallback on error
                return _buildEmojiIcon();
              },
            );
          }
          // Fallback to emoji
          return _buildEmojiIcon();
        },
      );
    }

    // Fallback to emoji
    return _buildEmojiIcon();
  }

  Widget _buildEmojiIcon() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getPageColor(widget.pageIndex),
            _getPageColor(widget.pageIndex).withAlpha(179),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: _getPageColor(widget.pageIndex).withAlpha(76),
            blurRadius: 30,
            spreadRadius: 10,
          ),
        ],
      ),
      child: Text(
        widget.page.iconEmoji,
        style: const TextStyle(
          fontSize: 120,
        ),
      ),
    );
  }
}

/// Custom painter for fluid blob animations
class BlobPainter extends CustomPainter {
  final Color color;
  final double radius;
  final Offset offset;

  BlobPainter({
    required this.color,
    required this.radius,
    required this.offset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final center = Offset(
      size.width * offset.dx,
      size.height * offset.dy,
    );

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

