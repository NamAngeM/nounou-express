import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_loader.dart';
import '../../../core/widgets/avatar_widget.dart';
import '../../../core/widgets/nanny_card.dart';
import '../../../core/widgets/rating_stars.dart';
import '../../../data/models/mission_model.dart';
import '../../../data/models/nanny_model.dart';
import '../../../data/providers/data_providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedCategory = 0;

  static const _categories = [
    ('Toutes', Icons.apps_rounded),
    ('Disponibles', Icons.check_circle_outline_rounded),
    ('Top Nounous', Icons.star_rounded),
    ('Proches', Icons.location_on_rounded),
    ('Moins chères', Icons.savings_rounded),
  ];

  List<NannyModel> _filteredNannies(List<NannyModel> all) {
    switch (_selectedCategory) {
      case 1:
        return all
            .where((n) => n.badges.contains('Disponible') || n.isVerified)
            .toList();
      case 2:
        return all.where((n) => n.badges.contains('Super Nounou')).toList();
      case 3:
        // "Proches" : les nounous du quartier de l'utilisateur d'abord.
        // (Tri par distance GPS réelle prévu avec la géolocalisation.)
        final userQuartier =
            ref.watch(currentUserProfileProvider).valueOrNull?['quartier']
                as String?;
        if (userQuartier == null || userQuartier.isEmpty) return all;
        return [
          ...all.where((n) => n.quartier == userQuartier),
          ...all.where((n) => n.quartier != userQuartier),
        ];
      case 4:
        return [...all]..sort((a, b) => a.hourlyRate.compareTo(b.hourlyRate));
      default:
        return all;
    }
  }

  List<NannyModel> _topRated(List<NannyModel> all) =>
      [...all]..sort((a, b) => b.rating.compareTo(a.rating));

  @override
  Widget build(BuildContext context) {
    final nanniesAsync = ref.watch(nanniesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.refresh(nanniesProvider.future),
          color: AppColors.primary,
          displacement: 60,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              // ── Header ─────────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: _HomeHeader()
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: -0.05, end: 0),
              ),

              // ── CTA Besoin d'une nounou ────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: AppSpacing.screenPadding.copyWith(
                    top: AppSpacing.lg,
                  ),
                  child: GestureDetector(
                    onTap: () => context.push('/missions/publish'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl,
                        vertical: AppSpacing.lg,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradientH,
                        borderRadius: AppSpacing.cardBorderRadius,
                        boxShadow: AppColors.primaryShadow,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.20),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.add_circle_outline_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Besoin d\'une nounou ?',
                                  style: AppTypography.h4.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  'Publiez une annonce en 2 minutes',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: Colors.white.withValues(alpha: 0.80),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 60.ms).slideY(begin: 0.08, end: 0),
              ),

              // ── Mes annonces (suivi des candidatures) ──────────────────────
              const SliverToBoxAdapter(child: _MyAnnouncementsSection()),

              // ── Search ─────────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: AppSpacing.screenPadding.copyWith(
                    bottom: AppSpacing.lg,
                  ),
                  child: _SearchBar(),
                ).animate().fadeIn(delay: 80.ms).slideY(begin: 0.08, end: 0),
              ),

              // ── Category chips ─────────────────────────────────────────────
              SliverToBoxAdapter(
                child: _CategoryChips(
                  categories: _categories,
                  selectedIndex: _selectedCategory,
                  onSelected: (i) => setState(() => _selectedCategory = i),
                ).animate().fadeIn(delay: 140.ms),
              ),

              // ── Sections alimentées par le provider ────────────────────────
              ...nanniesAsync.when(
                data: (nannies) => _buildNannySlivers(context, nannies),
                loading: () => const [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: AppLoader(),
                  ),
                ],
                error: (e, _) => [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: AppSpacing.screenPadding,
                        child: Text(
                          'Impossible de charger les nounous.\n$e',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildNannySlivers(
    BuildContext context,
    List<NannyModel> nannies,
  ) {
    return [
      // ── Section "À proximité" ─────────────────────────────────────────────
      SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.xl),
            _SectionHeader(
              title: 'À proximité',
              onSeeAll: () => context.go('/search'),
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: AppSpacing.md),
            _NearbyScroll(
              nannies: _filteredNannies(nannies),
            ).animate().fadeIn(delay: 250.ms).slideX(begin: 0.05, end: 0),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),

      // ── Promo banner ──────────────────────────────────────────────────────
      SliverToBoxAdapter(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: const _PromoBanner(),
        ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.08, end: 0),
      ),

      // ── Section "Top nounous" ─────────────────────────────────────────────
      SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.xxl),
            _SectionHeader(
              title: 'Les mieux notées',
              onSeeAll: () => context.go('/search'),
            ).animate().fadeIn(delay: 350.ms),
            const SizedBox(height: AppSpacing.md),
            _TopRatedList(
              nannies: _topRated(nannies).take(4).toList(),
            ).animate().fadeIn(delay: 400.ms),
            const SizedBox(height: 100),
          ],
        ),
      ),
    ];
  }
}

