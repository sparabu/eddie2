import 'package:flutter/material.dart';
import '../theme/eddie_theme.dart';
import '../theme/eddie_colors.dart';
import '../theme/eddie_text_styles.dart';

/// Eddie Text Field
/// 
/// A styled text field component for the Eddie app.
class EddieTextField extends StatelessWidget {
  // Constants
  static const double borderRadius = 8.0;
  static const double fieldHeight = 40.0; // Reduced height
  
  final String label;
  final String? labelSuffix;
  final String? placeholder;
  final String? helperText;
  final String? errorText;
  final bool obscureText;
  final TextEditingController? controller;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final void Function(String)? onChanged;
  final TextInputType keyboardType;
  final bool autofocus;
  final bool enabled;
  final FocusNode? focusNode;

  const EddieTextField({
    Key? key,
    required this.label,
    this.labelSuffix,
    this.placeholder,
    this.helperText,
    this.errorText,
    this.obscureText = false,
    this.controller,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.keyboardType = TextInputType.text,
    this.autofocus = false,
    this.enabled = true,
    this.focusNode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label with icon and optional suffix
        Row(
          children: [
            if (prefixIcon != null) ...[
              prefixIcon!,
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: EddieTextStyles.inputLabel(context),
            ),
            if (labelSuffix != null) ...[
              const SizedBox(width: 4),
              Text(
                labelSuffix!,
                style: EddieTextStyles.caption(context),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: fieldHeight,
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            onChanged: onChanged,
            keyboardType: keyboardType,
            autofocus: autofocus,
            enabled: enabled,
            focusNode: focusNode,
            style: EddieTextStyles.body1(context),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: EddieTextStyles.hintText(context),
              suffixIcon: suffixIcon,
              errorText: null, // Hide error text from decoration
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                borderSide: BorderSide(
                  color: EddieColors.getPrimary(context),
                  width: 1,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                borderSide: BorderSide(
                  color: EddieColors.getError(context),
                  width: 1,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                borderSide: BorderSide(
                  color: EddieColors.getError(context),
                  width: 1,
                ),
              ),
              filled: true,
              fillColor: EddieColors.getInputBackground(context),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10, // Reduced padding
              ),
              isDense: true, // Makes the field more compact
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            errorText!,
            style: EddieTextStyles.errorText(context),
          ),
        ] else if (helperText != null) ...[
          const SizedBox(height: 4),
          Text(
            helperText!,
            style: EddieTextStyles.helperText(context),
          ),
        ],
      ],
    );
  }
}

