import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/openai_service.dart';

class SettingsState {
  final bool isDarkMode;
  final String? apiKey;
  final String selectedModel;
  final bool hasApiKey;
  
  SettingsState({
    this.isDarkMode = false,
    this.apiKey,
    this.selectedModel = 'gpt-4o',
    this.hasApiKey = false,
  });
  
  SettingsState copyWith({
    bool? isDarkMode,
    String? apiKey,
    String? selectedModel,
    bool? hasApiKey,
  }) {
    return SettingsState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      apiKey: apiKey ?? this.apiKey,
      selectedModel: selectedModel ?? this.selectedModel,
      hasApiKey: hasApiKey ?? this.hasApiKey,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  final OpenAIService _openAIService;
  static const String _darkModeKey = 'dark_mode';
  static const String _modelKey = 'selected_model';
  
  SettingsNotifier(this._openAIService) : super(SettingsState()) {
    _loadSettings();
  }
  
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool(_darkModeKey) ?? false;
    final selectedModel = prefs.getString(_modelKey) ?? 'gpt-4o';
    final hasApiKey = await _openAIService.hasApiKey();
    
    state = state.copyWith(
      isDarkMode: isDarkMode,
      selectedModel: selectedModel,
      hasApiKey: hasApiKey,
    );
  }
  
  Future<void> toggleDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    final newValue = !state.isDarkMode;
    await prefs.setBool(_darkModeKey, newValue);
    state = state.copyWith(isDarkMode: newValue);
  }
  
  Future<void> setApiKey(String apiKey) async {
    await _openAIService.saveApiKey(apiKey);
    state = state.copyWith(
      apiKey: apiKey,
      hasApiKey: true,
    );
  }
  
  Future<void> deleteApiKey() async {
    await _openAIService.deleteApiKey();
    state = state.copyWith(
      apiKey: null,
      hasApiKey: false,
    );
  }
  
  Future<void> setSelectedModel(String model) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_modelKey, model);
    state = state.copyWith(selectedModel: model);
  }
  
  Future<String?> getApiKey() async {
    return await _openAIService.getApiKey();
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  final openAIService = ref.watch(openAIServiceProvider);
  return SettingsNotifier(openAIService);
});

final openAIServiceProvider = Provider<OpenAIService>((ref) {
  return OpenAIService();
}); 