// ─────────────────────────────────────────────────────── Header ──
class _HomeHeader extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentUserProfileProvider).valueOrNull;
    final firstName = (profile?['firstName'] as String?)?.trim();
    final fullName = (profile?['name'] as String?)?.trim();
    final quartier = (profile?['quartier'] as String?)?.trim();

    final greeting = firstName == null || firstName.isEmpty
        ? 'Bonjour 👋'
        : 'Bonjour, $firstName';
    final location = quartier == null || quartier.isEmpty
        ? 'Libreville · Gabon'
        : '$quartier · Libreville';

    return Container(
      padding: AppSpacing.screenPadding.copyWith(
        top: AppSpacing.lg,
        bottom: AppSpacing.xl,
      ),
      decoration: const BoxDecoration(gradient: AppColors.warmGradient),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(greeting, style: AppTypography.h2),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      size: 14,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      location,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          // Notification bell
          _NotifButton(),
          const SizedBox(width: AppSpacing.sm),
          // Profile avatar
          GestureDetector(
            onTap: () => context.go('/profile'),
            child: AppAvatar(
              name: fullName == null || fullName.isEmpty ? '?' : fullName,
              size: 40,
              showRing: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotifButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadNotificationsCountProvider);

    return Semantics(
      button: true,
      label: unreadCount > 0
          ? 'Notifications, $unreadCount non lue${unreadCount > 1 ? 's' : ''}'
          : 'Notifications',
      child: GestureDetector(
        onTap: () => context.push('/notifications'),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.md),
                boxShadow: AppColors.cardShadow,
              ),
              child: const Icon(
                Icons.notifications_outlined,
                color: AppColors.textPrimary,
                size: 22,
              ),
            ),
            if (unreadCount > 0)
              Positioned(
                top: -1,
                right: -1,
                child: Container(
                  width: 15,
                  height: 15,
                  decoration: BoxDecoration(
                    color: AppColors.danger,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: Center(
                    child: Text(
                      unreadCount > 9 ? '9+' : '$unreadCount',
                      style: AppTypography.small.copyWith(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────── Mes annonces ──
/// Annonces publiées par le parent, avec compteur de candidatures :
/// c'est le point d'entrée vers l'écran de sélection des candidates.
class _MyAnnouncementsSection extends ConsumerWidget {
  const _MyAnnouncementsSection();

  static const _openStatuses = {
    MissionStatus.pending,
    MissionStatus.confirmed,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(currentUserIdProvider);
    final missions = (ref.watch(missionsProvider).valueOrNull ?? const [])
        .where(
          (m) => m.parentId == userId && _openStatuses.contains(m.status),
        )
        .toList();
    if (missions.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: AppSpacing.screenPadding.copyWith(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Mes annonces', style: AppTypography.h3),
          const SizedBox(height: AppSpacing.md),
          ...missions.map(
            (mission) => _AnnouncementTile(mission: mission),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 70.ms).slideY(begin: 0.08, end: 0);
  }
}

class _AnnouncementTile extends StatelessWidget {
  final MissionModel mission;
  const _AnnouncementTile({required this.mission});

  @override
  Widget build(BuildContext context) {
    final count = mission.applicantIds.length;
    final isConfirmed = mission.status == MissionStatus.confirmed;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.cardBorderRadius,
        boxShadow: AppColors.cardShadow,
        border: Border.all(color: AppColors.border),
      ),
      child: InkWell(
        onTap: () => context.push('/missions/${mission.id}/candidatures'),
        borderRadius: AppSpacing.cardBorderRadius,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: AppColors.primarySurface,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.campaign_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mission.address,
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isConfirmed
                          ? 'Nounou sélectionnée'
                          : count == 0
                          ? 'En attente de candidatures'
                          : '$count candidature${count > 1 ? 's' : ''} reçue'
                                '${count > 1 ? 's' : ''}',
                      style: AppTypography.caption.copyWith(
                        color: isConfirmed
                            ? AppColors.success
                            : count > 0
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontWeight: count > 0 || isConfirmed
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────── Search bar ──
class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/search'),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppSpacing.inputBorderRadius,
          boxShadow: AppColors.cardShadow,
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const SizedBox(width: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradientH,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.search_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              'Rechercher par nom, quartier...',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
            const Spacer(),
            Container(
              margin: const EdgeInsets.only(right: AppSpacing.sm),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.tune_rounded,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Filtres',
                    style: AppTypography.small.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────── Category chips ──
class _CategoryChips extends StatelessWidget {
  final List<(String, IconData)> categories;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _CategoryChips({
    required this.categories,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final (label, icon) = categories[index];
          final isActive = index == selectedIndex;
          return GestureDetector(
            onTap: () => onSelected(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                gradient: isActive ? AppColors.primaryGradientH : null,
                color: isActive ? null : AppColors.surface,
                borderRadius: AppSpacing.chipBorderRadius,
                boxShadow: isActive
                    ? AppColors.primaryShadow
                    : [
                        BoxShadow(
                          color: AppColors.secondary.withValues(alpha: 0.05),
                          blurRadius: 4,
                        ),
                      ],
                border: isActive ? null : Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 14,
                    color: isActive ? Colors.white : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    label,
                    style: AppTypography.caption.copyWith(
                      color: isActive ? Colors.white : AppColors.textSecondary,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────── Section header ──
class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAll;

  const _SectionHeader({required this.title, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.screenPadding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTypography.h3),
          GestureDetector(
            onTap: onSeeAll,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: AppSpacing.chipBorderRadius,
              ),
              child: Text(
                'Voir tout',
                style: AppTypography.small.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────── Nearby scroll ──
class _NearbyScroll extends StatelessWidget {
  final List<NannyModel> nannies;
  const _NearbyScroll({required this.nannies});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        itemCount: nannies.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, index) {
          final nanny = nannies[index];
          final quartier = nanny.quartier.isNotEmpty
              ? nanny.quartier
              : 'Libreville';
          return _NannyCompactCard(nanny: nanny, quartier: quartier)
              .animate()
              .fadeIn(delay: (index * 70).ms, duration: 380.ms)
              .slideX(begin: 0.15, end: 0, curve: Curves.easeOutCubic);
        },
      ),
    );
  }
}

class _NannyCompactCard extends StatelessWidget {
  final NannyModel nanny;
  final String quartier;

  const _NannyCompactCard({required this.nanny, required this.quartier});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/nanny/${nanny.id}'),
      child: Container(
        width: 148,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppSpacing.cardBorderRadius,
          boxShadow: AppColors.cardShadow,
          border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
        ),
        child: Column(
          children: [
            // ── Top gradient header ──────────────────────────────────────────
            Container(
              height: 72,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.surfaceVariant, AppColors.primarySurface],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppSpacing.cardRadius),
                ),
              ),
              child: Center(
                child: AppAvatar(
                  name: nanny.name,
                  size: 56,
                  showRing: nanny.isVerified,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.sm,
                AppSpacing.sm,
                AppSpacing.sm,
                AppSpacing.md,
              ),
              child: Column(
                children: [
                  Text(
                    nanny.name.split(' ').first,
                    style: AppTypography.h4,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        size: 11,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 2),
                      Flexible(
                        child: Text(
                          quartier,
                          style: AppTypography.small.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  RatingStars(rating: nanny.rating, size: 12),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradientH,
                      borderRadius: AppSpacing.chipBorderRadius,
                    ),
                    child: Text(
                      AppFormatters.pricePerHour(nanny.hourlyRate),
                      style: AppTypography.small.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────── Promo banner ──
class _PromoBanner extends StatelessWidget {
  const _PromoBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        borderRadius: AppSpacing.cardBorderRadius,
        gradient: const LinearGradient(
          colors: [AppColors.secondary, AppColors.secondaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: AppColors.elevatedShadow,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.20),
                    borderRadius: AppSpacing.chipBorderRadius,
                  ),
                  child: Text(
                    'OFFRE SPECIALE',
                    style: AppTypography.overline.copyWith(
                      color: AppColors.primaryLight,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '1ère heure\nofferte !',
                  style: AppTypography.h2.copyWith(
                    color: Colors.white,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Pour votre première réservation',
                  style: AppTypography.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.70),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                GestureDetector(
                  onTap: () => context.go('/search'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: AppSpacing.chipBorderRadius,
                      boxShadow: AppColors.primaryShadow,
                    ),
                    child: Text(
                      'En profiter →',
                      style: AppTypography.buttonLabelSm.copyWith(fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.10),
                ),
                child: const Icon(
                  Icons.child_care_rounded,
                  size: 48,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.20),
                  borderRadius: AppSpacing.chipBorderRadius,
                ),
                child: Text(
                  'CODE : FIRST',
                  style: AppTypography.small.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────── Top rated list ──
class _TopRatedList extends StatelessWidget {
  final List<NannyModel> nannies;
  const _TopRatedList({required this.nannies});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.screenPadding,
      child: Column(
        children: nannies.asMap().entries.map((entry) {
          final index = entry.key;
          final nanny = entry.value;
          final quartier = nanny.quartier.isNotEmpty
              ? nanny.quartier
              : 'Libreville';
          return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: NannyCard(
                  nannyId: nanny.id,
                  name: nanny.name,
                  quartier: quartier,
                  rating: nanny.rating,
                  hourlyRate: nanny.hourlyRate,
                  isVerified: nanny.isVerified,
                ),
              )
              .animate()
              .fadeIn(delay: (index * 80).ms, duration: 380.ms)
              .slideY(begin: 0.07, end: 0);
        }).toList(),
      ),
    );
  }
}
