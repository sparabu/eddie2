import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
          child: Row(
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 16,
                color: isSelected
                    ? (isDarkMode ? Colors.white : Colors.black)
                    : (isDarkMode ? AppTheme.darkSecondaryTextColor : Colors.grey.shade700),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
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
                    if (chat.lastMessagePreview.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        chat.lastMessagePreview,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          color: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade600,
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 2),
                      Text(
                        l10n.noMessagesYet,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          fontStyle: FontStyle.italic,
                          color: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 14),
                onPressed: onDelete,
                tooltip: l10n.deleteChat,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                color: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade600,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 