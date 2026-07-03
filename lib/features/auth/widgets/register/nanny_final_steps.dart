import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_spacing.dart';
import 'register_fields.dart';
import 'register_form_data.dart';
import 'register_tiles.dart';

// ── SECTION 7 Nanny — Références ──────────────────────────────────────────────
class NannyReferencesStep extends StatelessWidget {
  final RegisterFormData data;
  final VoidCallback onChanged;

  const NannyReferencesStep({
    super.key,
    required this.data,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return StepContent(
      title: 'Références professionnelles',
      subtitle: 'Les références augmentent la confiance des familles.',
      children: [
        const SectionLabel('Référence 1 (recommandé)')
            .animate()
            .fadeIn(duration: 400.ms, delay: 0.ms)
            .slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 0.ms),
        RegisterTextField(controller: data.ref1.name, hint: 'Nom complet')
            .animate()
            .fadeIn(duration: 400.ms, delay: 100.ms)
            .slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 100.ms),
        const SizedBox(height: AppSpacing.sm),
        RegisterTextField(
              controller: data.ref1.phone,
              hint: '+241 XX XX XX',
              type: TextInputType.phone,
              validator: optionalPhoneValidator,
            )
            .animate()
            .fadeIn(duration: 400.ms, delay: 160.ms)
            .slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 160.ms),
        const SizedBox(height: AppSpacing.sm),
        RegisterTextField(
              controller: data.ref1.relation,
              hint: 'Relation (ex : Ancien employeur)',
            )
            .animate()
            .fadeIn(duration: 400.ms, delay: 220.ms)
            .slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 220.ms),
        const SizedBox(height: AppSpacing.xl),
        const SectionLabel('Référence 2 (optionnel)')
            .animate()
            .fadeIn(duration: 400.ms, delay: 280.ms)
            .slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 280.ms),
        RegisterTextField(controller: data.ref2.name, hint: 'Nom complet')
            .animate()
            .fadeIn(duration: 400.ms, delay: 340.ms)
            .slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 340.ms),
        const SizedBox(height: AppSpacing.sm),
        RegisterTextField(
              controller: data.ref2.phone,
              hint: '+241 XX XX XX',
              type: TextInputType.phone,
              validator: optionalPhoneValidator,
            )
            .animate()
            .fadeIn(duration: 400.ms, delay: 400.ms)
            .slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 400.ms),
        const SizedBox(height: AppSpacing.sm),
        RegisterTextField(controller: data.ref2.relation, hint: 'Relation')
            .animate()
            .fadeIn(duration: 400.ms, delay: 400.ms)
            .slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 400.ms),
      ],
    );
  }
}

// ── SECTION 8 Nanny — Engagement ──────────────────────────────────────────────
class NannyEngagementStep extends StatelessWidget {
  final RegisterFormData data;
  final VoidCallback onChanged;

  const NannyEngagementStep({
    super.key,
    required this.data,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return StepContent(
      title: 'Engagement & Vérification',
      subtitle:
          'En rejoignant Nounou Express, vous vous engagez à respecter nos standards.',
      children: [
        RegisterCheckTile(
              label:
                  'Je certifie que toutes les informations fournies sont exactes *',
              value: data.certifyNanny,
              requiredMessage: 'Veuillez cocher cette case pour continuer.',
              onChanged: (v) {
                data.certifyNanny = v;
                onChanged();
              },
            )
            .animate()
            .fadeIn(duration: 400.ms, delay: 100.ms)
            .slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 100.ms),
        RegisterCheckTile(
              label: 'J\'accepte les Conditions Générales d\'Utilisation *',
              value: data.acceptCGUNanny,
              requiredMessage: 'Veuillez cocher cette case pour continuer.',
              onChanged: (v) {
                data.acceptCGUNanny = v;
                onChanged();
              },
            )
            .animate()
            .fadeIn(duration: 400.ms, delay: 160.ms)
            .slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 160.ms),
        RegisterCheckTile(
              label: 'J\'accepte la Politique de Confidentialité *',
              value: data.acceptPrivacyNanny,
              requiredMessage: 'Veuillez cocher cette case pour continuer.',
              onChanged: (v) {
                data.acceptPrivacyNanny = v;
                onChanged();
              },
            )
            .animate()
            .fadeIn(duration: 400.ms, delay: 190.ms)
            .slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 190.ms),
        RegisterCheckTile(
              label: 'J\'autorise Nounou Express à vérifier mon identité *',
              value: data.acceptVerification,
              requiredMessage: 'Veuillez cocher cette case pour continuer.',
              onChanged: (v) {
                data.acceptVerification = v;
                onChanged();
              },
            )
            .animate()
            .fadeIn(duration: 400.ms, delay: 220.ms)
            .slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 220.ms),
        RegisterCheckTile(
              label: 'Je m\'engage à respecter la charte de bonne conduite *',
              value: data.acceptCharter,
              requiredMessage: 'Veuillez cocher cette case pour continuer.',
              onChanged: (v) {
                data.acceptCharter = v;
                onChanged();
              },
            )
            .animate()
            .fadeIn(duration: 400.ms, delay: 280.ms)
            .slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 280.ms),
      ],
    );
  }
}
