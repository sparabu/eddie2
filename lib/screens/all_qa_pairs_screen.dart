import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/qa_pair.dart';
import '../widgets/qa_list_item.dart';
import '../theme/eddie_theme.dart';
import '../theme/eddie_text_styles.dart';
import '../widgets/eddie_logo.dart';

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
            style: EddieTextStyles.heading2(context),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: qaPairs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const EddieLogo(size: 64),
                        const SizedBox(height: 24),
                        Text(
                          l10n.noQAPairsYet,
                          style: EddieTextStyles.heading2(context),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Create your first Q&A pair to get started.",
                          style: EddieTextStyles.body2(context),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: qaPairs.length,
                    itemBuilder: (context, index) {
                      final qaPair = qaPairs[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Card(
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: qaPair.id == selectedQAPairId
                                ? BorderSide(color: EddieTheme.getPrimary(context), width: 2)
                                : BorderSide.none,
                          ),
                          child: QAListItem(
                            qaPair: qaPair,
                            isSelected: qaPair.id == selectedQAPairId,
                            onTap: () => onSelectQAPair(qaPair),
                            onDelete: () => onDeleteQAPair(qaPair.id),
                          ),
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

