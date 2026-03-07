import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'scale_tap.dart';
import 'avatar_widget.dart';
import 'badge_widget.dart';
import 'rating_stars.dart';

class NannyCard extends StatelessWidget {
  final String nannyId;
  final String name;
  final String? avatarUrl;
  final String quartier;
  final double? distanceKm;
  final double rating;
  final bool isVerified;
  final double hourlyRate;
  final int? reviewCount;

  const NannyCard({
    super.key,
    required this.nannyId,
    required this.name,
    required this.quartier,
    required this.rating,
    required this.hourlyRate,
    this.avatarUrl,
    this.distanceKm,
    this.isVerified = false,
    this.reviewCount,
  });

  @override
  Widget build(BuildContext context) {
    return ScaleTap(
      onTap: () => context.push('/nanny/$nannyId'),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppSpacing.cardBorderRadius,
          boxShadow: AppColors.cardShadow,
          border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Avatar with hero ────────────────────────────────────────────
            Hero(
              tag: 'nanny_avatar_$nannyId',
              child: AppAvatar(
                imageUrl: avatarUrl,
                name: name,
                size: 60,
                showRing: isVerified,
              ),
            ),

            const SizedBox(width: AppSpacing.md),

            // ── Info ────────────────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + badge
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          style: AppTypography.h4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isVerified) ...[
                        const SizedBox(width: AppSpacing.xs),
                        const AppBadge(type: AppBadgeType.verified),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  // Location
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, size: 13, color: AppColors.primary),
                      const SizedBox(width: 3),
                      Flexible(
                        child: Text(
                          distanceKm != null
                              ? '$quartier · ${distanceKm!.toStringAsFixed(1)} km'
                              : quartier,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  // Rating row
                  Row(
                    children: [
                      RatingStars(rating: rating, size: 13),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        rating.toStringAsFixed(1),
                        style: AppTypography.small.copyWith(
                          color: AppColors.gold,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (reviewCount != null) ...[
                        Text(
                          ' ($reviewCount)',
                          style: AppTypography.small.copyWith(color: AppColors.textTertiary),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: AppSpacing.sm),

            // ── Price + CTA ─────────────────────────────────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Rate badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs + 2,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradientH,
                    borderRadius: AppSpacing.chipBorderRadius,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.20),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: hourlyRate.toStringAsFixed(0),
                          style: AppTypography.buttonLabelSm,
                        ),
                        TextSpan(
                          text: ' F',
                          style: AppTypography.small.copyWith(
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text('/heure', style: AppTypography.small.copyWith(color: AppColors.textTertiary)),
                const SizedBox(height: AppSpacing.sm),
                // Book button
                _BookButton(nannyId: nannyId),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BookButton extends StatelessWidget {
  final String nannyId;
  const _BookButton({required this.nannyId});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/nanny/$nannyId'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs + 2),
        decoration: BoxDecoration(
          color: AppColors.primarySurface,
          borderRadius: AppSpacing.chipBorderRadius,
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
        ),
        child: Text(
          'Voir',
          style: AppTypography.small.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
