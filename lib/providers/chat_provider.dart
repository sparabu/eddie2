import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat.dart';
import '../models/message.dart';
import '../services/storage_service.dart';
import '../services/openai_service.dart';
import '../services/file_service.dart';
import 'locale_provider.dart';
import 'project_provider.dart';
import 'settings_provider.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';

class ChatNotifier extends StateNotifier<List<Chat>> {
  final StorageService _storageService;
  final OpenAIService _openAIService;
  final FileService _fileService;
  final Ref _ref;
  
  ChatNotifier(this._storageService, this._openAIService, this._fileService, this._ref) : super([]) {
    _loadChats();
  }
  
  Future<void> _loadChats() async {
    final chats = await _storageService.getChats();
    state = chats;
  }
  
  Future<Chat> createChat({required String title, String? projectId}) async {
    // Create a new chat and immediately add it to the state
    final newChat = Chat(title: title, projectId: projectId);
    state = [...state, newChat];
    await _storageService.saveChat(newChat);
    
    // If this chat is associated with a project, update the project
    if (projectId != null) {
      await _ref.read(projectProvider.notifier).addChatToProject(projectId, newChat.id);
    }
    
    return newChat;
  }
  
  Future<void> deleteChat(String chatId) async {
    // Get the chat before removing it
    final chat = state.firstWhere((c) => c.id == chatId, orElse: () => null as Chat);
    
    // Remove from state
    state = state.where((chat) => chat.id != chatId).toList();
    await _storageService.deleteChat(chatId);
    
    // If the chat belonged to a project, update the project
    if (chat != null && chat.projectId != null) {
      await _ref.read(projectProvider.notifier).removeChatFromProject(chat.projectId!, chatId);
    }
  }
  
  Future<void> updateChatTitle(String chatId, String newTitle) async {
    final chatIndex = state.indexWhere((chat) => chat.id == chatId);
    if (chatIndex == -1) {
      debugPrint('Chat with ID $chatId not found.');
      return;
    }
    
    final chat = state[chatIndex];
    final updatedChat = chat.copyWith(title: newTitle);
    
    state = [
      ...state.sublist(0, chatIndex),
      updatedChat,
      ...state.sublist(chatIndex + 1),
    ];
    
    await _storageService.saveChat(updatedChat);
  }
  
  Chat? getChat(String chatId) {
    return state.firstWhere((chat) => chat.id == chatId, orElse: () => null as Chat);
  }
  
  Future<void> addMessageToChat(String chatId, Message message) async {
    state = state.map((chat) => chat.addMessage(message)).toList();
    await _storageService.saveChat(state.firstWhere((chat) => chat.id == chatId));
  }
  
  Future<void> sendMessage(String chatId, String content, {String? filePath}) async {
    try {
      // Check if this is a new chat (not yet in state)
      final chatIndex = state.indexWhere((chat) => chat.id == chatId);
      final isNewChat = chatIndex == -1;
      
      Chat chat;
      if (isNewChat) {
        // This is a new chat that wasn't found in the state
        // This shouldn't normally happen since createChat now adds the chat to the state
        // But we'll handle it just in case
        final title = content.length > 30 ? '${content.substring(0, 30)}...' : content;
        chat = Chat(id: chatId, title: title);
      } else {
        chat = state[chatIndex];
      }
      
      // Add user message
      final userMessage = Message(
        role: MessageRole.user,
        content: content,
        attachmentPath: filePath,
        attachmentName: filePath != null ? filePath.split('/').last : null,
      );
      
      final updatedChat = chat.addMessage(userMessage);
      
      if (isNewChat) {
        // Add the new chat to state
        state = [...state, updatedChat];
      } else {
        // Update existing chat in state
        state = state.map((c) => c.id == chatId ? updatedChat : c).toList();
      }
      
      // Save the updated chat to storage
      await _storageService.saveChat(updatedChat);
      
      // Get all previous messages for context
      final messages = updatedChat.messages;
      
      // Send the message to OpenAI API
      final responseText = await _openAIService.sendMessage(
        messages: messages,
        filePath: filePath,
        languageCode: _ref.read(localeProvider).languageCode,
      );
      
      // Add the assistant response as a new message
      final assistantMessage = Message(
        role: MessageRole.assistant,
        content: responseText,
      );
      
      // Update the chat with the assistant's response
      final chatWithResponse = updatedChat.addMessage(assistantMessage);
      
      // Update state and save
      state = state.map((c) => c.id == chatId ? chatWithResponse : c).toList();
      await _storageService.saveChat(chatWithResponse);
    } catch (e) {
      // Add error message
      final errorMessage = Message(
        role: MessageRole.assistant,
        content: e.toString(),
        isError: true,
      );
      
      // Find the chat again from current state
      final chat = state.firstWhere(
        (c) => c.id == chatId,
        orElse: () => Chat(id: chatId, title: 'Error'),
      );
      
      final updatedChat = chat.addMessage(errorMessage);
      
      state = state.map((c) => c.id == chatId ? updatedChat : c).toList();
      await _storageService.saveChat(updatedChat);
      
      rethrow;
    }
  }
  
