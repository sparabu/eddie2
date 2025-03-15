import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'eddie_colors.dart';

/// Eddie Text Styles
///
/// This file contains all the text style definitions for the Eddie design system.
class EddieTextStyles {
  // Font family
  static const String fontFamily = 'Inter';
  
  // Headings
  static TextStyle heading1(BuildContext context) {
    return GoogleFonts.inter(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: EddieColors.getTextPrimary(context),
    );
  }

  static TextStyle heading2(BuildContext context) {
    return GoogleFonts.inter(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: EddieColors.getTextPrimary(context),
    );
  }

  static TextStyle heading3(BuildContext context) {
    return GoogleFonts.inter(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: EddieColors.getTextPrimary(context),
    );
  }

  // Body text
  static TextStyle body1(BuildContext context) {
    return GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: EddieColors.getTextPrimary(context),
    );
  }

  static TextStyle body2(BuildContext context) {
    return GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: EddieColors.getTextPrimary(context),
    );
  }

  // Input styles
  static TextStyle inputLabel(BuildContext context) {
    return GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: EddieColors.getTextPrimary(context),
    );
  }

  // Hint text style
  static TextStyle hintText(BuildContext context) {
    return GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: EddieColors.getTextSecondary(context),
    );
  }

  // Button text
  static TextStyle buttonText(BuildContext context) {
    return GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: EddieColors.getButtonText(context),
    );
  }

  // Caption text
  static TextStyle caption(BuildContext context) {
    return GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: EddieColors.getTextSecondary(context),
    );
  }

  // Error text
  static TextStyle errorText(BuildContext context) {
    return GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: EddieColors.getError(context),
    );
  }

  // Helper text
  static TextStyle helperText(BuildContext context) {
    return GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: EddieColors.getTextSecondary(context),
    );
  }

  // Light weight text
  static TextStyle light(BuildContext context, {double fontSize = 14}) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: FontWeight.w300,
      color: EddieColors.getTextPrimary(context),
    );
  }

  // Medium weight text
  static TextStyle medium(BuildContext context, {double fontSize = 14}) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
      color: EddieColors.getTextPrimary(context),
    );
  }

  // Semi-bold text
  static TextStyle semiBold(BuildContext context, {double fontSize = 14}) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      color: EddieColors.getTextPrimary(context),
    );
  }

  // Link text
  static TextStyle link(BuildContext context, {double fontSize = 14, bool underline = true}) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
      color: EddieColors.getPrimary(context),
      decoration: underline ? TextDecoration.underline : TextDecoration.none,
    );
  }
  
  // Button-like link text
  static TextStyle buttonLink(BuildContext context) {
    return GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: EddieColors.getPrimary(context),
    );
  }
}

