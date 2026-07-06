import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_loader.dart';
import '../../../core/widgets/rating_stars.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../data/providers/data_providers.dart';
import '../widgets/stats_card.dart';

class NannyDashboardScreen extends ConsumerStatefulWidget {
  const NannyDashboardScreen({super.key});

  @override
  ConsumerState<NannyDashboardScreen> createState() =>
      _NannyDashboardScreenState();
}

class _NannyDashboardScreenState extends ConsumerState<NannyDashboardScreen> {
  bool _isAvailable = true;

  /// Réponses locales aux demandes de mission (le repository dashboard
  /// n'expose pas encore de mutation — même compromis que l'écran
  /// candidatures) : id mission → 'Confirmé' | 'Refusé'.
  final Map<String, String> _missionResponses = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Tableau de bord"),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            tooltip: 'Notifications',
            onPressed: () => context.push('/notifications'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: AppSpacing.xl),
            _buildAvailabilityToggle(),
            const SizedBox(height: AppSpacing.xl),
            // Les missions d'abord : c'est l'action prioritaire de la nounou.
            _buildSectionTitle("Prochaines missions"),
            const SizedBox(height: AppSpacing.md),
            _buildUpcomingMissions(),
            const SizedBox(height: AppSpacing.xl),
            _buildStatsGrid(),
            const SizedBox(height: AppSpacing.xl),
            _buildSectionTitle("Mes avis récents"),
            const SizedBox(height: AppSpacing.md),
            _buildRecentReviews(),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final firstName =
        (ref.watch(currentUserProfileProvider).valueOrNull?['firstName']
                as String?)
            ?.trim();
    final greeting = firstName == null || firstName.isEmpty
        ? "Bonjour 👋"
        : "Bonjour, $firstName 👋";
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(greeting, style: AppTypography.h1),
        Text(
          "Voici un résumé de votre activité ce mois-ci.",
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildAvailabilityToggle() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: _isAvailable
            ? AppColors.successSurface
            : AppColors.surfaceVariant,
        borderRadius: AppSpacing.cardBorderRadius,
        border: Border.all(
          color: _isAvailable ? AppColors.success : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _isAvailable ? Icons.check_circle : Icons.do_not_disturb_on,
            color: _isAvailable ? AppColors.success : AppColors.textSecondary,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isAvailable
                      ? "Vous êtes disponible"
                      : "Vous êtes indisponible",
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _isAvailable
                      ? "Les parents peuvent vous réserver."
                      : "Vous ne recevez pas de nouvelles demandes.",
                  style: AppTypography.caption,
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: _isAvailable,
            onChanged: (val) => setState(() => _isAvailable = val),
            activeTrackColor: AppColors.success,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return ref
        .watch(nannyStatsProvider)
        .when(
          data: (stats) => GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppSpacing.md,
            crossAxisSpacing: AppSpacing.md,
            childAspectRatio: 1.2,
            children: [
              StatsCard(
                value: stats["missionsMonth"],
                label: "Missions / mois",
                icon: Icons.calendar_today,
                iconColor: AppColors.primary,
              ),
              StatsCard(
                value: stats["earningsMonth"],
                label: "Revenus / mois",
                icon: Icons.payments_outlined,
                iconColor: AppColors.success,
              ),
              StatsCard(
                value: stats["avgRating"],
                label: "Note moyenne",
                icon: Icons.star_border,
                iconColor: AppColors.gold,
              ),
              StatsCard(
                value: stats["acceptanceRate"],
                label: "Taux d'acceptation",
                icon: Icons.check_circle_outline,
                iconColor: AppColors.accent,
              ),
            ],
          ),
          loading: () => const AppLoader(),
          error: (e, _) =>
              _buildErrorText("Impossible de charger les statistiques"),
        );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: AppTypography.h3);
  }

  Widget _buildErrorText(String message) {
    return Text(
      message,
      style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
    );
  }

  Widget _buildUpcomingMissions() {
    return ref
        .watch(upcomingMissionsProvider)
        .when(
          data: (missions) {
            // Les demandes en attente d'abord : c'est ce que la nounou
            // doit traiter en priorité.
            final sorted = [...missions]..sort((a, b) {
              final aPending = _statusOf(a) == "En attente" ? 0 : 1;
              final bPending = _statusOf(b) == "En attente" ? 0 : 1;
              return aPending.compareTo(bPending);
            });
            return Column(children: sorted.map(_buildMissionCard).toList());
          },
          loading: () => const AppLoader(),
          error: (e, _) =>
              _buildErrorText("Impossible de charger les missions"),
        );
  }

  /// Statut effectif d'une mission : réponse locale (accepter/refuser)
  /// prioritaire sur le statut renvoyé par le repository.
  String _statusOf(Map<String, dynamic> mission) =>
      _missionResponses["${mission["date"]}${mission["parentName"]}"] ??
      mission["status"];

  void _respondToMission(Map<String, dynamic> mission, String response) {
    setState(() {
      _missionResponses["${mission["date"]}${mission["parentName"]}"] =
          response;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          response == "Confirmé"
              ? "Mission acceptée. Le parent sera notifié."
              : "Mission refusée.",
          style: AppTypography.bodyMedium.copyWith(color: Colors.white),
        ),
        backgroundColor: response == "Confirmé"
            ? AppColors.success
            : AppColors.textSecondary,
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(
          borderRadius: AppSpacing.buttonBorderRadius,
        ),
      ),
    );
  }

  Widget _buildMissionCard(Map<String, dynamic> mission) {
    final status = _statusOf(mission);
    final bool isPending = status == "En attente";
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
              Text(
                mission["date"],
                style: AppTypography.labelMd.copyWith(
                  color: AppColors.primary,
                ),
              ),
              StatusBadge.fromStatus(status),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            mission["parentName"],
            style: AppTypography.h4,
          ),
          const SizedBox(height: AppSpacing.xs),
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
                  mission["address"],
                  style: AppTypography.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (isPending) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                // L'action destructive reste discrète : simple texte,
                // face au bouton plein « Accepter ».
                Expanded(
                  child: TextButton(
                    onPressed: () => _respondToMission(mission, "Refusé"),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                    ),
                    child: const Text("Refuser"),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () => _respondToMission(mission, "Confirmé"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppSpacing.buttonBorderRadius,
                      ),
                    ),
                    child: const Text("Accepter"),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRecentReviews() {
    return ref
        .watch(recentReviewsProvider)
        .when(
          data: (reviews) =>
              Column(children: reviews.map(_buildReviewCard).toList()),
          loading: () => const AppLoader(),
          error: (e, _) => _buildErrorText("Impossible de charger les avis"),
        );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
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
              Text(
                review["author"],
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              RatingStars(
                rating: (review["rating"] as num).toDouble(),
                size: 14,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            review["date"],
            style: AppTypography.small.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(review["comment"], style: AppTypography.caption),
        ],
      ),
    );
  }
}
