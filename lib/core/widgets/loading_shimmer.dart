import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class NannyCardShimmer extends StatelessWidget {
  const NannyCardShimmer({super.key});

  BoxDecoration _pill(double radius) =>
      BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(radius));

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppSpacing.cardBorderRadius,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar circle
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            ),
            const SizedBox(width: AppSpacing.md),

            // Text lines
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 120, height: 14, decoration: _pill(4)),
                  const SizedBox(height: AppSpacing.sm),
                  Container(width: 80, height: 11, decoration: _pill(4)),
                  const SizedBox(height: AppSpacing.sm),
                  Container(width: 60, height: 11, decoration: _pill(4)),
                ],
              ),
            ),

            // Right: rate + button
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(width: 60, height: 14, decoration: _pill(4)),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  width: 72,
                  height: 34,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppSpacing.sm),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class NannyListShimmer extends StatelessWidget {
  const NannyListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        5,
        (index) => const Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.md),
          child: NannyCardShimmer(),
        ),
      ),
    );
  }
}