  // Send a message with a system instruction that doesn't appear in the UI
  Future<void> sendMessageWithSystemInstruction(String chatId, String content, String systemInstruction) async {
    // Find the chat in the state
    final chatIndex = state.indexWhere((chat) => chat.id == chatId);
    if (chatIndex == -1) {
      debugPrint('Chat with ID $chatId not found.');
      return;
    }
    
    final chat = state[chatIndex];
    
    try {
      // Get all existing messages from the chat
      final chatMessages = chat.messages;
      
      // Create a system message
      final systemMessage = Message(
        role: MessageRole.system,
        content: systemInstruction,
      );
      
      // Create a list including the system message and all chat messages
      final allMessages = [systemMessage, ...chatMessages];
      
      // Send the request to OpenAI
      final responseText = await _openAIService.sendMessage(
        messages: allMessages,
        model: _ref.read(settingsProvider).selectedModel,
      );
      
      // Create a message from the assistant's response
      final assistantMessage = Message(
        role: MessageRole.assistant,
        content: responseText,
      );
      
      // Update the chat with the assistant's message
      final updatedMessages = [...chat.messages, assistantMessage];
      final updatedChat = chat.copyWith(messages: updatedMessages);
      
      // Update state and save to storage
      state = [
        ...state.sublist(0, chatIndex),
        updatedChat,
        ...state.sublist(chatIndex + 1),
      ];
      
      await _storageService.saveChat(updatedChat);
    } catch (e) {
      debugPrint('Error in sendMessageWithSystemInstruction: $e');
      
      // Create an error message
      final errorMessage = Message(
        role: MessageRole.assistant,
        content: 'Sorry, there was an error processing your request: $e',
        isError: true,
      );
      
      // Update the chat with the error message
      final updatedMessages = [...chat.messages, errorMessage];
      final updatedChat = chat.copyWith(messages: updatedMessages);
      
      // Update state and save to storage
      state = [
        ...state.sublist(0, chatIndex),
        updatedChat,
        ...state.sublist(chatIndex + 1),
      ];
      
      await _storageService.saveChat(updatedChat);
    }
  }
  
  // New method specifically for sending with text files
  Future<void> sendMessageWithFile(String chatId, String content, String filePath) async {
    try {
      // Check if this is a PDF file
      if (filePath.toLowerCase().endsWith('.pdf')) {
        await _handlePdfFile(chatId, content, filePath);
      } else {
        // Handle other file types
        await sendMessage(chatId, content, filePath: filePath);
      }
    } catch (e) {
      debugPrint('Error in sendMessageWithFile: $e');
      rethrow;
    }
  }
  
