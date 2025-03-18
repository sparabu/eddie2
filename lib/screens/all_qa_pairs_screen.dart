import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/qa_pair.dart';
import '../widgets/qa_list_item.dart';
import '../theme/eddie_colors.dart';
import '../theme/eddie_constants.dart';
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
    final l10n = AppLocalizations.of(context)!;
    
    return Padding(
      padding: EdgeInsets.all(EddieConstants.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.qaTabLabel,
            style: EddieTextStyles.heading2(context),
          ),
          SizedBox(height: EddieConstants.spacingMd),
          Expanded(
            child: qaPairs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const EddieLogo(size: 64),
                        SizedBox(height: EddieConstants.spacingLg),
                        Text(
                          l10n.noQAPairsYet,
                          style: EddieTextStyles.body1(context).copyWith(
                            color: EddieColors.getTextSecondary(context),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: qaPairs.length,
                    itemBuilder: (context, index) {
                      final qaPair = qaPairs[index];
                      return QAListItem(
                        qaPair: qaPair,
                        isSelected: qaPair.id == selectedQAPairId,
                        onTap: () => onSelectQAPair(qaPair),
                        onDelete: () => onDeleteQAPair(qaPair.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

