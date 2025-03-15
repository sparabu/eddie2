/// Eddie Design System
/// 
/// This file serves as the central documentation for the Eddie design system,
/// providing guidelines, best practices, and examples for using the design system
/// components consistently throughout the application.
/// 
/// ## Design System Structure
/// 
/// The Eddie design system consists of several key components:
/// 
/// - **EddieColors**: The primary source of truth for all color definitions and color-related
///   functionality. Always use the helper methods from this class for accessing colors.
/// 
/// - **EddieTheme**: Defines the application themes (light and dark) and provides theme-related
///   utilities. Note that the color helper methods in this class are deprecated in favor of
///   the methods in `EddieColors`.
/// 
/// - **EddieTextStyles**: Contains all text style definitions and helper methods for
///   accessing text styles based on the current theme.
///
/// - **EddieConstants**: Provides standardized values for spacing, sizing, animations,
///   and other constants used throughout the application.
///
/// - **EddieThemeExtension**: Extends Flutter's ThemeExtension to provide a more integrated
///   approach to theming in the Eddie app.
/// 
/// ## Best Practices
/// 
/// ### Colors
/// 
/// Always use the helper methods from `EddieColors` to access colors, rather than using
/// the color constants directly or the deprecated methods in `EddieTheme`:
/// 
/// ```dart
/// // GOOD
/// color: EddieColors.getPrimary(context)
/// 
/// // AVOID
/// color: EddieColors.primaryLight // Doesn't respect theme
/// color: EddieTheme.getPrimary(context) // Deprecated
/// ```
/// 
/// ### Text Styles
/// 
/// Use the helper methods from `EddieTextStyles` to access text styles:
/// 
/// ```dart
/// // GOOD
/// style: EddieTextStyles.body1(context)
/// 
/// // AVOID
/// style: TextStyle(...) // Inconsistent styling
/// ```
///
/// ### Constants
///
/// Use the constants from `EddieConstants` for consistent spacing, sizing, and timing:
///
/// ```dart
/// // GOOD
/// padding: EdgeInsets.all(EddieConstants.spacingMd)
///
/// // AVOID
/// padding: EdgeInsets.all(16) // Hardcoded values
/// ```
/// 
/// ### Theme Extensions
/// 
/// For more advanced theming needs, consider using the `EddieThemeExtension` which
/// integrates with Flutter's theming system:
/// 
/// ```dart
/// final eddieTheme = Theme.of(context).extension<EddieThemeExtension>()!;
/// color: eddieTheme.primaryColor
/// ```
/// 
/// ## Component Guidelines
/// 
/// ### Buttons
/// 
/// - Use `EddieButton` for primary actions with the following variants:
///   - `EddieButtonVariant.primary`: Main call-to-action buttons
///   - `EddieButtonVariant.secondary`: Alternative actions
///   - `EddieButtonVariant.danger`: Destructive actions
///
/// - Use `EddieOutlinedButton` for secondary actions
/// - Use `TextButton` for tertiary actions
///
/// Example:
/// ```dart
/// EddieButton(
///   text: 'Submit',
///   onPressed: () => handleSubmit(),
///   size: EddieButtonSize.medium,
/// )
/// ```
/// 
/// ### Text Fields
/// 
/// - Use `EddieTextField` for all input fields
/// - Always provide a label and placeholder for better accessibility
///
/// Example:
/// ```dart
/// EddieTextField(
///   label: 'Email',
///   placeholder: 'Enter your email',
///   controller: emailController,
///   keyboardType: TextInputType.emailAddress,
/// )
/// ```
/// 
/// ### Cards
/// 
/// - Use the `Card` widget with the theme's card theme
/// - Maintain consistent padding (EddieConstants.spacingMd) inside cards
///
/// ### Sidebar Components
///
/// - Use `SidebarSection` for organizing sidebar content
/// - Use `SidebarItem` for individual items within sections
///
/// Example:
/// ```dart
/// SidebarSection(
///   title: 'Recent Chats',
///   children: [
///     SidebarItem(
///       title: 'Chat Title',
///       onTap: () => selectChat(chatId),
///     ),
///   ],
/// )
/// ```
/// 
/// ## Accessibility Guidelines
/// 
/// - Ensure sufficient color contrast between text and background
/// - Provide meaningful labels for all interactive elements
/// - Support dynamic text sizing for users with visual impairments
/// - Use minimum touch target size of EddieConstants.minTouchTargetSize (44px)
/// 
/// ## Migration Guide
/// 
/// If you're updating code that uses the old `AppTheme` or deprecated methods in `EddieTheme`,
/// follow these steps:
/// 
/// 1. Replace imports of `utils/theme.dart` with imports of `theme/eddie_colors.dart` and
///    `theme/eddie_text_styles.dart` as needed.
/// 
/// 2. Replace references to `AppTheme` constants with the corresponding helper methods from
///    `EddieColors`:
///    - `AppTheme.primaryColor` → `EddieColors.getPrimary(context)`
///    - `AppTheme.backgroundColor` → `EddieColors.getBackground(context)`
/// 
/// 3. Replace deprecated methods from `EddieTheme` with the corresponding methods from
///    `EddieColors`:
///    - `EddieTheme.getPrimary(context)` → `EddieColors.getPrimary(context)`
///    - `EddieTheme.getTextPrimary(context)` → `EddieColors.getTextPrimary(context)`
///
/// 4. Replace hardcoded spacing, sizing, and timing values with constants from `EddieConstants`:
///    - `16.0` → `EddieConstants.spacingMd`
///    - `8.0` → `EddieConstants.spacingSm`
///    - `Duration(milliseconds: 300)` → `EddieConstants.animationMedium`
/// 
/// ## Component Library
///
/// Eddie2 includes a growing library of reusable components:
///
/// - **EddieButton**: Customizable button with multiple variants and sizes
/// - **EddieOutlinedButton**: Outlined variant of the button
/// - **EddieTextField**: Styled text input field
/// - **EddieLogo**: App logo component with customizable size
/// - **SidebarSection**: Collapsible section for sidebar content
/// - **SidebarItem**: Individual item for sidebar lists
/// - **ThemeToggle**: Dark/light mode toggle switch
/// - **ViewAllLink**: Link to view all items in a list
///
/// ## Future Considerations
/// 
/// - **Color Token System**: Moving towards a more abstract color token system where
///   semantic names are used instead of descriptive names.
/// 
/// - **Component-Specific Theming**: For complex components, creating component-specific
///   theme extensions.
/// 
/// - **Accessibility Checks**: Adding utility methods to check color contrast ratios
///   to ensure accessibility compliance.
///
/// - **Design Token Documentation**: Creating a comprehensive design token documentation
///   with visual examples.
///
/// - **Component Showcase**: Developing a showcase app that demonstrates all available
///   components and their variants. 