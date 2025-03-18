import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/chat.dart';
import '../theme/eddie_colors.dart';
import '../theme/eddie_constants.dart';
import '../theme/eddie_text_styles.dart';

class ChatListItem extends StatelessWidget {
  final Chat chat;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  
  const ChatListItem({
    Key? key,
    required this.chat,
    required this.isSelected,
    required this.onTap,
    required this.onDelete,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: EddieConstants.spacingXs,
        horizontal: EddieConstants.spacingSm
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          hoverColor: EddieColors.getSurfaceVariant(context),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          borderRadius: BorderRadius.circular(EddieConstants.borderRadiusMedium),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected 
                  ? EddieColors.getSurfaceVariant(context)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(EddieConstants.borderRadiusMedium),
              border: isSelected
                  ? Border.all(
                      color: EddieColors.getPrimary(context),
                      width: 1,
                    )
                  : null,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: EddieConstants.spacingMd,
              vertical: EddieConstants.spacingSm
            ),
            child: Row(
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 20,
                  color: isSelected
                      ? EddieColors.getPrimary(context)
                      : EddieColors.getTextSecondary(context),
                ),
                SizedBox(width: EddieConstants.spacingSm),
                Expanded(
                  child: Text(
                    chat.title,
                    style: EddieTextStyles.body1(context).copyWith(
                      color: isSelected
                          ? EddieColors.getTextPrimary(context)
                          : EddieColors.getTextPrimary(context),
                      fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: EddieColors.getTextSecondary(context),
                  ),
                  onPressed: onDelete,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: l10n.deleteChat,
                  splashRadius: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

