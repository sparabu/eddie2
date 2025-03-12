import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/qa_pair.dart';
import '../widgets/qa_list_item.dart';
import '../utils/theme.dart';

class AllQAPairsScreen extends StatelessWidget {
  final List<QAPair> qaPairs;
  final String? selectedQAPairId;
  final Function(QAPair) onSelectQAPair;
  final Function(String) onDeleteQAPair;
  
  const AllQAPairsScreen({
    Key? key,
    required this.qaPairs,
    required this.selectedQAPairId,
    required this.onSelectQAPair,
    required this.onDeleteQAPair,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.qaTabLabel,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: qaPairs.isEmpty
                ? Center(
                    child: Text(
                      l10n.noQAPairsYet,
                      style: TextStyle(
                        fontSize: 16,
                        color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: qaPairs.length,
                    itemBuilder: (context, index) {
                      final qaPair = qaPairs[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: QAListItem(
                          qaPair: qaPair,
                          isSelected: qaPair.id == selectedQAPairId,
                          onTap: () => onSelectQAPair(qaPair),
                          onDelete: () => onDeleteQAPair(qaPair.id),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
} 