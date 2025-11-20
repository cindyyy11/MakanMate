import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:makan_mate/core/constants/ui_constants.dart';
import 'package:makan_mate/core/theme/app_colors.dart';
import 'package:makan_mate/core/theme/app_theme.dart';

/// Creative bottom navigation bar with advanced animations and glassmorphism
class CreativeBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<BottomNavItem> items;

  const CreativeBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  State<CreativeBottomNavBar> createState() => _CreativeBottomNavBarState();
}

class _CreativeBottomNavBarState extends State<CreativeBottomNavBar>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _scaleAnimations;
  late List<Animation<double>> _slideAnimations;
  late AnimationController _indicatorController;

  @override
  void initState() {
    super.initState();
    
    // Create animation controllers for each item
    _controllers = List.generate(
      widget.items.length,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 300),
      ),
    );

    // Scale animations
    _scaleAnimations = _controllers.map((controller) {
      return Tween<double>(begin: 1.0, end: 1.15).animate(
        CurvedAnimation(parent: controller, curve: Curves.elasticOut),
      );
    }).toList();

    // Slide animations
    _slideAnimations = _controllers.map((controller) {
      return Tween<double>(begin: 0.0, end: -10.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOut),
      );
    }).toList();

    // Indicator animation
    _indicatorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // Animate initial selected item
    _controllers[widget.currentIndex].forward();
    _indicatorController.forward();
  }

  @override
  void didUpdateWidget(CreativeBottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      // Animate previous item out
      _controllers[oldWidget.currentIndex].reverse();
      // Animate new item in
      _controllers[widget.currentIndex].forward();
      _indicatorController.reset();
      _indicatorController.forward();
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    _indicatorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [
                  const Color(0xFF1E1E1E).withValues(alpha: 0.95),
                  const Color(0xFF1A1A1A).withValues(alpha: 0.98),
                ]
              : [
                  Colors.white.withValues(alpha: 0.95),
                  Colors.white.withValues(alpha: 0.98),
                ],
        ),
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : AppColors.grey200.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.1),
            blurRadius: 30,
            offset: const Offset(0, -10),
            spreadRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: UIConstants.spacingSm,
            vertical: UIConstants.spacingXs,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: widget.items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = widget.currentIndex == index;

              return Expanded(
                child: _buildNavItem(
                  item,
                  index,
                  isSelected,
                  isDark,
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BottomNavItem item,
    int index,
    bool isSelected,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: () {
        widget.onTap(index);
        HapticFeedback.lightImpact();
      },
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _controllers[index],
          _indicatorController,
        ]),
        builder: (context, child) {
          final scale = _scaleAnimations[index].value;
          final slide = _slideAnimations[index].value;
          final indicatorValue = _indicatorController.value;

          return Transform.translate(
            offset: Offset(0, slide),
            child: Transform.scale(
              scale: scale,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: UIConstants.spacingXs,
                ),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.primary.withValues(alpha: 0.15 * indicatorValue),
                            AppColors.primary.withValues(alpha: 0.05 * indicatorValue),
                          ],
                        )
                      : null,
                  borderRadius: UIConstants.borderRadiusMd,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Glow effect for selected item
                        if (isSelected)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 
                                      0.4 * indicatorValue,
                                    ),
                                    blurRadius: 15 * indicatorValue,
                                    spreadRadius: 3 * indicatorValue,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        // Icon container
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? AppColors.primaryGradient
                                : null,
                            color: isSelected
                                ? null
                                : Colors.transparent,
                            shape: BoxShape.circle,
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(alpha: 
                                        0.5 * indicatorValue,
                                      ),
                                      blurRadius: 12 * indicatorValue,
                                      spreadRadius: 2 * indicatorValue,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Icon(
                            isSelected ? item.activeIcon : item.icon,
                            size: 22,
                            color: isSelected
                                ? Colors.white
                                : AppColorsExtension.getGrey600(context),
                          ),
                        ),
                        // Active indicator dot
                        if (isSelected)
                          Positioned(
                            right: -2,
                            top: -2,
                            child: ScaleTransition(
                              scale: Tween<double>(begin: 0.0, end: 1.0).animate(
                                CurvedAnimation(
                                  parent: _indicatorController,
                                  curve: Curves.elasticOut,
                                ),
                              ),
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.success,
                                      AppColors.success.withValues(alpha: 0.8),
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isDark
                                        ? const Color(0xFF1E1E1E)
                                        : Colors.white,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.success.withValues(alpha: 0.6),
                                      blurRadius: 6,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Flexible(
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: TextStyle(
                          color: isSelected
                              ? AppColors.primary
                              : AppColorsExtension.getGrey600(context),
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                          fontSize: UIConstants.fontSizeXs,
                          letterSpacing: 0.3,
                        ),
                        child: Text(
                          item.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class BottomNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const BottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

