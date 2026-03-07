import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/rating_stars.dart';
import '../../../core/widgets/avatar_widget.dart';
import '../../../data/mock/mock_data.dart';
import '../../../data/models/nanny_model.dart';

// ─────────────────────────────────────── Mock helpers ──

class _Review {
  final String parentName;
  final double rating;
  final String comment;
  final DateTime date;
  const _Review({required this.parentName, required this.rating, required this.comment, required this.date});
}

List<_Review> _mockReviews(NannyModel nanny) {
  const parents = ['Aminata B.', 'Sylvie M.', 'Patricia N.', 'Rose O.', 'Claire E.'];
  const comments = [
    'Excellente, mes enfants l\'adorent ! Toujours ponctuelle et pleine d\'énergie.',
    'Très professionnelle et attentionnée. Je la recommande vivement.',
    'Parfaite avec les nourrissons. Sa patience est remarquable.',
    'Bonne communication, très sérieuse. Nous faisons appel à elle régulièrement.',
    'Disponible et réactive. Les enfants réclament leur nounou !',
  ];
  final hash = nanny.id.codeUnits.fold(0, (a, b) => a + b);
  return List.generate(3, (i) => _Review(
    parentName: parents[(hash + i) % parents.length],
    rating: [5.0, 4.0, 5.0, 4.0, 5.0][(hash + i) % 5],
    comment: comments[(hash + i * 2) % comments.length],
    date: DateTime.now().subtract(Duration(days: 10 + i * 20)),
  ));
}

Map<int, double> _ratingDistribution(double r) {
  if (r >= 4.8) return {5: 0.80, 4: 0.15, 3: 0.04, 2: 0.01, 1: 0.00};
  if (r >= 4.5) return {5: 0.65, 4: 0.25, 3: 0.08, 2: 0.02, 1: 0.00};
  if (r >= 4.0) return {5: 0.45, 4: 0.35, 3: 0.15, 2: 0.05, 1: 0.00};
  return {5: 0.30, 4: 0.40, 3: 0.20, 2: 0.08, 1: 0.02};
}

_SkillStyle _skillStyle(String skill) {
  final s = skill.toLowerCase();
  if (s.contains('secours') || s.contains('secourisme')) {
    return _SkillStyle(Colors.red.shade50, Colors.red.shade700);
  }
  if (s.contains('cuisine')) return _SkillStyle(Colors.orange.shade50, Colors.orange.shade700);
  if (s.contains('devoir') || s.contains('scolaire')) {
    return _SkillStyle(Colors.blue.shade50, Colors.blue.shade700);
  }
  if (s.contains('éveil') || s.contains('musical') || s.contains('créati') || s.contains('animation')) {
    return _SkillStyle(Colors.purple.shade50, Colors.purple.shade700);
  }
  if (s.contains('langue') || s.contains('bilingue')) {
    return _SkillStyle(Colors.green.shade50, Colors.green.shade700);
  }
  if (s.contains('hygiène') || s.contains('bébé') || s.contains('nourri')) {
    return _SkillStyle(Colors.teal.shade50, Colors.teal.shade700);
  }
  if (s.contains('nuit') || s.contains('garde')) {
    return _SkillStyle(Colors.indigo.shade50, Colors.indigo.shade700);
  }
  return _SkillStyle(Colors.grey.shade100, Colors.grey.shade700);
}

class _SkillStyle {
  final Color bg;
  final Color fg;
  const _SkillStyle(this.bg, this.fg);
}

// ─────────────────────────────────────── Screen ──

class NannyProfileScreen extends StatefulWidget {
  final String nannyId;
  const NannyProfileScreen({super.key, required this.nannyId});

  @override
  State<NannyProfileScreen> createState() => _NannyProfileScreenState();
}

class _NannyProfileScreenState extends State<NannyProfileScreen> {
  bool _isFavorite = false;

  NannyModel? get _nanny {
    try {
      return MockData.nannies.firstWhere((n) => n.id == widget.nannyId);
    } catch (_) {
      return null;
    }
  }

  String get _quartier => _nanny?.quartier.isNotEmpty == true ? _nanny!.quartier : 'Libreville';

  @override
  Widget build(BuildContext context) {
    final nanny = _nanny;
    if (nanny == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Nounou introuvable')),
      );
    }

