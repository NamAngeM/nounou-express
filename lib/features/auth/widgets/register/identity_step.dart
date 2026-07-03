import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import 'identity_widgets.dart';
import 'register_fields.dart';
import 'register_form_data.dart';

const _neighborhoods = [
  'Akanda',
  'Angondjé',
  'Nzeng-Ayong',
  'Owendo',
  'Glass',
  'Nombakélé',
  'Alibandeng',
  'Libreville Centre',
  'Autre',
];
const _radiusOptions = ['1 km', '3 km', '5 km', '10 km', 'Toute Libreville'];

// ── SECTION 1 — Identité (partagé parent / nounou) ────────────────────────────
class IdentityStep extends StatelessWidget {
  final RegisterFormData data;
  final bool isNanny;
  final VoidCallback onChanged;

  const IdentityStep({
    super.key,
    required this.data,
    required this.isNanny,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Photo hero ──────────────────────────────────────────────────────
        const IdentityPhotoPicker()
            .animate()
            .fadeIn(duration: 500.ms)
            .scale(begin: const Offset(0.85, 0.85), curve: Curves.easeOutBack),

        const SizedBox(height: AppSpacing.xxl),

        // ── Section Identité ────────────────────────────────────────────────
        IdentityCard(
          icon: Icons.person_outline_rounded,
          title: 'Identité',
          color: AppColors.primary,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: LabeledField(
                    label: 'Prénom *',
                    child: RegisterTextField(
                      controller: data.firstName,
                      hint: 'Marie',
                      icon: Icons.badge_outlined,
                      validator: (v) =>
                          Validators.validateRequired(v, 'Le prénom'),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: LabeledField(
                    label: 'Nom *',
                    child: RegisterTextField(
                      controller: data.lastName,
                      hint: 'Ndong',
                      icon: Icons.badge_outlined,
                      validator: (v) =>
                          Validators.validateRequired(v, 'Le nom'),
                    ),
                  ),
                ),
              ],
            ),
            LabeledField(
              label: 'Date de naissance *${isNanny ? ' (18 ans min.)' : ''}',
              child: RegisterDateTile(
                date: data.birthDate,
                requiredMessage: 'La date de naissance est requise.',
                onTap: () => showRegisterDatePicker(
                  context,
                  current: data.birthDate,
                  minAge: isNanny ? 18 : 0,
                  onPicked: (d) {
                    data.birthDate = d;
                    onChanged();
                  },
                ),
              ),
            ),
            LabeledField(
              label: 'Genre',
              child: GenderSelector(
                selected: data.gender,
                onChanged: (v) {
                  data.gender = v;
                  onChanged();
                },
              ),
            ),
            LabeledField(
              label: 'Nationalité *',
              child: RegisterTextField(
                controller: data.nationality,
                hint: 'Gabonaise',
                icon: Icons.flag_outlined,
                validator: requiredValidator('La nationalité est requise.'),
              ),
            ),
          ],
        ).animate(delay: 80.ms).fadeIn().slideY(begin: 0.06, end: 0),

        const SizedBox(height: AppSpacing.lg),

        // ── Section Coordonnées ─────────────────────────────────────────────
        IdentityCard(
          icon: Icons.phone_outlined,
          title: 'Coordonnées',
          color: AppColors.accent,
          children: [
            LabeledField(
              label: 'Téléphone (+241) *',
              child: RegisterTextField(
                controller: data.phone,
                hint: '06 00 00 00',
                type: TextInputType.phone,
                prefix: '+241 ',
                icon: Icons.phone_outlined,
                validator: Validators.validatePhone,
              ),
            ),
            LabeledField(
              label: 'Email (optionnel)',
              child: RegisterTextField(
                controller: data.email,
                hint: 'marie@email.com',
                type: TextInputType.emailAddress,
                icon: Icons.email_outlined,
                validator: optionalEmailValidator,
              ),
            ),
          ],
        ).animate(delay: 160.ms).fadeIn().slideY(begin: 0.06, end: 0),

        const SizedBox(height: AppSpacing.lg),

        // ── Section Localisation ────────────────────────────────────────────
        IdentityCard(
          icon: Icons.location_on_outlined,
          title: 'Localisation',
          color: AppColors.gold,
          children: [
            LabeledField(
              label: 'Quartier / Commune *',
              child: RegisterDropdown(
                value: data.neighborhood,
                items: _neighborhoods,
                onChanged: (v) {
                  data.neighborhood = v!;
                  onChanged();
                },
              ),
            ),
            if (!isNanny)
              LabeledField(
                label: 'Adresse complète *',
                child: RegisterTextField(
                  controller: data.address,
                  hint: 'Rue, immeuble, précisions...',
                  maxLines: 2,
                  icon: Icons.home_outlined,
                  validator: requiredValidator('L\'adresse est requise.'),
                ),
              ),
            if (isNanny)
              LabeledField(
                label: "Rayon d'intervention",
                child: RegisterDropdown(
                  value: data.radius,
                  items: _radiusOptions,
                  onChanged: (v) {
                    data.radius = v!;
                    onChanged();
                  },
                ),
              ),
          ],
        ).animate(delay: 240.ms).fadeIn().slideY(begin: 0.06, end: 0),

        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }
}
