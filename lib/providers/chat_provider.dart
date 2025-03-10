import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat.dart';
import '../models/message.dart';
import '../services/storage_service.dart';
import '../services/openai_service.dart';
import '../services/file_service.dart';

class ChatNotifier extends StateNotifier<List<Chat>> {
  final StorageService _storageService;
  final OpenAIService _openAIService;
  final FileService _fileService;
  
  ChatNotifier(this._storageService, this._openAIService, this._fileService) : super([]) {
    _loadChats();
  }
  
  Future<void> _loadChats() async {
    final chats = await _storageService.getChats();
    state = chats;
  }
  
  Future<Chat> createChat() async {
    final newChat = Chat();
    state = [...state, newChat];
    await _storageService.saveChat(newChat);
    return newChat;
  }
  
  Future<void> deleteChat(String chatId) async {
    state = state.where((chat) => chat.id != chatId).toList();
    await _storageService.deleteChat(chatId);
  }
  
  Future<void> updateChatTitle(String chatId, String newTitle) async {
    state = state.map((chat) {
      if (chat.id == chatId) {
        final updatedChat = chat.copyWith(title: newTitle);
        _storageService.saveChat(updatedChat);
        return updatedChat;
      }
      return chat;
    }).toList();
  }
  
  Chat? getChat(String chatId) {
    return state.firstWhere((chat) => chat.id == chatId, orElse: () => null as Chat);
  }
  
  Future<void> addMessageToChat(String chatId, Message message) async {
    state = state.map((chat) {
      if (chat.id == chatId) {
        final updatedChat = chat.addMessage(message);
        _storageService.saveChat(updatedChat);
        return updatedChat;
      }
      return chat;
    }).toList();
  }
  
  Future<void> sendMessage(String chatId, String content, {String? filePath}) async {
    try {
      // Get the chat
      final chatIndex = state.indexWhere((chat) => chat.id == chatId);
      if (chatIndex == -1) {
        throw Exception('Chat not found');
      }
      
      final chat = state[chatIndex];
      
      // Add user message
      final userMessage = Message(
        role: MessageRole.user,
        content: content,
        attachmentPath: filePath,
        attachmentName: filePath != null ? filePath.split('/').last : null,
      );
      
      final updatedChat = chat.addMessage(userMessage);
      state = [...state.sublist(0, chatIndex), updatedChat, ...state.sublist(chatIndex + 1)];
      await _storageService.saveChat(updatedChat);
      
      // Send to OpenAI
      try {
        final response = await _openAIService.sendMessage(
          messages: updatedChat.messages,
          filePath: filePath,
        );
        
        // Add assistant message
        final assistantMessage = Message(
          role: MessageRole.assistant,
          content: response,
        );
        
        final finalChat = updatedChat.addMessage(assistantMessage);
        state = [...state.sublist(0, chatIndex), finalChat, ...state.sublist(chatIndex + 1)];
        await _storageService.saveChat(finalChat);
        
        // Clean up temporary file if needed
        if (filePath != null) {
          await _fileService.deleteTemporaryFile(filePath);
        }
      } catch (e) {
        // Add error message
        final errorMessage = Message(
          role: MessageRole.assistant,
          content: 'Error: ${e.toString()}',
          isError: true,
        );
        
        final errorChat = updatedChat.addMessage(errorMessage);
        state = [...state.sublist(0, chatIndex), errorChat, ...state.sublist(chatIndex + 1)];
        await _storageService.saveChat(errorChat);
        
        // Clean up temporary file if needed
        if (filePath != null) {
          await _fileService.deleteTemporaryFile(filePath);
        }
        
        rethrow;
      }
    } catch (e) {
      print('Error sending message: $e');
      rethrow;
    }
  }
  
  Future<List<Map<String, String>>> detectQAPairs(String chatId) async {
    try {
      final chat = state.firstWhere((chat) => chat.id == chatId);
      final lastAssistantMessage = chat.messages.lastWhere(
        (message) => message.role == MessageRole.assistant && !message.isError,
        orElse: () => throw Exception('No assistant message found'),
      );
      
      return await _openAIService.detectQAPairs(lastAssistantMessage.content);
    } catch (e) {
      print('Error detecting Q&A pairs: $e');
      return [];
    }
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, List<Chat>>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  final openAIService = ref.watch(openAIServiceProvider);
  final fileService = ref.watch(fileServiceProvider);
  return ChatNotifier(storageService, openAIService, fileService);
});

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

final openAIServiceProvider = Provider<OpenAIService>((ref) {
  return OpenAIService();
});

final fileServiceProvider = Provider<FileService>((ref) {
  return FileService();
});

final selectedChatIdProvider = StateProvider<String?>((ref) => null);

final selectedChatProvider = Provider<Chat?>((ref) {
  final selectedChatId = ref.watch(selectedChatIdProvider);
  final chats = ref.watch(chatProvider);
  
  if (selectedChatId == null) {
    return null;
  }
  
  return chats.firstWhere(
    (chat) => chat.id == selectedChatId,
    orElse: () => null as Chat,
  );
}); 