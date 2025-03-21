import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/qa_pair.dart';
import '../providers/qa_provider.dart';
import '../theme/eddie_theme.dart';
import '../theme/eddie_colors.dart';
import '../theme/eddie_text_styles.dart';
import '../widgets/eddie_logo.dart';
import '../widgets/qa_pair_card.dart';
import '../widgets/qa_pair_form.dart';

class QAScreen extends ConsumerStatefulWidget {
  const QAScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<QAScreen> createState() => _QAScreenState();
}

class _QAScreenState extends ConsumerState<QAScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  void _showCreateQAPairDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.createQAPairTitle),
        content: SizedBox(
          width: 600,
          child: QAPairForm(
            onSave: (qaPair) {
              ref.read(qaPairProvider.notifier).addQAPair(qaPair);
              Navigator.of(context).pop();
            },
          ),
        ),
      ),
    );
  }
  
  void _showEditQAPairDialog(QAPair qaPair) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.editQAPairTitle),
        content: SizedBox(
          width: 600,
          child: QAPairForm(
            initialQAPair: qaPair,
            onSave: (updatedQAPair) {
              ref.read(qaPairProvider.notifier).updateQAPair(updatedQAPair);
              Navigator.of(context).pop();
            },
          ),
        ),
      ),
    );
  }
  
  void _showDeleteQAPairDialog(QAPair qaPair) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteQAPairTitle),
        content: Text(l10n.deleteQAPairMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancelButton),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(qaPairProvider.notifier).deleteQAPair(qaPair.id);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: EddieColors.getColor(context, Colors.red.shade200, Colors.red.shade800),
            ),
            child: Text(l10n.deleteButton),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final qaPairs = ref.watch(filteredQAPairsProvider(_searchQuery));
    final selectedQAPairId = ref.watch(selectedQAPairIdProvider);
    final l10n = AppLocalizations.of(context)!;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Find the selected QA pair
    QAPair? selectedQAPair;
    if (selectedQAPairId != null) {
      selectedQAPair = qaPairs.firstWhere(
        (qaPair) => qaPair.id == selectedQAPairId,
        orElse: () => qaPairs.isNotEmpty ? qaPairs.first : QAPair(question: "", answer: ""),
      );
    } else if (qaPairs.isNotEmpty) {
      selectedQAPair = qaPairs.first;
      // Update the selected QA pair ID
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(selectedQAPairIdProvider.notifier).state = selectedQAPair!.id;
      });
    }
    
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: l10n.searchQAPairsHint,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _showCreateQAPairDialog,
                icon: const Icon(Icons.add),
                label: Text(l10n.createQAPairButton),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),
        ),
        
        // Q&A pairs content
        Expanded(
          child: qaPairs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const EddieLogo(size: 64),
                      const SizedBox(height: 24),
                      Text(
                        _searchQuery.isEmpty
                            ? l10n.noQAPairsYet
                            : l10n.noQAPairsMatch,
                        style: EddieTextStyles.heading2(context),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _searchQuery.isEmpty
                            ? "Create your first Q&A pair by clicking the button above."
                            : "Try a different search term.",
                        style: EddieTextStyles.body2(context),
                        textAlign: TextAlign.center,
                      ),
                      if (_searchQuery.isEmpty) ...[
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _showCreateQAPairDialog,
                          child: Text(l10n.createQAPairButton),
                        ),
                      ],
                    ],
                  ),
                )
              : selectedQAPair == null
                  ? Center(
                      child: Text(
                        l10n.selectQAPair,
                        style: EddieTextStyles.body1(context),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(16),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Question
                              Row(
                                children: [
                                  Icon(
                                    Icons.question_answer,
                                    size: 20,
                                    color: EddieColors.getPrimary(context),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      selectedQAPair.question,
                                      style: EddieTextStyles.heading3(context),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => _showEditQAPairDialog(selectedQAPair!),
                                    tooltip: l10n.editQAPair,
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline),
                                    onPressed: () => _showDeleteQAPairDialog(selectedQAPair!),
                                    tooltip: l10n.deleteQAPair,
                                  ),
                                ],
                              ),
                              
                              const Divider(),
                              
                              // Answer
                              Expanded(
                                child: SingleChildScrollView(
                                  child: MarkdownBody(
                                    data: selectedQAPair.answer,
                                    selectable: true,
                                    styleSheet: MarkdownStyleSheet(
                                      p: EddieTextStyles.body1(context),
                                      h1: EddieTextStyles.heading1(context),
                                      h2: EddieTextStyles.heading2(context),
                                      h3: EddieTextStyles.heading3(context),
                                      h4: Theme.of(context).textTheme.titleMedium,
                                      h5: Theme.of(context).textTheme.titleSmall,
                                      h6: Theme.of(context).textTheme.labelLarge,
                                      code: TextStyle(
                                        backgroundColor: isDarkMode 
                                            ? Colors.grey.shade800.withOpacity(0.7)
                                            : Colors.grey.shade200.withOpacity(0.7),
                                        fontFamily: 'monospace',
                                        fontSize: 14,
                                      ),
                                      codeblockDecoration: BoxDecoration(
                                        color: isDarkMode 
                                            ? Colors.grey.shade800.withOpacity(0.7)
                                            : Colors.grey.shade200.withOpacity(0.7),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              
                              // Tags
                              if (selectedQAPair.tags.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: selectedQAPair.tags.map((tag) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: EddieColors.getPrimary(context).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Text(
                                        tag,
                                        style: EddieTextStyles.caption(context).copyWith(
                                          color: EddieColors.getPrimary(context),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
        ),
      ],
    );
  }
}

