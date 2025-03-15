import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/qa_pair.dart';
import '../theme/eddie_colors.dart';
import '../theme/eddie_text_styles.dart';
import '../theme/eddie_theme.dart';

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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      dense: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      hoverColor: EddieColors.getColor(
        context,
        Colors.grey.shade200,
        EddieColors.primaryDark.withOpacity(0.2),
      ),
      tileColor: isSelected
          ? EddieColors.getColor(
              context,
              Colors.grey.shade200,
              EddieColors.primaryDark.withOpacity(0.2),
            )
          : null,
      leading: Icon(
        Icons.question_answer,
        size: 20,
        color: isSelected
            ? EddieColors.getPrimary(context)
            : EddieColors.getTextSecondary(context),
      ),
      title: Text(
        qaPair.question,
        style: TextStyle(
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected
              ? EddieColors.getTextPrimary(context)
              : EddieColors.getTextSecondary(context),
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        qaPair.answer,
        style: TextStyle(
          fontSize: 12,
          color: EddieColors.getTextSecondary(context),
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: onDelete != null
          ? IconButton(
              icon: const Icon(Icons.delete_outline, size: 18),
              onPressed: onDelete,
              splashRadius: 20,
              tooltip: l10n.deleteQAPair,
            )
          : null,
      onTap: onTap,
    );
  }
} 