  Future<void> _handlePdfFile(String chatId, String content, String filePath) async {
    try {
      debugPrint('Processing PDF file: $filePath');
      
      // Get file bytes
      Uint8List? fileBytes;
      if (kIsWeb && filePath.startsWith('web_file_')) {
        fileBytes = _fileService.getWebFileBytes(filePath);
      } else {
        final file = File(filePath);
        fileBytes = await file.readAsBytes();
      }
      
      if (fileBytes == null) {
        throw Exception('Could not read file bytes');
      }
      
      debugPrint('PDF file size: ${(fileBytes.length / 1024 / 1024).toStringAsFixed(2)} MB');
      
      // Use PDF service to extract text and process the file
      final pdfService = PdfService();
      final result = await pdfService.extractAndChunkText(
        fileBytes,
        useOcrIfNeeded: true,
      );
      
      // Check if this is a scanned document with image files
      final firstChunk = result.isNotEmpty ? result.first : null;
      final metadata = firstChunk?['metadata'] as Map<String, dynamic>?;
      final isScanned = metadata?['isScanned'] as bool? ?? false;
      final imageFiles = metadata?['imageFiles'] as List<String>? ?? [];
      
      if (isScanned && imageFiles.isNotEmpty) {
        // Handle scanned PDF by processing the image files
        debugPrint('Handling scanned PDF with ${imageFiles.length} image files');
        
        // Create a user message that includes the original content
        final userMessage = Message(
          role: MessageRole.user,
          content: content,
          attachmentPath: filePath,
          attachmentName: filePath.split('/').last,
        );
        
        // Get the chat
        final chatIndex = state.indexWhere((c) => c.id == chatId);
        final chat = chatIndex != -1 ? state[chatIndex] : Chat(id: chatId);
        final updatedChat = chat.addMessage(userMessage);
        
        // Update state
        if (chatIndex != -1) {
          state = state.map((c) => c.id == chatId ? updatedChat : c).toList();
        } else {
          state = [...state, updatedChat];
        }
        
        await _storageService.saveChat(updatedChat);
        
        // Process the first image file immediately
        await _processScannedPdfImage(chatId, imageFiles.isNotEmpty ? imageFiles[0] : null, 
          '${content}\n\n[This is a scanned document being processed with OCR]');
        
        // If there are multiple images, process them in sequence
        if (imageFiles.length > 1) {
          for (int i = 1; i < imageFiles.length; i++) {
            final imagePath = imageFiles[i];
            await _processScannedPdfImage(chatId, imagePath, 
              "[Continuing OCR processing of page ${i + 1}/${imageFiles.length} of the scanned document]");
          }
        }
      } else {
        // Handle regular PDF with text extraction
        await _processPdfText(chatId, content, filePath, result);
      }
    } catch (e) {
      debugPrint('Error processing PDF file: $e');
      // Add error message to chat
      await sendMessage(chatId, 'Error processing PDF file: $e');
    }
  }
  
  Future<void> _processScannedPdfImage(String chatId, String? imagePath, String message) async {
    if (imagePath == null) return;
    
    try {
      // Use the OpenAI service to send the image with the message
      final locale = _ref.read(localeProvider);
      
      // Get all previous messages for context
      final chat = state.firstWhere((c) => c.id == chatId);
      final messages = chat.messages;
      
      // Send the message to OpenAI with image
      final responseText = await _openAIService.sendMessage(
        messages: messages,
        imagePath: imagePath,
        model: 'gpt-4o',  // Model that supports vision
        languageCode: locale.languageCode,
      );
      
      // Add the assistant response
      final assistantMessage = Message(
        role: MessageRole.assistant,
        content: responseText,
      );
      
      // Update the chat
      final updatedChat = chat.addMessage(assistantMessage);
      state = state.map((c) => c.id == chatId ? updatedChat : c).toList();
      await _storageService.saveChat(updatedChat);
    } catch (e) {
      debugPrint('Error processing scanned PDF image: $e');
      
      // Add error message
      final errorMessage = Message(
        role: MessageRole.assistant,
        content: 'Error processing scanned document image: $e',
        isError: true,
      );
      
      final chat = state.firstWhere((c) => c.id == chatId);
      final updatedChat = chat.addMessage(errorMessage);
      state = state.map((c) => c.id == chatId ? updatedChat : c).toList();
      await _storageService.saveChat(updatedChat);
    }
  }
  
