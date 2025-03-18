import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/theme_provider.dart';
import '../theme/eddie_colors.dart';
import '../theme/eddie_text_styles.dart';
import '../theme/eddie_theme.dart';

/// Theme Toggle
/// 
/// @deprecated This is a legacy component. Use EddieThemeToggle instead.
/// A toggle button for switching between light and dark themes.
class ThemeToggle extends ConsumerWidget {
  const ThemeToggle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;
    
    return IconButton(
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return RotationTransition(
            turns: animation,
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        child: isDarkMode
            ? const Icon(
                Icons.dark_mode,
                key: ValueKey('dark'),
              )
            : const Icon(
                Icons.light_mode,
                key: ValueKey('light'),
              ),
      ),
      onPressed: () {
        ref.read(themeControllerProvider.notifier).toggleTheme();
      },
      tooltip: isDarkMode ? 'Switch to light mode' : 'Switch to dark mode',
    );
  }
}

