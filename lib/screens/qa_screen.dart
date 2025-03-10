import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Q&A Pair'),
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Q&A Pair'),
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Q&A Pair'),
        content: const Text('Are you sure you want to delete this Q&A pair?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(qaPairProvider.notifier).deleteQAPair(qaPair.id);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final qaPairs = ref.watch(filteredQAPairsProvider(_searchQuery));
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Q&A Pairs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showCreateQAPairDialog,
            tooltip: 'Create Q&A Pair',
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
                hintText: 'Search Q&A pairs',
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
                              ? 'No Q&A pairs yet'
                              : 'No Q&A pairs match your search',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                        if (_searchQuery.isEmpty) ...[
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _showCreateQAPairDialog,
                            child: const Text('Create Q&A Pair'),
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