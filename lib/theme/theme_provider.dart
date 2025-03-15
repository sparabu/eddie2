import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'eddie_theme.dart';

/// Theme mode provider
final themeModeProvider = StateProvider<ThemeMode>((ref) {
  return EddieTheme.themeMode;
});

/// Theme provider
final themeProvider = Provider<ThemeData>((ref) {
  final themeMode = ref.watch(themeModeProvider);
  return themeMode == ThemeMode.dark ? EddieTheme.darkTheme : EddieTheme.lightTheme;
});

/// Theme controller
class ThemeController extends StateNotifier<ThemeMode> {
  ThemeController() : super(EddieTheme.themeMode);

  void toggleTheme() {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    EddieTheme.setTheme(state);
  }

  void setTheme(ThemeMode mode) {
    state = mode;
    EddieTheme.setTheme(mode);
  }
}

/// Theme controller provider
final themeControllerProvider = StateNotifierProvider<ThemeController, ThemeMode>((ref) {
  return ThemeController();
});

