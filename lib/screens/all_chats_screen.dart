import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/chat.dart';
import '../widgets/chat_list_item.dart';
import '../theme/eddie_colors.dart';
import '../theme/eddie_constants.dart';
import '../theme/eddie_text_styles.dart';
import '../widgets/eddie_logo.dart';

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
      padding: EdgeInsets.all(EddieConstants.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.chatTabLabel,
            style: EddieTextStyles.heading2(context),
          ),
          SizedBox(height: EddieConstants.spacingMd),
          Expanded(
            child: sortedChats.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const EddieLogo(size: 64),
                        SizedBox(height: EddieConstants.spacingLg),
                        Text(
                          l10n.noChatsYet,
                          style: EddieTextStyles.body1(context).copyWith(
                            color: EddieColors.getTextSecondary(context),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: sortedChats.length,
                    itemBuilder: (context, index) {
                      final chat = sortedChats[index];
                      return ChatListItem(
                        chat: chat,
                        isSelected: chat.id == selectedChatId,
                        onTap: () => onSelectChat(chat.id),
                        onDelete: () => onDeleteChat(chat.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

