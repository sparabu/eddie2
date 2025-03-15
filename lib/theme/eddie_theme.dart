import 'package:flutter/material.dart';
import 'eddie_colors.dart';
import 'eddie_theme_extension.dart';

/// Eddie Design System Theme Mode Enum
enum EddieThemeMode {
  light,
  dark,
  system
}

/// Eddie Design System Theme
/// 
/// This file contains all the theme definitions for the Eddie app,
/// including theme modes, component themes, and utility methods.
/// 
/// NOTE: For color-related functionality, prefer using methods from [EddieColors]
/// directly. The color helper methods in this class are deprecated and will be
/// removed in a future version.
class EddieTheme {
  // Theme Mode
  static ThemeMode themeMode = ThemeMode.system;

  // Color References from EddieColors
  static const Color primaryColor = EddieColors.primaryLight;
  static const Color primaryColorDark = EddieColors.primaryDark;
  
  static const Color secondaryColor = EddieColors.secondaryLight;
  static const Color secondaryColorDark = EddieColors.secondaryDark;
  
  static const Color backgroundColor = EddieColors.backgroundLight;
  static const Color backgroundColorDark = EddieColors.backgroundDark;
  
  static const Color surfaceColor = EddieColors.surfaceLight;
  static const Color surfaceColorDark = EddieColors.surfaceDark;
  
  static const Color surfaceVariantColor = EddieColors.surfaceVariantLight;
  static const Color surfaceVariantColorDark = EddieColors.surfaceVariantDark;
  
  static const Color textColor = EddieColors.textPrimaryLight;
  static const Color textColorDark = EddieColors.textPrimaryDark;
  
  static const Color secondaryTextColor = EddieColors.textSecondaryLight;
  static const Color secondaryTextColorDark = EddieColors.textSecondaryDark;
  
  static const Color errorColor = EddieColors.errorLight;
  static const Color errorColorDark = EddieColors.errorDark;
  
  static const Color successColor = EddieColors.successLight;
  static const Color successColorDark = EddieColors.successDark;
  
  static const Color warningColor = EddieColors.warningLight;
  static const Color warningColorDark = EddieColors.warningDark;
  
  static const Color outlineColor = EddieColors.outlineLight;
  static const Color outlineColorDark = EddieColors.outlineDark;
  
  static const Color hoverColor = EddieColors.hoverLight;
  static const Color hoverColorDark = EddieColors.hoverDark;
  
  static const Color selectedItemColor = EddieColors.selectedItemLight;
  static const Color selectedItemColorDark = EddieColors.selectedItemDark;
  
  // Chat UI specific colors
  static const Color userBubbleColor = EddieColors.userBubbleLight;
  static const Color userBubbleColorDark = EddieColors.userBubbleDark;
  
  static const Color assistantBubbleColor = EddieColors.assistantBubbleLight;
  static const Color assistantBubbleColorDark = EddieColors.assistantBubbleDark;
  
  static const Color userTextColor = EddieColors.userTextLight;
  static const Color userTextColorDark = EddieColors.userTextDark;
  
  static const Color assistantTextColor = EddieColors.assistantTextLight;
  static const Color assistantTextColorDark = EddieColors.assistantTextDark;
  
  // Sidebar colors
  static const Color sidebarColor = EddieColors.surfaceVariantLight;
  static const Color darkSidebarColor = EddieColors.surfaceVariantDark;
  