    final reviews = _mockReviews(nanny);
    final memberSince = DateTime.now().subtract(Duration(days: (nanny.experience * 365).round()));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(nanny),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoSection(nanny: nanny, quartier: _quartier, memberSince: memberSince)
                    .animate().fadeIn(delay: 100.ms, duration: 400.ms).slideY(begin: 0.05, end: 0),
                _TarifCard(hourlyRate: nanny.hourlyRate)
                    .animate().fadeIn(delay: 150.ms, duration: 400.ms),
                _BioSection(bio: nanny.bio)
                    .animate().fadeIn(delay: 200.ms, duration: 400.ms),
                _SkillsSection(skills: nanny.skills)
                    .animate().fadeIn(delay: 250.ms, duration: 400.ms),
                _AvailabilitySection()
                    .animate().fadeIn(delay: 300.ms, duration: 400.ms),
                _ReviewsSection(nanny: nanny, reviews: reviews)
                    .animate().fadeIn(delay: 350.ms, duration: 400.ms),
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
          icon: _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          iconColor: _isFavorite ? AppColors.danger : Colors.white,
          onTap: () => setState(() => _isFavorite = !_isFavorite),
        ),
        const SizedBox(width: AppSpacing.sm),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        stretchModes: const [StretchMode.zoomBackground],
        background: _HeaderBackground(nanny: nanny),
      ),
    );
  }
}

// ─────────────────────────────────────── Header background ──

class _HeaderBackground extends StatelessWidget {
  final NannyModel nanny;
  const _HeaderBackground({required this.nanny});

  String get _initials {
    final parts = nanny.name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return nanny.name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Gradient background
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFF6B35), Color(0xFFFF9A6C)],
            ),
          ),
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
            padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xxl, AppSpacing.xl, AppSpacing.lg),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black.withValues(alpha: 0.55), Colors.transparent],
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
                    RatingStars(rating: nanny.rating, size: 16),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      '${nanny.rating} · ${nanny.totalMissions} avis',
                      style: AppTypography.bodyMedium.copyWith(color: Colors.white.withValues(alpha: 0.9)),
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

  const _InfoSection({required this.nanny, required this.quartier, required this.memberSince});

  @override
  Widget build(BuildContext context) {
    final months = ['janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin',
                    'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.'];
    final sinceLabel = '${months[memberSince.month - 1]} ${memberSince.year}';

    return _Section(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badges row
          if (nanny.badges.isNotEmpty)
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: nanny.badges.map((b) => _BadgeChip(label: b)).toList(),
            ),
          if (nanny.badges.isNotEmpty) const SizedBox(height: AppSpacing.lg),
          // Info rows
          _InfoRow(icon: Icons.location_on_outlined, text: '$quartier, Libreville'),
          _InfoRow(
            icon: Icons.work_outline_rounded,
            text: '${nanny.experience} an${nanny.experience > 1 ? 's' : ''} d\'expérience',
          ),
          _InfoRow(
            icon: Icons.check_circle_outline_rounded,
            text: '${nanny.totalMissions} mission${nanny.totalMissions > 1 ? 's' : ''} réalisée${nanny.totalMissions > 1 ? 's' : ''}',
          ),
          _InfoRow(icon: Icons.calendar_today_outlined, text: 'Membre depuis $sinceLabel'),
        ],
      ),
    );
  }
}

class _BadgeChip extends StatelessWidget {
  final String label;
  const _BadgeChip({required this.label});

  Color get _bg {
    if (label.contains('Vérifié')) return AppColors.accent.withValues(alpha: 0.15);
    if (label.contains('Super')) return AppColors.warning.withValues(alpha: 0.2);
    if (label.contains('Disponible')) return AppColors.success.withValues(alpha: 0.15);
    return AppColors.primary.withValues(alpha: 0.12);
  }

