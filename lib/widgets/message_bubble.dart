import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/message.dart';
import '../utils/theme.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final VoidCallback? onSaveQAPair;
  
  const MessageBubble({
    Key? key,
    required this.message,
    this.onSaveQAPair,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    
    Color backgroundColor;
    if (message.isError) {
      backgroundColor = AppTheme.errorColor.withOpacity(0.1);
    } else if (isUser) {
      backgroundColor = isDarkMode 
          ? AppTheme.darkUserMessageColor 
          : AppTheme.userMessageColor;
    } else {
      backgroundColor = isDarkMode 
          ? AppTheme.darkAssistantMessageColor 
          : AppTheme.assistantMessageColor;
    }
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      color: backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isUser ? Icons.person : Icons.smart_toy_outlined,
                size: 20,
                color: isUser ? Colors.grey.shade700 : AppTheme.primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                isUser ? l10n.userLabel : l10n.assistantLabel,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isUser ? Colors.grey.shade700 : AppTheme.primaryColor,
                ),
              ),
              const Spacer(),
              if (!isUser && !message.isError && onSaveQAPair != null)
                TextButton.icon(
                  onPressed: onSaveQAPair,
                  icon: const Icon(Icons.save_alt, size: 16),
                  label: Text(l10n.saveAsQAButton),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (message.attachmentName != null) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.attach_file, size: 16),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      message.attachmentName!,
                      style: const TextStyle(fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
          SelectableText.rich(
            TextSpan(
              text: message.isError 
                  ? message.content 
                  : '',
              style: message.isError 
                  ? const TextStyle(color: AppTheme.errorColor)
                  : null,
            ),
          ),
          if (!message.isError)
            MarkdownBody(
              data: message.content,
              selectable: true,
              styleSheet: MarkdownStyleSheet(
                p: Theme.of(context).textTheme.bodyMedium,
                h1: Theme.of(context).textTheme.headlineMedium,
                h2: Theme.of(context).textTheme.headlineSmall,
                h3: Theme.of(context).textTheme.titleLarge,
                h4: Theme.of(context).textTheme.titleMedium,
                h5: Theme.of(context).textTheme.titleSmall,
                h6: Theme.of(context).textTheme.labelLarge,
                code: TextStyle(
                  backgroundColor: isDarkMode 
                      ? Colors.grey.shade800 
                      : Colors.grey.shade200,
                  fontFamily: 'monospace',
                  fontSize: 14,
                ),
                codeblockDecoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
        ],
      ),
    );
  }
} 