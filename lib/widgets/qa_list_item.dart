import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/qa_pair.dart';
import '../theme/eddie_colors.dart';
import '../theme/eddie_constants.dart';
import '../theme/eddie_text_styles.dart';

class QAListItem extends StatelessWidget {
  final QAPair qaPair;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  
  const QAListItem({
    Key? key,
    required this.qaPair,
    this.isSelected = false,
    required this.onTap,
    this.onDelete,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: EddieConstants.spacingXs,
        horizontal: EddieConstants.spacingSm,
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: EddieConstants.spacingMd,
          vertical: EddieConstants.spacingXs,
        ),
        dense: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(EddieConstants.borderRadiusMedium),
        ),
        tileColor: isSelected 
            ? EddieColors.getSurfaceVariant(context)
            : null,
        hoverColor: EddieColors.getSurfaceVariant(context),
        leading: Icon(
          Icons.question_answer,
          size: 20,
          color: isSelected
              ? EddieColors.getPrimary(context)
              : EddieColors.getTextSecondary(context),
        ),
        title: Text(
          qaPair.question,
          style: EddieTextStyles.body1(context).copyWith(
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        selected: isSelected,
        onTap: onTap,
        trailing: onDelete != null
            ? IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  size: 20,
                  color: EddieColors.getTextSecondary(context),
                ),
                onPressed: onDelete,
                tooltip: l10n.deleteQAPair,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              )
            : null,
      ),
    );
  }
} 