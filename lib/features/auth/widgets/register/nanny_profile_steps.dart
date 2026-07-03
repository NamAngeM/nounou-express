import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/utils/validators.dart';
import 'register_fields.dart';
import 'register_form_data.dart';
import 'register_tiles.dart';

const _experienceOptions = [
  'Débutant (< 1 an)',
  '1–3 ans',
  '3–5 ans',
  '+5 ans',
];
const _ageGroupOptions = [
  'Nourrissons (0–1 an)',
  '1–3 ans',
  '3–6 ans',
  '6–12 ans',
  'Ados',
];
const _nannySkillOptions = [
  'Premiers secours',
  'Aide aux devoirs',
  'Cuisine',
  'Ménage',
  'Activités créatives',
  'Langues étrangères',
  'Enfants handicapés',
  'Conduite',
];
const _diplomaOptions = [
  'Aucun',
  'CAP Petite Enfance',
  'Infirmier(e)',
  'Éducateur(trice)',
  'Autre',
];

// ── SECTION 2 Nanny — KYC ─────────────────────────────────────────────────────
class NannyKycStep extends StatelessWidget {
  final RegisterFormData data;
  final VoidCallback onChanged;

  const NannyKycStep({super.key, required this.data, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return StepContent(
      title: 'Documents & Vérification KYC',
      subtitle: 'Ces documents garantissent la sécurité des familles.',
      children: [
        LabeledField(
              label: 'Numéro CNI *',
              child: RegisterTextField(
                controller: data.cniNumber,
                hint: 'Ex: 123456789',
                validator: Validators.validateCNI,
              ),
            )
            .animate()
            .fadeIn(duration: 400.ms, delay: 0.ms)
            .slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 0.ms),
        DocUploadTile(
              label: 'Photo CNI recto *',
              icon: Icons.credit_card_rounded,
              uploaded: data.hasCNIRecto,
              onTap: () {
                data.hasCNIRecto = true;
                onChanged();
              },
            )
            .animate()
            .fadeIn(duration: 400.ms, delay: 100.ms)
            .slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 100.ms),
        DocUploadTile(
              label: 'Photo CNI verso *',
              icon: Icons.credit_card_rounded,
              uploaded: data.hasCNIVerso,
              onTap: () {
                data.hasCNIVerso = true;
                onChanged();
              },
            )
            .animate()
            .fadeIn(duration: 400.ms, delay: 160.ms)
            .slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 160.ms),
        DocUploadTile(
              label: 'Selfie de vérification *',
              icon: Icons.face_rounded,
              uploaded: data.hasSelfie,
              onTap: () {
                data.hasSelfie = true;
                onChanged();
              },
              subtitle: 'Visage visible, bonne luminosité',
            )
            .animate()
            .fadeIn(duration: 400.ms, delay: 220.ms)
            .slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 220.ms),
        DocUploadTile(
              label: 'Casier judiciaire vierge',
              icon: Icons.description_rounded,
              uploaded: data.hasCriminalRecord,
              onTap: () {
                data.hasCriminalRecord = true;
                onChanged();
              },
              subtitle: 'Optionnel à l\'inscription — requis sous 7 jours',
              required: false,
            )
            .animate()
            .fadeIn(duration: 400.ms, delay: 280.ms)
            .slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 280.ms),
      ],
    );
  }
}

// ── SECTION 3 Nanny — Compétences ─────────────────────────────────────────────
class NannySkillsStep extends StatelessWidget {
  final RegisterFormData data;
  final VoidCallback onChanged;

  const NannySkillsStep({
    super.key,
    required this.data,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return StepContent(
      title: 'Expérience & Compétences',
      children: [
        LabeledField(
              label: 'Années d\'expérience',
              child: RegisterDropdown(
                value: data.experience,
                items: _experienceOptions,
                onChanged: (v) {
                  data.experience = v!;
                  onChanged();
                },
              ),
            )
            .animate()
            .fadeIn(duration: 400.ms, delay: 0.ms)
            .slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 0.ms),
        LabeledField(
              label: 'Tranches d\'âge maîtrisées',
              child: SelectableChips(
                options: _ageGroupOptions,
                selected: data.ageGroups,
                onTap: (v) {
                  toggleSelection(data.ageGroups, v);
                  onChanged();
                },
              ),
            )
            .animate()
            .fadeIn(duration: 400.ms, delay: 100.ms)
            .slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 100.ms),
        LabeledField(
              label: 'Compétences',
              child: SelectableChips(
                options: _nannySkillOptions,
                selected: data.nannySkills,
                onTap: (v) {
                  toggleSelection(data.nannySkills, v);
                  onChanged();
                },
              ),
            )
            .animate()
            .fadeIn(duration: 400.ms, delay: 160.ms)
            .slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 160.ms),
        LabeledField(
              label: 'Diplôme / Formation (optionnel)',
              child: RegisterDropdown(
                value: data.diploma,
                items: _diplomaOptions,
                onChanged: (v) {
                  data.diploma = v!;
                  onChanged();
                },
              ),
            )
            .animate()
            .fadeIn(duration: 400.ms, delay: 220.ms)
            .slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 220.ms),
        LabeledField(
              label: 'Langues parlées',
              child: SelectableChips(
                options: kRegisterLangOptions,
                selected: data.nannyLangs,
                onTap: (v) {
                  toggleSelection(data.nannyLangs, v);
                  onChanged();
                },
              ),
            )
            .animate()
            .fadeIn(duration: 400.ms, delay: 280.ms)
            .slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 280.ms),
      ],
    );
  }
}

// ── SECTION 4 Nanny — Bio ─────────────────────────────────────────────────────
class NannyBioStep extends StatelessWidget {
  final RegisterFormData data;
  final VoidCallback onChanged;

  const NannyBioStep({super.key, required this.data, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return StepContent(
      title: 'Biographie',
      subtitle: 'Une bonne bio augmente vos chances de décrocher des missions.',
      children: [
        LabeledField(
              label:
                  'Bio courte * (150 caractères — affichée sur votre profil)',
              child: RegisterTextField(
                controller: data.shortBio,
                hint:
                    'Ex : "Passionnée de la petite enfance, 3 ans d\'expérience..."',
                maxLines: 3,
                maxLength: 150,
                validator: requiredValidator('La bio courte est requise.'),
              ),
            )
            .animate()
            .fadeIn(duration: 400.ms, delay: 100.ms)
            .slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 100.ms),
        LabeledField(
              label:
                  'Description longue (500 caractères — visible en "Voir plus")',
              child: RegisterTextField(
                controller: data.longBio,
                hint: 'Parlez de votre parcours, vos valeurs, vos méthodes...',
                maxLines: 6,
                maxLength: 500,
              ),
            )
            .animate()
            .fadeIn(duration: 400.ms, delay: 160.ms)
            .slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 160.ms),
      ],
    );
  }
}
