import 'dart:ui';
import 'package:flutter/material.dart';

class SocialAuthButton extends StatelessWidget {
  final dynamic icon; // Can be String (asset path) or IconData
  final String? label;
  final VoidCallback onPressed;
  final bool isIcon;
  final bool fullWidth;

  const SocialAuthButton({
    super.key,
    required this.icon,
    this.label,
    required this.onPressed,
    this.isIcon = false,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    if (fullWidth) {
      return _buildFullWidthButton(context);
    }
    return _buildIconButton(context);
  }

  Widget _buildIconButton(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.6),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withValues(alpha: 0.2),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: _buildIcon(size: 28),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFullWidthButton(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.6),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withValues(alpha: 0.2),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildIcon(size: 24),
                if (label != null) ...[
                  const SizedBox(width: 12),
                  Text(
                    label!,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon({required double size}) {
    if (isIcon && icon is IconData) {
      return Icon(
        icon as IconData,
        color: Colors.black87,
        size: size,
      );
    } else if (icon is String) {
      return Image.asset(
        icon as String,
        width: size,
        height: size,
        errorBuilder: (context, error, stackTrace) {
          // Fallback to Google icon
          return Icon(
            Icons.g_mobiledata,
            color: Colors.black87,
            size: size + 4,
          );
        },
      );
    }
    return Icon(
      Icons.help_outline,
      color: Colors.black87,
      size: size,
    );
  }
}