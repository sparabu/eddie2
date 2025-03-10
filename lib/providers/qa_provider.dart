import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/qa_pair.dart';
import '../services/storage_service.dart';
import 'chat_provider.dart';

class QAPairNotifier extends StateNotifier<List<QAPair>> {
  final StorageService _storageService;
  
  QAPairNotifier(this._storageService) : super([]) {
    _loadQAPairs();
  }
  
  Future<void> _loadQAPairs() async {
    final qaPairs = await _storageService.getQAPairs();
    state = qaPairs;
  }
  
  Future<void> addQAPair(QAPair qaPair) async {
    state = [...state, qaPair];
    await _storageService.saveQAPair(qaPair);
  }
  
  Future<void> updateQAPair(QAPair qaPair) async {
    state = state.map((pair) {
      if (pair.id == qaPair.id) {
        return qaPair;
      }
      return pair;
    }).toList();
    
    await _storageService.saveQAPair(qaPair);
  }
  
  Future<void> deleteQAPair(String qaPairId) async {
    state = state.where((pair) => pair.id != qaPairId).toList();
    await _storageService.deleteQAPair(qaPairId);
  }
  
  Future<void> saveQAPairsFromChat(String chatId, List<Map<String, String>> detectedPairs) async {
    if (detectedPairs.isEmpty) {
      return;
    }
    
    final newPairs = detectedPairs.map((pair) {
      return QAPair(
        question: pair['question'] ?? '',
        answer: pair['answer'] ?? '',
      );
    }).toList();
    
    // Add all new pairs to state
    state = [...state, ...newPairs];
    
    // Save each pair to storage
    for (final pair in newPairs) {
      await _storageService.saveQAPair(pair);
    }
  }
  
  Future<void> deleteAllQAPairs() async {
    state = [];
    await _storageService.deleteAllQAPairs();
  }
}

final qaPairProvider = StateNotifierProvider<QAPairNotifier, List<QAPair>>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  return QAPairNotifier(storageService);
});

final filteredQAPairsProvider = Provider.family<List<QAPair>, String>((ref, filter) {
  final qaPairs = ref.watch(qaPairProvider);
  
  if (filter.isEmpty) {
    return qaPairs;
  }
  
  final lowerCaseFilter = filter.toLowerCase();
  return qaPairs.where((pair) {
    return pair.question.toLowerCase().contains(lowerCaseFilter) ||
           pair.answer.toLowerCase().contains(lowerCaseFilter) ||
           pair.tags.any((tag) => tag.toLowerCase().contains(lowerCaseFilter));
  }).toList();
}); 