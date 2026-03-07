import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'scale_tap.dart';

enum AppButtonType { primary, secondary, danger, text, ghost }

enum AppButtonSize { small, medium, large }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final bool isLoading;
  final IconData? icon;
  final bool isFullWidth;
  final AppButtonSize size;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.type = AppButtonType.primary,
    this.isLoading = false,
    this.icon,
    this.isFullWidth = true,
    this.size = AppButtonSize.medium,
  });

  double get _height => switch (size) {
        AppButtonSize.small  => 40,
        AppButtonSize.medium => 54,
        AppButtonSize.large  => 60,
      };

  double get _fontSize => switch (size) {
        AppButtonSize.small  => 14,
        AppButtonSize.medium => 16,
        AppButtonSize.large  => 17,
      };

  Color get _fgColor => switch (type) {
        AppButtonType.secondary => AppColors.primary,
        AppButtonType.text      => AppColors.primary,
        AppButtonType.ghost     => AppColors.textSecondary,
        _                       => Colors.white,
      };

  Gradient? get _gradient => switch (type) {
        AppButtonType.primary => AppColors.primaryGradientH,
        AppButtonType.danger  => const LinearGradient(
            colors: [Color(0xFFE53935), Color(0xFFEF5350)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        _ => null,
      };

  Widget _content() {
    if (isLoading) {
      return SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          color: _fgColor,
          strokeWidth: 2.5,
        ),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: _fontSize + 4, color: _fgColor),
          const SizedBox(width: AppSpacing.sm),
        ],
        Text(
          label,
          style: AppTypography.buttonLabel.copyWith(
            fontSize: _fontSize,
            color: _fgColor,
          ),
        ),
      ],
    );
  }

  // ── Gradient primary / danger ──────────────────────────────────────────────
  Widget _gradientButton(bool disabled) {
    return Container(
      decoration: BoxDecoration(
        gradient: disabled ? null : _gradient,
        color: disabled ? AppColors.textTertiary : null,
        borderRadius: AppSpacing.buttonBorderRadius,
        boxShadow: disabled
            ? null
            : (type == AppButtonType.danger
                ? [
                    BoxShadow(
                      color: AppColors.danger.withValues(alpha: 0.30),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : AppColors.primaryShadow),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: disabled ? null : onPressed,
          borderRadius: AppSpacing.buttonBorderRadius,
          splashColor: Colors.white.withValues(alpha: 0.15),
          highlightColor: Colors.white.withValues(alpha: 0.08),
          child: SizedBox(
            height: _height,
            child: Center(child: _content()),
          ),
        ),
      ),
    );
  }

  Widget _outlined(bool disabled) => Container(
        decoration: BoxDecoration(
          borderRadius: AppSpacing.buttonBorderRadius,
          border: Border.all(
            color: disabled ? AppColors.border : AppColors.primary,
            width: 1.5,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: disabled ? null : onPressed,
            borderRadius: AppSpacing.buttonBorderRadius,
            splashColor: AppColors.primarySurface,
            child: SizedBox(
              height: _height,
              child: Center(child: _content()),
            ),
          ),
        ),
      );

  Widget _ghost(bool disabled) => Container(
        decoration: BoxDecoration(
          color: disabled ? AppColors.border : AppColors.surfaceVariant,
          borderRadius: AppSpacing.buttonBorderRadius,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: disabled ? null : onPressed,
            borderRadius: AppSpacing.buttonBorderRadius,
            child: SizedBox(
              height: _height,
              child: Center(child: _content()),
            ),
          ),
        ),
      );

  Widget _textBtn(bool disabled) => TextButton(
        onPressed: disabled ? null : onPressed,
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: EdgeInsets.zero,
        ),
        child: _content(),
      );

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null || isLoading;

    Widget btn = switch (type) {
      AppButtonType.primary || AppButtonType.danger => _gradientButton(disabled),
      AppButtonType.secondary                       => _outlined(disabled),
      AppButtonType.ghost                           => _ghost(disabled),
      AppButtonType.text                            => _textBtn(disabled),
    };

    // SOS pulse animation
    if (type == AppButtonType.danger && !disabled) {
      btn = btn
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scaleXY(begin: 1.0, end: 1.04, duration: 900.ms, curve: Curves.easeInOut);
    }

    return Opacity(
      opacity: (disabled && !isLoading) ? 0.55 : 1.0,
      child: SizedBox(
        width: isFullWidth ? double.infinity : null,
        child: ScaleTap(
          onTap: disabled ? null : onPressed,
          child: btn,
        ),
      ),
    );
  }
}
