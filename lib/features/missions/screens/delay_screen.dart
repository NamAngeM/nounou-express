import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_back_button.dart';
import '../../../core/widgets/app_loader.dart';
import '../../../data/models/mission_model.dart';
import '../../../data/providers/data_providers.dart';
import '../../auth/providers/auth_provider.dart';

class DelayScreen extends ConsumerStatefulWidget {
  final String missionId;
  final double hourlyRate;

  const DelayScreen({
    super.key,
    required this.missionId,
    required this.hourlyRate,
  });

  @override
  ConsumerState<DelayScreen> createState() => _DelayScreenState();
}

class _DelayScreenState extends ConsumerState<DelayScreen> {
  int? _selectedMinutes;
  String? _parentChoice; // 'en_route' | 'bloque'
  bool _showDurationSelector = false;

  /// Le point de vue (nounou qui prolonge / parent en retard) est déduit
  /// du rôle de la session — plus de toggle manuel.
  bool get _isNanny => ref.watch(authProvider).isNanny;

  // ── Helpers ─────────────────────────────────────────────────────────────────

  int _extraCostFcfa(int minutes) {
    final double hours = minutes <= 30 ? 0.5 : (minutes / 60.0).ceilToDouble();
    return (hours * widget.hourlyRate).toInt();
  }

  int _plannedCostFcfa(MissionModel mission) {
    return (mission.plannedHours * widget.hourlyRate).ceil().toInt();
  }

  String _minutesLabel(int minutes) {
    if (minutes < 60) return '+$minutes min';
    return '+${minutes ~/ 60}h';
  }

  String _formatFcfa(int amount) {
    if (amount >= 1000) {
      final k = amount ~/ 1000;
      final rest = amount % 1000;
      if (rest == 0) return '$k 000';
      return '$k ${rest.toString().padLeft(3, '0')}';
    }
    return amount.toString();
  }

