import 'package:flutter/material.dart';
import '../theme/eddie_colors.dart';
import '../theme/eddie_text_styles.dart';
import '../theme/eddie_theme.dart';
import '../widgets/eddie_button.dart';
import '../widgets/eddie_text_field.dart';

class SidebarItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;
  final bool showTrailing;
  final VoidCallback? onDelete;
  final Function(String)? onRename;
  final String id;

  const SidebarItem({
    Key? key,
    required this.title,
    this.subtitle,
    this.icon,
    this.isSelected = false,
    required this.onTap,
    this.showTrailing = false,
    this.onDelete,
    this.onRename,
    required this.id,
  }) : super(key: key);

  void _showOptionsMenu(BuildContext context, TapDownDetails details) {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    
    // Use the tap position to show the menu
    final RelativeRect position = RelativeRect.fromLTRB(
      details.globalPosition.dx,
      details.globalPosition.dy,
      details.globalPosition.dx + 1,
      details.globalPosition.dy + 1,
    );

    showMenu(
      context: context,
      position: position,
      items: [
        PopupMenuItem(
          child: Row(
            children: [
              Icon(
                Icons.edit_outlined,
                size: 18,
                color: EddieColors.getTextPrimary(context),
              ),
              const SizedBox(width: 8),
              Text(
                'Rename',
                style: EddieTextStyles.body2(context),
              ),
            ],
          ),
          onTap: () {
            // We need to use a delay because the menu closes immediately
            Future.delayed(const Duration(milliseconds: 10), () {
              _showRenameDialog(context);
            });
          },
        ),
        PopupMenuItem(
          child: Row(
            children: [
              Icon(
                Icons.delete_outline,
                size: 18,
                color: Colors.red,
              ),
              const SizedBox(width: 8),
              Text(
                'Delete',
                style: EddieTextStyles.body2(context).copyWith(
                  color: Colors.red,
                ),
              ),
            ],
          ),
          onTap: () {
            // We need to use a delay because the menu closes immediately
            Future.delayed(const Duration(milliseconds: 10), () {
              _showDeleteConfirmation(context);
            });
          },
        ),
      ],
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  void _showRenameDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final titleController = TextEditingController(text: title);
        return AlertDialog(
          title: Text('Rename'),
          content: TextField(
            controller: titleController,
            decoration: InputDecoration(
              hintText: 'Enter new name',
            ),
            autofocus: true,
            onSubmitted: (_) {
              final newTitle = titleController.text.trim();
              if (newTitle.isNotEmpty) {
                onRename?.call(newTitle);
              }
              Navigator.of(context).pop();
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final newTitle = titleController.text.trim();
                if (newTitle.isNotEmpty) {
                  onRename?.call(newTitle);
                }
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete chat?'),
        content: Text(
          'The chat will be deleted and removed from your chat history. This action cannot be undone.',
          style: EddieTextStyles.body2(context),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: EddieColors.getOutline(context)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Cancel',
              style: EddieTextStyles.body2(context),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (onDelete != null) {
                onDelete!();
                Navigator.of(context).pop();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Delete'),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: EddieColors.getSurface(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Row(
      children: [
        Expanded(
          child: ListTile(
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
            onTap: onTap,
          ),
        ),
        if (isSelected)
          GestureDetector(
            onTapDown: (details) => _showOptionsMenu(context, details),
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Icon(
                Icons.more_horiz,
                size: 18,
                color: EddieColors.getTextSecondary(context),
              ),
            ),
          ),
      ],
    );
  }
}

