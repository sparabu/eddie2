import 'package:flutter/material.dart';

/// Eddie Design System Constants
///
/// This file contains standardized values for spacing, sizing, animations,
/// and other constants used throughout the Eddie design system.
class EddieConstants {
  // Spacing
  static const double spacingXxs = 2.0;
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 48.0;
  
  // Border radius
  static const double borderRadiusSmall = 4.0;
  static const double borderRadiusMedium = 8.0;
  static const double borderRadiusLarge = 12.0;
  static const double borderRadiusXl = 16.0;
  static const double borderRadiusRound = 999.0; // For fully rounded elements
  
  // Animation durations
  static const Duration animationShort = Duration(milliseconds: 150);
  static const Duration animationMedium = Duration(milliseconds: 300);
  static const Duration animationLong = Duration(milliseconds: 500);
  
  // Elevation (for shadows)
  static const double elevationNone = 0.0;
  static const double elevationXs = 1.0;
  static const double elevationSm = 2.0;
  static const double elevationMd = 4.0;
  static const double elevationLg = 8.0;
  static const double elevationXl = 16.0;
  
  // Icon sizes
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 20.0;
  static const double iconSizeLarge = 24.0;
  static const double iconSizeXl = 32.0;
  
  // Minimum touch target size (for accessibility)
  static const double minTouchTargetSize = 44.0;
  
  // Button sizes
  static const double buttonHeightSmall = 32.0;
  static const double buttonHeightMedium = 40.0;
  static const double buttonHeightLarge = 48.0;
  
  // Input field heights
  static const double inputHeightSmall = 36.0;
  static const double inputHeightMedium = 44.0;
  static const double inputHeightLarge = 52.0;
  
  // Content width constraints
  static const double maxContentWidth = 1200.0;
  static const double maxCardWidth = 600.0;
  static const double maxFormWidth = 400.0;
  
  // Standard box shadows
  static List<BoxShadow> getShadowSmall(BuildContext context, {Color? shadowColor}) {
    final color = shadowColor ?? 
        (Theme.of(context).brightness == Brightness.light 
            ? Colors.black.withOpacity(0.1) 
            : Colors.black.withOpacity(0.2));
    
    return [
      BoxShadow(
        color: color,
        blurRadius: 4,
        offset: const Offset(0, 1),
      ),
    ];
  }
  
  static List<BoxShadow> getShadowMedium(BuildContext context, {Color? shadowColor}) {
    final color = shadowColor ?? 
        (Theme.of(context).brightness == Brightness.light 
            ? Colors.black.withOpacity(0.1) 
            : Colors.black.withOpacity(0.2));
    
    return [
      BoxShadow(
        color: color,
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ];
  }
  
  static List<BoxShadow> getShadowLarge(BuildContext context, {Color? shadowColor}) {
    final color = shadowColor ?? 
        (Theme.of(context).brightness == Brightness.light 
            ? Colors.black.withOpacity(0.1) 
            : Colors.black.withOpacity(0.2));
    
    return [
      BoxShadow(
        color: color,
        blurRadius: 16,
        offset: const Offset(0, 4),
      ),
    ];
  }
}

