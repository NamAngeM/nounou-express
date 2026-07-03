import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/validators.dart';

// ══════════════════════════════════════════════════════════════════════════════
// VALIDATION HELPERS
// ══════════════════════════════════════════════════════════════════════════════

/// Validateur « champ requis » avec un message français personnalisé
/// (permet l'accord en genre, ex. « La nationalité est requise. »).
String? Function(String?) requiredValidator(String message) {
  return (value) => (value == null || value.trim().isEmpty) ? message : null;
}

/// Téléphone gabonais facultatif : validé uniquement s'il est renseigné.
String? optionalPhoneValidator(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  return Validators.validatePhone(value);
}

/// Email facultatif : validé uniquement s'il est renseigné.
String? optionalEmailValidator(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  return Validators.validateEmail(value);
}

/// Ouvre le sélecteur de date commun aux étapes d'inscription.
Future<void> showRegisterDatePicker(
  BuildContext context, {
  required DateTime? current,
  required ValueChanged<DateTime> onPicked,
  int minAge = 0,
}) async {
  final now = DateTime.now();
  final picked = await showDatePicker(
    context: context,
    initialDate:
        current ??
        now.subtract(Duration(days: 365 * (minAge > 0 ? minAge : 5))),
    firstDate: DateTime(1950),
    lastDate: minAge > 0 ? now.subtract(Duration(days: 365 * minAge)) : now,
  );
  if (picked != null) onPicked(picked);
}

/// Message d'erreur affiché sous un champ non-Material (date, case à cocher).
class FormFieldError extends StatelessWidget {
  final String message;

  const FormFieldError(this.message, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, left: AppSpacing.xs),
      child: Text(
        message,
        style: AppTypography.caption.copyWith(color: AppColors.danger),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// LAYOUT
// ══════════════════════════════════════════════════════════════════════════════

class StepContent extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> children;

  const StepContent({
    super.key,
    required this.title,
    this.subtitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.h2)
            .animate()
            .fadeIn(duration: 400.ms, delay: 0.ms)
            .slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 0.ms),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: AppTypography.bodySmall,
          ).animate().fadeIn(duration: 400.ms, delay: 60.ms),
        ],
        const SizedBox(height: AppSpacing.xl),
        ...children,
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }
}

class LabeledField extends StatelessWidget {
  final String label;
  final Widget child;

  const LabeledField({super.key, required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }
}

class SectionLabel extends StatelessWidget {
  final String text;

  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
    child: Text(text, style: AppTypography.h4),
  );
}

// ── Text Field ──────────────────────────────────────────────────────────────
class RegisterTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? hint;
  final TextInputType? type;
  final int maxLines;
  final int? maxLength;
  final String? prefix;
  final IconData? icon;
  final String? Function(String?)? validator;

  const RegisterTextField({
    super.key,
    required this.controller,
    this.hint,
    this.type,
    this.maxLines = 1,
    this.maxLength,
    this.prefix,
    this.icon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      maxLines: maxLines,
      maxLength: maxLength,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        prefixText: prefix,
        prefixIcon: icon != null
            ? Icon(icon, size: 18, color: AppColors.textTertiary)
            : null,
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: EdgeInsets.symmetric(
          horizontal: icon != null ? AppSpacing.sm : AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: AppSpacing.inputBorderRadius,
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppSpacing.inputBorderRadius,
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppSpacing.inputBorderRadius,
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }
}

// ── Dropdown ────────────────────────────────────────────────────────────────
class RegisterDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final void Function(String?) onChanged;

  const RegisterDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: AppSpacing.inputBorderRadius,
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppSpacing.inputBorderRadius,
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppSpacing.inputBorderRadius,
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      items: items
          .map(
            (e) => DropdownMenuItem(
              value: e,
              child: Text(e, style: AppTypography.bodyMedium),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}

// ── Date Tile ────────────────────────────────────────────────────────────────
/// Tuile de sélection de date. Si [requiredMessage] est fourni, la tuile
/// participe à la validation du `Form` englobant (date obligatoire).
class RegisterDateTile extends StatelessWidget {
  final DateTime? date;
  final VoidCallback onTap;
  final String? requiredMessage;

  const RegisterDateTile({
    super.key,
    required this.date,
    required this.onTap,
    this.requiredMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (requiredMessage == null) return _tile();
    return FormField<DateTime>(
      validator: (_) => date == null ? requiredMessage : null,
      builder: (state) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _tile(),
          if (state.hasError) FormFieldError(state.errorText!),
        ],
      ),
    );
  }

  Widget _tile() {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppSpacing.inputBorderRadius,
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_rounded,
              size: 18,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              date == null
                  ? 'Sélectionner une date'
                  : '${date!.day.toString().padLeft(2, '0')}/${date!.month.toString().padLeft(2, '0')}/${date!.year}',
              style: AppTypography.bodyMedium.copyWith(
                color: date == null
                    ? AppColors.textSecondary
                    : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Chips (multiselect & single) ─────────────────────────────────────────────
class SelectableChips extends StatelessWidget {
  final List<String> options;
  final Set<String> selected;
  final void Function(String) onTap;
  final bool single;

  const SelectableChips({
    super.key,
    required this.options,
    required this.selected,
    required this.onTap,
    this.single = false,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: options.map((opt) {
        final isSelected = selected.contains(opt);
        return GestureDetector(
          onTap: () => onTap(opt),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.surface,
              borderRadius: AppSpacing.chipBorderRadius,
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
              ),
            ),
            child: Text(
              opt,
              style: AppTypography.bodySmall.copyWith(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Slider ───────────────────────────────────────────────────────────────────
class RegisterSlider extends StatelessWidget {
  final double value;
  final double min, max;
  final int divisions;
  final bool showEstimate;
  final void Function(double) onChanged;

  const RegisterSlider({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    this.showEstimate = false,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${value.round()} ${AppConstants.currency}/h',
              style: AppTypography.h3.copyWith(color: AppColors.primary),
            ),
            if (showEstimate)
              Text(
                '4h = ${(value * 4).round()} ${AppConstants.currency}',
                style: AppTypography.caption,
              ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          activeColor: AppColors.primary,
          inactiveColor: AppColors.border,
          onChanged: onChanged,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${min.round()} ${AppConstants.currency}',
              style: AppTypography.caption,
            ),
            Text(
              '${max.round()} ${AppConstants.currency}',
              style: AppTypography.caption,
            ),
          ],
        ),
      ],
    );
  }
}
