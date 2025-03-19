import 'package:flutter/material.dart';
import '../theme/eddie_colors.dart';
import '../theme/eddie_text_styles.dart';
import '../theme/eddie_constants.dart';

class ViewAllLink extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final bool isExpanded;
  final String? collapsedText;
  final String? expandedText;

  const ViewAllLink({
    Key? key,
    required this.onTap,
    this.text = '',
    this.isExpanded = false,
    this.collapsedText,
    this.expandedText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final displayText = isExpanded 
        ? (expandedText ?? 'Show Less') 
        : (collapsedText ?? (text.isNotEmpty ? text : 'View All'));
    
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: EddieConstants.spacingXxs),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            displayText,
            style: EddieTextStyles.caption(context).copyWith(
              color: EddieColors.getPrimary(context),
            ),
          ),
          SizedBox(width: EddieConstants.spacingXxs),
          Icon(
            isExpanded ? Icons.expand_less : Icons.expand_more,
            size: 14,
            color: EddieColors.getPrimary(context),
          ),
        ],
      ),
    );
  }
} 