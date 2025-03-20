---
title: Eddie2 Design System
version: 1.5.0
last_updated: 2025-03-20
status: active
---

# Eddie2 Design System

![Version](https://img.shields.io/badge/version-1.5.0-blue.svg)
![Status](https://img.shields.io/badge/status-active-green.svg)
![Last Updated](https://img.shields.io/badge/last%20updated-2025--03--20-lightgrey.svg)

## 📚 Related Documents
- [UI/UX Specifications](EDDIE_UIUX_SPEC_MAIN.md)
- [Interaction Patterns](EDDIE_UIUX_INTERACTIONS.md)
- [Product Requirements](../prd/EDDIE_PRD_MAIN.md)
- [Features Specification](../prd/EDDIE_PRD_FEATURES.md)

## 📑 Table of Contents
1. [Color System](#1-color-system)
2. [Typography](#2-typography)
3. [Spacing & Layout](#3-spacing--layout)
4. [Component Library](#4-component-library)
5. [Icons & Assets](#5-icons--assets)
6. [Animation Guidelines](#6-animation-guidelines)
7. [Accessibility Standards](#7-accessibility-standards)

## 🔗 Code References
- Design System Implementation: `lib/theme/eddie_design_system.dart`
- Colors: `lib/theme/eddie_colors.dart`
- Text Styles: `lib/theme/eddie_text_styles.dart`
- Constants: `lib/theme/eddie_constants.dart`

# Eddie2 UI/UX – Design System Deep Dive

This document supplements [EDDIE_UIUX_SPEC_MAIN.md](./EDDIE_UIUX_SPEC_MAIN.md), focusing on the **design tokens**, **theming**, and **best practices** for building consistent UI components. It references our Dart code in `lib/theme/`.

---

## 1. Overview

Eddie2's design system provides a **single source of truth** for color, typography, spacing, and components, ensuring a cohesive look and feel across the app. Most of this is centralized in:

- [`eddie_colors.dart`](../../lib/theme/eddie_colors.dart)  
- [`eddie_constants.dart`](../../lib/theme/eddie_constants.dart)  
- [`eddie_text_styles.dart`](../../lib/theme/eddie_text_styles.dart)  
- [`eddie_theme.dart`](../../lib/theme/eddie_theme.dart)  
- [`eddie_theme_extension.dart`](../../lib/theme/eddie_theme_extension.dart)  

---

## 2. Design Token Categories

### 2.1 Colors
- **Neutral Palette**: black/white primary, with semantic accent colors (error, success, warning).  
- **Surface/Background**: Light vs. dark theme specifics (e.g., #FFFFFF vs. #121212).  
- **Text Colors**: `getTextPrimary`, `getTextSecondary`, etc. ensure consistent usage based on theme brightness.  

**Reference**:  
- `EddieColors.getPrimary(context)` → returns light or dark primary.  
- `EddieColors.getError(context)` → thematically correct error color.

### 2.2 Typography
- **Heading (H1, H2, H3)**, **body text**, **button text**, **input labels**, etc.  
- Using Google Fonts "Inter" across the board.  
- Example: `EddieTextStyles.heading1(context)` for a 24px bold heading.

### 2.3 Spacing & Sizing
- Predefined constants like `spacingSm`, `spacingMd`, `spacingLg` in `EddieConstants`.  
- Helps maintain consistent spacing in all layouts.  

### 2.4 Border Radii
- `borderRadiusSmall`, `borderRadiusMedium`, etc. keep corners consistent (4px, 8px, 12px...).

### 2.5 Animations
- `animationShort`, `animationMedium`, `animationLong` (150ms, 300ms, 500ms).  
- Encourages uniform transition timings app-wide.

---

## 3. Theming in Flutter

### 3.1 `EddieTheme`
- **LightTheme** and **DarkTheme** definitions in [`eddie_theme.dart`](../../lib/theme/eddie_theme.dart).  
- Applies Material 3 guidelines, colorScheme, and textTheme.  
- Deprecates older color helper methods in favor of `EddieColors`.

### 3.2 `EddieThemeExtension`
- Provides an **extension** for advanced theming (e.g., userBubbleColor, assistantBubbleColor).  
- Access via:
  ```dart
  final eddieTheme = Theme.of(context).extension<EddieThemeExtension>()!;
  color: eddieTheme.primaryColor;

3.3 Theme Provider
theme_provider.dart uses Riverpod to toggle or set theme mode.
Allows easy switching between light/dark or system mode.

4. Best Practices
Use EddieColors:
// GOOD
color: EddieColors.getPrimary(context);

// AVOID
color: Colors.black;  // Hardcoded

Use EddieTextStyles for headings/body text:

dart
Copy
Edit
style: EddieTextStyles.heading1(context);
Use EddieConstants for spacing, sizing, durations:

dart
Copy
Edit
padding: EdgeInsets.all(EddieConstants.spacingMd);
Deprecated Methods in EddieTheme (like getPrimary(context)) are only for backward-compatibility. Plan to remove them eventually.

Accessibility:

Keep color contrast >= 4.5:1.
Use dynamic text sizing.
Minimum 44x44 touch targets.
5. Component Guidelines
5.1 Buttons
EddieButton for primary actions, with size (small/medium/large) and variant (primary, secondary, danger).
EddieOutlinedButton for secondary or less prominent actions.
TextButton for tertiary actions.
5.2 Text Fields
EddieTextField: always provide label and placeholder.
States: normal, focused, error.
Use EddieColors.getInputBackground(context) for background to respect theme.
5.3 Cards
Standard corner rounding (borderRadiusMedium), possibly elevated or outlined depending on theme.
Keep EddieConstants.spacingMd as internal padding.
5.4 Sidebar Sections
SidebarSection for grouping items with a collapse/expand behavior.
SidebarItem for individual clickable entries, highlight on hover or selection.
6. Migration Guide
If you have older code referencing AppTheme or raw color constants:

Replace old color constants with EddieColors methods.
Replace direct TextStyle(...) calls with EddieTextStyles.
Replace manual spacing with EddieConstants.
Mark any leftover theme methods as deprecated, then remove them once everything is migrated.
7. Future Considerations
More Abstract Token Names: Instead of colorPrimary/secondary, eventually a system like colorBrand, colorAccent to help with brand expansions.
Component-Specific Theming: E.g., "ChatBubbleThemeExtension" for advanced chat bubble customization.
Contrast Checkers: Tools to ensure compliance with WCAG.
Design Token Visual Docs: A dedicated style guide web page or storybook.
End of EDDIE_UIUX_DESIGN_SYSTEM.md