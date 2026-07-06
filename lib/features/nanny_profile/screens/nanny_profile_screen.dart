import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/pricing.dart';
import '../../../core/widgets/app_loader.dart';
import '../../../core/widgets/avatar_widget.dart';
import '../../../core/widgets/rating_stars.dart';
import '../../../data/models/nanny_model.dart';
import '../../../data/models/review_model.dart';
import '../../../data/providers/data_providers.dart';

/// Couleurs des chips de compétences, limitées à la palette de la charte.
_SkillStyle _skillStyle(String skill) {
  final s = skill.toLowerCase();
  if (s.contains('secours') || s.contains('secourisme')) {
    return const _SkillStyle(AppColors.dangerSurface, AppColors.danger);
  }
  if (s.contains('cuisine')) {
    return const _SkillStyle(AppColors.goldSurface, AppColors.gold);
  }
  if (s.contains('devoir') || s.contains('scolaire')) {
    return const _SkillStyle(AppColors.primarySurface, AppColors.primary);
  }
  if (s.contains('éveil') ||
      s.contains('musical') ||
      s.contains('créati') ||
      s.contains('animation')) {
    return const _SkillStyle(AppColors.accentSurface, AppColors.accentDark);
  }
  if (s.contains('langue') || s.contains('bilingue')) {
    return const _SkillStyle(AppColors.surfaceVariant, AppColors.secondary);
  }
  if (s.contains('hygiène') || s.contains('bébé') || s.contains('nourri')) {
    return const _SkillStyle(AppColors.accentSurface, AppColors.accentDark);
  }
  if (s.contains('nuit') || s.contains('garde')) {
    return const _SkillStyle(AppColors.primarySurface, AppColors.primaryDark);
  }
  return const _SkillStyle(AppColors.surfaceVariant, AppColors.textSecondary);
}

class _SkillStyle {
  final Color bg;
  final Color fg;
  const _SkillStyle(this.bg, this.fg);
}

// ─────────────────────────────────────── Screen ──

class NannyProfileScreen extends ConsumerStatefulWidget {
  final String nannyId;
  const NannyProfileScreen({super.key, required this.nannyId});

  @override
  ConsumerState<NannyProfileScreen> createState() => _NannyProfileScreenState();
}

class _NannyProfileScreenState extends ConsumerState<NannyProfileScreen> {
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    return ref
        .watch(nannyByIdProvider(widget.nannyId))
        .when(
          data: _buildProfile,
          loading: () => const Scaffold(body: AppLoader()),
          // L'état error couvre aussi le cas « nounou introuvable ».
          error: (e, _) => Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Nounou introuvable')),
          ),
        );
  }

  Widget _buildProfile(NannyModel nanny) {
    final quartier = nanny.quartier.isNotEmpty ? nanny.quartier : 'Libreville';
    final memberSince = DateTime.now().subtract(
      Duration(days: (nanny.experience * 365).round()),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(nanny),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoSection(
                      nanny: nanny,
                      quartier: quartier,
                      memberSince: memberSince,
                    )
                    .animate()
                    .fadeIn(delay: 100.ms, duration: 400.ms)
                    .slideY(begin: 0.05, end: 0),
                _TarifCard(
                  hourlyRate: nanny.hourlyRate,
                ).animate().fadeIn(delay: 150.ms, duration: 400.ms),
                _BioSection(
                  bio: nanny.bio,
                ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
                _SkillsSection(
                  skills: nanny.skills,
                ).animate().fadeIn(delay: 250.ms, duration: 400.ms),
                if (nanny.availability.isNotEmpty)
                  _AvailabilitySection(
                    availability: nanny.availability,
                  ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
                _ReviewsSection(
                  nanny: nanny,
                ).animate().fadeIn(delay: 350.ms, duration: 400.ms),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _BottomBookingBar(nanny: nanny),
    );
  }

  SliverAppBar _buildSliverAppBar(NannyModel nanny) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      stretch: true,
      backgroundColor: AppColors.primary,
      leading: _CircleIconButton(
        icon: Icons.arrow_back_rounded,
        onTap: () => context.canPop() ? context.pop() : context.go('/home'),
      ),
      actions: [
        _CircleIconButton(
          icon: _isFavorite
              ? Icons.favorite_rounded
              : Icons.favorite_border_rounded,
          iconColor: _isFavorite ? AppColors.danger : Colors.white,
          onTap: () => setState(() => _isFavorite = !_isFavorite),
        ),
        const SizedBox(width: AppSpacing.sm),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: _HeaderBackground(nanny: nanny),
      ),
    );
  }
}

