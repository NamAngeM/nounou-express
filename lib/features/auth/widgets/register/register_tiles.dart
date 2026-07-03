import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import 'register_fields.dart';

// ── Switch Tile ───────────────────────────────────────────────────────────────
class RegisterSwitchTile extends StatelessWidget {
  final String label;
  final String? subtitle;
  final bool value;
  final void Function(bool) onChanged;

  const RegisterSwitchTile({
    super.key,
    required this.label,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.cardBorderRadius,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null)
                  Text(subtitle!, style: AppTypography.caption),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

// ── Checkbox Tile ─────────────────────────────────────────────────────────────
/// Case à cocher stylée. Si [requiredMessage] est fourni, la case doit être
/// cochée pour que le `Form` englobant soit valide.
class RegisterCheckTile extends StatelessWidget {
  final String label;
  final bool value;
  final void Function(bool) onChanged;
  final String? requiredMessage;

  const RegisterCheckTile({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.requiredMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (requiredMessage == null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: _tile(),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: FormField<bool>(
        validator: (_) => value ? null : requiredMessage,
        builder: (state) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _tile(),
            if (state.hasError) FormFieldError(state.errorText!),
          ],
        ),
      ),
    );
  }

  Widget _tile() {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: value
              ? AppColors.primary.withValues(alpha: 0.06)
              : AppColors.surface,
          borderRadius: AppSpacing.cardBorderRadius,
          border: Border.all(
            color: value ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: value ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: value ? AppColors.primary : AppColors.border,
                  width: 2,
                ),
              ),
              child: value
                  ? const Icon(
                      Icons.check_rounded,
                      size: 14,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Document Upload ───────────────────────────────────────────────────────────
class DocUploadTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool uploaded;
  final VoidCallback onTap;
  final String? subtitle;
  final bool required;

  const DocUploadTile({
    super.key,
    required this.label,
    required this.icon,
    required this.uploaded,
    required this.onTap,
    this.subtitle,
    this.required = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: uploaded
              ? AppColors.success.withValues(alpha: 0.06)
              : AppColors.surface,
          borderRadius: AppSpacing.cardBorderRadius,
          border: Border.all(
            color: uploaded ? AppColors.success : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: uploaded
                    ? AppColors.success.withValues(alpha: 0.12)
                    : AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                uploaded ? Icons.check_circle_rounded : icon,
                color: uploaded ? AppColors.success : AppColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null)
                    Text(subtitle!, style: AppTypography.caption),
                  if (!required)
                    Text(
                      'Optionnel',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              uploaded ? Icons.check_rounded : Icons.upload_rounded,
              color: uploaded ? AppColors.success : AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bottom Navigation ─────────────────────────────────────────────────────────
class RegisterBottomNav extends StatelessWidget {
  final int currentStep, totalSteps;
  final VoidCallback onNext, onPrev;

  const RegisterBottomNav({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.onNext,
    required this.onPrev,
  });

  @override
  Widget build(BuildContext context) {
    final isLast = currentStep == totalSteps - 1;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.lg + bottomPad,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          if (currentStep > 0) ...[
            Expanded(
              child:
                  OutlinedButton(
                        onPressed: onPrev,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textPrimary,
                          side: const BorderSide(color: AppColors.border),
                          minimumSize: const Size(0, 52),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppSpacing.buttonBorderRadius,
                          ),
                        ),
                        child: const Text('Précédent'),
                      )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 340.ms)
                      .slideY(
                        begin: 0.08,
                        end: 0,
                        duration: 400.ms,
                        delay: 340.ms,
                      ),
            ),
            const SizedBox(width: AppSpacing.md),
          ],
          Expanded(
            flex: 2,
            child:
                ElevatedButton(
                      onPressed: onNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 52),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: AppSpacing.buttonBorderRadius,
                        ),
                      ),
                      child: Text(
                        isLast ? 'Créer mon compte' : 'Suivant',
                        style: AppTypography.buttonLabel,
                      ),
                    )
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 400.ms)
                    .slideY(
                      begin: 0.08,
                      end: 0,
                      duration: 400.ms,
                      delay: 400.ms,
                    ),
          ),
        ],
      ),
    );
  }
}
