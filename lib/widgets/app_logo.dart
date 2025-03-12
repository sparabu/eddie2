import 'package:flutter/material.dart';
import '../utils/theme.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;
  
  const AppLogo({
    Key? key,
    this.size = 32.0,
    this.showText = true,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo icon
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              'E',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: size * 0.6,
              ),
            ),
          ),
        ),
        
        // Logo text
        if (showText) ...[
          const SizedBox(width: 8),
          Text(
            'Eddie',
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: size * 0.5,
            ),
          ),
        ],
      ],
    );
  }
} 