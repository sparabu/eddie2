import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import '../models/qa_pair.dart';
import '../utils/theme.dart';

class QAPairCard extends StatelessWidget {
  final QAPair qaPair;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  
  const QAPairCard({
    Key? key,
    required this.qaPair,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final dateFormat = DateFormat('MMM d, yyyy');
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.question_answer, size: 20, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    qaPair.question,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 18),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: onEdit,
                  tooltip: 'Edit',
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: onDelete,
                  tooltip: 'Delete',
                ),
              ],
            ),
            const Divider(),
            MarkdownBody(
              data: qaPair.answer,
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
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Created: ${dateFormat.format(qaPair.createdAt)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                  ),
                ),
                if (qaPair.tags.isNotEmpty)
                  Wrap(
                    spacing: 4,
                    children: qaPair.tags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDarkMode 
                              ? Colors.grey.shade800 
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            fontSize: 10,
                            color: isDarkMode 
                                ? Colors.grey.shade300 
                                : Colors.grey.shade700,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 