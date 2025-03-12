import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../utils/theme.dart';

class SidebarSection extends StatelessWidget {
  final String title;
  final IconData? icon;
  final List<Widget> children;
  final VoidCallback? onAddPressed;
  
  const SidebarSection({
    Key? key,
    required this.title,
    this.icon,
    required this.children,
    this.onAddPressed,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 16,
                  color: isDarkMode ? AppTheme.darkSecondaryTextColor : Colors.grey.shade700,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? AppTheme.darkSecondaryTextColor : Colors.grey.shade700,
                ),
              ),
              const Spacer(),
              if (onAddPressed != null)
                IconButton(
                  icon: const Icon(Icons.add, size: 16),
                  onPressed: onAddPressed,
                  tooltip: l10n.createNew,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  color: isDarkMode ? AppTheme.darkSecondaryTextColor : Colors.grey.shade700,
                ),
            ],
          ),
        ),
        
        // Section children
        ...children,
        
        // Divider
        const SizedBox(height: 8),
        Divider(
          color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
          height: 1,
        ),
        const SizedBox(height: 8),
      ],
    );
  }
} 