// ─────────────────────────────────────── Header background ──

class _HeaderBackground extends StatelessWidget {
  final NannyModel nanny;
  const _HeaderBackground({required this.nanny});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Gradient background
        Container(
          decoration: const BoxDecoration(gradient: AppColors.heroGradient),
        ),
        // Avatar centered
        // Avatar centered
        Center(
          child: Hero(
            tag: 'nanny_avatar_${nanny.id}',
            child: AppAvatar(
              name: nanny.name,
              imageUrl: nanny.avatar,
              size: 100,
            ),
          ),
        ),
        // Bottom overlay: name + rating
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.xxl,
              AppSpacing.xl,
              AppSpacing.lg,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.55),
                  Colors.transparent,
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  nanny.name,
                  style: AppTypography.h2.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    RatingStars(rating: nanny.rating),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      '${nanny.rating} · ${nanny.totalMissions} avis',
                      style: AppTypography.bodyMedium.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color iconColor;

  const _CircleIconButton({
    required this.icon,
    required this.onTap,
    this.iconColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(AppSpacing.sm),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withValues(alpha: 0.25),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
    );
  }
}

// ─────────────────────────────────────── Info section ──

class _InfoSection extends StatelessWidget {
  final NannyModel nanny;
  final String quartier;
  final DateTime memberSince;

  const _InfoSection({
    required this.nanny,
    required this.quartier,
    required this.memberSince,
  });

  @override
  Widget build(BuildContext context) {
    final months = [
      'janv.',
      'févr.',
      'mars',
      'avr.',
      'mai',
      'juin',
      'juil.',
      'août',
      'sept.',
      'oct.',
      'nov.',
      'déc.',
    ];
    final sinceLabel = '${months[memberSince.month - 1]} ${memberSince.year}';

    return _Section(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badges row
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              if (nanny.badges.isNotEmpty)
                ...nanny.badges.map((b) => _BadgeChip(label: b)),
              const _BadgeChip(label: 'Identité Vérifiée'),
              const _BadgeChip(label: 'Casier Judiciaire Vierge'),
              const _BadgeChip(label: 'Premiers Secours'),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          // Info rows
          _InfoRow(
            icon: Icons.location_on_outlined,
            text: '$quartier, Libreville',
          ),
          _InfoRow(
            icon: Icons.work_outline_rounded,
            text:
                '${nanny.experience} an${nanny.experience > 1 ? 's' : ''} d\'expérience',
          ),
          _InfoRow(
            icon: Icons.check_circle_outline_rounded,
            text:
                '${nanny.totalMissions} mission${nanny.totalMissions > 1 ? 's' : ''} réalisée${nanny.totalMissions > 1 ? 's' : ''}',
          ),
          _InfoRow(
            icon: Icons.calendar_today_outlined,
            text: 'Membre depuis $sinceLabel',
          ),
        ],
      ),
    );
  }
}

class _BadgeChip extends StatelessWidget {
  final String label;
  const _BadgeChip({required this.label});

  Color get _bg {
    if (label.contains('Vérifié')) {
      return AppColors.accent.withValues(alpha: 0.15);
    }
    if (label.contains('Super')) {
      return AppColors.warning.withValues(alpha: 0.2);
    }
    if (label.contains('Disponible')) {
      return AppColors.success.withValues(alpha: 0.15);
    }
    return AppColors.primary.withValues(alpha: 0.12);
  }

