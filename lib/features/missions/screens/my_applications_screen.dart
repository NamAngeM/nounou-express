import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_loader.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../data/models/application_model.dart';
import '../../../data/providers/data_providers.dart';

/// Suivi des candidatures envoyées par la nounou connectée :
/// statut (en attente / acceptée / refusée) et accès au suivi de
/// mission quand la candidature est acceptée.
class MyApplicationsScreen extends ConsumerWidget {
  const MyApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applicationsAsync = ref.watch(myApplicationsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text('Mes candidatures', style: AppTypography.h3),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: applicationsAsync.when(
        loading: () => const AppLoader(),
        error: (e, _) => ErrorState(
          onRetry: () => ref.invalidate(myApplicationsProvider),
        ),
        data: (applications) => applications.isEmpty
            ? EmptyState(
                icon: Icons.work_outline_rounded,
                title: 'Aucune candidature',
                description:
                    'Vos candidatures apparaîtront ici avec leur statut. '
                    'Parcourez les annonces pour postuler.',
                actionLabel: 'Voir les annonces',
                onAction: () => context.go('/search'),
              )
            : RefreshIndicator(
                onRefresh: () => ref.refresh(myApplicationsProvider.future),
                color: AppColors.primary,
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.lg,
                    AppSpacing.xl,
                    AppSpacing.huge,
                  ),
                  itemCount: applications.length,
                  itemBuilder: (context, index) =>
                      _ApplicationCard(application: applications[index])
                          .animate()
                          .fadeIn(delay: (index * 60).ms, duration: 350.ms)
                          .slideY(begin: 0.06, end: 0),
                ),
              ),
      ),
    );
  }
}

class _ApplicationCard extends ConsumerWidget {
  final ApplicationModel application;
  const _ApplicationCard({required this.application});

  String get _statusLabel => switch (application.status) {
    ApplicationStatus.pending => 'En attente',
    ApplicationStatus.accepted => 'Acceptée',
    ApplicationStatus.rejected => 'Refusée',
  };

  StatusBadgeVariant get _statusVariant => switch (application.status) {
    ApplicationStatus.pending => StatusBadgeVariant.warning,
    ApplicationStatus.accepted => StatusBadgeVariant.success,
    ApplicationStatus.rejected => StatusBadgeVariant.danger,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mission = ref
        .watch(missionByIdProvider(application.missionId))
        .valueOrNull;
    final isAccepted = application.status == ApplicationStatus.accepted;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.cardBorderRadius,
        boxShadow: AppColors.cardShadow,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  mission?.parentName ?? 'Mission',
                  style: AppTypography.h4,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              StatusBadge(label: _statusLabel, variant: _statusVariant),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          if (mission != null) ...[
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    mission.address,
                    style: AppTypography.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
          ],
          Text(
            'Envoyée le '
            '${AppFormatters.formatShortDate(application.appliedAt)}',
            style: AppTypography.small.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          if (isAccepted) ...[
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.push(
                  '/missions/${application.missionId}/tracking',
                ),
                icon: const Icon(Icons.route_rounded, size: 18),
                label: const Text('Suivre la mission'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppSpacing.buttonBorderRadius,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
