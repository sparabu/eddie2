import 'package:flutter/material.dart';
import '../theme/eddie_theme.dart';

/// Eddie Logo Widget
/// 
/// A customizable logo widget for the Eddie app.
class EddieLogo extends StatelessWidget {
  final double size;
  final bool withText;
  final bool useAltColor;

  const EddieLogo({
    Key? key,
    this.size = 48.0,
    this.withText = false,
    this.useAltColor = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = EddieTheme.getPrimary(context);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(size * 0.16), // Rounded corners
          ),
          child: Center(
            child: Text(
              'E',
              style: TextStyle(
                color: Colors.white,
                fontSize: size * 0.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        if (withText) ...[
          const SizedBox(width: 12),
          Text(
            'Eddie',
            style: TextStyle(
              fontSize: size * 0.5,
              fontWeight: FontWeight.bold,
              color: EddieTheme.getTextPrimary(context),
            ),
          ),
        ],
      ],
    );
  }
}

