import 'package:flutter/material.dart';

/// Centralized color palette for MakanMate app
///
/// All colors used across the app should be defined here to ensure
/// consistency and easy theme management
class AppColors {
  // Prevent instantiation
  AppColors._();

  // ============================================================================
  // PRIMARY BRAND COLORS
  // ============================================================================

  static const Color primary = Color(0xFFFF9800); // Orange
  static const Color primaryDark = Color(0xFFF57C00);
  static const Color primaryLight = Color(0xFFFFB74D);

  // ============================================================================
  // SECONDARY COLORS
  // ============================================================================

  static const Color secondary = Color(0xFFFF5722); // Deep Orange
  static const Color secondaryDark = Color(0xFFE64A19);
  static const Color secondaryLight = Color(0xFFFF8A65);

  // ============================================================================
  // AI & RECOMMENDATION COLORS
  // ============================================================================

  static const Color aiPrimary = Color(0xFF9C27B0); // Purple
  static const Color aiSecondary = Color(0xFF673AB7); // Deep Purple
  static const Color aiAccent = Color(0xFFBA68C8); // Light Purple
  static const Color aiGradientStart = Color(0xFFAB47BC);
  static const Color aiGradientEnd = Color(0xFF7B1FA2);

  // ============================================================================
  // BACKGROUND & SURFACE
  // ============================================================================

  static const Color background = Color(0xFFF5F5F5);
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF5F5F5);
  static const Color overlay = Color(0x80000000); // 50% black

  // ============================================================================
  // TEXT COLORS
  // ============================================================================

  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color textOnPrimary = Colors.white;
  static const Color textOnDark = Colors.white;

  // ============================================================================
  // STATUS & SEMANTIC COLORS
  // ============================================================================

  static const Color success = Color(0xFF4CAF50); // Green
  static const Color successLight = Color(0xFF81C784);
  static const Color successDark = Color(0xFF388E3C);

  static const Color error = Color(0xFFF44336); // Red
  static const Color errorLight = Color(0xFFE57373);
  static const Color errorDark = Color(0xFFD32F2F);

  static const Color warning = Color(0xFFFFC107); // Amber
  static const Color warningLight = Color(0xFFFFD54F);
  static const Color warningDark = Color(0xFFFFA000);

  static const Color info = Color(0xFF2196F3); // Blue
  static const Color infoLight = Color(0xFF64B5F6);
  static const Color infoDark = Color(0xFF1976D2);

  // ============================================================================
  // FEATURE-SPECIFIC COLORS
  // ============================================================================

  // Food attributes
  static const Color halal = Color(0xFF4CAF50);
  static const Color vegetarian = Color(0xFF8BC34A);
  static const Color vegan = Color(0xFF689F38);
  static const Color glutenFree = Color(0xFFAED581);

  // Ratings & Reviews
  static const Color rating = Color(0xFFFFC107); // Amber/Gold
  static const Color ratingFilled = Color(0xFFFFA000);
  static const Color ratingEmpty = Color(0xFFE0E0E0);

  // Spice level
  static const Color spiceMild = Color(0xFFFF9800);
  static const Color spiceMedium = Color(0xFFFF5722);
  static const Color spiceHot = Color(0xFFF44336);

  // ============================================================================
  // GREY SCALE
  // ============================================================================

  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);

  // ============================================================================
  // GRADIENTS
  // ============================================================================

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient aiGradient = LinearGradient(
    colors: [aiGradientStart, aiGradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [successLight, successDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ============================================================================
  // SHADOWS
  // ============================================================================

  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.12),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> get aiShadow => [
    BoxShadow(
      color: aiPrimary.withOpacity(0.3),
      blurRadius: 10,
      offset: const Offset(0, 5),
    ),
  ];

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Get color with opacity
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  /// Get cuisine type color
  static Color getCuisineColor(String cuisineType) {
    switch (cuisineType.toLowerCase()) {
      case 'malay':
        return const Color(0xFFE91E63); // Pink
      case 'chinese':
        return const Color(0xFFF44336); // Red
      case 'indian':
        return const Color(0xFFFF9800); // Orange
      case 'western':
        return const Color(0xFF795548); // Brown
      case 'thai':
        return const Color(0xFF4CAF50); // Green
      case 'japanese':
        return const Color(0xFFF44336); // Red
      case 'korean':
        return const Color(0xFFE91E63); // Pink
      default:
        return grey600;
    }
  }

  /// Get spice level color
  static Color getSpiceLevelColor(double spiceLevel) {
    if (spiceLevel < 0.3) return spiceMild;
    if (spiceLevel < 0.7) return spiceMedium;
    return spiceHot;
  }
}
