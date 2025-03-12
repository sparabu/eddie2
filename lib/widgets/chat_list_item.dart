import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/chat.dart';
import '../utils/theme.dart';

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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    
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
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          margin: const EdgeInsets.symmetric(vertical: 1, horizontal: 8),
          child: Row(
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 14,
                color: isSelected
                    ? (isDarkMode ? Colors.white : Colors.black)
                    : (isDarkMode ? AppTheme.darkSecondaryTextColor : Colors.grey.shade700),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  chat.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                    color: isSelected
                        ? (isDarkMode ? Colors.white : Colors.black)
                        : (isDarkMode ? AppTheme.darkSecondaryTextColor : Colors.grey.shade700),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.close, size: 12),
                onPressed: onDelete,
                tooltip: l10n.deleteChat,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 20,
                  minHeight: 20,
                ),
                color: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade600,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 