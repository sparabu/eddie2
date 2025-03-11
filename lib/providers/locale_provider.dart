import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleNotifier extends StateNotifier<Locale> {
  static const String _localeKey = 'locale';
  
  LocaleNotifier() : super(const Locale('en')) {
    _loadLocale();
  }
  
  Future<void> _loadLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final localeString = prefs.getString(_localeKey);
      
      if (localeString != null) {
        state = Locale(localeString);
      }
    } catch (e) {
      print('Error loading locale: $e');
    }
  }
  
  Future<void> setLocale(Locale locale) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, locale.languageCode);
      state = locale;
    } catch (e) {
      print('Error saving locale: $e');
    }
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

// List of supported locales
final supportedLocales = [
  const Locale('en'), // English
  const Locale('ko'), // Korean
];

// Map of locale names for display
final localeNames = {
  'en': 'English',
  'ko': '한국어',
}; 