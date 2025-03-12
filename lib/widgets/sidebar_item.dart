import 'package:flutter/material.dart';
import '../utils/theme.dart';

class SidebarItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final Widget? trailing;
  final bool isHeader;
  
  const SidebarItem({
    Key? key,
    required this.title,
    required this.icon,
    this.isSelected = false,
    required this.onTap,
    this.trailing,
    this.isHeader = false,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        hoverColor: isDarkMode ? AppTheme.hoverColor : Colors.grey.shade200,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: isSelected 
                ? (isDarkMode ? AppTheme.selectedItemColor : Colors.grey.shade200) 
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
          child: Row(
            children: [
              Icon(
                icon,
                size: isHeader ? 18 : 16,
                color: isSelected
                    ? (isDarkMode ? Colors.white : Colors.black)
                    : (isDarkMode ? AppTheme.darkSecondaryTextColor : Colors.grey.shade700),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: isHeader ? 13 : 12,
                    fontWeight: isHeader ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? (isDarkMode ? Colors.white : Colors.black)
                        : (isDarkMode ? AppTheme.darkSecondaryTextColor : Colors.grey.shade700),
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
} 