import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

enum AppBadgeType { verified, superNanny, available, gold }

class AppBadge extends StatelessWidget {
  final AppBadgeType type;
  final String? customLabel;

  const AppBadge({super.key, required this.type, this.customLabel});

  @override
  Widget build(BuildContext context) {
    final cfg = _config;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: cfg.background,
        borderRadius: AppSpacing.badgeBorderRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(cfg.icon, size: 11, color: cfg.foreground),
          const SizedBox(width: 4),
          Text(
            customLabel ?? cfg.label,
            style: AppTypography.small.copyWith(
              color: cfg.foreground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  _BadgeConfig get _config => switch (type) {
        AppBadgeType.verified => _BadgeConfig(
            icon: Icons.verified_rounded,
            label: 'Vérifiée',
            background: AppColors.accent.withValues(alpha: 0.15),
            foreground: AppColors.accent,
          ),
        AppBadgeType.superNanny => _BadgeConfig(
            icon: Icons.star_rounded,
            label: 'Super Nounou',
            background: AppColors.warning.withValues(alpha: 0.15),
            foreground: const Color(0xFFB8860B),
          ),
        AppBadgeType.available => _BadgeConfig(
            icon: Icons.circle,
            label: 'Disponible',
            background: AppColors.success.withValues(alpha: 0.15),
            foreground: AppColors.success,
          ),
        AppBadgeType.gold => _BadgeConfig(
            icon: Icons.emoji_events_rounded,
            label: 'Gold',
            background: AppColors.warning.withValues(alpha: 0.2),
            foreground: const Color(0xFFB8860B),
          ),
      };
}

class _BadgeConfig {
  final IconData icon;
  final String label;
  final Color background;
  final Color foreground;

  const _BadgeConfig({
    required this.icon,
    required this.label,
    required this.background,
    required this.foreground,
  });
}