  Future<void> _processPdfText(String chatId, String content, String filePath, List<Map<String, dynamic>> textChunks) async {
    // Add user message with attachment
    final userMessage = Message(
      role: MessageRole.user,
      content: content,
      attachmentPath: filePath,
      attachmentName: filePath.split('/').last,
    );
    
    // Get the chat
    final chatIndex = state.indexWhere((c) => c.id == chatId);
    final chat = chatIndex != -1 ? state[chatIndex] : Chat(id: chatId);
    final updatedChat = chat.addMessage(userMessage);
    
    // Update state
    if (chatIndex != -1) {
      state = state.map((c) => c.id == chatId ? updatedChat : c).toList();
    } else {
      state = [...state, updatedChat];
    }
    
    await _storageService.saveChat(updatedChat);
    
    // Process the chunks
    if (textChunks.isEmpty) {
      // Handle the case where no text could be extracted
      final noTextMessage = Message(
        role: MessageRole.assistant,
        content: 'I could not extract any text from the provided PDF. It may be empty, password-protected, or contain only images without OCR text.',
      );
      
      final chatWithResponse = updatedChat.addMessage(noTextMessage);
      state = state.map((c) => c.id == chatId ? chatWithResponse : c).toList();
      await _storageService.saveChat(chatWithResponse);
      return;
    }
    
    // Send the text to OpenAI
    final locale = _ref.read(localeProvider);
    final extractedText = textChunks.map((chunk) => chunk['content']).join('\n\n--- Next Section ---\n\n');
    final pdfPrompt = '$content\n\n$extractedText';
    
    try {
      final responseText = await _openAIService.sendMessage(
        messages: [
          ...updatedChat.messages.where((m) => m.id != userMessage.id).toList(),
          Message(
            role: MessageRole.user,
            content: pdfPrompt,
          ),
        ],
        model: 'gpt-4o',
        languageCode: locale.languageCode,
      );
      
      // Add assistant response
      final assistantMessage = Message(
        role: MessageRole.assistant,
        content: responseText,
      );
      
      final chatWithResponse = updatedChat.addMessage(assistantMessage);
      state = state.map((c) => c.id == chatId ? chatWithResponse : c).toList();
      await _storageService.saveChat(chatWithResponse);
    } catch (e) {
      debugPrint('Error processing PDF text with OpenAI: $e');
      
      // Add error message
      final errorMessage = Message(
        role: MessageRole.assistant,
        content: 'Error processing PDF: $e',
        isError: true,
      );
      
      final chatWithError = updatedChat.addMessage(errorMessage);
      state = state.map((c) => c.id == chatId ? chatWithError : c).toList();
      await _storageService.saveChat(chatWithError);
    }
  }
  
  // New method specifically for sending with image files
  Future<void> sendMessageWithImage(String chatId, String content, String imagePath) async {
    try {
      debugPrint('Starting sendMessageWithImage with image: $imagePath');
      
      // Check if this is a new chat
      final chatIndex = state.indexWhere((chat) => chat.id == chatId);
      final isNewChat = chatIndex == -1;
      
      Chat chat;
      if (isNewChat) {
        final title = content.length > 30 ? '${content.substring(0, 30)}...' : content;
        chat = Chat(id: chatId, title: title);
        debugPrint('Created new chat with title: $title');
      } else {
        chat = state[chatIndex];
        debugPrint('Using existing chat with ID: $chatId');
      }
      
      // Add user message with image attachment
      debugPrint('Creating user message with image attachment');
      final userMessage = Message(
        role: MessageRole.user,
        content: content,
        attachmentPath: imagePath,
        attachmentName: imagePath.split('/').last,
      );
      
      debugPrint('Adding message to chat');
      final updatedChat = chat.addMessage(userMessage);
      
      if (isNewChat) {
        state = [...state, updatedChat];
        debugPrint('Added new chat to state');
      } else {
        state = state.map((c) => c.id == chatId ? updatedChat : c).toList();
        debugPrint('Updated existing chat in state');
      }
      
      // Save the updated chat
      await _storageService.saveChat(updatedChat);
      debugPrint('Saved chat to storage');
      
      // Get all previous messages for context
      final messages = updatedChat.messages;
      debugPrint('Retrieved ${messages.length} messages for API request');
      
      // Verify the last message has the correct attachment path
      final lastMessage = messages.lastWhere((m) => m.role == MessageRole.user);
      debugPrint('Last user message has attachment: ${lastMessage.attachmentPath != null}');
      
      // Send the message to OpenAI API, specifying this is an image
      debugPrint('Sending message to OpenAI with image: $imagePath');
      final responseText = await _openAIService.sendMessage(
        messages: messages,
        imagePath: imagePath,  // This will trigger vision API use
        model: 'gpt-4o',       // Ensure we use a model that supports vision
        languageCode: _ref.read(localeProvider).languageCode,
      );
      
      debugPrint('Received response from OpenAI');
      
      // Add the assistant response
      final assistantMessage = Message(
        role: MessageRole.assistant,
        content: responseText,
      );
      
      // Update the chat with the response
      final chatWithResponse = updatedChat.addMessage(assistantMessage);
      debugPrint('Added assistant response to chat');
      
      // Update state and save
      state = state.map((c) => c.id == chatId ? chatWithResponse : c).toList();
      await _storageService.saveChat(chatWithResponse);
      debugPrint('Updated state and saved final chat');
    } catch (e) {
      debugPrint('Error in sendMessageWithImage: $e');
      
      // Add error message
      final errorMessage = Message(
        role: MessageRole.assistant,
        content: e.toString(),
        isError: true,
      );
      
      // Find the chat again from current state
      final chat = state.firstWhere(
        (c) => c.id == chatId,
        orElse: () => Chat(id: chatId, title: 'Error'),
      );
      
      final updatedChat = chat.addMessage(errorMessage);
      
      state = state.map((c) => c.id == chatId ? updatedChat : c).toList();
      await _storageService.saveChat(updatedChat);
      
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
      
      // Get the current locale
      final locale = _ref.read(localeProvider);
      
      return await _openAIService.detectQAPairs(
        lastAssistantMessage.content,
        languageCode: locale.languageCode,
      );
    } catch (e) {
      print('Error detecting Q&A pairs: $e');
      return [];
    }
  }

