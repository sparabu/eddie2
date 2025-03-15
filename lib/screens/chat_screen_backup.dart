import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/chat.dart';
import '../models/message.dart';
import '../providers/chat_provider.dart';
import '../providers/qa_provider.dart';
import '../theme/eddie_theme.dart';
import '../theme/eddie_text_styles.dart';
import '../widgets/chat_input.dart';
import '../widgets/chat_list_item.dart';
import '../widgets/message_bubble.dart';
import '../widgets/qa_pair_form.dart';
import '../widgets/eddie_logo.dart';
import '../models/qa_pair.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }
  
  Future<void> _sendMessage(String message) async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final selectedChatId = ref.read(selectedChatIdProvider);
      
      if (selectedChatId == null) {
        // Create a new chat if none is selected
        final newChat = await ref.read(chatProvider.notifier).createChat();
        ref.read(selectedChatIdProvider.notifier).state = newChat.id;
        await ref.read(chatProvider.notifier).sendMessage(newChat.id, message);
      } else {
        await ref.read(chatProvider.notifier).sendMessage(selectedChatId, message);
      }
      
      // Scroll to bottom after the message is sent
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: EddieTheme.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _sendMessageWithFile(String message, String filePath) async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final selectedChatId = ref.read(selectedChatIdProvider);
      
      if (selectedChatId == null) {
        // Create a new chat if none is selected
        final newChat = await ref.read(chatProvider.notifier).createChat();
        ref.read(selectedChatIdProvider.notifier).state = newChat.id;
        await ref.read(chatProvider.notifier).sendMessage(
          newChat.id, 
          message,
          filePath: filePath,
        );
      } else {
        await ref.read(chatProvider.notifier).sendMessage(
          selectedChatId, 
          message,
          filePath: filePath,
        );
      }
      
      // Scroll to bottom after the message is sent
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: EddieTheme.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _createNewChat() async {
    final newChat = await ref.read(chatProvider.notifier).createChat();
    ref.read(selectedChatIdProvider.notifier).state = newChat.id;
  }
  
  Future<void> _deleteChat(String chatId) async {
    final selectedChatId = ref.read(selectedChatIdProvider);
    
    await ref.read(chatProvider.notifier).deleteChat(chatId);
    
    // If the deleted chat was selected, clear the selection
    if (selectedChatId == chatId) {
      ref.read(selectedChatIdProvider.notifier).state = null;
    }
  }
  
  Future<void> _detectAndSaveQAPairs(String chatId) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final pairs = await ref.read(chatProvider.notifier).detectQAPairs(chatId);
      
      if (pairs.isNotEmpty) {
        await ref.read(qaPairProvider.notifier).saveQAPairsFromChat(chatId, pairs);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.qaPairsDetected(pairs.length)),
            backgroundColor: EddieTheme.primaryColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      } else {
        // Show dialog to manually create Q&A pair
        final chats = ref.read(chatProvider);
        final selectedChat = chats.firstWhere(
          (chat) => chat.id == chatId,
          orElse: () => throw Exception('Chat not found'),
        );
        
        if (selectedChat.messages.isNotEmpty) {
          final lastAssistantMessage = selectedChat.messages.lastWhere(
            (message) => message.role == MessageRole.assistant && !message.isError,
            orElse: () => throw Exception(l10n.noAssistantMessage),
          );
          
          // Show dialog to manually create Q&A pair
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(
                l10n.noQAPairsDetected,
                style: EddieTextStyles.titleLarge,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.noQAPairsDetectedMessage,
                    style: EddieTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          foregroundColor: EddieTheme.secondaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          l10n.cancelButton,
                          style: EddieTextStyles.labelLarge,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          // Show dialog to manually create Q&A pair
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(
                                l10n.createQAPairTitle,
                                style: EddieTextStyles.titleLarge,
                              ),
                              content: SizedBox(
                                width: 600,
                                child: QAPairForm(
                                  initialQAPair: QAPair(
                                    question: '',
                                    answer: lastAssistantMessage.content,
                                  ),
                                  onSave: (qaPair) {
                                    ref.read(qaPairProvider.notifier).addQAPair(qaPair);
                                    Navigator.of(context).pop();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(l10n.qaPairCreatedSuccess),
                                        backgroundColor: EddieTheme.primaryColor,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: EddieTheme.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        child: Text(
                          l10n.createManuallyButton,
                          style: EddieTextStyles.labelLarge.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.noQAPairsDetected),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.errorDetectingQAPairs(e.toString())),
          backgroundColor: EddieTheme.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final chats = ref.watch(chatProvider);
    final selectedChatId = ref.watch(selectedChatIdProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Find the selected chat or use the first one if none is selected
    Chat? selectedChat;
    if (selectedChatId != null) {
      selectedChat = chats.firstWhere(
        (chat) => chat.id == selectedChatId,
        orElse: () => chats.isEmpty ? null : chats.first,
      );
    } else if (chats.isNotEmpty) {
      selectedChat = chats.first;
    }
    
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          selectedChat?.title ?? l10n.newChat,
          style: EddieTextStyles.titleMedium,
        ),
        elevation: 0,
        backgroundColor: isDarkMode 
            ? EddieTheme.darkSurfaceColor 
            : EddieTheme.surfaceColor,
        foregroundColor: isDarkMode 
            ? EddieTheme.darkTextColor 
            : EddieTheme.textColor,
      ),
      body: Row(
        children: [
          // Chat list sidebar
          Container(
            width: 250,
            decoration: BoxDecoration(
              color: isDarkMode 
                  ? EddieTheme.darkSurfaceVariantColor 
                  : EddieTheme.surfaceVariantColor,
              border: Border(
                right: BorderSide(
                  color: isDarkMode 
                      ? EddieTheme.darkOutlineColor 
                      : EddieTheme.outlineColor,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                // New chat button
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: OutlinedButton.icon(
                    onPressed: _createNewChat,
                    icon: const Icon(Icons.add),
                    label: Text(
                      l10n.newChatButton,
                      style: EddieTextStyles.labelLarge,
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      foregroundColor: EddieTheme.primaryColor,
                      side: BorderSide(color: EddieTheme.primaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                
                // Chat list
                Expanded(
                  child: chats.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                l10n.noChatsYet,
                                style: EddieTextStyles.bodyMedium.copyWith(
                                  color: isDarkMode 
                                      ? EddieTheme.darkSecondaryTextColor 
                                      : EddieTheme.secondaryTextColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _createNewChat,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: EddieTheme.primaryColor,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                                child: Text(
                                  l10n.newChatButton,
                                  style: EddieTextStyles.labelLarge.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: chats.length,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemBuilder: (context, index) {
                            final chat = chats[index];
                            return ChatListItem(
                              chat: chat,
                              isSelected: chat.id == selectedChat?.id,
                              onTap: () {
                                ref.read(selectedChatIdProvider.notifier).state = chat.id;
                              },
                              onDelete: () => _deleteChat(chat.id),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          
          // Chat messages
          Expanded(
            child: Container(
              color: isDarkMode 
                  ? EddieTheme.darkBackgroundColor 
                  : EddieTheme.backgroundColor,
              child: Column(
                children: [
                  // Messages area
                  Expanded(
                    child: selectedChat == null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const EddieLogo(size: 64),
                                const SizedBox(height: 24),
                                Text(
                                  l10n.startNewChat,
                                  style: EddieTextStyles.titleMedium,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  l10n.startNewChatDescription,
                                  style: EddieTextStyles.bodyMedium.copyWith(
                                    color: isDarkMode 
                                        ? EddieTheme.darkSecondaryTextColor 
                                        : EddieTheme.secondaryTextColor,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton(
                                  onPressed: _createNewChat,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: EddieTheme.primaryColor,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 16,
                                    ),
                                  ),
                                  child: Text(
                                    l10n.newChatButton,
                                    style: EddieTextStyles.labelLarge.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : selectedChat.messages.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.chat_bubble_outline,
                                      size: 64,
                                      color: isDarkMode 
                                          ? EddieTheme.darkSecondaryTextColor 
                                          : EddieTheme.secondaryTextColor,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      l10n.sendMessageToStart,
                                      style: EddieTextStyles.bodyLarge.copyWith(
                                        color: isDarkMode 
                                            ? EddieTheme.darkSecondaryTextColor 
                                            : EddieTheme.secondaryTextColor,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                controller: _scrollController,
                                padding: const EdgeInsets.all(16),
                                itemCount: selectedChat.messages.length,
                                itemBuilder: (context, index) {
                                  final message = selectedChat!.messages[index];
                                  return MessageBubble(
                                    message: message,
                                    onSaveQAPair: message.role == MessageRole.assistant && !message.isError
                                        ? () => _detectAndSaveQAPairs(selectedChat.id)
                                        : null,
                                  );
                                },
                              ),
                  ),
                  
                  // Loading indicator
                  if (_isLoading)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      color: isDarkMode 
                          ? EddieTheme.darkSurfaceColor 
                          : EddieTheme.surfaceColor,
                      child: Center(
                        child: SpinKitThreeBounce(
                          color: EddieTheme.primaryColor,
                          size: 24,
                        ),
                      ),
                    ),
                  
                  // Chat input
                  ChatInput(
                    onSendMessage: _sendMessage,
                    onSendMessageWithFile: _sendMessageWithFile,
                    isLoading: _isLoading,
                    hintText: l10n.typeMessageHint,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

