import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/avatar_widget.dart';
import '../../../core/widgets/rating_stars.dart';
import '../../../data/models/nanny_model.dart';
import '../../../data/providers/data_providers.dart';

const _mockQuartiers = [
  'Akanda',
  'Angondjé',
  'Nzeng-Ayong',
  'Owendo',
  'Glass',
  'Nombakélé',
  'Alibandeng',
  'PK8',
  'Louis',
  'Batterie IV',
];

const _mockDistances = [1.2, 0.8, 2.5, 1.9, 3.1, 0.5, 4.2, 2.1, 1.7, 3.8];

class MapScreen extends ConsumerWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nanniesAsync = ref.watch(nanniesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: nanniesAsync.when(
        data: (nannies) => _MapBody(nannies: nannies),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
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
    );
  }
}

class _MapBody extends StatelessWidget {
  final List<NannyModel> nannies;
  const _MapBody({required this.nannies});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ── Map placeholder ──────────────────────────────────────────
        _MapPlaceholder(),

        // ── Top bar ─────────────────────────────────────────────────
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                // Back / Liste button
                GestureDetector(
                  onTap: () =>
                      context.canPop() ? context.pop() : context.go('/search'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(
                        AppSpacing.badgeRadius,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.secondary.withValues(alpha: 0.12),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.list_rounded,
                          size: 18,
                          color: AppColors.textPrimary,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'Liste',
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                // Result count chip
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppSpacing.badgeRadius),
                  ),
                  child: Text(
                    '${nannies.length} nounous',
                    style: AppTypography.caption.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Draggable bottom sheet ───────────────────────────────────
        DraggableScrollableSheet(
          initialChildSize: 0.38,
          minChildSize: 0.18,
          maxChildSize: 0.82,
          snap: true,
          snapSizes: const [0.18, 0.38, 0.82],
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x18000000),
                    blurRadius: 20,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Handle
                  Padding(
                    padding: const EdgeInsets.only(
                      top: AppSpacing.md,
                      bottom: AppSpacing.sm,
                    ),
                    child: Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                    ),
                    child: Row(
                      children: [
                        Text('Nounous à proximité', style: AppTypography.h3),
                        const Spacer(),
                        const Icon(
                          Icons.keyboard_arrow_up_rounded,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  // List
                  Expanded(
                    child: ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.xl,
                        AppSpacing.sm,
                        AppSpacing.xl,
                        AppSpacing.xxxl,
                      ),
                      itemCount: nannies.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        final n = nannies[index];
                        final quartier =
                            _mockQuartiers[index.clamp(
                              0,
                              _mockQuartiers.length - 1,
                            )];
                        final distance =
                            _mockDistances[index.clamp(
                              0,
                              _mockDistances.length - 1,
                            )];
                        return _NannyMapCard(
                          nanny: n,
                          quartier: quartier,
                          distance: distance,
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

// ─────────────────────────────────────── Map placeholder ──
class _MapPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFFE8EAF0),
      child: Stack(
        children: [
          // Grid lines to suggest a map
          CustomPaint(size: Size.infinite, painter: _GridPainter()),
          // Center icon + text
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.secondary.withValues(alpha: 0.1),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.map_rounded,
                    size: 40,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Vue carte',
                  style: AppTypography.h3.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Bientôt disponible',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Mock location pins
          ..._buildMockPins(),
        ],
      ),
    );
  }

  List<Widget> _buildMockPins() {
    final positions = [
      const Offset(0.25, 0.2),
      const Offset(0.6, 0.25),
      const Offset(0.4, 0.35),
      const Offset(0.75, 0.4),
      const Offset(0.2, 0.5),
    ];
    return positions.map((pos) {
      return Positioned(
        left: pos.dx,
        top: pos.dy,
        child: FractionalTranslation(
          translation: const Offset(-0.5, -0.5),
          child: LayoutBuilder(
            builder: (context, constraints) => Transform.translate(
              offset: Offset(
                pos.dx * MediaQuery.of(context).size.width,
                pos.dy * (MediaQuery.of(context).size.height * 0.62),
              ),
              child: const _MapPin(),
            ),
          ),
        ),
      );
    }).toList();
  }
}

class _MapPin extends StatelessWidget {
  const _MapPin();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            '3500 F',
            style: AppTypography.small.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        CustomPaint(size: const Size(10, 6), painter: _PinTailPainter()),
      ],
    );
  }
}

class _PinTailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.primary;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..strokeWidth = 1;
    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─────────────────────────────────────── Compact nanny card for map sheet ──
class _NannyMapCard extends StatelessWidget {
  final NannyModel nanny;
  final String quartier;
  final double distance;

  const _NannyMapCard({
    required this.nanny,
    required this.quartier,
    required this.distance,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/nanny/${nanny.id}'),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppSpacing.cardBorderRadius,
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            AppAvatar(name: nanny.name, size: 48),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nanny.name,
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 12,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '$quartier · ${distance.toStringAsFixed(1)} km',
                        style: AppTypography.small,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  RatingStars(rating: nanny.rating, size: 12),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  nanny.hourlyRate.toStringAsFixed(0),
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${AppConstants.currency}/h',
                  style: AppTypography.small.copyWith(color: AppColors.primary),
                ),
                const SizedBox(height: AppSpacing.sm),
                if (nanny.isVerified)
                  const Icon(
                    Icons.verified_rounded,
                    size: 16,
                    color: AppColors.accent,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