  Future<void> sendMessageWithMultipleFiles(String chatId, String content, List<String> filePaths) async {
    try {
      debugPrint('Starting sendMessageWithMultipleFiles with ${filePaths.length} files');
      debugPrint('Files in original order: ${filePaths.map((p) => p.split('/').last).join(', ')}');
      
      // Check if this is a new chat
      final chatIndex = state.indexWhere((chat) => chat.id == chatId);
      final isNewChat = chatIndex == -1;
      
      Chat chat;
      if (isNewChat) {
        final title = content.length > 60 ? '${content.substring(0, 60)}...' : content;
        chat = Chat(id: chatId, title: title);
        debugPrint('Created new chat with title: $title');
      } else {
        chat = state[chatIndex];
        debugPrint('Using existing chat with ID: $chatId');
      }
      
      // Filter image files while preserving original order
      final imageFiles = filePaths.where((path) {
        final extension = path.split('.').last.toLowerCase();
        return ['jpg', 'jpeg', 'png', 'webp', 'gif'].contains(extension) ||
            path.startsWith('web_file_'); // Web files might not have extensions
      }).toList();
      
      debugPrint('Image files in filtered order: ${imageFiles.map((p) => p.split('/').last).join(', ')}');
      
      // Add user message with multiple attachments
      debugPrint('Creating user message with multiple file attachments');
      final userMessage = Message(
        role: MessageRole.user,
        content: content,
        attachmentPath: filePaths.isNotEmpty ? filePaths.first : null, // Main attachment path
        attachmentName: filePaths.isNotEmpty ? filePaths.first.split('/').last : null, // Main attachment name
        additionalAttachments: filePaths.length > 1 ? filePaths.sublist(1) : [], // Additional paths
      );
      
      debugPrint('Adding message to chat');
      final updatedChat = chat.addMessage(userMessage);
      
      if (isNewChat) {
        state = [...state, updatedChat];
        debugPrint('Added new chat to state');
      } else {
        state = state.map((c) => c.id == chatId ? updatedChat : c).toList();
        debugPrint('Updated existing chat in state');
      }
      
      // Save the updated chat
      await _storageService.saveChat(updatedChat);
      debugPrint('Saved chat to storage');
      
      // Get all previous messages for context
      final messages = updatedChat.messages;
      debugPrint('Retrieved ${messages.length} messages for API request');
      
      // Verify the last message has the correct attachment paths
      final lastMessage = messages.lastWhere((m) => m.role == MessageRole.user);
      debugPrint('Last user message has main attachment: ${lastMessage.attachmentPath != null}');
      if (lastMessage.attachmentPath != null) {
        debugPrint('Main attachment: ${lastMessage.attachmentPath!.split('/').last}');
      }
      debugPrint('Last user message has ${lastMessage.additionalAttachments?.length ?? 0} additional attachments');
      if (lastMessage.additionalAttachments != null && lastMessage.additionalAttachments!.isNotEmpty) {
        debugPrint('Additional attachments in order: ${lastMessage.additionalAttachments!.map((p) => p.split('/').last).join(', ')}');
      }
      
      // Prepare the API call - if we only have images, use the image-based flow
      final bool hasOnlyImages = imageFiles.length == filePaths.length && imageFiles.isNotEmpty;
      
      String responseText;
      if (hasOnlyImages) {
        // For multiple images, use the first image as primary and the rest as additional
        // The order here is critical - maintain the same order the user selected
        final primaryImage = imageFiles.first;
        List<String>? additionalImages = imageFiles.length > 1 ? imageFiles.sublist(1) : null;
        
        debugPrint('Sending to OpenAI - primary image: ${primaryImage.split('/').last}');
        if (additionalImages != null && additionalImages.isNotEmpty) {
          debugPrint('Sending to OpenAI - additional images: ${additionalImages.map((p) => p.split('/').last).join(', ')}');
        }
        
        // Pass the messages with primary image and additional images to the API
        responseText = await _openAIService.sendMessage(
          messages: messages,
          imagePath: primaryImage,
          additionalImagePaths: additionalImages,
          model: 'gpt-4o', // Make sure we use a model that supports vision
          languageCode: _ref.read(localeProvider).languageCode,
        );
      } else {
        // For mixed content or non-images, we'll handle differently
        // Currently, the OpenAI API doesn't support multiple file attachments in a single message
        // So we'll just pass the main attachment
        responseText = await _openAIService.sendMessage(
          messages: messages,
          filePath: filePaths.isNotEmpty ? filePaths.first : null,
          languageCode: _ref.read(localeProvider).languageCode,
        );
      }
      
      // Add the assistant response as a new message
      final assistantMessage = Message(
        role: MessageRole.assistant,
        content: responseText,
      );
      
      // Update the chat with the assistant's response
      final chatWithResponse = updatedChat.addMessage(assistantMessage);
      
      // Update state and save
      state = state.map((c) => c.id == chatId ? chatWithResponse : c).toList();
      await _storageService.saveChat(chatWithResponse);
      
      debugPrint('Completed message with multiple files');
    } catch (e) {
      debugPrint('Error sending message with multiple files: $e');
      rethrow;
    }
  }
  
