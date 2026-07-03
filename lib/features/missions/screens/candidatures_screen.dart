import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/application_model.dart';
import '../../../data/models/mission_model.dart';
import '../../../data/providers/data_providers.dart';

// ── Sort options ──────────────────────────────────────────────────────────────
enum _SortOption { rating, price, speed }

// ── Screen ────────────────────────────────────────────────────────────────────
class CandidaturesScreen extends ConsumerStatefulWidget {
  final String missionId;

  const CandidaturesScreen({super.key, required this.missionId});

  @override
  ConsumerState<CandidaturesScreen> createState() => _CandidaturesScreenState();
}

class _CandidaturesScreenState extends ConsumerState<CandidaturesScreen> {
  _SortOption _sortOption = _SortOption.rating;

  // État UI transitoire : surcouche locale sur les données des providers
  // (le repository n'expose pas encore de mutation sur les candidatures).
  String? _acceptedApplicationId;
  final Set<String> _rejectedApplicationIds = {};

  List<ApplicationModel> _visibleApplications(List<ApplicationModel> all) {
    final applications = all
        .where((a) => !_rejectedApplicationIds.contains(a.id))
        .map(
          (a) => a.id == _acceptedApplicationId
              ? a.copyWith(status: ApplicationStatus.accepted)
              : a,
        )
        .toList();
    switch (_sortOption) {
      case _SortOption.rating:
        applications.sort((a, b) => b.nannyRating.compareTo(a.nannyRating));
      case _SortOption.price:
        applications.sort((a, b) => a.hourlyRate.compareTo(b.hourlyRate));
      case _SortOption.speed:
        applications.sort((a, b) => a.appliedAt.compareTo(b.appliedAt));
    }
    return applications;
  }

  void _setSortOption(_SortOption option) {
    setState(() => _sortOption = option);
  }

  void _acceptApplication(ApplicationModel app) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.cardBorderRadius,
        ),
        title: Text('Confirmer la sélection', style: AppTypography.h3),
        content: Text(
          'Voulez-vous accepter la candidature de ${app.nannyName} ?',
          style: AppTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Annuler',
              style: AppTypography.labelMd.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              shape: RoundedRectangleBorder(
                borderRadius: AppSpacing.buttonBorderRadius,
              ),
              elevation: 0,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Accepter', style: AppTypography.buttonLabelSm),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final mission = await ref.read(
        missionByIdProvider(widget.missionId).future,
      );
      final updated = mission.copyWith(
        status: MissionStatus.confirmed,
        selectedNannyId: app.nannyId,
      );
      await ref.read(missionRepositoryProvider).updateMission(updated);
      ref.invalidate(missionByIdProvider(widget.missionId));
      ref.invalidate(missionsProvider);
      if (!mounted) return;
      setState(() => _acceptedApplicationId = app.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: AppSpacing.inputBorderRadius,
            ),
            content: Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.surface,
                  size: 18,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    '${app.nannyName} a été acceptée !',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.surface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }
  }

  void _rejectApplication(ApplicationModel app) {
    setState(() {
      _rejectedApplicationIds.add(app.id);
      if (_acceptedApplicationId == app.id) {
        _acceptedApplicationId = null;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.dangerSurface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.inputBorderRadius,
        ),
        content: Text(
          'Candidature de ${app.nannyName} refusée.',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.danger),
        ),
      ),
    );
  }

  // ── Widgets ───────────────────────────────────────────────────────────────
  Widget _buildMissionSummaryCard(MissionModel? mission) {
    if (mission == null) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.xl,
        0,
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.cardBorderRadius,
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: mission.isUrgent
                      ? AppColors.dangerSurface
                      : AppColors.accentSurface,
                  borderRadius: AppSpacing.chipBorderRadius,
                ),
                child: Text(
                  mission.isUrgent ? 'Urgente' : 'Planifiée',
                  style: AppTypography.small.copyWith(
                    color: mission.isUrgent
                        ? AppColors.danger
                        : AppColors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '${mission.childrenSummary.length} enfant'
                '${mission.childrenSummary.length > 1 ? 's' : ''}',
                style: AppTypography.caption,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              const Icon(
                Icons.location_on_rounded,
                size: 14,
                color: AppColors.primary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  mission.address,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              const Icon(
                Icons.schedule_rounded,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '${mission.startTime} – ${mission.endTime}',
                style: AppTypography.bodySmall,
              ),
              const SizedBox(width: AppSpacing.md),
              const Icon(
                Icons.calendar_today_rounded,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '${mission.date.day.toString().padLeft(2, '0')}/'
                '${mission.date.month.toString().padLeft(2, '0')}/'
                '${mission.date.year}',
                style: AppTypography.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSortRow() {
    const options = [
      (_SortOption.rating, 'Note'),
      (_SortOption.price, 'Tarif'),
      (_SortOption.speed, 'Rapidité'),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          Text('Trier par :', style: AppTypography.labelMd),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: options.map((opt) {
                  final isSelected = _sortOption == opt.$1;
                  return Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: GestureDetector(
                      onTap: () => _setSortOption(opt.$1),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.surfaceVariant,
                          borderRadius: AppSpacing.chipBorderRadius,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.border,
                          ),
                        ),
                        child: Text(
                          opt.$2,
                          style: AppTypography.labelMd.copyWith(
                            color: isSelected
                                ? AppColors.surface
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.inbox_rounded,
                size: 40,
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Aucune candidature pour l\'instant',
              style: AppTypography.h4.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Les nounous disponibles pourront postuler à votre annonce.',
              style: AppTypography.caption,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mission = ref
        .watch(missionByIdProvider(widget.missionId))
        .asData
        ?.value;
    final applicationsAsync = ref.watch(
      missionApplicationsProvider(widget.missionId),
    );
    final count = _visibleApplications(
      applicationsAsync.asData?.value ?? const [],
    ).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Candidatures', style: AppTypography.h4),
            Text(
              '$count candidature'
              '${count > 1 ? 's' : ''}',
              style: AppTypography.caption,
            ),
          ],
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.border),
        ),
      ),
      body: applicationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            'Erreur de chargement des candidatures',
            style: AppTypography.bodyMedium,
          ),
        ),
        data: (allApplications) {
          final applications = _visibleApplications(allApplications);
          return applications.isEmpty
              ? Column(
                  children: [
                    _buildMissionSummaryCard(mission),
                    Expanded(child: _buildEmptyState()),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMissionSummaryCard(mission),
                    _buildSortRow(),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.xl,
                          AppSpacing.sm,
                          AppSpacing.xl,
                          AppSpacing.xl,
                        ),
                        itemCount: applications.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: AppSpacing.md),
                        itemBuilder: (ctx, i) => _ApplicationCard(
                          application: applications[i],
                          onAccept: () => _acceptApplication(applications[i]),
                          onReject: () => _rejectApplication(applications[i]),
                        ),
                      ),
                    ),
                  ],
                );
        },
      ),
    );
  }
}

