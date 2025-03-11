import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/message.dart';
import 'dart:math' as Math;

class OpenAIService {
  static const String _baseUrl = 'https://api.openai.com/v1';
  static const String _apiKeyStorageKey = 'openai_api_key';
  
  final Dio _dio = Dio();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  Future<String?> getApiKey() async {
    return await _secureStorage.read(key: _apiKeyStorageKey);
  }
  
  Future<void> saveApiKey(String apiKey) async {
    await _secureStorage.write(key: _apiKeyStorageKey, value: apiKey);
  }
  
  Future<void> deleteApiKey() async {
    await _secureStorage.delete(key: _apiKeyStorageKey);
  }
  
  Future<bool> hasApiKey() async {
    final apiKey = await getApiKey();
    return apiKey != null && apiKey.isNotEmpty;
  }
  
  Future<String> sendMessage({
    required List<Message> messages,
    String? filePath,
    String model = 'gpt-4o',
    String languageCode = 'en',
  }) async {
    try {
      final apiKey = await getApiKey();
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('API key not found. Please add your OpenAI API key in settings.');
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
      final apiKey = await getApiKey();
      final file = File(filePath);
      final fileName = file.path.split('/').last;
      final bytes = await file.readAsBytes();
      final base64File = base64Encode(bytes);
      
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
      final apiKey = await getApiKey();
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('API key not found. Please add your OpenAI API key in settings.');
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
          final jsonData = jsonDecode(content);
          
          // Handle the case where the response is a JSON object with a "pairs" key
          if (jsonData is Map && jsonData.containsKey('pairs')) {
            final pairs = jsonData['pairs'] as List;
            return pairs.map<Map<String, String>>((pair) {
              return {
                'question': pair['question'] as String,
                'answer': pair['answer'] as String,
              };
            }).toList();
          } 
          // Handle the case where the response is a direct array of Q&A pairs
          else if (jsonData is List) {
            return jsonData.map<Map<String, String>>((pair) {
              return {
                'question': pair['question'] as String,
                'answer': pair['answer'] as String,
              };
            }).toList();
          }
          // If no valid format is found but we have text, create a single Q&A pair
          else if (text.isNotEmpty) {
            // Create a fallback Q&A pair from the entire message
            final lines = text.split('\n');
            String question = '';
            String answer = '';
            
            // Try to find a question in the first few lines
            for (int i = 0; i < Math.min(5, lines.length); i++) {
              if (lines[i].trim().endsWith('?')) {
                question = lines[i].trim();
                answer = text.substring(text.indexOf(question) + question.length).trim();
                break;
              }
            }
            
            // If no question found, use first line as question and rest as answer
            if (question.isEmpty && lines.isNotEmpty) {
              question = lines[0].trim();
              if (lines.length > 1) {
                answer = lines.sublist(1).join('\n').trim();
              }
            }
            
            if (question.isNotEmpty) {
              return [{
                'question': question,
                'answer': answer.isEmpty ? text : answer,
              }];
            }
          }
          
          debugPrint('No valid Q&A pairs format found in response');
        } catch (e) {
          debugPrint('Error parsing Q&A pairs: $e');
        }
      }
      
      return [];
    } catch (e) {
      debugPrint('Error detecting Q&A pairs: $e');
      return [];
    }
  }
} 