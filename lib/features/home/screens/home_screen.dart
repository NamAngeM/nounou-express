import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/avatar_widget.dart';
import '../../../core/widgets/nanny_card.dart';
import '../../../core/widgets/rating_stars.dart';
import '../../../data/mock/mock_data.dart';
import '../../../data/models/nanny_model.dart';

const _mockDistances = [1.2, 0.8, 2.5, 1.9, 3.1, 0.5, 4.2, 2.1, 1.7, 3.8];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedCategory = 0;

  static const _categories = [
    ('Toutes', Icons.apps_rounded),
    ('Disponibles', Icons.check_circle_outline_rounded),
    ('Top Nounous', Icons.star_rounded),
    ('Proches', Icons.location_on_rounded),
    ('Moins chères', Icons.savings_rounded),
  ];

  List<NannyModel> get _filteredNannies {
    final all = MockData.nannies;
    switch (_selectedCategory) {
      case 1:
        return all
            .where((n) => n.badges.contains('Disponible') || n.isVerified)
            .toList();
      case 2:
        return all.where((n) => n.badges.contains('Super Nounou')).toList();
      case 3:
        final indexed = List.generate(all.length, (i) => (i, all[i]));
        indexed.sort(
          (a, b) => _mockDistances[a.$1].compareTo(_mockDistances[b.$1]),
        );
        return indexed.map((e) => e.$2).toList();
      case 4:
        return [...all]..sort((a, b) => a.hourlyRate.compareTo(b.hourlyRate));
      default:
        return all;
    }
  }

  List<NannyModel> get _topRated =>
      [...MockData.nannies]..sort((a, b) => b.rating.compareTo(a.rating));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => await Future.delayed(1.seconds),
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

              // ── Section "À proximité" ───────────────────────────────────────
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
                    _NearbyScroll(nannies: _filteredNannies)
                        .animate()
                        .fadeIn(delay: 250.ms)
                        .slideX(begin: 0.05, end: 0),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),

              // ── Promo banner ────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: AppSpacing.screenPadding,
                  child: const _PromoBanner(),
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.08, end: 0),
              ),

              // ── Section "Top nounous" ───────────────────────────────────────
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
                      nannies: _topRated.take(4).toList(),
                    ).animate().fadeIn(delay: 400.ms),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────── Header ──
class _HomeHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
                Text('Bonjour, Aminata', style: AppTypography.h2),
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
                      'Libreville · Gabon',
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
            child: const AppAvatar(
              name: 'Aminata B.',
              size: 40,
              showRing: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotifButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/notifications'),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 42,
            height: 42,
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
          Positioned(
            top: -1,
            right: -1,
            child: Container(
              width: 15,
              height: 15,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.danger, Color(0xFFEF5350)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: const Center(
                child: Text(
                  '3',
                  style: TextStyle(
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
          final originalIndex = MockData.nannies.indexOf(nanny);
          final quartier = nanny.quartier.isNotEmpty
              ? nanny.quartier
              : 'Libreville';
          final distance =
              _mockDistances[originalIndex.clamp(0, _mockDistances.length - 1)];
          return _NannyCompactCard(
                nanny: nanny,
                quartier: quartier,
                distance: distance,
              )
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
  final double distance;

  const _NannyCompactCard({
    required this.nanny,
    required this.quartier,
    required this.distance,
  });

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
          crossAxisAlignment: CrossAxisAlignment.center,
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
                          '$quartier · ${distance.toStringAsFixed(1)} km',
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
                      '${nanny.hourlyRate.toStringAsFixed(0)} F/h',
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
          final originalIndex = MockData.nannies.indexOf(nanny);
          final quartier = nanny.quartier.isNotEmpty
              ? nanny.quartier
              : 'Libreville';
          final distance =
              _mockDistances[originalIndex.clamp(0, _mockDistances.length - 1)];
          return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: NannyCard(
                  nannyId: nanny.id,
                  name: nanny.name,
                  quartier: quartier,
                  rating: nanny.rating,
                  hourlyRate: nanny.hourlyRate,
                  distanceKm: distance,
                  isVerified: nanny.isVerified,
                  reviewCount: 12 + index * 7,
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
