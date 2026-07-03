import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import 'register_fields.dart';
import 'register_form_data.dart';
import 'register_tiles.dart';

const _nannyCarModeOptions = ['À domicile parent', 'Chez moi', 'Les deux'];
const _maxChildrenOptions = ['1', '2', '3', '4+'];
const _paymentOptions = ['Espèces', 'Airtel Money', 'Moov Money'];

// ── SECTION 5 Nanny — Disponibilités ──────────────────────────────────────────
class NannyAvailabilityStep extends StatelessWidget {
  final RegisterFormData data;
  final VoidCallback onChanged;

  const NannyAvailabilityStep({
    super.key,
    required this.data,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return StepContent(
      title: 'Disponibilités & Tarifs',
      children: [
        LabeledField(
              label: 'Tarif horaire *',
              child: RegisterSlider(
                value: data.hourlyRate,
                min: 1000,
                max: 10000,
                divisions: 18,
                showEstimate: true,
                onChanged: (v) {
                  data.hourlyRate = v;
                  onChanged();
                },
              ),
            )
            .animate()
            .fadeIn(duration: 400.ms, delay: 0.ms)
            .slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 0.ms),
        LabeledField(
              label: 'Disponibilités habituelles',
              child: _AvailabilityGrid(
                availability: data.availability,
                onChanged: (day, slot) {
                  toggleSelection(data.availability[day]!, slot);
                  onChanged();
                },
              ),
            )
            .animate()
            .fadeIn(duration: 400.ms, delay: 100.ms)
            .slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 100.ms),
        RegisterSwitchTile(
              label: 'Disponible pour missions urgentes',
              subtitle: 'Moins de 2h de préavis',
              value: data.urgentAvailable,
              onChanged: (v) {
                data.urgentAvailable = v;
                onChanged();
              },
            )
            .animate()
            .fadeIn(duration: 400.ms, delay: 160.ms)
            .slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 160.ms),
        LabeledField(
              label: 'Mode de garde accepté',
              child: SelectableChips(
                options: _nannyCarModeOptions,
                selected: {data.nannyCarMode},
                single: true,
                onTap: (v) {
                  data.nannyCarMode = v;
                  onChanged();
                },
              ),
            )
            .animate()
            .fadeIn(duration: 400.ms, delay: 220.ms)
            .slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 220.ms),
        LabeledField(
              label: 'Nombre maximum d\'enfants simultanés',
              child: SelectableChips(
                options: _maxChildrenOptions,
                selected: {data.maxChildren},
                single: true,
                onTap: (v) {
                  data.maxChildren = v;
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

// ── SECTION 6 Nanny — Paiement ────────────────────────────────────────────────
class NannyPaymentStep extends StatelessWidget {
  final RegisterFormData data;
  final VoidCallback onChanged;

  const NannyPaymentStep({
    super.key,
    required this.data,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return StepContent(
      title: 'Informations de paiement',
      children: [
        LabeledField(
              label: 'Méthode(s) acceptée(s)',
              child: SelectableChips(
                options: _paymentOptions,
                selected: data.paymentMethods,
                onTap: (v) {
                  toggleSelection(data.paymentMethods, v);
                  onChanged();
                },
              ),
            )
            .animate()
            .fadeIn(duration: 400.ms, delay: 0.ms)
            .slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 0.ms),
        if (data.paymentMethods.contains('Airtel Money'))
          LabeledField(
                label: 'Numéro Airtel Money',
                child: RegisterTextField(
                  controller: data.airtelNumber,
                  hint: '07 XX XX XX',
                  type: TextInputType.phone,
                  validator: optionalPhoneValidator,
                ),
              )
              .animate()
              .fadeIn(duration: 400.ms, delay: 100.ms)
              .slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 100.ms),
        if (data.paymentMethods.contains('Moov Money'))
          LabeledField(
                label: 'Numéro Moov Money',
                child: RegisterTextField(
                  controller: data.moovNumber,
                  hint: '06 XX XX XX',
                  type: TextInputType.phone,
                  validator: optionalPhoneValidator,
                ),
              )
              .animate()
              .fadeIn(duration: 400.ms, delay: 100.ms)
              .slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 100.ms),
      ],
    );
  }
}

// ── Availability Grid ─────────────────────────────────────────────────────────
class _AvailabilityGrid extends StatelessWidget {
  final Map<String, Set<String>> availability;
  final void Function(String day, String slot) onChanged;

  static const _days = [
    'Lundi',
    'Mardi',
    'Mercredi',
    'Jeudi',
    'Vendredi',
    'Samedi',
    'Dimanche',
  ];
  static const _slots = ['Matin', 'Après-midi', 'Soir', 'Nuit'];

  const _AvailabilityGrid({
    required this.availability,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const SizedBox(width: 76),
            ..._slots.map(
              (s) => Expanded(
                child: Text(
                  s,
                  style: AppTypography.small,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        ..._days.map((day) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                SizedBox(
                  width: 76,
                  child: Text(
                    day,
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ..._slots.map((slot) {
                  final active = availability[day]?.contains(slot) ?? false;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => onChanged(day, slot),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        height: 32,
                        decoration: BoxDecoration(
                          color: active
                              ? AppColors.primary
                              : AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: active
                            ? const Icon(
                                Icons.check_rounded,
                                size: 14,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        }),
      ],
    );
  }
}
