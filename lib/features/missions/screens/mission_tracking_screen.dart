import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/mission_model.dart';
import '../../../data/providers/data_providers.dart';
import '../../auth/providers/auth_provider.dart';

class MissionTrackingScreen extends ConsumerStatefulWidget {
  final String missionId;

  const MissionTrackingScreen({super.key, required this.missionId});

  @override
  ConsumerState<MissionTrackingScreen> createState() =>
      _MissionTrackingScreenState();
}

class _MissionTrackingScreenState extends ConsumerState<MissionTrackingScreen> {
  late MissionModel _mission;
  MissionStatus _status = MissionStatus.pending;

  /// Le point de vue est déduit du rôle de la session — plus de toggle.
  bool get _isNanny => ref.watch(authProvider).isNanny;

  Timer? _timer;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    final missionAsync = ref.read(missionByIdProvider(widget.missionId));
    _mission = missionAsync.valueOrNull ?? _fallbackMission();
    _status = _mission.status;
    if (_status == MissionStatus.inProgress ||
        _status == MissionStatus.delayed) {
      _startTimer();
    }
  }

  /// Fallback minimal si le provider n'a pas encore résolu.
  MissionModel _fallbackMission() => MissionModel(
    id: widget.missionId,
    parentId: '',
    parentName: '',
    parentPhotoUrl: '',
    address: '',
    locationType: LocationType.home,
    date: DateTime.now(),
    startTime: '08:00',
    endTime: '12:00',
    isUrgent: false,
    childrenIds: const [],
    childrenSummary: const [],
    needs: const [],
    hasPets: false,
    paymentMethod: PaymentMethod.cash,
    status: MissionStatus.pending,
    applicantIds: const [],
    publishedAt: DateTime.now(),
  );

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    // Initialise elapsed from actualStartTime if available
    if (_mission.actualStartTime != null) {
      _elapsed = DateTime.now().difference(_mission.actualStartTime!);
    }
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _elapsed = _elapsed + const Duration(seconds: 1);
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _setStatus(MissionStatus next) {
    setState(() {
      _status = next;
      _mission = _mission.copyWith(status: next);
      if (next == MissionStatus.inProgress || next == MissionStatus.delayed) {
        if (next == MissionStatus.inProgress) {
          _elapsed = Duration.zero;
        }
        _startTimer();
      } else if (next == MissionStatus.completed) {
        _stopTimer();
      }
    });
  }

  // ── Formatting helpers ──────────────────────────────────────────────────────

  String _formatElapsed(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  String _elapsedCaption(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    if (h > 0) return 'Garde en cours depuis ${h}h ${m}min';
    return 'Garde en cours depuis ${m}min';
  }

  int _estimatedCostFcfa() {
    final rate = _mission.hourlyRateSnapshot ?? 3000;
    final hours = _elapsed.inMinutes / 60.0;
    return (hours.ceilToDouble() * rate).toInt();
  }

  // ── Timeline data ───────────────────────────────────────────────────────────

  List<_TimelineStep> get _steps {
    return [
      _TimelineStep(
        label: 'Annonce publiée',
        icon: Icons.campaign_rounded,
        activeStatus: MissionStatus.pending,
        color: AppColors.warning,
      ),
      _TimelineStep(
        label: 'Nounou sélectionnée',
        icon: Icons.how_to_reg_rounded,
        activeStatus: MissionStatus.confirmed,
        color: AppColors.accent,
      ),
      _TimelineStep(
        label: 'Nounou en route',
        icon: Icons.directions_car_rounded,
        activeStatus: MissionStatus.nannyEnRoute,
        color: AppColors.primaryLight,
      ),
      _TimelineStep(
        label: 'Nounou arrivée',
        icon: Icons.home_rounded,
        activeStatus: MissionStatus.nannyArrived,
        color: AppColors.success,
      ),
      _TimelineStep(
        label: 'Garde en cours',
        icon: Icons.child_care_rounded,
        activeStatus: MissionStatus.inProgress,
        color: AppColors.success,
        isLiveTimer: true,
      ),
      _TimelineStep(
        label: 'Retard signalé',
        icon: Icons.alarm_rounded,
        activeStatus: MissionStatus.delayed,
        color: AppColors.warning,
        showOnlyWhenDelayed: true,
      ),
      _TimelineStep(
        label: 'Parent rentré',
        icon: Icons.flag_rounded,
        activeStatus: MissionStatus.completed,
        color: AppColors.secondary,
      ),
      _TimelineStep(
        label: 'Paiement',
        icon: Icons.payment_rounded,
        activeStatus: MissionStatus.paid,
        color: AppColors.success,
      ),
      _TimelineStep(
        label: 'Avis mutuels',
        icon: Icons.star_rounded,
        activeStatus: MissionStatus.reviewed,
        color: AppColors.gold,
      ),
    ];
  }

  int get _currentStatusIndex {
    const order = [
      MissionStatus.pending,
      MissionStatus.confirmed,
      MissionStatus.nannyEnRoute,
      MissionStatus.nannyArrived,
      MissionStatus.inProgress,
      MissionStatus.delayed,
      MissionStatus.completed,
      MissionStatus.paid,
      MissionStatus.reviewed,
    ];
    final idx = order.indexOf(_status);
    return idx < 0 ? 0 : idx;
  }

  _StepState _stepState(_TimelineStep step) {
    const order = [
      MissionStatus.pending,
      MissionStatus.confirmed,
      MissionStatus.nannyEnRoute,
      MissionStatus.nannyArrived,
      MissionStatus.inProgress,
      MissionStatus.delayed,
      MissionStatus.completed,
      MissionStatus.paid,
      MissionStatus.reviewed,
    ];
    final stepIdx = order.indexOf(step.activeStatus);
    final curIdx = _currentStatusIndex;
    if (stepIdx < curIdx) return _StepState.done;
    if (stepIdx == curIdx) return _StepState.current;
    return _StepState.future;
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Column(
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
                  _buildTimeline(),
                  if (_status == MissionStatus.inProgress ||
                      _status == MissionStatus.delayed) ...[
                    const SizedBox(height: AppSpacing.lg),
                    _buildLiveTimer(),
                    const SizedBox(height: AppSpacing.md),
                    _buildCostCard(),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  _buildActionArea(),
                  const SizedBox(height: AppSpacing.xxxl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_rounded,
          color: AppColors.textPrimary,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Suivi de mission', style: AppTypography.h4),
          Text(
            AppFormatters.formatShortDate(_mission.date),
            style: AppTypography.caption,
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppColors.border),
      ),
    );
  }

  // ── Timeline ────────────────────────────────────────────────────────────────

  Widget _buildTimeline() {
    final steps = _steps.where((s) {
      if (s.showOnlyWhenDelayed && _status != MissionStatus.delayed) {
        return false;
      }
      return true;
    }).toList();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.cardBorderRadius,
        boxShadow: AppColors.cardShadow,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Progression', style: AppTypography.h4),
          const SizedBox(height: AppSpacing.md),
          ...List.generate(steps.length, (i) {
            final step = steps[i];
            final state = _stepState(step);
            final isLast = i == steps.length - 1;
            return _TimelineTile(
              step: step,
              state: state,
              isLast: isLast,
              elapsed: _elapsed,
            );
          }),
        ],
      ),
    );
  }

  // ── Live Timer ──────────────────────────────────────────────────────────────

  Widget _buildLiveTimer() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: AppSpacing.cardBorderRadius,
        boxShadow: AppColors.primaryShadow,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xxl,
      ),
      child: Column(
        children: [
          Text(
            _formatElapsed(_elapsed),
            style: AppTypography.h1.copyWith(
              color: Colors.white,
              fontSize: 42,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
              fontFeatures: [const FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _elapsedCaption(_elapsed),
            style: AppTypography.caption.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCostCard() {
    final rate = _mission.hourlyRateSnapshot ?? 3000;
    final cost = _estimatedCostFcfa();
    final formattedCost = _formatFcfa(cost);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: AppSpacing.cardBorderRadius,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.attach_money_rounded,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'Coût estimé :',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          Text(
            '$formattedCost ${AppConstants.currency}',
            style: AppTypography.price,
          ),
          Text(
            '  (${rate.toInt()} ${AppConstants.currency}/h)',
            style: AppTypography.caption,
          ),
        ],
      ),
    );
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

  // ── Action area ─────────────────────────────────────────────────────────────

  Widget _buildActionArea() {
    return _isNanny ? _buildNannyActions() : _buildParentActions();
  }

  Widget _buildParentActions() {
    switch (_status) {
      case MissionStatus.pending:
        return _disabledButton(
          icon: Icons.hourglass_empty_rounded,
          label: 'En attente de candidatures...',
        );

      case MissionStatus.confirmed:
        return _infoCard(
          icon: Icons.check_circle_rounded,
          color: AppColors.accent,
          message: 'La nounou est confirmée — elle se prépare.',
        );

      case MissionStatus.nannyEnRoute:
        return _infoCard(
          icon: Icons.directions_car_rounded,
          color: AppColors.primaryLight,
          message: 'Votre nounou est en route !',
        );

      case MissionStatus.nannyArrived:
        return _primaryButton(
          icon: Icons.play_arrow_rounded,
          label: 'Démarrer la garde',
          onTap: () => _setStatus(MissionStatus.inProgress),
        );

      case MissionStatus.inProgress:
        return _primaryButton(
          icon: Icons.home_rounded,
          label: 'Je suis rentré(e)',
          onTap: () => _setStatus(MissionStatus.completed),
        );

      case MissionStatus.delayed:
        return _secondaryButton(
          icon: Icons.alarm_rounded,
          label: 'Signaler mon retour',
          color: AppColors.warning,
          onTap: () => _setStatus(MissionStatus.completed),
        );

      case MissionStatus.completed:
        return _primaryButton(
          icon: Icons.payment_rounded,
          label: 'Confirmer le paiement',
          onTap: () => _setStatus(MissionStatus.paid),
        );

      case MissionStatus.paid:
        return _infoCard(
          icon: Icons.check_circle_rounded,
          color: AppColors.success,
          message: 'Paiement confirmé. Merci !',
        );

      case MissionStatus.reviewed:
        return _infoCard(
          icon: Icons.star_rounded,
          color: AppColors.gold,
          message: 'Avis envoyé. Mission clôturée.',
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildNannyActions() {
    switch (_status) {
      case MissionStatus.pending:
        return _infoCard(
          icon: Icons.hourglass_empty_rounded,
          color: AppColors.warning,
          message: 'Mission en attente de sélection.',
        );

      case MissionStatus.confirmed:
        return _primaryButton(
          icon: Icons.directions_car_rounded,
          label: 'Je suis en route',
          onTap: () => _setStatus(MissionStatus.nannyEnRoute),
        );

      case MissionStatus.nannyEnRoute:
        return _primaryButton(
          icon: Icons.location_on_rounded,
          label: 'Check-in GPS (Arrivée)',
          onTap: () async {
            // Simulation de Check-in GPS
            unawaited(
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (c) => const AlertDialog(
                  content: Row(
                    children: [
                      CircularProgressIndicator(color: AppColors.primary),
                      SizedBox(width: 16),
                      Expanded(
                        child: Text("Vérification de la position GPS..."),
                      ),
                    ],
                  ),
                ),
              ),
            );
            await Future.delayed(const Duration(seconds: 2));
            if (!mounted) return;
            Navigator.pop(context);
            _setStatus(MissionStatus.nannyArrived);
          },
        );

      case MissionStatus.nannyArrived:
        return _infoCard(
          icon: Icons.access_time_rounded,
          color: AppColors.accent,
          message: 'En attente que le parent démarre la garde.',
        );

      case MissionStatus.inProgress:
        return _secondaryButton(
          icon: Icons.warning_amber_rounded,
          label: 'Signaler un retard',
          color: AppColors.warning,
          onTap: () => context.push(
            '/missions/${_mission.id}/delay'
            '?rate=${_mission.hourlyRateSnapshot ?? AppConstants.defaultHourlyRate}',
          ),
        );

      case MissionStatus.delayed:
        return _infoCard(
          icon: Icons.alarm_rounded,
          color: AppColors.warning,
          message: 'Retard signalé — en attente du parent.',
        );

      case MissionStatus.completed:
        return _primaryButton(
          icon: Icons.star_rounded,
          label: 'Laisser un avis',
          onTap: () => _setStatus(MissionStatus.reviewed),
        );

      case MissionStatus.reviewed:
        return _infoCard(
          icon: Icons.star_rounded,
          color: AppColors.gold,
          message: 'Avis envoyé. Merci !',
        );

      default:
        return const SizedBox.shrink();
    }
  }

  // ── Button/card helpers ─────────────────────────────────────────────────────

  Widget _primaryButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white),
        label: Text(label, style: AppTypography.buttonLabel),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: AppSpacing.buttonBorderRadius,
          ),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _secondaryButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: color),
        label: Text(
          label,
          style: AppTypography.buttonLabel.copyWith(color: color),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color, width: 2),
          shape: const RoundedRectangleBorder(
            borderRadius: AppSpacing.buttonBorderRadius,
          ),
        ),
      ),
    );
  }

  Widget _disabledButton({required IconData icon, required String label}) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: null,
        icon: Icon(icon, color: AppColors.textTertiary),
        label: Text(
          label,
          style: AppTypography.buttonLabel.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.surfaceVariant,
          disabledBackgroundColor: AppColors.surfaceVariant,
          shape: const RoundedRectangleBorder(
            borderRadius: AppSpacing.buttonBorderRadius,
          ),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required Color color,
    required String message,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: AppSpacing.cardBorderRadius,
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodyMedium.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Timeline tile ─────────────────────────────────────────────────────────────

enum _StepState { done, current, future }

class _TimelineStep {
  final String label;
  final IconData icon;
  final MissionStatus activeStatus;
  final Color color;
  final bool isLiveTimer;
  final bool showOnlyWhenDelayed;

  const _TimelineStep({
    required this.label,
    required this.icon,
    required this.activeStatus,
    required this.color,
    this.isLiveTimer = false,
    this.showOnlyWhenDelayed = false,
  });
}

class _TimelineTile extends StatelessWidget {
  final _TimelineStep step;
  final _StepState state;
  final bool isLast;
  final Duration elapsed;

  const _TimelineTile({
    required this.step,
    required this.state,
    required this.isLast,
    required this.elapsed,
  });

  @override
  Widget build(BuildContext context) {
    final color = state == _StepState.future ? AppColors.border : step.color;
    final isDone = state == _StepState.done;
    final isCurrent = state == _StepState.current;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vertical line + circle column
          SizedBox(
            width: 36,
            child: Column(
              children: [
                _buildCircle(color, isDone, isCurrent),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: isDone ? step.color : AppColors.border,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          // Label + timestamp
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg, top: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          step.label,
                          style: isCurrent
                              ? AppTypography.h4.copyWith(color: step.color)
                              : isDone
                              ? AppTypography.labelLg.copyWith(
                                  color: AppColors.textPrimary,
                                )
                              : AppTypography.bodyMedium.copyWith(
                                  color: AppColors.textTertiary,
                                ),
                        ),
                      ),
                      if (isCurrent && step.isLiveTimer)
                        _LiveBadge(elapsed: elapsed),
                    ],
                  ),
                  if (isDone)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.xs),
                      child: Text(
                        'Terminé',
                        style: AppTypography.caption.copyWith(
                          color: step.color,
                          fontSize: 11,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircle(Color color, bool isDone, bool isCurrent) {
    if (isDone) {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: const Icon(Icons.check_rounded, color: Colors.white, size: 18),
      );
    }
    if (isCurrent) {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.35),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(step.icon, color: Colors.white, size: 18),
      );
    }
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.border, width: 2),
      ),
      child: Icon(step.icon, color: AppColors.textTertiary, size: 16),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  final Duration elapsed;

  const _LiveBadge({required this.elapsed});

  String _fmt(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    final s = d.inSeconds % 60;
    if (h > 0) {
      return '${h}h ${m.toString().padLeft(2, '0')}m';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: AppColors.success,
        borderRadius: AppSpacing.chipBorderRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            _fmt(elapsed),
            style: AppTypography.small.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
