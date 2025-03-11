import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/qa_pair.dart';
import '../providers/qa_provider.dart';
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
              backgroundColor: Colors.red,
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
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.qaTabLabel),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showCreateQAPairDialog,
            tooltip: l10n.createQAPairButton,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
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
          
          // Q&A pairs list
          Expanded(
            child: qaPairs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.question_answer_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? l10n.noQAPairsYet
                              : l10n.noQAPairsMatch,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
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
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: qaPairs.length,
                    itemBuilder: (context, index) {
                      final qaPair = qaPairs[index];
                      return QAPairCard(
                        qaPair: qaPair,
                        onEdit: () => _showEditQAPairDialog(qaPair),
                        onDelete: () => _showDeleteQAPairDialog(qaPair),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
} 