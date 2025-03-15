import 'package:flutter/material.dart';
import 'eddie_colors.dart';
import 'eddie_theme_extension.dart';

/// Example widget that demonstrates how to use the Eddie design system.
///
/// This widget shows different approaches to accessing theme colors:
/// 1. Using EddieColors helper methods (recommended)
/// 2. Using the EddieThemeExtension (for advanced use cases)
/// 3. Using Theme.of(context) directly (for standard Flutter theming)
class EddieThemeExample extends StatelessWidget {
  const EddieThemeExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the EddieThemeExtension from the current theme
    final eddieTheme = Theme.of(context).extension<EddieThemeExtension>()!;

    return Scaffold(
      appBar: AppBar(
        title: Text('Eddie Design System Example'),
        // Using EddieColors helper method
        backgroundColor: EddieColors.getSurface(context),
      ),
      // Using EddieColors helper method
      backgroundColor: EddieColors.getBackground(context),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1: Using EddieColors helper methods
            Text(
              'Using EddieColors Helper Methods (Recommended)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                // Using EddieColors helper method
                color: EddieColors.getTextPrimary(context),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _ColorSwatch(
                  color: EddieColors.getPrimary(context),
                  label: 'Primary',
                ),
                const SizedBox(width: 8),
                _ColorSwatch(
                  color: EddieColors.getSecondary(context),
                  label: 'Secondary',
                ),
                const SizedBox(width: 8),
                _ColorSwatch(
                  color: EddieColors.getError(context),
                  label: 'Error',
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Section 2: Using EddieThemeExtension
            Text(
              'Using EddieThemeExtension',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                // Using EddieThemeExtension
                color: eddieTheme.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _ColorSwatch(
                  color: eddieTheme.primaryColor,
                  label: 'Primary',
                ),
                const SizedBox(width: 8),
                _ColorSwatch(
                  color: eddieTheme.secondaryColor,
                  label: 'Secondary',
                ),
                const SizedBox(width: 8),
                _ColorSwatch(
                  color: eddieTheme.errorColor,
                  label: 'Error',
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Section 3: Using Theme.of(context) directly
            Text(
              'Using Theme.of(context)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                // Using Theme.of(context)
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _ColorSwatch(
                  color: Theme.of(context).colorScheme.primary,
                  label: 'Primary',
                ),
                const SizedBox(width: 8),
                _ColorSwatch(
                  color: Theme.of(context).colorScheme.secondary,
                  label: 'Secondary',
                ),
                const SizedBox(width: 8),
                _ColorSwatch(
                  color: Theme.of(context).colorScheme.error,
                  label: 'Error',
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Example of a button using the design system
            ElevatedButton(
              onPressed: () {},
              // Button uses the theme's elevated button style
              child: Text('Primary Button'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () {},
              // Button uses the theme's outlined button style
              child: Text('Secondary Button'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {},
              // Button uses the theme's text button style
              child: Text('Tertiary Button'),
            ),
          ],
        ),
      ),
    );
  }
}

/// A simple widget to display a color swatch with a label.
class _ColorSwatch extends StatelessWidget {
  final Color color;
  final String label;

  const _ColorSwatch({
    Key? key,
    required this.color,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: EddieColors.getOutline(context),
              width: 1,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: EddieColors.getTextSecondary(context),
            fontSize: 14,
          ),
        ),
      ],
    );
  }
} 