import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/validators.dart';
import 'register_fields.dart';
import 'register_form_data.dart';

// ── SECTION 2 Parent — Enfants ────────────────────────────────────────────────
class ParentChildrenStep extends StatelessWidget {
  final RegisterFormData data;
  final VoidCallback onChanged;

  const ParentChildrenStep({
    super.key,
    required this.data,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return StepContent(
      title: 'Informations des enfants',
      subtitle: 'Ajoutez un profil pour chaque enfant.',
      children: [
        for (int i = 0; i < data.children.length; i++) ...[
          _ChildCard(
                index: i,
                info: data.children[i],
                canRemove: data.children.length > 1,
                onRemove: () => _removeChild(i),
                onPickDate: () => showRegisterDatePicker(
                  context,
                  current: data.children[i].birthDate,
                  onPicked: (d) {
                    data.children[i].birthDate = d;
                    onChanged();
                  },
                ),
                onGender: (v) {
                  data.children[i].gender = v;
                  onChanged();
                },
                onNeeds: (v) {
                  data.children[i].specialNeeds = v;
                  onChanged();
                },
              )
              .animate(delay: Duration(milliseconds: 160 + i * 60))
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.08, end: 0, duration: 400.ms),
          const SizedBox(height: AppSpacing.lg),
        ],
        OutlinedButton.icon(
              onPressed: () {
                data.children.add(ChildInfo());
                onChanged();
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text('Ajouter un enfant'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: AppSpacing.buttonBorderRadius,
                ),
              ),
            )
            .animate()
            .fadeIn(duration: 400.ms, delay: 280.ms)
            .slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 280.ms),
      ],
    );
  }

  void _removeChild(int index) {
    final removed = data.children.removeAt(index);
    onChanged();
    // Dispose des contrôleurs après le rebuild, une fois les TextFields
    // correspondants démontés.
    WidgetsBinding.instance.addPostFrameCallback((_) => removed.dispose());
  }
}

// ── Child Card ────────────────────────────────────────────────────────────────
class _ChildCard extends StatelessWidget {
  final int index;
  final ChildInfo info;
  final bool canRemove;
  final VoidCallback onRemove;
  final VoidCallback onPickDate;
  final void Function(String) onGender;
  final void Function(String) onNeeds;

  const _ChildCard({
    required this.index,
    required this.info,
    required this.canRemove,
    required this.onRemove,
    required this.onPickDate,
    required this.onGender,
    required this.onNeeds,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.cardBorderRadius,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Enfant ${index + 1}', style: AppTypography.h4),
              const Spacer(),
              if (canRemove)
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18),
                  color: AppColors.danger,
                  onPressed: onRemove,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          LabeledField(
            label: 'Prénom *',
            child: RegisterTextField(
              controller: info.firstName,
              hint: 'Prénom',
              validator: (v) => Validators.validateRequired(v, 'Le prénom'),
            ),
          ),
          LabeledField(
            label: 'Date de naissance *',
            child: RegisterDateTile(
              date: info.birthDate,
              requiredMessage: 'La date de naissance est requise.',
              onTap: onPickDate,
            ),
          ),
          LabeledField(
            label: 'Sexe',
            child: SelectableChips(
              options: const ['Garçon', 'Fille'],
              selected: {info.gender},
              single: true,
              onTap: onGender,
            ),
          ),
          LabeledField(
            label: 'Besoins spéciaux',
            child: SelectableChips(
              options: const ['Aucun', 'Allergie', 'Handicap', 'Autre'],
              selected: {info.specialNeeds},
              single: true,
              onTap: onNeeds,
            ),
          ),
          LabeledField(
            label: 'Allergies connues',
            child: RegisterTextField(
              controller: info.allergies,
              hint: 'Ex: arachides, lait...',
            ),
          ),
          LabeledField(
            label: 'Médicaments réguliers (optionnel)',
            child: RegisterTextField(
              controller: info.medications,
              hint: 'Nom, dosage, fréquence...',
            ),
          ),
        ],
      ),
    );
  }
}
