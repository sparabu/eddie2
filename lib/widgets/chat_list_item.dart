import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/chat.dart';
import '../theme/eddie_theme.dart';
import '../theme/eddie_colors.dart';
import '../theme/eddie_text_styles.dart';

class ChatListItem extends StatelessWidget {
  final Chat chat;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  
  const ChatListItem({
    Key? key,
    required this.chat,
    required this.isSelected,
    required this.onTap,
    required this.onDelete,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        hoverColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: isSelected 
                ? (isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200) 
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isSelected
                ? Border.all(
                    color: isDarkMode ? EddieColors.primaryDark : EddieColors.getPrimary(context),
                    width: 1,
                  )
                : null,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
          child: Row(
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 16,
                color: isSelected
                    ? (isDarkMode ? EddieColors.primaryDark : EddieColors.getPrimary(context))
                    : (isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  chat.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: (isSelected ? TextStyle(fontWeight: FontWeight.w500, fontSize: 14) : TextStyle(fontSize: 14)).copyWith(
                    color: isSelected
                        ? (isDarkMode ? EddieColors.primaryDark : EddieColors.getPrimary(context))
                        : (isDarkMode ? Colors.white : Colors.black87),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: Icon(
                  Icons.close, 
                  size: 14,
                  color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
                onPressed: onDelete,
                tooltip: l10n.deleteChat,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 24,
                  minHeight: 24,
                ),
                hoverColor: isDarkMode ? Colors.red.shade800.withOpacity(0.1) : Colors.red.shade200.withOpacity(0.1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

