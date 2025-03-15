import 'package:flutter/material.dart';
import 'eddie_colors.dart';

/// Eddie Theme Extension
///
/// This class extends Flutter's ThemeExtension to provide a more integrated
/// approach to theming in the Eddie app. It allows accessing theme colors
/// directly from the Theme object using the extension mechanism.
///
/// Example usage:
/// ```dart
/// final eddieTheme = Theme.of(context).extension<EddieThemeExtension>()!;
/// color: eddieTheme.primaryColor
/// ```
@immutable
class EddieThemeExtension extends ThemeExtension<EddieThemeExtension> {
  final Color primaryColor;
  final Color secondaryColor;
  final Color backgroundColor;
  final Color surfaceColor;
  final Color surfaceVariantColor;
  final Color textPrimaryColor;
  final Color textSecondaryColor;
  final Color outlineColor;
  final Color errorColor;
  final Color successColor;
  final Color warningColor;
  final Color hoverColor;
  final Color selectedItemColor;
  
  // Chat-specific colors
  final Color userBubbleColor;
  final Color assistantBubbleColor;
  final Color userTextColor;
  final Color assistantTextColor;

  const EddieThemeExtension({
    required this.primaryColor,
    required this.secondaryColor,
    required this.backgroundColor,
    required this.surfaceColor,
    required this.surfaceVariantColor,
    required this.textPrimaryColor,
    required this.textSecondaryColor,
    required this.outlineColor,
    required this.errorColor,
    required this.successColor,
    required this.warningColor,
    required this.hoverColor,
    required this.selectedItemColor,
    required this.userBubbleColor,
    required this.assistantBubbleColor,
    required this.userTextColor,
    required this.assistantTextColor,
  });

  /// Light theme extension
  static const light = EddieThemeExtension(
    primaryColor: EddieColors.primaryLight,
    secondaryColor: EddieColors.secondaryLight,
    backgroundColor: EddieColors.backgroundLight,
    surfaceColor: EddieColors.surfaceLight,
    surfaceVariantColor: EddieColors.surfaceVariantLight,
    textPrimaryColor: EddieColors.textPrimaryLight,
    textSecondaryColor: EddieColors.textSecondaryLight,
    outlineColor: EddieColors.outlineLight,
    errorColor: EddieColors.errorLight,
    successColor: EddieColors.successLight,
    warningColor: EddieColors.warningLight,
    hoverColor: EddieColors.hoverLight,
    selectedItemColor: EddieColors.selectedItemLight,
    userBubbleColor: EddieColors.userBubbleLight,
    assistantBubbleColor: EddieColors.assistantBubbleLight,
    userTextColor: EddieColors.userTextLight,
    assistantTextColor: EddieColors.assistantTextLight,
  );

  /// Dark theme extension
  static const dark = EddieThemeExtension(
    primaryColor: EddieColors.primaryDark,
    secondaryColor: EddieColors.secondaryDark,
    backgroundColor: EddieColors.backgroundDark,
    surfaceColor: EddieColors.surfaceDark,
    surfaceVariantColor: EddieColors.surfaceVariantDark,
    textPrimaryColor: EddieColors.textPrimaryDark,
    textSecondaryColor: EddieColors.textSecondaryDark,
    outlineColor: EddieColors.outlineDark,
    errorColor: EddieColors.errorDark,
    successColor: EddieColors.successDark,
    warningColor: EddieColors.warningDark,
    hoverColor: EddieColors.hoverDark,
    selectedItemColor: EddieColors.selectedItemDark,
    userBubbleColor: EddieColors.userBubbleDark,
    assistantBubbleColor: EddieColors.assistantBubbleDark,
    userTextColor: EddieColors.userTextDark,
    assistantTextColor: EddieColors.assistantTextDark,
  );

  @override
  ThemeExtension<EddieThemeExtension> copyWith({
    Color? primaryColor,
    Color? secondaryColor,
    Color? backgroundColor,
    Color? surfaceColor,
    Color? surfaceVariantColor,
    Color? textPrimaryColor,
    Color? textSecondaryColor,
    Color? outlineColor,
    Color? errorColor,
    Color? successColor,
    Color? warningColor,
    Color? hoverColor,
    Color? selectedItemColor,
    Color? userBubbleColor,
    Color? assistantBubbleColor,
    Color? userTextColor,
    Color? assistantTextColor,
  }) {
    return EddieThemeExtension(
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      surfaceColor: surfaceColor ?? this.surfaceColor,
      surfaceVariantColor: surfaceVariantColor ?? this.surfaceVariantColor,
      textPrimaryColor: textPrimaryColor ?? this.textPrimaryColor,
      textSecondaryColor: textSecondaryColor ?? this.textSecondaryColor,
      outlineColor: outlineColor ?? this.outlineColor,
      errorColor: errorColor ?? this.errorColor,
      successColor: successColor ?? this.successColor,
      warningColor: warningColor ?? this.warningColor,
      hoverColor: hoverColor ?? this.hoverColor,
      selectedItemColor: selectedItemColor ?? this.selectedItemColor,
      userBubbleColor: userBubbleColor ?? this.userBubbleColor,
      assistantBubbleColor: assistantBubbleColor ?? this.assistantBubbleColor,
      userTextColor: userTextColor ?? this.userTextColor,
      assistantTextColor: assistantTextColor ?? this.assistantTextColor,
    );
  }

  @override
  ThemeExtension<EddieThemeExtension> lerp(
    covariant ThemeExtension<EddieThemeExtension>? other, 
    double t
  ) {
    if (other is! EddieThemeExtension) {
      return this;
    }
    return EddieThemeExtension(
      primaryColor: Color.lerp(primaryColor, other.primaryColor, t)!,
      secondaryColor: Color.lerp(secondaryColor, other.secondaryColor, t)!,
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t)!,
      surfaceColor: Color.lerp(surfaceColor, other.surfaceColor, t)!,
      surfaceVariantColor: Color.lerp(surfaceVariantColor, other.surfaceVariantColor, t)!,
      textPrimaryColor: Color.lerp(textPrimaryColor, other.textPrimaryColor, t)!,
      textSecondaryColor: Color.lerp(textSecondaryColor, other.textSecondaryColor, t)!,
      outlineColor: Color.lerp(outlineColor, other.outlineColor, t)!,
      errorColor: Color.lerp(errorColor, other.errorColor, t)!,
      successColor: Color.lerp(successColor, other.successColor, t)!,
      warningColor: Color.lerp(warningColor, other.warningColor, t)!,
      hoverColor: Color.lerp(hoverColor, other.hoverColor, t)!,
      selectedItemColor: Color.lerp(selectedItemColor, other.selectedItemColor, t)!,
      userBubbleColor: Color.lerp(userBubbleColor, other.userBubbleColor, t)!,
      assistantBubbleColor: Color.lerp(assistantBubbleColor, other.assistantBubbleColor, t)!,
      userTextColor: Color.lerp(userTextColor, other.userTextColor, t)!,
      assistantTextColor: Color.lerp(assistantTextColor, other.assistantTextColor, t)!,
    );
  }
} 