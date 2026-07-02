import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/mock/mock_data.dart';
import '../widgets/stats_card.dart';

class NannyDashboardScreen extends StatefulWidget {
  const NannyDashboardScreen({super.key});

  @override
  State<NannyDashboardScreen> createState() => _NannyDashboardScreenState();
}

class _NannyDashboardScreenState extends State<NannyDashboardScreen> {
  bool _isAvailable = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Tableau de bord"),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
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
            _buildStatsGrid(),
            const SizedBox(height: AppSpacing.xl),
            _buildSectionTitle("Prochaines missions"),
            const SizedBox(height: AppSpacing.md),
            _buildUpcomingMissions(),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Bonjour, Marie 👋", style: AppTypography.h1),
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
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: _isAvailable
            ? Colors.green.withValues(alpha: 0.1)
            : AppColors.border.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isAvailable ? Colors.green : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _isAvailable ? Icons.check_circle : Icons.do_not_disturb_on,
            color: _isAvailable ? Colors.green : AppColors.textSecondary,
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
            activeTrackColor: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    final stats = MockData.nannyStats;
    return GridView.count(
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
          iconColor: Colors.blue,
        ),
        StatsCard(
          value: stats["earningsMonth"],
          label: "Revenus / mois",
          icon: Icons.payments_outlined,
          iconColor: Colors.green,
        ),
        StatsCard(
          value: stats["avgRating"],
          label: "Note moyenne",
          icon: Icons.star_border,
          iconColor: Colors.orange,
        ),
        StatsCard(
          value: stats["acceptanceRate"],
          label: "Taux d'acceptation",
          icon: Icons.check_circle_outline,
          iconColor: Colors.teal,
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: AppTypography.h3);
  }

  Widget _buildUpcomingMissions() {
    final missions = MockData.upcomingMissions;
    return Column(children: missions.map((m) => _buildMissionCard(m)).toList());
  }

  Widget _buildMissionCard(Map<String, dynamic> mission) {
    final bool isPending = mission["status"] == "En attente";
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
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
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isPending
                      ? Colors.orange.withValues(alpha: 0.1)
                      : Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  mission["status"],
                  style: AppTypography.small.copyWith(
                    color: isPending ? Colors.orange : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            mission["parentName"],
            style: AppTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
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
          const SizedBox(height: AppSpacing.md),
          if (isPending)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      side: const BorderSide(color: AppColors.danger),
                    ),
                    child: const Text("Refuser"),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text("Accepter"),
                  ),
                ),
              ],
            )
          else
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                child: const Text("Voir les détails"),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRecentReviews() {
    final reviews = MockData.recentReviews;
    return Column(children: reviews.map((r) => _buildReviewCard(r)).toList());
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
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
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (index) => Icon(
                    Icons.star,
                    size: 14,
                    color: index < review["rating"]
                        ? Colors.orange
                        : AppColors.border,
                  ),
                ),
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
