import 'package:flutter/material.dart';

/// Admin-specific theme enhancements
class AdminTheme {
  // Light Theme Colors
  static const Color lightBackground = Color(0xFFF8F9FA);
  static const Color lightSurface = Colors.white;
  static const Color lightCardBackground = Colors.white;
  static const Color lightBorderColor = Color(0xFFE5E7EB);
  static const Color lightTextPrimary = Color(0xFF111827);
  static const Color lightTextSecondary = Color(0xFF6B7280);
  static const Color lightDividerColor = Color(0xFFE5E7EB);

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF0F0F0F);
  static const Color darkSurface = Color(0xFF1A1A1A);
  static const Color darkCardBackground = Color(0xFF1E1E1E);
  static const Color darkBorderColor = Color(0xFF2C2C2C);
  static const Color darkTextPrimary = Color(0xFFF9FAFB);
  static const Color darkTextSecondary = Color(0xFF9CA3AF);
  static const Color darkDividerColor = Color(0xFF2C2C2C);

  /// Get admin-specific background color
  static Color getAdminBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkBackground
        : lightBackground;
  }

  /// Get admin-specific surface color
  static Color getAdminSurface(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkSurface
        : lightSurface;
  }

  /// Get admin-specific card background
  static Color getAdminCardBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkCardBackground
        : lightCardBackground;
  }

  /// Get admin-specific border color
  static Color getAdminBorderColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkBorderColor
        : lightBorderColor;
  }

  /// Get admin-specific text primary color
  static Color getAdminTextPrimary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkTextPrimary
        : lightTextPrimary;
  }

  /// Get admin-specific text secondary color
  static Color getAdminTextSecondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkTextSecondary
        : lightTextSecondary;
  }

  /// Get admin-specific divider color
  static Color getAdminDividerColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkDividerColor
        : lightDividerColor;
  }

  /// Admin card decoration
  static BoxDecoration getAdminCardDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: getAdminCardBackground(context),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: getAdminBorderColor(context),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: isDark
              ? Colors.black.withOpacity(0.5)
              : Colors.black.withOpacity(0.05),
          blurRadius: 20,
          offset: const Offset(0, 4),
          spreadRadius: 0,
        ),
      ],
    );
  }

  /// Glassmorphism effect for admin panels
  static BoxDecoration getGlassmorphismDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDark
            ? [
                Colors.white.withOpacity(0.05),
                Colors.white.withOpacity(0.02),
              ]
            : [
                Colors.white.withOpacity(0.9),
                Colors.white.withOpacity(0.7),
              ],
      ),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: isDark
            ? Colors.white.withOpacity(0.1)
            : Colors.white.withOpacity(0.8),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: isDark
              ? Colors.black.withOpacity(0.5)
              : Colors.black.withOpacity(0.1),
          blurRadius: 30,
          offset: const Offset(0, 10),
          spreadRadius: 0,
        ),
      ],
    );
  }
}

