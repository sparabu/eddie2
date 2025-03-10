import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../models/chat.dart';
import '../models/message.dart';
import '../providers/chat_provider.dart';
import '../providers/qa_provider.dart';
import '../utils/theme.dart';
import '../widgets/chat_input.dart';
import '../widgets/chat_list_item.dart';
import '../widgets/message_bubble.dart';
import '../widgets/qa_pair_form.dart';
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
          backgroundColor: AppTheme.errorColor,
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
          backgroundColor: AppTheme.errorColor,
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
    try {
      final pairs = await ref.read(chatProvider.notifier).detectQAPairs(chatId);
      
      if (pairs.isNotEmpty) {
        await ref.read(qaPairProvider.notifier).saveQAPairsFromChat(chatId, pairs);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Saved ${pairs.length} Q&A pairs'),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
      } else {
        // Show dialog to manually create Q&A pair
        final selectedChat = ref.read(selectedChatProvider);
        if (selectedChat != null) {
          final lastAssistantMessage = selectedChat.messages.lastWhere(
            (message) => message.role == MessageRole.assistant && !message.isError,
            orElse: () => throw Exception('No assistant message found'),
          );
          
          // Show dialog to manually create Q&A pair
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('No Q&A pairs detected'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'No Q&A pairs were automatically detected in this message. Would you like to:',
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          // Show dialog to manually create Q&A pair
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Create Q&A Pair'),
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
                                      const SnackBar(
                                        content: Text('Q&A pair created successfully'),
                                        backgroundColor: AppTheme.primaryColor,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                        child: const Text('Create Manually'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No Q&A pairs detected in this message'),
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error detecting Q&A pairs: ${e.toString()}'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final chats = ref.watch(chatProvider);
    final selectedChatId = ref.watch(selectedChatIdProvider);
    final selectedChat = ref.watch(selectedChatProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(selectedChat?.title ?? 'New Chat'),
        actions: [
          if (isSmallScreen)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _createNewChat,
              tooltip: 'New Chat',
            ),
        ],
      ),
      body: Row(
        children: [
          // Chat list sidebar (only visible on larger screens)
          if (!isSmallScreen)
            Container(
              width: 250,
              decoration: BoxDecoration(
                color: isDarkMode 
                    ? AppTheme.darkSidebarColor 
                    : AppTheme.sidebarColor,
                border: Border(
                  right: BorderSide(
                    color: isDarkMode 
                        ? Colors.grey.shade800 
                        : Colors.grey.shade300,
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: ElevatedButton.icon(
                      onPressed: _createNewChat,
                      icon: const Icon(Icons.add),
                      label: const Text('New Chat'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(40),
                      ),
                    ),
                  ),
                  Expanded(
                    child: chats.isEmpty
                        ? Center(
                            child: Text(
                              'No chats yet',
                              style: TextStyle(
                                color: isDarkMode 
                                    ? Colors.grey.shade400 
                                    : Colors.grey.shade700,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: chats.length,
                            itemBuilder: (context, index) {
                              final chat = chats[index];
                              return ChatListItem(
                                chat: chat,
                                isSelected: chat.id == selectedChatId,
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
            child: Column(
              children: [
                // Messages area
                Expanded(
                  child: selectedChat == null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.chat_bubble_outline,
                                size: 64,
                                color: AppTheme.primaryColor,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Start a new chat',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: isDarkMode 
                                      ? Colors.grey.shade300 
                                      : Colors.grey.shade700,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _createNewChat,
                                child: const Text('New Chat'),
                              ),
                            ],
                          ),
                        )
                      : selectedChat.messages.isEmpty
                          ? Center(
                              child: Text(
                                'Send a message to start chatting',
                                style: TextStyle(
                                  color: isDarkMode 
                                      ? Colors.grey.shade400 
                                      : Colors.grey.shade700,
                                ),
                              ),
                            )
                          : ListView.builder(
                              controller: _scrollController,
                              itemCount: selectedChat.messages.length,
                              itemBuilder: (context, index) {
                                final message = selectedChat.messages[index];
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
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    color: isDarkMode 
                        ? AppTheme.darkChatBackgroundColor 
                        : Colors.white,
                    child: const Center(
                      child: SpinKitThreeBounce(
                        color: AppTheme.primaryColor,
                        size: 24,
                      ),
                    ),
                  ),
                
                // Chat input
                ChatInput(
                  onSendMessage: _sendMessage,
                  onSendMessageWithFile: _sendMessageWithFile,
                  isLoading: _isLoading,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 