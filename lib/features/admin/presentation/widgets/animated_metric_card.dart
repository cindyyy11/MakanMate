import 'package:flutter/material.dart';
import 'package:makan_mate/core/constants/ui_constants.dart';
import 'package:makan_mate/core/theme/app_theme.dart';

/// Enhanced metric card with animations
class AnimatedMetricCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final LinearGradient? gradient;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  const AnimatedMetricCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.gradient,
    this.subtitle,
    this.onTap,
    this.trailing,
  }) : super(key: key);

  @override
  State<AnimatedMetricCard> createState() => _AnimatedMetricCardState();
}

class _AnimatedMetricCardState extends State<AnimatedMetricCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.03,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasGradient = widget.gradient != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: UIConstants.borderRadiusLg,
        onTapDown: (_) {
          setState(() => _isHovered = true);
          _controller.forward();
        },
        onTapUp: (_) {
          setState(() => _isHovered = false);
          _controller.reverse();
        },
        onTapCancel: () {
          setState(() => _isHovered = false);
          _controller.reverse();
        },
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                constraints: const BoxConstraints(
                  // Enforce consistent card height across varying content
                  minHeight: 220,
                ),
                padding: const EdgeInsets.all(UIConstants.spacingLg),
                decoration: BoxDecoration(
                  // Enhanced background with better theme support
                  color: hasGradient
                      ? null
                      : (isDark
                            ? widget.color.withValues(alpha: 0.12)
                            : widget.color.withValues(alpha: 0.08)),
                  gradient: hasGradient
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: widget.gradient!.colors,
                        )
                      : null,
                  borderRadius: UIConstants.borderRadiusLg,
                  border: Border.all(
                    color: isDark
                        ? widget.color.withValues(alpha: 0.4)
                        : widget.color.withValues(alpha: 0.25),
                    width: _isHovered ? 2 : 1.5,
                  ),
                  boxShadow: [
                    // Enhanced shadow with better visibility
                    BoxShadow(
                      color: widget.color.withValues(
                        alpha: _isHovered
                            ? (isDark ? 0.4 : 0.25)
                            : (isDark ? 0.2 : 0.12),
                      ),
                      blurRadius: _isHovered ? 24 : 12,
                      spreadRadius: _isHovered ? 3 : 0,
                      offset: Offset(0, _isHovered ? 10 : 6),
                    ),
                    // Additional subtle shadow for depth
                    if (_isHovered)
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: isDark ? 0.3 : 0.1,
                        ),
                        blurRadius: 8,
                        spreadRadius: 0,
                        offset: const Offset(0, 4),
                      ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        // Responsive icon sizing to avoid overflow on small cards
                        final iconSize =
                            constraints.biggest.shortestSide * 0.22;
                        final clampedIcon = iconSize.clamp(18.0, 28.0);
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                gradient: hasGradient
                                    ? null
                                    : LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          widget.color.withValues(alpha: 0.25),
                                          widget.color.withValues(alpha: 0.15),
                                        ],
                                      ),
                                color: hasGradient
                                    ? Colors.white.withValues(alpha: 0.2)
                                    : null,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: widget.color.withValues(alpha: 0.35),
                                    blurRadius: 10,
                                    spreadRadius: 0,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Icon(
                                widget.icon,
                                color: hasGradient
                                    ? Colors.white
                                    : widget.color,
                                size: clampedIcon.toDouble(),
                              ),
                            ),
                            _buildPulseIndicator(widget.color),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: UIConstants.spacingLg),
                    Text(
                      widget.title,
                      softWrap: true,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: hasGradient
                            ? Colors.white
                            : AppColorsExtension.getTextPrimary(context),
                        fontWeight: FontWeight.w600,
                        fontSize: UIConstants.fontSizeSm,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: UIConstants.spacingXs),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              widget.value,
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(
                                    color: hasGradient
                                        ? Colors.white
                                        : AppColorsExtension.getTextPrimary(
                                            context,
                                          ),
                                    fontWeight: FontWeight.bold,
                                    fontSize: UIConstants.fontSize3Xl,
                                    letterSpacing: -0.5,
                                  ),
                              maxLines: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (widget.trailing != null) ...[
                      const SizedBox(height: UIConstants.spacingSm),
                      // Place trend indicator on its own line and allow it to fill remaining width
                      SizedBox(width: double.infinity, child: widget.trailing!),
                    ],
                    if (widget.subtitle != null) ...[
                      const SizedBox(height: UIConstants.spacingXs),
                      Text(
                        widget.subtitle!,
                        softWrap: true,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: hasGradient
                              ? Colors.white.withValues(alpha: 0.9)
                              : AppColorsExtension.getTextSecondary(context),
                          fontSize: UIConstants.fontSizeXs,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPulseIndicator(Color color) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(seconds: 2),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer pulse ring
            Container(
              width: 12 + (8 * value),
              height: 12 + (8 * value),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: color.withValues(alpha: 0.3 * (1 - value)),
                  width: 2,
                ),
              ),
            ),
            // Inner dot
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.6),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ],
        );
      },
      onEnd: () {
        if (mounted) {
          setState(() {});
        }
      },
    );
  }
}
