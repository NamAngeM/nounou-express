import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

enum StatusBadgeVariant { success, warning, danger, primary, neutral }

/// Pilule de statut (« En attente », « Confirmé »...) au format unique :
/// fond surface sémantique, texte de la couleur associée, radius pilule.
class StatusBadge extends StatelessWidget {
  final String label;
  final StatusBadgeVariant variant;

  const StatusBadge({
    super.key,
    required this.label,
    this.variant = StatusBadgeVariant.neutral,
  });

  /// Variante déduite des libellés de statut utilisés dans l'app.
  factory StatusBadge.fromStatus(String status, {Key? key}) {
    final variant = switch (status.toLowerCase()) {
      'confirmé' || 'confirmée' || 'terminé' || 'terminée' =>
        StatusBadgeVariant.success,
      'en attente' || 'à venir' => StatusBadgeVariant.warning,
      'annulé' || 'annulée' || 'refusé' || 'refusée' =>
        StatusBadgeVariant.danger,
      'en cours' => StatusBadgeVariant.primary,
      _ => StatusBadgeVariant.neutral,
    };
    return StatusBadge(key: key, label: status, variant: variant);
  }

  Color get _fg => switch (variant) {
    StatusBadgeVariant.success => AppColors.success,
    StatusBadgeVariant.warning => AppColors.warning,
    StatusBadgeVariant.danger => AppColors.danger,
    StatusBadgeVariant.primary => AppColors.primary,
    StatusBadgeVariant.neutral => AppColors.textSecondary,
  };

  Color get _bg => switch (variant) {
    StatusBadgeVariant.success => AppColors.successSurface,
    StatusBadgeVariant.warning => AppColors.warningSurface,
    StatusBadgeVariant.danger => AppColors.dangerSurface,
    StatusBadgeVariant.primary => AppColors.primarySurface,
    StatusBadgeVariant.neutral => AppColors.surfaceVariant,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: AppSpacing.badgeBorderRadius,
      ),
      child: Text(
        label,
        style: AppTypography.small.copyWith(
          color: _fg,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
