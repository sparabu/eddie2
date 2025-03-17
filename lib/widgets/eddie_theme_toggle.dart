import 'package:flutter/material.dart';
import '../theme/eddie_colors.dart';
import '../theme/eddie_constants.dart';
import '../theme/eddie_text_styles.dart';
import '../theme/eddie_theme.dart';

/// Eddie Theme Toggle
///
/// A widget that allows users to toggle between system, light, and dark themes.
class EddieThemeToggle extends StatelessWidget {
  final EddieThemeMode currentThemeMode;
  final Function(EddieThemeMode) onThemeModeChanged;
  final bool showLabel;
  final bool isCompact;

  const EddieThemeToggle({
    Key? key,
    required this.currentThemeMode,
    required this.onThemeModeChanged,
    this.showLabel = true,
    this.isCompact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: EddieColors.getSurfaceVariant(context),
        borderRadius: BorderRadius.circular(EddieConstants.borderRadiusMedium),
        border: Border.all(
          color: EddieColors.getOutline(context),
          width: 1,
        ),
      ),
      child: isCompact ? _buildCompactToggle(context) : _buildFullToggle(context),
    );
  }

  Widget _buildCompactToggle(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildThemeButton(
          context,
          EddieThemeMode.system,
          Icons.settings_suggest_outlined,
          'System',
        ),
        _buildDivider(context),
        _buildThemeButton(
          context,
          EddieThemeMode.light,
          Icons.light_mode_outlined,
          'Light',
        ),
        _buildDivider(context),
        _buildThemeButton(
          context,
          EddieThemeMode.dark,
          Icons.dark_mode_outlined,
          'Dark',
        ),
      ],
    );
  }

  Widget _buildFullToggle(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildThemeButton(
          context,
          EddieThemeMode.system,
          Icons.settings_suggest_outlined,
          'System',
        ),
        _buildDivider(context),
        _buildThemeButton(
          context,
          EddieThemeMode.light,
          Icons.light_mode_outlined,
          'Light',
        ),
        _buildDivider(context),
        _buildThemeButton(
          context,
          EddieThemeMode.dark,
          Icons.dark_mode_outlined,
          'Dark',
        ),
      ],
    );
  }

  Widget _buildThemeButton(
    BuildContext context,
    EddieThemeMode mode,
    IconData icon,
    String label,
  ) {
    final isSelected = currentThemeMode == mode;
    
    return InkWell(
      onTap: () => onThemeModeChanged(mode),
      borderRadius: BorderRadius.circular(EddieConstants.borderRadiusSmall),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? EddieConstants.spacingSm : EddieConstants.spacingMd,
          vertical: EddieConstants.spacingSm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? EddieColors.getPrimary(context).withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(EddieConstants.borderRadiusSmall),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: EddieConstants.iconSizeSmall,
              color: isSelected
                  ? EddieColors.getPrimary(context)
                  : EddieColors.getTextSecondary(context),
            ),
            if (showLabel && !isCompact) ...[
              SizedBox(width: EddieConstants.spacingXs),
              Text(
                label,
                style: EddieTextStyles.body2(context).copyWith(
                  color: isSelected
                      ? EddieColors.getPrimary(context)
                      : EddieColors.getTextSecondary(context),
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return SizedBox(
      height: isCompact ? 24 : 28,
      child: VerticalDivider(
        width: 1,
        thickness: 1,
        color: EddieColors.getOutline(context),
      ),
    );
  }
} 