  // Chat background colors
  static const Color chatBackgroundColor = EddieColors.backgroundLight;
  static const Color darkChatBackgroundColor = EddieColors.backgroundDark;

  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: EddieColors.primaryLight,
      onPrimary: Colors.white,
      primaryContainer: EddieColors.primaryContainerLight,
      onPrimaryContainer: Color(0xFF280680),
      secondary: EddieColors.secondaryLight,
      onSecondary: Colors.white,
      surface: EddieColors.surfaceLight,
      background: EddieColors.backgroundLight,
      error: EddieColors.errorLight,
    ),
    scaffoldBackgroundColor: EddieColors.backgroundLight,
    cardTheme: CardTheme(
      color: EddieColors.surfaceLight,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: EddieColors.surfaceLight,
      foregroundColor: EddieColors.textPrimaryLight,
      elevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide(color: EddieColors.outlineLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide(color: EddieColors.primaryLight, width: 2),
      ),
      filled: true,
      fillColor: EddieColors.surfaceLight,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: EddieColors.primaryLight,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: EddieColors.primaryLight,
        side: BorderSide(color: EddieColors.primaryLight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: EddieColors.primaryLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: EddieColors.textPrimaryLight),
      displayMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: EddieColors.textPrimaryLight),
      bodyLarge: TextStyle(fontSize: 16, color: EddieColors.textPrimaryLight),
      bodyMedium: TextStyle(fontSize: 14, color: EddieColors.textPrimaryLight),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: EddieColors.textPrimaryLight),
    ),
    extensions: const [
      EddieThemeExtension.light,
    ],
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: EddieColors.primaryDark,
      onPrimary: Colors.white,
      primaryContainer: EddieColors.primaryContainerDark,
      onPrimaryContainer: EddieColors.primaryContainerLight,
      secondary: EddieColors.secondaryDark,
      onSecondary: Colors.white,
      surface: EddieColors.surfaceDark,
      background: EddieColors.backgroundDark,
      error: EddieColors.errorDark,
    ),
    scaffoldBackgroundColor: EddieColors.backgroundDark,
    cardTheme: CardTheme(
      color: EddieColors.surfaceDark,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: EddieColors.outlineDark, width: 1),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: EddieColors.surfaceDark,
      foregroundColor: EddieColors.textPrimaryDark,
      elevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide(color: EddieColors.outlineDark),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide(color: EddieColors.primaryDark, width: 2),
      ),
      filled: true,
      fillColor: Color(0xFF2A2A2A),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: EddieColors.primaryDark,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: EddieColors.primaryDark,
        side: BorderSide(color: EddieColors.primaryDark),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: EddieColors.primaryDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: EddieColors.textPrimaryDark),
      displayMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: EddieColors.textPrimaryDark),
      bodyLarge: TextStyle(fontSize: 16, color: EddieColors.textPrimaryDark),
      bodyMedium: TextStyle(fontSize: 14, color: EddieColors.textPrimaryDark),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: EddieColors.textPrimaryDark),
    ),
    extensions: const [
      EddieThemeExtension.dark,
    ],
  );

  // Toggle Theme
  static void toggleTheme() {
    themeMode = themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }

  // Set Theme
  static void setTheme(ThemeMode mode) {
    themeMode = mode;
  }

  // Get color based on brightness
  @deprecated
  static Color getColor(BuildContext context, Color lightColor, Color darkColor) {
    // Redirect to EddieColors implementation
    return EddieColors.getColor(context, lightColor, darkColor);
  }

  // Get primary color based on brightness
  @deprecated
  static Color getPrimary(BuildContext context) {
    // Redirect to EddieColors implementation
    return EddieColors.getPrimary(context);
  }

  // Get background color based on brightness
  @deprecated
  static Color getBackground(BuildContext context) {
    // Redirect to EddieColors implementation
    return EddieColors.getBackground(context);
  }

  // Get surface color based on brightness
  @deprecated
  static Color getSurface(BuildContext context) {
    // Redirect to EddieColors implementation
    return EddieColors.getSurface(context);
  }

  // Get text color based on brightness
  @deprecated
  static Color getTextPrimary(BuildContext context) {
    // Redirect to EddieColors implementation
    return EddieColors.getTextPrimary(context);
  }

  // Get secondary text color based on brightness
  @deprecated
  static Color getTextSecondary(BuildContext context) {
    // Redirect to EddieColors implementation
    return EddieColors.getTextSecondary(context);
  }
}

