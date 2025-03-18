import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/message.dart';
import 'dart:math' as Math;
import '../services/file_service.dart';

class OpenAIService {
  static const String _baseUrl = 'https://api.openai.com/v1';
  
  final Dio _dio = Dio();
  
  // Get API key from environment variables
  String? getApiKey() {
    return dotenv.env['OPENAI_API_KEY'];
  }
  
  // These methods are kept for backward compatibility but don't actually store anything
  Future<String?> getApiKeyLegacy() async {
    return getApiKey();
  }
  
  Future<void> saveApiKey(String apiKey) async {
    // No longer saving to secure storage since we're using .env file
    debugPrint('API key management moved to .env file - this method is deprecated');
  }
  
  Future<void> deleteApiKey() async {
    // No longer deleting from secure storage since we're using .env file
    debugPrint('API key management moved to .env file - this method is deprecated');
  }
  
  Future<bool> hasApiKey() async {
    final apiKey = getApiKey();
    return apiKey != null && apiKey.isNotEmpty;
  }
  
  Future<String> sendMessage({
    required List<Message> messages,
    String? filePath,
    String? imagePath,
    String model = 'gpt-4o',
    String languageCode = 'en',
  }) async {
    try {
      final apiKey = getApiKey();
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('API key not found in .env file. Please add your OpenAI API key to the OPENAI_API_KEY variable.');
      }
      
      _dio.options.headers = {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      };
      
      // Create a system message to instruct the AI to respond in the user's language
      String languageName = 'English';
      if (languageCode == 'ko') {
        languageName = 'Korean';
      }
      
      final List<Map<String, dynamic>> formattedMessages = [];
      
      // Add system message with language instruction
      formattedMessages.add({
        'role': 'system',
        'content': 'You are a helpful assistant. Always respond in $languageName unless explicitly asked to use a different language.'
      });
      
      // Add user and assistant messages, handling images if present
      bool hasImageAttachment = false;
      
      for (final message in messages) {
        if (message.role == MessageRole.user && message.attachmentPath != null && 
            _isImageFile(message.attachmentPath!)) {
          // This is an image attachment from the user
          hasImageAttachment = true;
          final imageContent = await _formatImageMessageContent(message);
          formattedMessages.add({
            'role': message.role.toString().split('.').last,
            'content': imageContent,
          });
          debugPrint('Added message with image attachment: ${message.attachmentPath}');
        } else {
          // Regular text message
          formattedMessages.add({
            'role': message.role.toString().split('.').last,
            'content': message.content,
          });
        }
      }
      
      // If there's a text file, use the chat completions with file API
      if (filePath != null && filePath.isNotEmpty && !_isImageFile(filePath)) {
        return await _sendMessageWithFile(formattedMessages, filePath, model);
      }
      
      // If there's an image file from the current message, add it now
      if (imagePath != null && imagePath.isNotEmpty) {
        hasImageAttachment = true;
        final lastMessage = formattedMessages.last;
        if (lastMessage['role'] == 'user') {
          // Replace the last user message with one that includes the image
          formattedMessages.removeLast();
          
          // Get the last user message content
          final userContent = messages.lastWhere((m) => m.role == MessageRole.user).content;
          
          final imageContent = await _createImageMessageContent(userContent, imagePath);
          formattedMessages.add({
            'role': 'user',
            'content': imageContent
          });
          debugPrint('Added message with current image: $imagePath');
        }
      }

      // Print the first few characters of the request for debugging
      final requestData = {
        'model': model,
        'messages': formattedMessages,
      };
      
      debugPrint('Sending message to OpenAI API');
      if (hasImageAttachment) {
        debugPrint('Request includes image attachment(s)');
      }
      
      // Otherwise use the standard chat completions API
      final response = await _dio.post(
        '$_baseUrl/chat/completions',
        data: requestData,
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        final content = data['choices'][0]['message']['content'];
        return content;
      } else {
        throw Exception('Failed to get response: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorData = e.response?.data;
        final errorMessage = errorData?['error']?['message'] ?? 'Unknown API error';
        throw Exception('API Error: $errorMessage');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error sending message: $e');
    }
  }
  
  Future<String> _sendMessageWithFile(
    List<Map<String, dynamic>> messages,
    String filePath,
    String model,
  ) async {
    try {
      final apiKey = getApiKey();
      
      try {
        final file = File(filePath);
        if (!await file.exists()) {
          throw Exception('File not found at path: $filePath');
        }
        
        final fileName = file.path.split('/').last;
        final bytes = await file.readAsBytes();
        
        // Check if file is readable and not corrupted
        if (bytes.isEmpty) {
          throw Exception('File is empty or corrupted');
        }
        
        // Safely encode bytes to base64
        String base64File;
        try {
          base64File = base64Encode(bytes);
        } catch (e) {
          debugPrint('Error encoding file to base64: $e');
          throw Exception('Could not encode file: $e');
        }
        
        // Add the file content to the messages
        messages.add({
          'role': 'user',
          'content': [
            {
              'type': 'text',
              'text': 'I am sending you a file named $fileName. Please analyze it.'
            },
            {
              'type': 'file_content',
              'file_content': {
                'name': fileName,
                'data': base64File,
              }
            }
          ]
        });
      } catch (e) {
        // If there's any error with the file, add a message explaining the issue
        debugPrint('Error processing file: $e');
        messages.add({
          'role': 'user',
          'content': 'I tried to send you a file, but there was an error: $e'
        });
      }
      
      final response = await _dio.post(
        '$_baseUrl/chat/completions',
        data: {
          'model': model,
          'messages': messages,
        },
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        final content = data['choices'][0]['message']['content'];
        return content;
      } else {
        throw Exception('Failed to get response: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error sending file: $e');
    }
  }
  
  Future<List<Map<String, String>>> detectQAPairs(String text, {String languageCode = 'en'}) async {
    try {
      final apiKey = getApiKey();
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('API key not found in .env file. Please add your OpenAI API key to the OPENAI_API_KEY variable.');
      }
      
      _dio.options.headers = {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      };
      
      // Determine language for response
      String languageName = 'English';
      if (languageCode == 'ko') {
        languageName = 'Korean';
      }
      
      final response = await _dio.post(
        '$_baseUrl/chat/completions',
        data: {
          'model': 'gpt-4o',
          'messages': [
            {
              'role': 'system',
              'content': '''You are a helpful assistant that identifies question-answer pairs in text. 
Your task is to:
1. Extract all question-answer pairs from the provided text
2. Format them as a JSON object with a "pairs" key containing an array of objects with "question" and "answer" fields
3. If no clear Q&A pairs are found, still return a valid JSON with an empty "pairs" array: {"pairs": []}
4. If the text itself is in a Q&A format, treat the entire text as a single Q&A pair

Always respond in $languageName unless explicitly asked to use a different language.

Example output format:
{"pairs": [{"question": "What is X?", "answer": "X is Y."}, {"question": "How does Z work?", "answer": "Z works by..."}]}'''
            },
            {
              'role': 'user',
              'content': text
            }
          ],
          'response_format': {'type': 'json_object'}
        },
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        final content = data['choices'][0]['message']['content'];
        
        try {
          final decodedJson = jsonDecode(content);
          final pairs = decodedJson['pairs'] as List;
          return pairs.map<Map<String, String>>((pair) {
            return {
              'question': pair['question'],
              'answer': pair['answer'],
            };
          }).toList();
        } catch (e) {
          debugPrint('Error parsing JSON response: $e');
          return [];
        }
      } else {
        throw Exception('Failed to get response: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorData = e.response?.data;
        final errorMessage = errorData?['error']?['message'] ?? 'Unknown API error';
        throw Exception('API Error: $errorMessage');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error detecting Q&A pairs: $e');
    }
  }

  // Helper to check if a file is an image
  bool _isImageFile(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'webp', 'gif'].contains(extension);
  }

  // Create message content for a message that contains an image
  Future<List<Map<String, dynamic>>> _formatImageMessageContent(Message message) async {
    final content = <Map<String, dynamic>>[];
    
    // Add the text content
    content.add({
      'type': 'text',
      'text': message.content,
    });
    
    // Add the image content
    try {
      debugPrint('Processing image from path: ${message.attachmentPath}');
      final imageData = await _getImageData(message.attachmentPath!);
      debugPrint('Successfully generated image data');
      
      content.add({
        'type': 'image_url',
        'image_url': {
          'url': imageData,
        }
      });
    } catch (e) {
      debugPrint('Error processing image: $e');
      content.add({
        'type': 'text',
        'text': 'I tried to send you an image, but there was an error: $e'
      });
    }
    
    return content;
  }

  // Create a message content array that includes both text and image
  Future<List<Map<String, dynamic>>> _createImageMessageContent(String text, String imagePath) async {
    final content = <Map<String, dynamic>>[];
    
    // Add the text content
    content.add({
      'type': 'text',
      'text': text,
    });
    
    // Add the image content
    try {
      debugPrint('Processing image from path: $imagePath');
      final imageData = await _getImageData(imagePath);
      debugPrint('Successfully generated image data');
      
      content.add({
        'type': 'image_url',
        'image_url': {
          'url': imageData,
        }
      });
    } catch (e) {
      debugPrint('Error processing image: $e');
      content.add({
        'type': 'text',
        'text': 'I tried to send you an image, but there was an error: $e'
      });
    }
    
    return content;
  }

  // Convert image file to base64 data URI
  Future<String> _getImageData(String imagePath) async {
    try {
      debugPrint('Starting image processing for path: $imagePath');
      
      // Special handling for web platform
      if (kIsWeb) {
        debugPrint('Running on web platform - using alternative image handling');
        
        // Check if the path starts with 'web_file_' which indicates it's a reference to our stored web files
        if (imagePath.startsWith('web_file_')) {
          // Access the FileService to get the data URI
          final fileService = FileService();
          
          // Try multiple attempts to get the data URI
          String? dataUri;
          int retryCount = 0;
          const maxRetries = 3;
          
          while (dataUri == null && retryCount < maxRetries) {
            dataUri = fileService.getWebFileDataUri(imagePath);
            if (dataUri == null) {
              retryCount++;
              if (retryCount < maxRetries) {
                debugPrint('Retry $retryCount/$maxRetries to get web file data');
                // Small delay before retrying
                await Future.delayed(const Duration(milliseconds: 100));
              }
            }
          }
          
          if (dataUri != null) {
            debugPrint('Found data URI for web file: ${dataUri.substring(0, Math.min(30, dataUri.length))}...');
            return dataUri;
          } else {
            throw Exception('Web file data not found. The file may have been removed or the session expired.');
          }
        }
        
        // Check if the imagePath starts with "data:" which indicates it's already a data URI
        if (imagePath.startsWith('data:')) {
          debugPrint('Image is already a data URI, returning as is');
          return imagePath;
        }
        
        throw Exception('Unsupported image path format for web platform: $imagePath');
      }
      
      // Native platforms (mobile/desktop) handling
      final file = File(imagePath);
      if (!await file.exists()) {
        debugPrint('Image file not found at path: $imagePath');
        throw Exception('Image file not found at path: $imagePath');
      }
      
      debugPrint('Reading image file bytes...');
      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) {
        debugPrint('Image file is empty or corrupted: $imagePath');
        throw Exception('Image file is empty or corrupted');
      }
      
      debugPrint('Image size: ${bytes.length} bytes');
      
      // Get file extension for MIME type
      final extension = imagePath.split('.').last.toLowerCase();
      String mimeType;
      
      switch (extension) {
        case 'jpg':
        case 'jpeg':
          mimeType = 'image/jpeg';
          break;
        case 'png':
          mimeType = 'image/png';
          break;
        case 'webp':
          mimeType = 'image/webp';
          break;
        case 'gif':
          mimeType = 'image/gif';
          break;
        default:
          mimeType = 'image/jpeg'; // Default fallback
      }
      
      debugPrint('Using MIME type: $mimeType for extension: $extension');
      
      // Create base64 data URI
      debugPrint('Encoding image to base64...');
      final base64Data = base64Encode(bytes);
      final dataUri = 'data:$mimeType;base64,$base64Data';
      
      // Only log a substring of the base64 data to avoid flooding logs
      debugPrint('Base64 data URI created (first 50 chars): ${dataUri.substring(0, Math.min(50, dataUri.length))}...');
      
      return dataUri;
    } catch (e) {
      debugPrint('Error processing image file: $e');
      rethrow;
    }
  }
} 