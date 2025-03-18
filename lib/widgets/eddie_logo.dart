import 'package:flutter/material.dart';
import '../theme/eddie_colors.dart';
import '../theme/eddie_constants.dart';
import '../theme/eddie_text_styles.dart';

/// Eddie Logo
/// 
/// A simple logo widget for Eddie with customizable size and optional text.
class EddieLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool useFullName;
  final Color? customColor;
  
  // For backward compatibility
  static const String deprecationMessage = 'The withText parameter is deprecated. Use showText instead.';
  
  const EddieLogo({
    Key? key,
    this.size = 32,
    this.showText = false,
    this.useFullName = false,
    this.customColor,
  }) : super(key: key);
  
  // Deprecated constructor with withText parameter for backward compatibility
  @Deprecated(deprecationMessage)
  EddieLogo.legacy({
    Key? key,
    double size = 32,
    bool withText = false,
    bool useFullName = false,
    Color? customColor,
  }) : this(
      key: key,
      size: size,
      showText: withText,
      useFullName: useFullName,
      customColor: customColor,
  );
  
  @override
  Widget build(BuildContext context) {
    final Color primaryColor = customColor ?? EddieColors.getPrimary(context);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(EddieConstants.borderRadiusSmall),
          ),
          child: Center(
            child: Text(
              'E',
              style: EddieTextStyles.heading2(context).copyWith(
                fontSize: size * 0.5,
                color: Colors.white, // Use white for contrast on primary color
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        if (showText) ...[
          SizedBox(width: size * 0.25),
          Text(
            useFullName ? 'Eddie AI' : 'eddie',
            style: EddieTextStyles.heading2(context).copyWith(
              fontSize: size * 0.5,
              color: EddieColors.getTextPrimary(context),
            ),
          ),
        ],
      ],
    );
  }
}

