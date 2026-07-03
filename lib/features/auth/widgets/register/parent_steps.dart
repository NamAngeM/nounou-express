import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import 'register_fields.dart';
import 'register_form_data.dart';
import 'register_tiles.dart';

const _careTypeOptions = [
  'À domicile (chez moi)',
  'Chez la nounou',
  'Les deux',
];
const _timeSlotOptions = ['Matin', 'Après-midi', 'Soir', 'Nuit', 'Week-end'];
const _parentCriteria = [
  'Premiers secours',
  'Aide aux devoirs',
  'Expérience nourrissons',
  'Cuisine',
  'Permis de conduire',
];
const _bloodGroups = [
  'A+',
  'A-',
  'B+',
  'B-',
  'AB+',
  'AB-',
  'O+',
  'O-',
  'Inconnu',
];

// ── SECTION 3 Parent — Préférences ────────────────────────────────────────────
class ParentPreferencesStep extends StatelessWidget {
  final RegisterFormData data;
  final VoidCallback onChanged;

  const ParentPreferencesStep({
    super.key,
    required this.data,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return StepContent(
      title: 'Préférences de garde',
      children: [
        LabeledField(
              label: 'Type de garde souhaité',
              child: SelectableChips(
                options: _careTypeOptions,
                selected: {data.careType},
                single: true,
                onTap: (v) {
                  data.careType = v;
                  onChanged();
                },
              ),
            )
            .animate()
            .fadeIn(duration: 400.ms, delay: 100.ms)
            .slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 100.ms),
        LabeledField(
              label: 'Créneaux habituels',
              child: SelectableChips(
                options: _timeSlotOptions,
                selected: data.timeSlots,
                onTap: (v) {
                  toggleSelection(data.timeSlots, v);
                  onChanged();
                },
              ),
            )
            .animate()
            .fadeIn(duration: 400.ms, delay: 160.ms)
            .slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 160.ms),
        LabeledField(
              label: 'Budget horaire maximum',
              child: RegisterSlider(
                value: data.maxBudget,
                min: 1000,
                max: 10000,
                divisions: 18,
                onChanged: (v) {
                  data.maxBudget = v;
                  onChanged();
                },
              ),
            )
            .animate()
            .fadeIn(duration: 400.ms, delay: 220.ms)
            .slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 220.ms),
        LabeledField(
              label: 'Langues parlées à la maison',
              child: SelectableChips(
                options: kRegisterLangOptions,
                selected: data.homeLangs,
                onTap: (v) {
                  toggleSelection(data.homeLangs, v);
                  onChanged();
                },
              ),
            )
            .animate()
            .fadeIn(duration: 400.ms, delay: 280.ms)
            .slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 280.ms),
        LabeledField(
              label: 'Critères importants',
              child: SelectableChips(
                options: _parentCriteria,
                selected: data.careCriteria,
                onTap: (v) {
                  toggleSelection(data.careCriteria, v);
                  onChanged();
                },
              ),
            )
            .animate()
            .fadeIn(duration: 400.ms, delay: 340.ms)
            .slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 340.ms),
      ],
    );
  }
}

// ── SECTION 4 Parent — Urgence ────────────────────────────────────────────────
class ParentEmergencyStep extends StatelessWidget {
  final RegisterFormData data;
  final VoidCallback onChanged;