  Color get _fg {
    if (label.contains('Vérifié')) return AppColors.accent;
    if (label.contains('Super')) return AppColors.gold;
    if (label.contains('Disponible')) return AppColors.success;
    return AppColors.primary;
  }

  IconData get _icon {
    if (label.contains('Vérifié')) return Icons.verified_rounded;
    if (label.contains('Super')) return Icons.star_rounded;
    if (label.contains('Disponible')) return Icons.circle;
    return Icons.workspace_premium_rounded;
  }

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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 13, color: _fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.small.copyWith(
              color: _fg,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.md),
          Text(text, style: AppTypography.bodyMedium),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────── Tarif card ──

class _TarifCard extends StatelessWidget {
  final double hourlyRate;
  const _TarifCard({required this.hourlyRate});

  @override
  Widget build(BuildContext context) {
    final nightRate = PricingService.nightRate(hourlyRate).toStringAsFixed(0);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradientH,
          borderRadius: AppSpacing.cardBorderRadius,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tarif horaire',
                    style: AppTypography.caption.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text:
                              '${hourlyRate.toStringAsFixed(0)} ${AppConstants.currency}',
                          style: AppTypography.h2.copyWith(color: Colors.white),
                        ),
                        TextSpan(
                          text: ' /h',
                          style: AppTypography.bodyMedium.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tarif de nuit : $nightRate ${AppConstants.currency}/h',
                    style: AppTypography.small.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppSpacing.sm),
              ),
              child: Text(
                'Week-end\n${PricingService.weekendLabel}',
                style: AppTypography.small.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────── Bio section ──

class _BioSection extends StatefulWidget {
  final String bio;
  const _BioSection({required this.bio});

  @override
  State<_BioSection> createState() => _BioSectionState();
}

class _BioSectionState extends State<_BioSection> {
  bool _expanded = false;
  static const _maxChars = 120;

  @override
  Widget build(BuildContext context) {
    final isLong = widget.bio.length > _maxChars;
    final displayed = _expanded || !isLong
        ? widget.bio
        : '${widget.bio.substring(0, _maxChars)}...';

    return _Section(
      title: 'À propos',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            displayed,
            style: AppTypography.bodyMedium.copyWith(height: 1.6),
          ),
          if (isLong) ...[
            const SizedBox(height: AppSpacing.sm),
            GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Text(
                _expanded ? 'Voir moins' : 'Voir plus',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────── Skills section ──

class _SkillsSection extends StatelessWidget {
  final List<String> skills;
  const _SkillsSection({required this.skills});

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Compétences',
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: skills.map((s) {
          final style = _skillStyle(s);
          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs + 2,
            ),
            decoration: BoxDecoration(
              color: style.bg,
              borderRadius: BorderRadius.circular(AppSpacing.badgeRadius),
            ),
            child: Text(
              s,
              style: AppTypography.caption.copyWith(
                color: style.fg,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────── Availability section ──

class _AvailabilitySection extends StatefulWidget {
  /// Disponibilités déclarées par la nounou : jour → créneaux.
  final Map<String, List<String>> availability;
  const _AvailabilitySection({required this.availability});

  @override
  State<_AvailabilitySection> createState() => _AvailabilitySectionState();
}

class _AvailabilitySectionState extends State<_AvailabilitySection> {
  int? _selectedDay;

  static const _dayKeys = [
    'Lundi',
    'Mardi',
    'Mercredi',
    'Jeudi',
    'Vendredi',
    'Samedi',
    'Dimanche',
  ];
  static const _dayLabels = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];

  List<String> _slotsOf(int dayIndex) =>
      widget.availability[_dayKeys[dayIndex]] ?? const [];

  @override
  Widget build(BuildContext context) {
    final available = List.generate(7, (i) => _slotsOf(i).isNotEmpty);
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));

    return _Section(
      title: 'Disponibilités',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Week calendar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              final day = monday.add(Duration(days: i));
              final isSelected = _selectedDay == i;
              final isAvail = available[i];
              return GestureDetector(
                onTap: isAvail
                    ? () => setState(
                        () => _selectedDay = _selectedDay == i ? null : i,
                      )
                    : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 40,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : isAvail
                        ? AppColors.success.withValues(alpha: 0.12)
                        : AppColors.border.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : Colors.transparent,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _dayLabels[i],
                        style: AppTypography.small.copyWith(
                          color: isSelected
                              ? Colors.white
                              : isAvail
                              ? AppColors.success
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${day.day}',
                        style: AppTypography.caption.copyWith(
                          color: isSelected
                              ? Colors.white
                              : isAvail
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isAvail ? AppColors.success : AppColors.border,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
          // Slots when a day is selected
          if (_selectedDay != null && available[_selectedDay!]) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Créneaux disponibles — ${_dayLabels[_selectedDay!]}',
              style: AppTypography.caption.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: _slotsOf(_selectedDay!)
                  .map(
                    (slot) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppSpacing.sm),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        slot,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────── Reviews section ──

class _ReviewsSection extends ConsumerWidget {
  final NannyModel nanny;

  const _ReviewsSection({required this.nanny});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasRating = nanny.rating > 0 && nanny.totalMissions > 0;
    final reviews =
        ref.watch(reviewsForUserProvider(nanny.id)).valueOrNull ??
        const <ReviewModel>[];

    return _Section(
      title: 'Avis des parents',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasRating)
            Row(
              children: [
                Text(
                  nanny.rating.toStringAsFixed(1),
                  style: AppTypography.h1.copyWith(
                    fontSize: 48,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RatingStars(rating: nanny.rating, size: 18),
                    const SizedBox(height: 4),
                    Text(
                      'Note moyenne sur ${nanny.totalMissions} '
                      'mission${nanny.totalMissions > 1 ? 's' : ''}',
                      style: AppTypography.small,
                    ),
                  ],
                ),
              ],
            ),
          if (reviews.isNotEmpty) ...[
            if (hasRating) ...[
              const SizedBox(height: AppSpacing.lg),
              const Divider(),
              const SizedBox(height: AppSpacing.md),
            ],
            ...reviews.map((r) => _ReviewTile(review: r)),
          ] else if (hasRating) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Les commentaires détaillés des parents seront '
              'affichés ici dès leur publication.',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ] else
            Text(
              'Pas encore d\'avis — cette nounou démarre sur '
              'Nounou Express.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }
}

class _ReviewTile extends ConsumerWidget {
  final ReviewModel review;
  const _ReviewTile({required this.review});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMine = review.fromUserId == ref.watch(currentUserIdProvider);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isMine ? 'Vous' : 'Un parent',
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              RatingStars(rating: review.rating, size: 13),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            AppFormatters.formatShortDate(review.createdAt),
            style: AppTypography.small,
          ),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              review.comment,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────── Bottom booking bar ──

class _BottomBookingBar extends StatelessWidget {
  final NannyModel nanny;
  const _BottomBookingBar({required this.nanny});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.md,
        AppSpacing.xl,
        AppSpacing.md + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left: rate
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text:
                          '${nanny.hourlyRate.toStringAsFixed(0)} ${AppConstants.currency}',
                      style: AppTypography.h3.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Text('/heure', style: AppTypography.small),
            ],
          ),
          const SizedBox(width: AppSpacing.xl),
          // Right: book button
          Expanded(
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: () => context.push('/booking/new/${nanny.id}'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppSpacing.buttonBorderRadius,
                  ),
                ),
                child: Text(
                  'Réserver maintenant',
                  style: AppTypography.buttonLabel,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────── Shared section wrapper ──

class _Section extends StatelessWidget {
  final String? title;
  final Widget child;

  const _Section({this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xxl,
        AppSpacing.xl,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(title!, style: AppTypography.h3),
            const SizedBox(height: AppSpacing.lg),
          ],
          child,
        ],
      ),
    );
  }
}