  int _minutesLate(MissionModel mission) {
    final now = DateTime.now();
    final parts = mission.endTime.split(':');
    final planned = DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
    final diff = now.difference(planned).inMinutes;
    return diff > 0 ? diff : 0;
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final missionAsync = ref.watch(missionByIdProvider(widget.missionId));
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: missionAsync.when(
        loading: () => const AppLoader(),
        error: (e, _) => Center(
          child: Text('Mission introuvable', style: AppTypography.bodyMedium),
        ),
        data: (mission) => Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeaderWarningCard(mission),
                    const SizedBox(height: AppSpacing.lg),
                    _isNanny
                        ? _buildNannyBody(mission)
                        : _buildParentBody(mission),
                    const SizedBox(height: AppSpacing.lg),
                    if (_selectedMinutes != null) _buildCostBreakdown(mission),
                    const SizedBox(height: AppSpacing.lg),
                    _buildEmergencyOption(),
                    const SizedBox(height: AppSpacing.xxxl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: const AppBackButton(),
      title: Row(
        children: [
          const Icon(Icons.alarm_rounded, color: AppColors.warning, size: 22),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'Retard signalé',
            style: AppTypography.h4.copyWith(color: AppColors.warning),
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppColors.border),
      ),
    );
  }

  // ── Header warning card ──────────────────────────────────────────────────────

  Widget _buildHeaderWarningCard(MissionModel mission) {
    final isNanny = _isNanny;
    final title = isNanny
        ? "L'heure de fin prévue est dépassée"
        : 'Vous êtes en retard !';
    final subtitle = isNanny
        ? 'Heure de fin prévue : ${mission.endTime}'
        : 'Retard actuel : ${_minutesLate(mission)} min — '
              'votre nounou attend';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.warningSurface,
        borderRadius: AppSpacing.cardBorderRadius,
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: AppColors.warning,
              size: 28,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.h4.copyWith(color: AppColors.warning),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(subtitle, style: AppTypography.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Nanny body ───────────────────────────────────────────────────────────────

  Widget _buildNannyBody(MissionModel mission) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Le parent n\'est pas encore rentré. Combien de temps estimez-vous attendre ?',
          style: AppTypography.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.lg),
        ..._durationOptions.map(_buildNannyDurationCard),
        _buildNannyDurationCard(null), // "Je ne sais pas"
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: _selectedMinutes != null || _selectedMinutes == -1
                ? () => _onNannySend(mission)
                : null,
            icon: const Icon(Icons.notifications_rounded, color: Colors.white),
            label: Text(
              'Envoyer la notification au parent',
              style: AppTypography.buttonLabel,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
              disabledBackgroundColor: AppColors.surfaceVariant,
              shape: const RoundedRectangleBorder(
                borderRadius: AppSpacing.buttonBorderRadius,
              ),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }

  static const List<int> _durationOptions = [15, 30, 60];

  Widget _buildNannyDurationCard(int? minutes) {
    final isUnknown = minutes == null;
    final isSelected = isUnknown
        ? _selectedMinutes == -1
        : _selectedMinutes == minutes;
    final label = isUnknown ? 'Je ne sais pas' : _minutesLabel(minutes);
    final extraCost = minutes != null ? _extraCostFcfa(minutes) : null;

    return GestureDetector(
      onTap: () => setState(() {
        _selectedMinutes = isUnknown ? -1 : minutes;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primarySurface : AppColors.surface,
          borderRadius: AppSpacing.cardBorderRadius,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [] : AppColors.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 14,
                    )
                  : null,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                style: AppTypography.h4.copyWith(
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
            ),
            if (extraCost != null)
              Text(
                '+${_formatFcfa(extraCost)} ${AppConstants.currency}',
                style: AppTypography.labelLg.copyWith(color: AppColors.success),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _onNannySend(MissionModel mission) async {
    await _submitDelayRequest(mission, reason: 'autre');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Notification envoyée au parent.',
          style: AppTypography.bodyMedium.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.warning,
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(
          borderRadius: AppSpacing.cardBorderRadius,
        ),
      ),
    );
  }

  // ── Parent body ──────────────────────────────────────────────────────────────

  Widget _buildParentBody(MissionModel mission) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Votre nounou attend. Que se passe-t-il ?',
          style: AppTypography.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.lg),
        _buildParentChoiceCard(
          choice: 'en_route',
          icon: Icons.directions_car_rounded,
          label: 'Je suis en route',
          subtitle: 'Indiquez votre heure d\'arrivée estimée',
          color: AppColors.accent,
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildParentChoiceCard(
          choice: 'bloque',
          icon: Icons.report_problem_rounded,
          label: 'Je suis bloqué(e)',
          subtitle: 'Cas de force majeure — contactez la nounou',
          color: AppColors.danger,
        ),
        if (_parentChoice == 'en_route' && _showDurationSelector) ...[
          const SizedBox(height: AppSpacing.lg),
          _buildParentDurationSelector(mission),
        ],
        if (_parentChoice == 'bloque') ...[
          const SizedBox(height: AppSpacing.lg),
          _buildContactOptions(mission),
        ],
      ],
    );
  }

  Widget _buildParentChoiceCard({
    required String choice,
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
  }) {
    final isSelected = _parentChoice == choice;

    return GestureDetector(
      onTap: () => setState(() {
        _parentChoice = choice;
        if (choice == 'en_route') _showDurationSelector = true;
        _selectedMinutes = null;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.06) : AppColors.surface,
          borderRadius: AppSpacing.cardBorderRadius,
          border: Border.all(
            color: isSelected ? color : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [] : AppColors.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTypography.h4.copyWith(
                      color: isSelected ? color : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(subtitle, style: AppTypography.bodySmall),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: isSelected ? color : AppColors.border,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParentDurationSelector(MissionModel mission) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.cardBorderRadius,
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Dans combien de temps arrivez-vous ?", style: AppTypography.h4),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              ..._durationOptions.map(
                (m) => _PillButton(
                  label: _minutesLabel(m),
                  isSelected: _selectedMinutes == m,
                  onTap: () => setState(() => _selectedMinutes = m),
                ),
              ),
              _PillButton(
                label: 'Autre',
                isSelected: _selectedMinutes == -2,
                onTap: () => setState(() => _selectedMinutes = -2),
              ),
            ],
          ),
          if (_selectedMinutes != null && _selectedMinutes! > 0) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.warningSurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Soit +${_formatFcfa(_extraCostFcfa(_selectedMinutes!))} ${AppConstants.currency} supplémentaires',
                style: AppTypography.labelLg.copyWith(color: AppColors.warning),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _selectedMinutes != null
                  ? () => _onParentConfirm(mission)
                  : null,
              icon: const Icon(Icons.send_rounded, color: Colors.white),
              label: Text(
                'Confirmer et notifier la nounou',
                style: AppTypography.buttonLabel,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.surfaceVariant,
                shape: const RoundedRectangleBorder(
                  borderRadius: AppSpacing.buttonBorderRadius,
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onParentConfirm(MissionModel mission) async {
    await _submitDelayRequest(mission, reason: 'en_route');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'La nounou a été notifiée de votre retard.',
          style: AppTypography.bodyMedium.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(
          borderRadius: AppSpacing.cardBorderRadius,
        ),
      ),
    );
  }

  Future<void> _callNanny(String nannyId) async {
    final nanny = await ref.read(nannyByIdProvider(nannyId).future);
    final uri = Uri(scheme: 'tel', path: nanny.phone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Widget _buildContactOptions(MissionModel mission) {
    final nannyId = mission.selectedNannyId;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.dangerSurface,
        borderRadius: AppSpacing.cardBorderRadius,
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contactez votre nounou directement :',
            style: AppTypography.h4.copyWith(color: AppColors.danger),
          ),
          const SizedBox(height: AppSpacing.md),
          _contactRow(
            icon: Icons.phone_rounded,
            label: 'Appeler la nounou',
            color: AppColors.danger,
            onPressed: nannyId == null ? null : () => _callNanny(nannyId),
          ),
          const SizedBox(height: AppSpacing.sm),
          _contactRow(
            icon: Icons.chat_rounded,
            label: 'Envoyer un message',
            color: AppColors.danger,
            onPressed: nannyId == null
                ? null
                : () => context.push('/chat/$nannyId'),
          ),
        ],
      ),
    );
  }

  Widget _contactRow({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: color, size: 20),
      label: Text(label, style: AppTypography.labelLg.copyWith(color: color)),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color.withValues(alpha: 0.5)),
        minimumSize: const Size(double.infinity, 48),
        shape: const RoundedRectangleBorder(
          borderRadius: AppSpacing.buttonBorderRadius,
        ),
      ),
    );
  }

  // ── Mutation ─────────────────────────────────────────────────────────────────

  /// Persiste la demande de retard sur la mission (statut `delayed` +
  /// ajout d'un [DelayRequest]) puis rafraîchit les providers.
  Future<void> _submitDelayRequest(
    MissionModel mission, {
    required String reason,
  }) async {
    final minutes = (_selectedMinutes != null && _selectedMinutes! > 0)
        ? _selectedMinutes!
        : 0;
    final updated = mission.copyWith(
      status: MissionStatus.delayed,
      delayRequests: [
        ...mission.delayRequests,
        DelayRequest(
          requestedAt: DateTime.now(),
          minutesRequested: minutes,
          reason: reason,
        ),
      ],
    );
    await ref.read(missionRepositoryProvider).updateMission(updated);
    ref.invalidate(missionByIdProvider(widget.missionId));
    ref.invalidate(missionsProvider);
  }

  // ── Cost breakdown ───────────────────────────────────────────────────────────

  Widget _buildCostBreakdown(MissionModel mission) {
    final plannedCost = _plannedCostFcfa(mission);
    final hasExtra = _selectedMinutes != null && _selectedMinutes! > 0;
    final extraCost = hasExtra ? _extraCostFcfa(_selectedMinutes!) : 0;
    final totalCost = plannedCost + extraCost;
    final plannedH = mission.plannedHours
        .toStringAsFixed(1)
        .replaceAll('.0', '');

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.cardBorderRadius,
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Récapitulatif du coût', style: AppTypography.h4),
          const SizedBox(height: AppSpacing.md),
          Divider(color: AppColors.border, height: 1),
          const SizedBox(height: AppSpacing.md),
          _costRow(
            label: 'Heures prévues : ${plannedH}h',
            value: '${_formatFcfa(plannedCost)} ${AppConstants.currency}',
            valueColor: AppColors.textPrimary,
          ),
          if (hasExtra) ...[
            const SizedBox(height: AppSpacing.sm),
            _costRow(
              label: 'Prolongation : +${_minutesLabel(_selectedMinutes!)}',
              value: '+${_formatFcfa(extraCost)} ${AppConstants.currency}',
              valueColor: AppColors.warning,
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Divider(color: AppColors.border, height: 1),
          const SizedBox(height: AppSpacing.md),
          _costRow(
            label: 'Total estimé',
            value: '${_formatFcfa(totalCost)} ${AppConstants.currency}',
            valueColor: AppColors.primary,
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _costRow({
    required String label,
    required String value,
    required Color valueColor,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isBold ? AppTypography.labelLg : AppTypography.bodyMedium,
        ),
        Text(
          value,
          style: isBold
              ? AppTypography.price.copyWith(color: valueColor)
              : AppTypography.labelLg.copyWith(color: valueColor),
        ),
      ],
    );
  }

  // ── Emergency ────────────────────────────────────────────────────────────────

  Widget _buildEmergencyOption() {
    return Center(
      child: TextButton.icon(
        onPressed: () => context.push('/sos'),
        icon: const Icon(Icons.sos_rounded, color: AppColors.danger, size: 20),
        label: Text(
          'Situation d\'urgence — Contacter le support',
          style: AppTypography.labelLg.copyWith(color: AppColors.danger),
        ),
      ),
    );
  }
}

// ── Pill button ───────────────────────────────────────────────────────────────

class _PillButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PillButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
          borderRadius: AppSpacing.chipBorderRadius,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.labelLg.copyWith(
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
