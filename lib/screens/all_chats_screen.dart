import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/chat.dart';
import '../widgets/chat_list_item.dart';
import '../utils/theme.dart';

class AllChatsScreen extends StatelessWidget {
  final List<Chat> chats;
  final String? selectedChatId;
  final Function(String) onSelectChat;
  final Function(String) onDeleteChat;
  
  const AllChatsScreen({
    Key? key,
    required this.chats,
    required this.selectedChatId,
    required this.onSelectChat,
    required this.onDeleteChat,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    
    // Sort chats by updatedAt (most recent first)
    final sortedChats = List<Chat>.from(chats)
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.chatTabLabel,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: sortedChats.isEmpty
                ? Center(
                    child: Text(
                      l10n.noChatsYet,
                      style: TextStyle(
                        fontSize: 16,
                        color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: sortedChats.length,
                    itemBuilder: (context, index) {
                      final chat = sortedChats[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: ChatListItem(
                          chat: chat,
                          isSelected: chat.id == selectedChatId,
                          onTap: () => onSelectChat(chat.id),
                          onDelete: () => onDeleteChat(chat.id),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
} 