import 'package:flutter/material.dart';

/// UI Constants for consistent spacing, sizing, and animations
/// across the MakanMate application
class UIConstants {
  UIConstants._();

  // ============================================================================
  // SPACING & PADDING
  // ============================================================================

  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double spacing2Xl = 48.0;

  // ============================================================================
  // BORDER RADIUS
  // ============================================================================

  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusCircular = 999.0;

  static BorderRadius get borderRadiusSm => BorderRadius.circular(radiusSm);
  static BorderRadius get borderRadiusMd => BorderRadius.circular(radiusMd);
  static BorderRadius get borderRadiusLg => BorderRadius.circular(radiusLg);
  static BorderRadius get borderRadiusXl => BorderRadius.circular(radiusXl);
  static BorderRadius get borderRadiusCircular =>
      BorderRadius.circular(radiusCircular);

  // ============================================================================
  // ICON SIZES
  // ============================================================================

  static const double iconSizeSm = 16.0;
  static const double iconSizeMd = 20.0;
  static const double iconSizeLg = 24.0;
  static const double iconSizeXl = 32.0;
  static const double iconSize2Xl = 48.0;

  // ============================================================================
  // FONT SIZES
  // ============================================================================

  static const double fontSizeXs = 10.0;
  static const double fontSizeSm = 12.0;
  static const double fontSizeMd = 14.0;
  static const double fontSizeLg = 16.0;
  static const double fontSizeXl = 18.0;
  static const double fontSize2Xl = 20.0;
  static const double fontSize3Xl = 24.0;

  // ============================================================================
  // ELEVATION
  // ============================================================================

  static const double elevationNone = 0.0;
  static const double elevationSm = 2.0;
  static const double elevationMd = 4.0;
  static const double elevationLg = 8.0;
  static const double elevationXl = 16.0;

  // ============================================================================
  // CARD DIMENSIONS
  // ============================================================================

  static const double cardHeight = 200.0;
  static const double cardWidth = 180.0;
  static const double cardImageHeight = 120.0;

  // ============================================================================
  // ANIMATION DURATIONS
  // ============================================================================

  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // ============================================================================
  // OPACITY VALUES
  // ============================================================================

  static const double opacityDisabled = 0.38;
  static const double opacityMedium = 0.6;
  static const double opacityLight = 0.87;
  static const double opacityFull = 1.0;

  // ============================================================================
  // CONSTRAINTS
  // ============================================================================

  static const double maxContentWidth = 600.0;
  static const double minButtonHeight = 48.0;
  static const double minTouchTarget = 44.0;

  // ============================================================================
  // EDGE INSETS
  // ============================================================================

  static const EdgeInsets paddingXs = EdgeInsets.all(spacingXs);
  static const EdgeInsets paddingSm = EdgeInsets.all(spacingSm);
  static const EdgeInsets paddingMd = EdgeInsets.all(spacingMd);
  static const EdgeInsets paddingLg = EdgeInsets.all(spacingLg);
  static const EdgeInsets paddingXl = EdgeInsets.all(spacingXl);

  static const EdgeInsets paddingHorizontalMd = EdgeInsets.symmetric(
    horizontal: spacingMd,
  );
  static const EdgeInsets paddingHorizontalLg = EdgeInsets.symmetric(
    horizontal: spacingLg,
  );
  static const EdgeInsets paddingVerticalMd = EdgeInsets.symmetric(
    vertical: spacingMd,
  );
  static const EdgeInsets paddingVerticalLg = EdgeInsets.symmetric(
    vertical: spacingLg,
  );

  // ============================================================================
  // GAPS (for Row/Column spacing)
  // ============================================================================

  static const SizedBox gapXs = SizedBox(width: spacingXs, height: spacingXs);
  static const SizedBox gapSm = SizedBox(width: spacingSm, height: spacingSm);
  static const SizedBox gapMd = SizedBox(width: spacingMd, height: spacingMd);
  static const SizedBox gapLg = SizedBox(width: spacingLg, height: spacingLg);
  static const SizedBox gapXl = SizedBox(width: spacingXl, height: spacingXl);
}
