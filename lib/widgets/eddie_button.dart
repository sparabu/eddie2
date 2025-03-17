import 'package:flutter/material.dart';
import '../theme/eddie_colors.dart';
import '../theme/eddie_text_styles.dart';
import '../theme/eddie_constants.dart';

/// Button size options
enum EddieButtonSize {
  small,
  medium,
  large,
}

/// Button type options
enum ButtonType {
  primary,
  secondary,
  tertiary,
}

/// Eddie Button
///
/// A styled button component for the Eddie app.
class EddieButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final Widget? leadingIconWidget;
  final Widget? trailingIconWidget;
  final EddieButtonSize size;
  final bool isExpanded;
  final EdgeInsetsGeometry? padding;
  final ButtonType buttonType;

  const EddieButton({
    Key? key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.leadingIcon,
    this.trailingIcon,
    this.leadingIconWidget,
    this.trailingIconWidget,
    this.size = EddieButtonSize.medium,
    this.isExpanded = false,
    this.padding,
    this.buttonType = ButtonType.primary,
  }) : assert(
         (leadingIcon == null || leadingIconWidget == null) && 
         (trailingIcon == null || trailingIconWidget == null),
         'Cannot provide both IconData and Widget for the same position'
       ),
       super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine button height based on size
    final double buttonHeight = _getButtonHeight();
    
    // Determine icon size based on button size
    final double iconSize = _getIconSize();
    
    // Determine padding based on size and icons
    final EdgeInsetsGeometry buttonPadding = padding ?? _getButtonPadding();
    
    // Get button style based on type
    final ButtonStyle style = _getButtonStyle(context);
    
    return SizedBox(
      width: isExpanded ? double.infinity : null,
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: style,
        child: _buildButtonContent(context, iconSize),
      ),
    );
  }

  /// Get button style based on type
  ButtonStyle _getButtonStyle(BuildContext context) {
    switch (buttonType) {
      case ButtonType.primary:
        return ElevatedButton.styleFrom(
          backgroundColor: EddieColors.getPrimary(context),
          foregroundColor: EddieColors.getButtonText(context),
          elevation: 0,
          padding: padding ?? _getButtonPadding(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(EddieConstants.borderRadiusMedium),
          ),
          disabledBackgroundColor: Theme.of(context).brightness == Brightness.light
              ? Colors.grey[300]
              : Colors.grey[700],
          disabledForegroundColor: Theme.of(context).brightness == Brightness.light
              ? Colors.grey[600]
              : Colors.grey[400],
        );
      case ButtonType.secondary:
        return ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: EddieColors.getPrimary(context),
          elevation: 0,
          padding: padding ?? _getButtonPadding(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(EddieConstants.borderRadiusMedium),
            side: BorderSide(color: EddieColors.getPrimary(context)),
          ),
          disabledBackgroundColor: Colors.transparent,
          disabledForegroundColor: Theme.of(context).brightness == Brightness.light
              ? Colors.grey[600]
              : Colors.grey[400],
        );
      case ButtonType.tertiary:
        return ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: EddieColors.getPrimary(context),
          elevation: 0,
          padding: padding ?? _getButtonPadding(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(EddieConstants.borderRadiusMedium),
          ),
          disabledBackgroundColor: Colors.transparent,
          disabledForegroundColor: Theme.of(context).brightness == Brightness.light
              ? Colors.grey[600]
              : Colors.grey[400],
        );
    }
  }

  /// Builds the button content with optional loading indicator, icons, and text
  Widget _buildButtonContent(BuildContext context, double iconSize) {
    if (isLoading) {
      return SizedBox(
        width: iconSize,
        height: iconSize,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: buttonType == ButtonType.primary
              ? EddieColors.getButtonText(context)
              : EddieColors.getPrimary(context),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leadingIconWidget != null) ...[
          leadingIconWidget!,
          SizedBox(width: EddieConstants.spacingSm),
        ] else if (leadingIcon != null) ...[
          Icon(leadingIcon, size: iconSize),
          SizedBox(width: EddieConstants.spacingSm),
        ],
        Text(
          label,
          style: _getTextStyle(context),
        ),
        if (trailingIconWidget != null) ...[
          SizedBox(width: EddieConstants.spacingSm),
          trailingIconWidget!,
        ] else if (trailingIcon != null) ...[
          SizedBox(width: EddieConstants.spacingSm),
          Icon(trailingIcon, size: iconSize),
        ],
      ],
    );
  }

  /// Returns the appropriate text style based on button size
  TextStyle _getTextStyle(BuildContext context) {
    switch (size) {
      case EddieButtonSize.small:
        return EddieTextStyles.buttonText(context).copyWith(fontSize: 14);
      case EddieButtonSize.large:
        return EddieTextStyles.buttonText(context).copyWith(fontSize: 18);
      case EddieButtonSize.medium:
      default:
        return EddieTextStyles.buttonText(context);
    }
  }

  /// Returns the appropriate button height based on size
  double _getButtonHeight() {
    switch (size) {
      case EddieButtonSize.small:
        return EddieConstants.buttonHeightSmall;
      case EddieButtonSize.large:
        return EddieConstants.buttonHeightLarge;
      case EddieButtonSize.medium:
      default:
        return EddieConstants.buttonHeightMedium;
    }
  }

  /// Returns the appropriate icon size based on button size
  double _getIconSize() {
    switch (size) {
      case EddieButtonSize.small:
        return EddieConstants.iconSizeSmall;
      case EddieButtonSize.large:
        return EddieConstants.iconSizeLarge;
      case EddieButtonSize.medium:
      default:
        return EddieConstants.iconSizeMedium;
    }
  }

  /// Returns the appropriate padding based on size and icons
  EdgeInsetsGeometry _getButtonPadding() {
    final bool hasLeadingIcon = leadingIcon != null || leadingIconWidget != null;
    final bool hasTrailingIcon = trailingIcon != null || trailingIconWidget != null;
    final double horizontalPadding = hasLeadingIcon || hasTrailingIcon
        ? EddieConstants.spacingMd
        : EddieConstants.spacingLg;
        
    switch (size) {
      case EddieButtonSize.small:
        return EdgeInsets.symmetric(
          horizontal: horizontalPadding - 4,
          vertical: EddieConstants.spacingXs,
        );
      case EddieButtonSize.large:
        return EdgeInsets.symmetric(
          horizontal: horizontalPadding + 4,
          vertical: EddieConstants.spacingXs,
        );
      case EddieButtonSize.medium:
      default:
        return EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: EddieConstants.spacingXs,
        );
    }
  }
}

