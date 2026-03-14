import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/avatar_widget.dart';

class LeaveReviewScreen extends StatefulWidget {
  final String bookingId;
  const LeaveReviewScreen({super.key, required this.bookingId});

  @override
  State<LeaveReviewScreen> createState() => _LeaveReviewScreenState();
}

class _LeaveReviewScreenState extends State<LeaveReviewScreen> {
  double _rating = 0;
  final TextEditingController _commentController = TextEditingController();
  final List<String> _selectedQualities = [];

  final List<String> _qualities = [
    'Ponctuelle',
    'Douce',
    'Sérieuse',
    'Bienveillante',
    'Créative',
    'Propre',
    'Patiente',
    'Énergique',
  ];

  /// Returns a label and matching color for the current star rating.
  ({String label, Color color}) get _ratingLabel {
    switch (_rating.toInt()) {
      case 1:
        return (label: 'Passable', color: AppColors.danger);
      case 2:
        return (label: 'Moyen', color: AppColors.warning);
      case 3:
        return (label: 'Bien', color: AppColors.gold);
      case 4:
        return (label: 'Très bien', color: AppColors.accent);
      case 5:
        return (label: 'Excellent !', color: AppColors.success);
      default:
        return (label: '', color: AppColors.textTertiary);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ratingInfo = _ratingLabel;

    return Scaffold(
      backgroundColor: AppColors.background,
      // ── App bar sits above the gradient header ──────────────────────────────
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Laisser un avis',
          style: AppTypography.h4.copyWith(
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Column(
        children: [
          // ── Hero gradient header card ────────────────────────────────────
          _HeroHeader(),

          // ── Scrollable content ───────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.xxl,
                AppSpacing.xl,
                AppSpacing.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Star rating card
                  _StarRatingCard(
                        rating: _rating,
                        ratingLabel: ratingInfo.label,
                        ratingColor: ratingInfo.color,
                        onRatingChanged: (v) => setState(() => _rating = v),
                      )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 100.ms)
                      .slideY(
                        begin: 0.12,
                        end: 0,
                        duration: 400.ms,
                        delay: 100.ms,
                      ),

                  const SizedBox(height: AppSpacing.xxl),

                  // Quality tags section
                  if (_rating > 0) ...[
                    _QualityTagsSection(
                          qualities: _qualities,
                          selectedQualities: _selectedQualities,
                          onToggle: (q) {
                            setState(() {
                              if (_selectedQualities.contains(q)) {
                                _selectedQualities.remove(q);
                              } else {
                                _selectedQualities.add(q);
                              }
                            });
                          },
                        )
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 180.ms)
                        .slideY(
                          begin: 0.1,
                          end: 0,
                          duration: 400.ms,
                          delay: 180.ms,
                        ),
                    const SizedBox(height: AppSpacing.xxl),
                  ],

                  // Comment field
                  _CommentField(controller: _commentController)
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 260.ms)
                      .slideY(
                        begin: 0.1,
                        end: 0,
                        duration: 400.ms,
                        delay: 260.ms,
                      ),

                  const SizedBox(height: AppSpacing.xxxl),

                  // Submit button
                  AppButton(
                    label: 'Soumettre mon avis',
                    onPressed: _rating == 0 ? null : () => _submitReview(),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Report a problem
                  TextButton.icon(
                    onPressed: () => _showReportDialog(),
                    icon: const Icon(
                      Icons.flag_outlined,
                      size: 16,
                      color: AppColors.textTertiary,
                    ),
                    label: Text(
                      'Signaler un problème',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Signaler un problème',
          style: AppTypography.h4.copyWith(fontWeight: FontWeight.w800),
        ),
        content: TextField(
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Décrivez le problème rencontré...',
            hintStyle: AppTypography.bodySmall.copyWith(
              color: AppColors.textTertiary,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Annuler',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Signalement envoyé. Merci !'),
                  backgroundColor: AppColors.primary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              );
            },
            child: Text(
              'Envoyer',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _submitReview() {
    // Show success snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 12),
            const Text('Merci ! Votre avis a été enregistré.'),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
    context.go('/home');
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

/// Gradient hero header with avatar, name and subtitle.
class _HeroHeader extends StatelessWidget {
  const _HeroHeader();

  @override
  Widget build(BuildContext context) {
    // Reserve space for status bar + app bar
    final topPad = MediaQuery.of(context).padding.top + kToolbarHeight;

    return Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
            AppSpacing.xxl,
            topPad + AppSpacing.lg,
            AppSpacing.xxl,
            AppSpacing.xxxl,
          ),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primaryLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
          ),
          child: Column(
            children: [
              const AppAvatar(name: 'Julie M.', size: 90),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Comment s\'est passée votre mission avec Julie ?',
                textAlign: TextAlign.center,
                style: AppTypography.h3.copyWith(
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Votre avis aide la communauté Nounou Express.',
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.75),
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 500.ms)
        .slideY(begin: -0.08, end: 0, duration: 500.ms, curve: Curves.easeOut);
  }
}

/// Star rating wrapped in a warm surface card with dynamic label.
class _StarRatingCard extends StatelessWidget {
  final double rating;
  final String ratingLabel;
  final Color ratingColor;
  final ValueChanged<double> onRatingChanged;

  const _StarRatingCard({
    required this.rating,
    required this.ratingLabel,
    required this.ratingColor,
    required this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.xl,
        horizontal: AppSpacing.xxl,
      ),
      decoration: BoxDecoration(
        color: AppColors.warningSurface,
        borderRadius: AppSpacing.cardBorderRadius,
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(
            'Votre note',
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final starValue = index + 1;
              final isSelected = rating >= starValue;
              return GestureDetector(
                onTap: () => onRatingChanged(starValue.toDouble()),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child:
                      Icon(
                            isSelected
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            color: isSelected
                                ? AppColors.warning
                                : AppColors.textTertiary.withValues(alpha: 0.3),
                            size: 48,
                          )
                          .animate(target: isSelected ? 1 : 0)
                          .scale(duration: 200.ms, curve: Curves.easeOutBack),
                ),
              );
            }),
          ),
          if (ratingLabel.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                ratingLabel,
                key: ValueKey(ratingLabel),
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: ratingColor,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Quality tags with a "Points forts" section header.
class _QualityTagsSection extends StatelessWidget {
  final List<String> qualities;
  final List<String> selectedQualities;
  final ValueChanged<String> onToggle;

  const _QualityTagsSection({
    required this.qualities,
    required this.selectedQualities,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            const Icon(
              Icons.thumb_up_outlined,
              size: 18,
              color: AppColors.primary,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Points forts',
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          "Qu'avez-vous le plus apprécié ?",
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: qualities.map((quality) {
            final isSelected = selectedQualities.contains(quality);
            return GestureDetector(
              onTap: () => onToggle(quality),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.primary.withValues(alpha: 0.1),
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [],
                ),
                child: Text(
                  quality,
                  style: AppTypography.small.copyWith(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// Comment text field with an icon label.
class _CommentField extends StatelessWidget {
  final TextEditingController controller;

  const _CommentField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Votre commentaire',
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: controller,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Détaillez votre expérience (optionnel)...',
            hintStyle: AppTypography.bodySmall.copyWith(
              color: AppColors.textTertiary,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                color: AppColors.primary.withValues(alpha: 0.1),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                color: AppColors.primary.withValues(alpha: 0.1),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }
}
