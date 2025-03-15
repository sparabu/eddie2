import 'package:flutter/material.dart';

/// Eddie Design System Colors
///
/// This file contains all the color definitions for the Eddie design system.
class EddieColors {
  // Primary Colors - Neutral palette
  static const Color primaryLight = Color(0xFF000000);
  static const Color primaryDark = Color(0xFFFFFFFF);

  // Background Colors
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color backgroundDark = Color(0xFF121212);

  // Surface Colors
  static const Color surfaceLight = Colors.white;
  static const Color surfaceDark = Color(0xFF121212); // Matches background

  static const Color cardLight = Colors.white;
  static const Color cardDark = Color(0xFF121212); // Matches background

  // Text Colors
  static const Color textPrimaryLight = Color(0xFF000000);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);

  static const Color textSecondaryLight = Color(0xFF757575);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);

  // Input Colors
  static const Color inputBackgroundLight = Color(0xFFF5F5F5);
  static const Color inputBackgroundDark = Color(0xFF1A1A1A); // Slightly lighter than background

  static const Color inputBorderLight = Color(0xFFE0E0E0);
  static const Color inputBorderDark = Color(0xFF333333);

  // Outline Colors
  static const Color outlineLight = Color(0xFFE0E0E0);
  static const Color outlineDark = Color(0xFF333333);

  // Button Colors
  static const Color buttonLight = Color(0xFF000000);
  static const Color buttonDark = Color(0xFFFFFFFF);

  static const Color buttonTextLight = Color(0xFFFFFFFF);
  static const Color buttonTextDark = Color(0xFF000000);
  
  // Login Button Colors
  static const Color loginButtonBackgroundLight = Color(0xFFF5F5F5);
  static const Color loginButtonBackgroundDark = Color(0xFF333333);
  
  static const Color loginButtonTextLight = Color(0xFF000000);
  static const Color loginButtonTextDark = Color(0xFFFFFFFF);

  // Semantic Colors
  static const Color errorLight = Color(0xFFDC3545);
  static const Color errorDark = Color(0xFFFF453A);

  static const Color successLight = Color(0xFF28A745);
  static const Color successDark = Color(0xFF32D74B);

  // =========================================================================
  // REFACTORING NEEDED: The following color constants are referenced by other
  // files in the codebase (theme files, chat interface, settings screen, etc.)
  // but were missing from this central color definition file.
  //
  // During the planned refactoring, these should be:
  // 1. Reviewed for consistency with the design system
  // 2. Potentially consolidated with existing colors where appropriate
  // 3. Properly documented with their specific usage contexts
  // =========================================================================

  // Chat Interface Colors
  static const Color userBubbleLight = Color(0xFFE1F5FE);
  static const Color userBubbleDark = Color(0xFF0D47A1);
  
  static const Color assistantBubbleLight = Color(0xFFF5F5F5);
  static const Color assistantBubbleDark = Color(0xFF2A2A2A);
  
  static const Color userTextLight = Color(0xFF000000);
  static const Color userTextDark = Color(0xFFFFFFFF);
  
  static const Color assistantTextLight = Color(0xFF000000);
  static const Color assistantTextDark = Color(0xFFFFFFFF);

  // Additional Theme Colors
  static const Color secondaryLight = Color(0xFF6200EE);
  static const Color secondaryDark = Color(0xFFBB86FC);
  
  static const Color surfaceVariantLight = Color(0xFFEEEEEE);
  static const Color surfaceVariantDark = Color(0xFF2C2C2C);
  
  static const Color warningLight = Color(0xFFFFC107);
  static const Color warningDark = Color(0xFFFFD54F);
  
  static const Color hoverLight = Color(0xFFE0E0E0);
  static const Color hoverDark = Color(0xFF3A3A3A);
  
  static const Color selectedItemLight = Color(0xFFE3F2FD);
  static const Color selectedItemDark = Color(0xFF0D47A1);

  // Container Colors
  static const Color primaryContainerLight = Color(0xFFE3F2FD);
  static const Color primaryContainerDark = Color(0xFF0D47A1);

  // Helper methods
  static Color getColor(BuildContext context, Color lightColor, Color darkColor) {
    return Theme.of(context).brightness == Brightness.light ? lightColor : darkColor;
  }

  static Color getPrimary(BuildContext context) {
    return getColor(context, primaryLight, primaryDark);
  }

  static Color getBackground(BuildContext context) {
    return getColor(context, backgroundLight, backgroundDark);
  }

  static Color getSurface(BuildContext context) {
    return getColor(context, surfaceLight, surfaceDark);
  }

  static Color getCard(BuildContext context) {
    return getColor(context, cardLight, cardDark);
  }

  static Color getTextPrimary(BuildContext context) {
    return getColor(context, textPrimaryLight, textPrimaryDark);
  }

  static Color getTextSecondary(BuildContext context) {
    return getColor(context, textSecondaryLight, textSecondaryDark);
  }

  static Color getInputBackground(BuildContext context) {
    return getColor(context, inputBackgroundLight, inputBackgroundDark);
  }

  static Color getInputBorder(BuildContext context) {
    return getColor(context, inputBorderLight, inputBorderDark);
  }

  static Color getOutline(BuildContext context) {
    return getColor(context, outlineLight, outlineDark);
  }

  static Color getButton(BuildContext context) {
    return getColor(context, buttonLight, buttonDark);
  }

  static Color getButtonText(BuildContext context) {
    return getColor(context, buttonTextLight, buttonTextDark);
  }
  
  static Color getLoginButtonBackground(BuildContext context) {
    return getColor(context, loginButtonBackgroundLight, loginButtonBackgroundDark);
  }
  
  static Color getLoginButtonText(BuildContext context) {
    return getColor(context, loginButtonTextLight, loginButtonTextDark);
  }

  static Color getError(BuildContext context) {
    return getColor(context, errorLight, errorDark);
  }

  static Color getSuccess(BuildContext context) {
    return getColor(context, successLight, successDark);
  }

  // =========================================================================
  // REFACTORING NEEDED: The following helper methods correspond to the color
  // constants added above and are needed by other parts of the codebase.
  // These should be reviewed during the planned refactoring.
  // =========================================================================

  // Chat Interface Color Getters
  static Color getUserBubble(BuildContext context) {
    return getColor(context, userBubbleLight, userBubbleDark);
  }

  static Color getAssistantBubble(BuildContext context) {
    return getColor(context, assistantBubbleLight, assistantBubbleDark);
  }

  static Color getUserText(BuildContext context) {
    return getColor(context, userTextLight, userTextDark);
  }

  static Color getAssistantText(BuildContext context) {
    return getColor(context, assistantTextLight, assistantTextDark);
  }

  // Additional Theme Color Getters
  static Color getSecondary(BuildContext context) {
    return getColor(context, secondaryLight, secondaryDark);
  }

  static Color getSurfaceVariant(BuildContext context) {
    return getColor(context, surfaceVariantLight, surfaceVariantDark);
  }

  static Color getWarning(BuildContext context) {
    return getColor(context, warningLight, warningDark);
  }

  static Color getHover(BuildContext context) {
    return getColor(context, hoverLight, hoverDark);
  }

  static Color getSelectedItem(BuildContext context) {
    return getColor(context, selectedItemLight, selectedItemDark);
  }

  // Container Color Getters
  static Color getPrimaryContainer(BuildContext context) {
    return getColor(context, primaryContainerLight, primaryContainerDark);
  }
}

