import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/message.dart';
import 'dart:math' as Math;

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
      
      // Add user and assistant messages
      formattedMessages.addAll(messages.map((message) {
        return {
          'role': message.role.toString().split('.').last,
          'content': message.content,
        };
      }));
      
      // If there's a file, use the chat completions with file API
      if (filePath != null && filePath.isNotEmpty) {
        return await _sendMessageWithFile(formattedMessages, filePath, model);
      }
      
      // Otherwise use the standard chat completions API
      final response = await _dio.post(
        '$_baseUrl/chat/completions',
        data: {
          'model': model,
          'messages': formattedMessages,
        },
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
} 