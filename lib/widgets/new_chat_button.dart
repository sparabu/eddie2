import 'package:flutter/material.dart';
import '../theme/eddie_colors.dart';
import '../theme/eddie_text_styles.dart';
import '../theme/eddie_theme.dart';

class NewChatButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;

  const NewChatButton({
    Key? key,
    required this.onPressed,
    this.label = 'New Chat',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.add),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: EddieColors.getTextPrimary(context),
        side: BorderSide(
          color: EddieColors.getColor(
            context,
            Colors.grey.shade300,
            Colors.grey.shade700,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
} 