// ── Application card ──────────────────────────────────────────────────────────
class _ApplicationCard extends StatelessWidget {
  final ApplicationModel application;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _ApplicationCard({
    required this.application,
    required this.onAccept,
    required this.onReject,
  });

  Widget _buildStars(double rating) {
    final fullStars = rating.floor();
    final hasHalf = (rating - fullStars) >= 0.5;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (i) {
          if (i < fullStars) {
            return const Icon(
              Icons.star_rounded,
              color: AppColors.gold,
              size: 14,
            );
          } else if (i == fullStars && hasHalf) {
            return const Icon(
              Icons.star_half_rounded,
              color: AppColors.gold,
              size: 14,
            );
          } else {
            return const Icon(
              Icons.star_outline_rounded,
              color: AppColors.gold,
              size: 14,
            );
          }
        }),
        const SizedBox(width: AppSpacing.xs),
        Text(
          rating.toStringAsFixed(1),
          style: AppTypography.small.copyWith(
            color: AppColors.gold,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text('(${application.nannyReviewCount})', style: AppTypography.small),
      ],
    );
  }

  Widget _buildSkillChips(List<String> skills) {
    const maxVisible = 3;
    final visible = skills.take(maxVisible).toList();
    final extra = skills.length - maxVisible;
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        ...visible.map(
          (s) => Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: AppColors.accentSurface,
              borderRadius: AppSpacing.chipBorderRadius,
            ),
            child: Text(
              s,
              style: AppTypography.small.copyWith(
                color: AppColors.accent,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        if (extra > 0)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: AppSpacing.chipBorderRadius,
            ),
            child: Text(
              '+$extra autres',
              style: AppTypography.small.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAccepted = application.status == ApplicationStatus.accepted;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.cardBorderRadius,
        border: Border.all(
          color: isAccepted ? AppColors.success : AppColors.border,
          width: isAccepted ? 1.5 : 1,
        ),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isAccepted)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              decoration: const BoxDecoration(
                color: AppColors.successSurface,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppSpacing.cardRadius),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.success,
                    size: 14,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'Candidature acceptée',
                    style: AppTypography.small.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.primarySurface,
                  backgroundImage: application.nannyPhotoUrl.isNotEmpty
                      ? NetworkImage(application.nannyPhotoUrl)
                      : null,
                  child: application.nannyPhotoUrl.isEmpty
                      ? Text(
                          application.nannyName.isNotEmpty
                              ? application.nannyName[0].toUpperCase()
                              : '?',
                          style: AppTypography.h3.copyWith(
                            color: AppColors.primary,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: AppSpacing.md),
                // Center info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(application.nannyName, style: AppTypography.h4),
                      const SizedBox(height: AppSpacing.xs),
                      _buildStars(application.nannyRating),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '${application.hourlyRate.toInt()} ${AppConstants.currency}/h',
                        style: AppTypography.labelMd.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '${application.experienceYears} an'
                        '${application.experienceYears > 1 ? 's' : ''} d\'expérience',
                        style: AppTypography.bodySmall,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _buildSkillChips(application.skills),
                      if (application.message != null) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.inputRadius - 2,
                            ),
                          ),
                          child: Text(
                            '"${application.message!}"',
                            style: AppTypography.caption.copyWith(
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.md),
                      // Action buttons
                      if (!isAccepted)
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: onAccept,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.success,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: AppSpacing.sm,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: AppSpacing.buttonBorderRadius,
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  'Accepter',
                                  style: AppTypography.buttonLabelSm,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: onReject,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.danger,
                                  side: const BorderSide(
                                    color: AppColors.danger,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: AppSpacing.sm,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: AppSpacing.buttonBorderRadius,
                                  ),
                                ),
                                child: Text(
                                  'Refuser',
                                  style: AppTypography.buttonLabelSm.copyWith(
                                    color: AppColors.danger,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      else
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: onReject,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.textSecondary,
                              side: const BorderSide(color: AppColors.border),
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.sm,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: AppSpacing.buttonBorderRadius,
                              ),
                            ),
                            child: Text(
                              'Annuler la sélection',
                              style: AppTypography.buttonLabelSm.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
