import 'package:flutter/material.dart';
import '../theme/eddie_colors.dart';
import '../theme/eddie_text_styles.dart';
import '../theme/eddie_constants.dart';
import 'eddie_button.dart';

/// Eddie Outlined Button
///
/// A styled outlined button component for the Eddie app.
class EddieOutlinedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final Widget? leadingIconWidget;
  final Widget? trailingIconWidget;
  final EddieButtonSize size;
  final bool fullWidth;
  final EdgeInsetsGeometry? padding;
  final Color? borderColor;
  final Color? textColor;

  const EddieOutlinedButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.leadingIcon,
    this.trailingIcon,
    this.leadingIconWidget,
    this.trailingIconWidget,
    this.size = EddieButtonSize.medium,
    this.fullWidth = false,
    this.padding,
    this.borderColor,
    this.textColor,
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
    
    // Determine colors
    final Color actualBorderColor = borderColor ?? EddieColors.getPrimary(context);
    final Color actualTextColor = textColor ?? EddieColors.getPrimary(context);
    
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: buttonHeight,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: actualTextColor,
          side: BorderSide(color: actualBorderColor),
          padding: buttonPadding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(EddieConstants.borderRadiusMedium),
          ),
        ),
        child: _buildButtonContent(context, iconSize, actualTextColor),
      ),
    );
  }

  /// Builds the button content with optional loading indicator, icons, and text
  Widget _buildButtonContent(BuildContext context, double iconSize, Color textColor) {
    if (isLoading) {
      return SizedBox(
        width: iconSize,
        height: iconSize,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: textColor,
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
          Icon(leadingIcon, size: iconSize, color: textColor),
          SizedBox(width: EddieConstants.spacingSm),
        ],
        Text(
          text,
          style: _getTextStyle(context, textColor),
        ),
        if (trailingIconWidget != null) ...[
          SizedBox(width: EddieConstants.spacingSm),
          trailingIconWidget!,
        ] else if (trailingIcon != null) ...[
          SizedBox(width: EddieConstants.spacingSm),
          Icon(trailingIcon, size: iconSize, color: textColor),
        ],
      ],
    );
  }

  /// Returns the appropriate text style based on button size
  TextStyle _getTextStyle(BuildContext context, Color textColor) {
    TextStyle baseStyle = EddieTextStyles.buttonText(context).copyWith(color: textColor);
    
    switch (size) {
      case EddieButtonSize.small:
        return baseStyle.copyWith(fontSize: 14);
      case EddieButtonSize.large:
        return baseStyle.copyWith(fontSize: 18);
      case EddieButtonSize.medium:
      default:
        return baseStyle;
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