  Color get _fg {
    if (label.contains('Vérifié')) return AppColors.accent;
    if (label.contains('Super')) return const Color(0xFFB8860B);
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
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      decoration: BoxDecoration(color: _bg, borderRadius: AppSpacing.badgeBorderRadius),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 13, color: _fg),
          const SizedBox(width: 4),
          Text(label, style: AppTypography.small.copyWith(color: _fg, fontWeight: FontWeight.w600)),
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
    final nightRate = (hourlyRate * 1.4).toStringAsFixed(0);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, Color(0xFFFF9A6C)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: AppSpacing.cardBorderRadius,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tarif horaire', style: AppTypography.caption.copyWith(color: Colors.white.withValues(alpha: 0.8))),
                  const SizedBox(height: 4),
                  RichText(
                    text: TextSpan(children: [
                      TextSpan(
                        text: '${hourlyRate.toStringAsFixed(0)} FCFA',
                        style: AppTypography.h2.copyWith(color: Colors.white),
                      ),
                      TextSpan(
                        text: ' /h',
                        style: AppTypography.bodyMedium.copyWith(color: Colors.white.withValues(alpha: 0.8)),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tarif de nuit : $nightRate FCFA/h',
                    style: AppTypography.small.copyWith(color: Colors.white.withValues(alpha: 0.85)),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppSpacing.sm),
              ),
              child: Text(
                'Week-end\n+25%',
                style: AppTypography.small.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
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
    final displayed = _expanded || !isLong ? widget.bio : '${widget.bio.substring(0, _maxChars)}...';

    return _Section(
      title: 'À propos',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(displayed, style: AppTypography.bodyMedium.copyWith(height: 1.6)),
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
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs + 2),
            decoration: BoxDecoration(
              color: style.bg,
              borderRadius: BorderRadius.circular(AppSpacing.badgeRadius),
            ),
            child: Text(s, style: AppTypography.caption.copyWith(color: style.fg, fontWeight: FontWeight.w600)),
          );
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────── Availability section ──

class _AvailabilitySection extends StatefulWidget {
  const _AvailabilitySection();

  @override
  State<_AvailabilitySection> createState() => _AvailabilitySectionState();
}

class _AvailabilitySectionState extends State<_AvailabilitySection> {
  int? _selectedDay;

  static const _dayLabels = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
  // Mock: Mon-Fri available, Sat-Sun not
  static const _available = [true, true, true, true, true, false, false];
  static const _slots = ['08:00–12:00', '14:00–18:00', '18:00–22:00'];

  @override
  Widget build(BuildContext context) {
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
              final isAvail = _available[i];
              return GestureDetector(
                onTap: isAvail ? () => setState(() => _selectedDay = _selectedDay == i ? null : i) : null,
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
                      color: isSelected ? AppColors.primary : Colors.transparent,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _dayLabels[i],
                        style: AppTypography.small.copyWith(
                          color: isSelected ? Colors.white : isAvail ? AppColors.success : AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${day.day}',
                        style: AppTypography.caption.copyWith(
                          color: isSelected ? Colors.white : isAvail ? AppColors.textPrimary : AppColors.textSecondary,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
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
          if (_selectedDay != null && _available[_selectedDay!]) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Créneaux disponibles — ${_dayLabels[_selectedDay!]}',
              style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600, color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: _slots.map((slot) => Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.sm),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: Text(slot, style: AppTypography.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────── Reviews section ──

class _ReviewsSection extends StatelessWidget {
  final NannyModel nanny;
  final List<_Review> reviews;

  const _ReviewsSection({required this.nanny, required this.reviews});

  @override
  Widget build(BuildContext context) {
    final dist = _ratingDistribution(nanny.rating);

    return _Section(
      title: 'Avis des parents (${nanny.totalMissions})',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Big rating
              Column(
                children: [
                  Text(
                    nanny.rating.toStringAsFixed(1),
                    style: AppTypography.h1.copyWith(fontSize: 48, color: AppColors.primary),
                  ),
                  RatingStars(rating: nanny.rating, size: 18),
                  const SizedBox(height: 4),
                  Text('${nanny.totalMissions} avis', style: AppTypography.small),
                ],
              ),
              const SizedBox(width: AppSpacing.xl),
              // Bars
              Expanded(
                child: Column(
                  children: List.generate(5, (i) {
                    final stars = 5 - i;
                    final pct = dist[stars] ?? 0;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Text('$stars', style: AppTypography.small),
                          const SizedBox(width: 4),
                          const Icon(Icons.star_rounded, size: 11, color: AppColors.warning),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: pct,
                                backgroundColor: AppColors.border,
                                valueColor: const AlwaysStoppedAnimation(AppColors.warning),
                                minHeight: 8,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          SizedBox(
                            width: 30,
                            child: Text(
                              '${(pct * 100).round()}%',
                              style: AppTypography.small,
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          const Divider(),
          const SizedBox(height: AppSpacing.md),
          // Review cards
          ...reviews.map((r) => _ReviewCard(review: r)),
          const SizedBox(height: AppSpacing.md),
          // See all
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(borderRadius: AppSpacing.buttonBorderRadius),
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              ),
              child: Text(
                'Voir tous les avis',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final _Review review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    final months = ['janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin',
                    'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.'];
    final dateLabel = '${review.date.day} ${months[review.date.month - 1]} ${review.date.year}';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Parent initial avatar
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.secondary.withValues(alpha: 0.15),
                child: Text(
                  review.parentName[0],
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.parentName, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                    Text(dateLabel, style: AppTypography.small),
                  ],
                ),
              ),
              RatingStars(rating: review.rating, size: 13),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(review.comment, style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary, height: 1.5)),
          const SizedBox(height: AppSpacing.md),
          const Divider(),
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
                text: TextSpan(children: [
                  TextSpan(
                    text: '${nanny.hourlyRate.toStringAsFixed(0)} FCFA',
                    style: AppTypography.h3.copyWith(color: AppColors.primary),
                  ),
                ]),
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
                  shape: RoundedRectangleBorder(borderRadius: AppSpacing.buttonBorderRadius),
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
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xxl, AppSpacing.xl, 0),
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
