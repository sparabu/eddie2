import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat.dart';
import '../models/qa_pair.dart';

class StorageService {
  static const String _chatsKey = 'chats';
  static const String _qaPairsKey = 'qa_pairs';
  
  // Chat methods
  Future<List<Chat>> getChats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final chatsJson = prefs.getStringList(_chatsKey) ?? [];
      
      return chatsJson.map((chatJson) {
        final Map<String, dynamic> chatMap = jsonDecode(chatJson);
        return Chat.fromJson(chatMap);
      }).toList();
    } catch (e) {
      print('Error loading chats: $e');
      return [];
    }
  }
  
  Future<void> saveChat(Chat chat) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final chats = await getChats();
      
      // Check if chat already exists
      final existingIndex = chats.indexWhere((c) => c.id == chat.id);
      if (existingIndex >= 0) {
        chats[existingIndex] = chat;
      } else {
        chats.add(chat);
      }
      
      final chatsJson = chats.map((chat) => jsonEncode(chat.toJson())).toList();
      await prefs.setStringList(_chatsKey, chatsJson);
    } catch (e) {
      print('Error saving chat: $e');
      throw Exception('Failed to save chat: $e');
    }
  }
  
  Future<void> deleteChat(String chatId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final chats = await getChats();
      
      final updatedChats = chats.where((chat) => chat.id != chatId).toList();
      final chatsJson = updatedChats.map((chat) => jsonEncode(chat.toJson())).toList();
      
      await prefs.setStringList(_chatsKey, chatsJson);
    } catch (e) {
      print('Error deleting chat: $e');
      throw Exception('Failed to delete chat: $e');
    }
  }
  
  // QA Pair methods
  Future<List<QAPair>> getQAPairs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final qaPairsJson = prefs.getStringList(_qaPairsKey) ?? [];
      
      return qaPairsJson.map((pairJson) {
        final Map<String, dynamic> pairMap = jsonDecode(pairJson);
        return QAPair.fromJson(pairMap);
      }).toList();
    } catch (e) {
      print('Error loading QA pairs: $e');
      return [];
    }
  }
  
  Future<void> saveQAPair(QAPair qaPair) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final qaPairs = await getQAPairs();
      
      // Check if QA pair already exists
      final existingIndex = qaPairs.indexWhere((pair) => pair.id == qaPair.id);
      if (existingIndex >= 0) {
        qaPairs[existingIndex] = qaPair;
      } else {
        qaPairs.add(qaPair);
      }
      
      final qaPairsJson = qaPairs.map((pair) => jsonEncode(pair.toJson())).toList();
      await prefs.setStringList(_qaPairsKey, qaPairsJson);
    } catch (e) {
      print('Error saving QA pair: $e');
      throw Exception('Failed to save QA pair: $e');
    }
  }
  
  Future<void> deleteQAPair(String qaPairId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final qaPairs = await getQAPairs();
      
      final updatedQAPairs = qaPairs.where((pair) => pair.id != qaPairId).toList();
      final qaPairsJson = updatedQAPairs.map((pair) => jsonEncode(pair.toJson())).toList();
      
      await prefs.setStringList(_qaPairsKey, qaPairsJson);
    } catch (e) {
      print('Error deleting QA pair: $e');
      throw Exception('Failed to delete QA pair: $e');
    }
  }
  
  Future<void> deleteAllQAPairs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_qaPairsKey);
    } catch (e) {
      print('Error deleting all QA pairs: $e');
      throw Exception('Failed to delete all QA pairs: $e');
    }
  }
  
  Future<void> deleteAllChats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_chatsKey);
    } catch (e) {
      print('Error deleting all chats: $e');
      throw Exception('Failed to delete all chats: $e');
    }
  }
} 