  const ParentEmergencyStep({
    super.key,
    required this.data,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return StepContent(
      title: 'Urgence & Sécurité',
      children: [
        const SectionLabel('Contact d\'urgence 1 *')
            .animate()
            .fadeIn(duration: 400.ms, delay: 0.ms)
            .slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 0.ms),
        Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: RegisterTextField(
                    controller: data.emerg1Name,
                    hint: 'Nom complet',
                    validator: (v) =>
                        Validators.validateRequired(v, 'Le nom du contact'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: RegisterTextField(
                    controller: data.emerg1Phone,
                    hint: '+241 XX XX XX',
                    type: TextInputType.phone,
                    validator: Validators.validatePhone,
                  ),
                ),
              ],
            )
            .animate()
            .fadeIn(duration: 400.ms, delay: 100.ms)
            .slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 100.ms),
        const SizedBox(height: AppSpacing.lg),
        const SectionLabel('Contact d\'urgence 2 (optionnel)')
            .animate()
            .fadeIn(duration: 400.ms, delay: 160.ms)
            .slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 160.ms),
        Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: RegisterTextField(
                    controller: data.emerg2Name,
                    hint: 'Nom complet',
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: RegisterTextField(
                    controller: data.emerg2Phone,
                    hint: '+241 XX XX XX',
                    type: TextInputType.phone,
                    validator: optionalPhoneValidator,
                  ),
                ),
              ],
            )
            .animate()
            .fadeIn(duration: 400.ms, delay: 220.ms)
            .slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 220.ms),
        const SizedBox(height: AppSpacing.lg),
        const SectionLabel('Médecin de famille (optionnel)')
            .animate()
            .fadeIn(duration: 400.ms, delay: 280.ms)
            .slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 280.ms),
        Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: RegisterTextField(
                    controller: data.doctorName,
                    hint: 'Dr. Nom',
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: RegisterTextField(
                    controller: data.doctorPhone,
                    hint: '+241 XX XX XX',
                    type: TextInputType.phone,
                    validator: optionalPhoneValidator,
                  ),
                ),
              ],
            )
            .animate()
            .fadeIn(duration: 400.ms, delay: 340.ms)
            .slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 340.ms),
        const SizedBox(height: AppSpacing.lg),
        LabeledField(
              label: 'Groupe sanguin (optionnel)',
              child: RegisterDropdown(
                value: data.bloodGroup,
                items: _bloodGroups,
                onChanged: (v) {
                  data.bloodGroup = v!;
                  onChanged();
                },
              ),
            )
            .animate()
            .fadeIn(duration: 400.ms, delay: 400.ms)
            .slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 400.ms),
        RegisterSwitchTile(
          label: 'Autorisation de transport',
          subtitle: 'La nounou peut transporter l\'enfant',
          value: data.transportAuth,
          onChanged: (v) {
            data.transportAuth = v;
            onChanged();
          },
        ).animate().fadeIn(duration: 400.ms, delay: 400.ms),
        RegisterSwitchTile(
          label: 'Autorisation de prise de photo',
          subtitle: 'La nounou peut photographier l\'enfant',
          value: data.photoAuth,
          onChanged: (v) {
            data.photoAuth = v;
            onChanged();
          },
        ).animate().fadeIn(duration: 400.ms, delay: 400.ms),
      ],
    );
  }
}

// ── SECTION 5 Parent — Vérification ───────────────────────────────────────────
class ParentVerificationStep extends StatelessWidget {
  final RegisterFormData data;
  final VoidCallback onChanged;

  const ParentVerificationStep({
    super.key,
    required this.data,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return StepContent(
      title: 'Vérification & Accord',
      subtitle: 'Veuillez lire et accepter les conditions avant de finaliser.',
      children: [
        RegisterCheckTile(
              label: 'J\'accepte les Conditions Générales d\'Utilisation *',
              value: data.acceptCGU,
              requiredMessage: 'Veuillez cocher cette case pour continuer.',
              onChanged: (v) {
                data.acceptCGU = v;
                onChanged();
              },
            )
            .animate()
            .fadeIn(duration: 400.ms, delay: 100.ms)
            .slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 100.ms),
        RegisterCheckTile(
              label: 'J\'accepte la Politique de Confidentialité *',
              value: data.acceptPrivacy,
              requiredMessage: 'Veuillez cocher cette case pour continuer.',
              onChanged: (v) {
                data.acceptPrivacy = v;
                onChanged();
              },
            )
            .animate()
            .fadeIn(duration: 400.ms, delay: 160.ms)
            .slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 160.ms),
        RegisterCheckTile(
              label:
                  'Je certifie que toutes les informations fournies sont exactes *',
              value: data.certifyAccurate,
              requiredMessage: 'Veuillez cocher cette case pour continuer.',
              onChanged: (v) {
                data.certifyAccurate = v;
                onChanged();
              },
            )
            .animate()
            .fadeIn(duration: 400.ms, delay: 220.ms)
            .slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 220.ms),
      ],
    );
  }
}