  // Get chats for a specific project
  List<Chat> getChatsForProject(String projectId) {
    return state.where((chat) => chat.projectId == projectId).toList();
  }
  
  // Associate a chat with a project
  Future<void> addChatToProject(String chatId, String projectId) async {
    state = state.map((chat) => chat.copyWith(projectId: projectId)).toList();
    
    // Update the project as well
    await _ref.read(projectProvider.notifier).addChatToProject(projectId, chatId);
  }
  
  // Remove a chat from a project
  Future<void> removeChatFromProject(String chatId) async {
    final chat = state.firstWhere((c) => c.id == chatId, orElse: () => null as Chat);
    if (chat == null || chat.projectId == null) return;
    
    final projectId = chat.projectId!;
    
    state = state.map((chat) {
      if (chat.id == chatId) {
        final updatedChat = chat.copyWith(projectId: null);
        _storageService.saveChat(updatedChat);
        return updatedChat;
      }
      return chat;
    }).toList();
    
    // Update the project as well
    await _ref.read(projectProvider.notifier).removeChatFromProject(projectId, chatId);
  }
  
  // Delete all chats associated with a project
  Future<void> deleteProjectChats(String projectId) async {
    final projectChats = state.where((chat) => chat.projectId == projectId).toList();
    
    for (final chat in projectChats) {
      await deleteChat(chat.id);
    }
  }
  
  // Get a chat by ID
  Chat? getChatById(String chatId) {
    try {
      return state.firstWhere((chat) => chat.id == chatId);
    } catch (e) {
      return null;
    }
  }
  
  // Process a message with system instruction without showing the response in the UI
  Future<String> processMessageWithHiddenResponse(String chatId, String content, String systemInstruction) async {
    // Find the chat in the state
    final chatIndex = state.indexWhere((chat) => chat.id == chatId);
    if (chatIndex == -1) {
      debugPrint('Chat with ID $chatId not found.');
      return '';
    }
    
    final chat = state[chatIndex];
    
    try {
      // Get all existing messages from the chat
      final chatMessages = chat.messages;
      
      // Create a system message
      final systemMessage = Message(
        role: MessageRole.system,
        content: systemInstruction,
      );
      
      // Create a list including the system message and all chat messages
      final allMessages = [systemMessage, ...chatMessages];
      
      // Send the request to OpenAI but don't display the response in the UI
      final responseText = await _openAIService.sendMessage(
        messages: allMessages,
        model: _ref.read(settingsProvider).selectedModel,
      );
      
      // Return the response without adding it to the chat history
      return responseText;
    } catch (e) {
      debugPrint('Error in processMessageWithHiddenResponse: $e');
      return 'Error: $e';
    }
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, List<Chat>>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  final openAIService = ref.watch(openAIServiceProvider);
  final fileService = ref.watch(fileServiceProvider);
  return ChatNotifier(storageService, openAIService, fileService, ref);
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