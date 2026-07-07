import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

class StatsCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData? icon;
  final Color? iconColor;

  /// Rend la carte cliquable (ex: « Revenus / mois » → portefeuille).
  final VoidCallback? onTap;

  const StatsCard({
    super.key,
    required this.value,
    required this.label,
    this.icon,
    this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.cardBorderRadius,
        boxShadow: AppColors.cardShadow,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: iconColor ?? AppColors.primary, size: 24),
            const SizedBox(height: AppSpacing.sm),
          ],
          Text(
            value,
            style: AppTypography.h2.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );

    if (onTap == null) return card;
    return InkWell(
      onTap: onTap,
      borderRadius: AppSpacing.cardBorderRadius,
      child: card,
    );
  }
}
