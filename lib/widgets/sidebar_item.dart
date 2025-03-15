import 'package:flutter/material.dart';
import '../theme/eddie_colors.dart';
import '../theme/eddie_text_styles.dart';
import '../theme/eddie_theme.dart';

class SidebarItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;
  final bool showTrailing;
  final VoidCallback? onDelete;

  const SidebarItem({
    Key? key,
    required this.title,
    this.subtitle,
    this.icon,
    this.isSelected = false,
    required this.onTap,
    this.showTrailing = false,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      dense: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      hoverColor: EddieColors.getColor(
        context,
        Colors.grey.shade200,
        EddieColors.primaryDark.withOpacity(0.2),
      ),
      tileColor: isSelected
          ? EddieColors.getColor(
              context,
              Colors.grey.shade200,
              EddieColors.primaryDark.withOpacity(0.2),
            )
          : null,
      leading: icon != null
          ? Icon(
              icon,
              size: 20,
              color: isSelected
                  ? EddieColors.getPrimary(context)
                  : EddieColors.getTextSecondary(context),
            )
          : null,
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected
              ? EddieColors.getTextPrimary(context)
              : EddieColors.getTextSecondary(context),
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: TextStyle(
                fontSize: 12,
                color: EddieColors.getTextSecondary(context),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      trailing: showTrailing
          ? IconButton(
              icon: const Icon(Icons.delete_outline, size: 18),
              onPressed: onDelete,
              splashRadius: 20,
              tooltip: 'Delete',
            )
          : null,
      onTap: onTap,
    );
  }
} 