import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/chat.dart';
import '../models/message.dart';
import '../models/qa_pair.dart';
import '../providers/chat_provider.dart';
import '../providers/qa_provider.dart';
import '../theme/eddie_colors.dart';
import '../theme/eddie_constants.dart';
import '../theme/eddie_text_styles.dart';
import '../widgets/chat_input.dart';
import '../widgets/message_bubble.dart';
import '../widgets/qa_pair_form.dart';
import '../widgets/eddie_logo.dart';

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
        // Create a new chat with the first message as the title
        final title = message.length > 60 ? '${message.substring(0, 60)}...' : message;
        final newChat = await ref.read(chatProvider.notifier).createChat(title: title);
        ref.read(selectedChatIdProvider.notifier).state = newChat.id;
        await ref.read(chatProvider.notifier).sendMessage(newChat.id, message);
        
        // Force a rebuild to ensure the chat screen updates properly
        if (mounted) {
          setState(() {});
        }
      } else {
        await ref.read(chatProvider.notifier).sendMessage(selectedChatId, message);
      }
      
      // Scroll to bottom after the message is sent
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } catch (e) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.apiError(e.toString())),
          backgroundColor: EddieColors.getError(context),
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
        // Create a new chat with the first message as the title
        final title = message.length > 60 ? '${message.substring(0, 60)}...' : message;
        final newChat = await ref.read(chatProvider.notifier).createChat(title: title);
        ref.read(selectedChatIdProvider.notifier).state = newChat.id;
        await ref.read(chatProvider.notifier).sendMessageWithFile(newChat.id, message, filePath);
      } else {
        await ref.read(chatProvider.notifier).sendMessageWithFile(selectedChatId, message, filePath);
      }
      
      // Scroll to bottom after the message is sent
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } catch (e) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.apiError(e.toString())),
          backgroundColor: EddieColors.getError(context),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _sendMessageWithImage(String message, String imagePath) async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final selectedChatId = ref.read(selectedChatIdProvider);
      
      if (selectedChatId == null) {
        // Create a new chat with the first message as the title
        final title = message.length > 60 ? '${message.substring(0, 60)}...' : message;
        final newChat = await ref.read(chatProvider.notifier).createChat(title: title);
        ref.read(selectedChatIdProvider.notifier).state = newChat.id;
        await ref.read(chatProvider.notifier).sendMessageWithImage(newChat.id, message, imagePath);
      } else {
        await ref.read(chatProvider.notifier).sendMessageWithImage(selectedChatId, message, imagePath);
      }
      
      // Scroll to bottom after the message is sent
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } catch (e) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.apiError(e.toString())),
          backgroundColor: EddieColors.getError(context),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _sendMessageWithMultipleFiles(String message, List<String> filePaths) async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final selectedChatId = ref.read(selectedChatIdProvider);
      
      if (selectedChatId == null) {
        // Create a new chat with the first message as the title
        final title = message.length > 60 ? '${message.substring(0, 60)}...' : message;
        final newChat = await ref.read(chatProvider.notifier).createChat(title: title);
        ref.read(selectedChatIdProvider.notifier).state = newChat.id;
        await ref.read(chatProvider.notifier).sendMessageWithMultipleFiles(
          newChat.id, 
          message, 
          filePaths
        );
      } else {
        await ref.read(chatProvider.notifier).sendMessageWithMultipleFiles(
          selectedChatId, 
          message, 
          filePaths
        );
      }
      
      // Scroll to bottom after the message is sent
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } catch (e) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.apiError(e.toString())),
          backgroundColor: EddieColors.getError(context),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
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
            backgroundColor: EddieColors.getPrimary(context),
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
              title: Text(l10n.noQAPairsDetected),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.noQAPairsDetectedMessage),
                  SizedBox(height: EddieConstants.spacingMd),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(l10n.cancelButton),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          // Show dialog to manually create Q&A pair
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(l10n.createQAPairTitle),
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
                                        backgroundColor: EddieColors.getPrimary(context),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                        child: Text(l10n.createManuallyButton),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.noQAPairsDetected),
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.apiError(e.toString())),
          backgroundColor: EddieColors.getError(context),
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final selectedChatId = ref.watch(selectedChatIdProvider);
    final chats = ref.watch(chatProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Find the selected chat
    Chat? selectedChat;
    if (selectedChatId != null) {
      try {
        selectedChat = chats.firstWhere((chat) => chat.id == selectedChatId);
      } catch (e) {
        // Chat not found, leave selectedChat as null
      }
    }
    
    return Column(
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
                        l10n.chatWelcomeTitle,
                        style: EddieTextStyles.heading2(context),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Ask me anything about programming, design, or any topic you're interested in learning about.",
                        style: EddieTextStyles.body2(context),
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
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: MessageBubble(
                        message: message,
                        onSaveQAPair: message.role == MessageRole.assistant && !message.isError
                            ? () => _detectAndSaveQAPairs(selectedChat!.id)
                            : null,
                      ),
                    );
                  },
                ),
        ),
        
        // Loading indicator
        if (_isLoading)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: EddieColors.getSurface(context),
            child: Center(
              child: SpinKitThreeBounce(
                color: EddieColors.getPrimary(context),
                size: 24,
              ),
            ),
          ),
        
        // Chat input
        Padding(
          padding: const EdgeInsets.all(16),
          child: ChatInput(
            onSendMessage: _sendMessage,
            onSendMessageWithFile: _sendMessageWithFile,
            onSendMessageWithImage: _sendMessageWithImage,
            onSendMessageWithMultipleFiles: _sendMessageWithMultipleFiles,
            isLoading: _isLoading,
            hintText: l10n.typeMessageHint,
          ),
        ),
      ],
    );
  }
}

