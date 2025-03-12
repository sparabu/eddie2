import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Primary colors
  static const Color primaryColor = Color(0xFF10A37F); // ChatGPT green
  
  // Background colors
  static const Color backgroundColor = Color(0xFFFAFAFA);
  static const Color darkBackgroundColor = Color(0xFF0F0F0F); // Darker background for dark mode
  
  // Sidebar colors
  static const Color sidebarColor = Color(0xFFF7F7F8);
  static const Color darkSidebarColor = Color(0xFF0F0F0F); // Darker sidebar for dark mode
  
  // Chat colors
  static const Color chatBackgroundColor = Color(0xFFFFFFFF);
  static const Color darkChatBackgroundColor = Color(0xFF1E1E1E); // Darker chat background
  static const Color userMessageColor = Color(0xFFFFFFFF);
  static const Color darkUserMessageColor = Color(0xFF343541);
  static const Color assistantMessageColor = Color(0xFFF7F7F8);
  static const Color darkAssistantMessageColor = Color(0xFF444654);
  
  // UI element colors
  static const Color errorColor = Color(0xFFFF4D4F);
  static const Color hoverColor = Color(0xFF2A2A2A); // Hover color for dark mode
  static const Color selectedItemColor = Color(0xFF2A2A2A); // Selected item background for dark mode
  
  // Text colors
  static const Color darkTextColor = Color(0xFFFFFFFF);
  static const Color darkSecondaryTextColor = Color(0xFFAAAAAA);
  
  // Button colors
  static const Color buttonColor = Color(0xFF3E3E3E); // Button background for dark mode
  static const Color buttonHoverColor = Color(0xFF4E4E4E); // Button hover for dark mode
  
  static TextTheme _createTextTheme(TextTheme base, bool isDark) {
    return GoogleFonts.interTextTheme(base).copyWith(
      displayLarge: GoogleFonts.inter(
        textStyle: base.displayLarge,
        color: isDark ? darkTextColor : Colors.black,
        fontWeight: FontWeight.w600,
      ),
      displayMedium: GoogleFonts.inter(
        textStyle: base.displayMedium,
        color: isDark ? darkTextColor : Colors.black,
        fontWeight: FontWeight.w600,
      ),
      displaySmall: GoogleFonts.inter(
        textStyle: base.displaySmall,
        color: isDark ? darkTextColor : Colors.black,
        fontWeight: FontWeight.w600,
      ),
      headlineLarge: GoogleFonts.inter(
        textStyle: base.headlineLarge,
        color: isDark ? darkTextColor : Colors.black,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: GoogleFonts.inter(
        textStyle: base.headlineMedium,
        color: isDark ? darkTextColor : Colors.black,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: GoogleFonts.inter(
        textStyle: base.headlineSmall,
        color: isDark ? darkTextColor : Colors.black,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: GoogleFonts.inter(
        textStyle: base.titleLarge,
        color: isDark ? darkTextColor : Colors.black,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: GoogleFonts.inter(
        textStyle: base.titleMedium,
        color: isDark ? darkTextColor : Colors.black,
        fontWeight: FontWeight.w500,
      ),
      titleSmall: GoogleFonts.inter(
        textStyle: base.titleSmall,
        color: isDark ? darkTextColor : Colors.black,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: GoogleFonts.inter(
        textStyle: base.bodyLarge,
        color: isDark ? darkTextColor : Colors.black,
      ),
      bodyMedium: GoogleFonts.inter(
        textStyle: base.bodyMedium,
        color: isDark ? darkTextColor : Colors.black,
      ),
      bodySmall: GoogleFonts.inter(
        textStyle: base.bodySmall,
        color: isDark ? darkSecondaryTextColor : Colors.black54,
      ),
      labelLarge: GoogleFonts.inter(
        textStyle: base.labelLarge,
        color: isDark ? darkTextColor : Colors.black,
        fontWeight: FontWeight.w500,
      ),
      labelMedium: GoogleFonts.inter(
        textStyle: base.labelMedium,
        color: isDark ? darkTextColor : Colors.black,
      ),
      labelSmall: GoogleFonts.inter(
        textStyle: base.labelSmall,
        color: isDark ? darkSecondaryTextColor : Colors.black54,
      ),
    );
  }
  
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: primaryColor,
      background: backgroundColor,
      surface: chatBackgroundColor,
      error: errorColor,
    ),
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: AppBarTheme(
      backgroundColor: backgroundColor,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
      iconTheme: const IconThemeData(color: Colors.black),
    ),
    textTheme: _createTextTheme(ThemeData.light().textTheme, false),
    cardTheme: CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      color: chatBackgroundColor,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColor),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: errorColor),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    dividerTheme: DividerThemeData(
      color: Colors.grey.shade200,
      thickness: 1,
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: sidebarColor,
      selectedIconTheme: const IconThemeData(color: primaryColor),
      selectedLabelTextStyle: GoogleFonts.inter(
        color: primaryColor,
        fontWeight: FontWeight.w600,
      ),
      unselectedIconTheme: IconThemeData(color: Colors.grey.shade700),
      unselectedLabelTextStyle: GoogleFonts.inter(
        color: Colors.grey.shade700,
      ),
    ),
  );
  
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.dark(
      primary: primaryColor,
      secondary: Colors.white,
      background: darkBackgroundColor,
      surface: darkChatBackgroundColor,
      error: errorColor,
    ),
    scaffoldBackgroundColor: darkBackgroundColor,
    appBarTheme: AppBarTheme(
      backgroundColor: darkBackgroundColor,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    textTheme: _createTextTheme(ThemeData.dark().textTheme, true),
    cardTheme: CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade800),
      ),
      color: darkChatBackgroundColor,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: BorderSide(color: Colors.grey.shade700),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkChatBackgroundColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade700),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade700),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColor),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: errorColor),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    dividerTheme: DividerThemeData(
      color: Colors.grey.shade800,
      thickness: 1,
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: darkSidebarColor,
      selectedIconTheme: const IconThemeData(color: Colors.white),
      selectedLabelTextStyle: GoogleFonts.inter(
        color: Colors.white,
        fontWeight: FontWeight.w500,
      ),
      unselectedIconTheme: const IconThemeData(color: darkSecondaryTextColor),
      unselectedLabelTextStyle: const TextStyle(
        color: darkSecondaryTextColor,
      ),
    ),
  );
} 