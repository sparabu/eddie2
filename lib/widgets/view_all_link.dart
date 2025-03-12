import 'package:flutter/material.dart';
import '../utils/theme.dart';

class ViewAllLink extends StatelessWidget {
  final VoidCallback onTap;
  final String text;
  
  const ViewAllLink({
    Key? key,
    required this.onTap,
    this.text = 'View All',
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: isDarkMode ? AppTheme.darkSecondaryTextColor : Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right,
              size: 16,
              color: isDarkMode ? AppTheme.darkSecondaryTextColor : Colors.grey.shade700,
            ),
          ],
        ),
      ),
    );
  }
} 