import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/nanny_model.dart';

class BookingConfirmationScreen extends StatelessWidget {
  final String bookingId;

  const BookingConfirmationScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context) {
    // We expect the booking details to be passed in the extra
    final Map<String, dynamic> extra =
        GoRouterState.of(context).extra as Map<String, dynamic>;
    final NannyModel nanny = extra['nanny'] as NannyModel;
    final DateTime date = extra['date'] as DateTime;
    final TimeOfDay startTime = extra['startTime'] as TimeOfDay;
    final TimeOfDay endTime = extra['endTime'] as TimeOfDay;
    final String address = extra['address'] as String;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: AppSpacing.xxxl),

              // ── Success checkmark hero ──────────────────────────────────
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: AppColors.accentGradient,
                  shape: BoxShape.circle,
                  boxShadow: AppColors.primaryShadow,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 64,
                ),
              )
                  .animate()
                  .scale(duration: 600.ms, curve: Curves.elasticOut)
                  .fadeIn(duration: 400.ms),

              const SizedBox(height: AppSpacing.xl),

              Text(
                "Réservation confirmée ! 🎉",
                style: AppTypography.h2,
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),

              const SizedBox(height: AppSpacing.sm),

              Text(
                "${nanny.name} a été notifiée",
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 400.ms),

              const SizedBox(height: AppSpacing.xl),

              // ── Status timeline ─────────────────────────────────────────
              _buildStatusTimeline()
                  .animate()
                  .fadeIn(delay: 500.ms)
                  .slideY(begin: 0.15, end: 0),

              const SizedBox(height: AppSpacing.xl),

              // ── Booking ID badge ────────────────────────────────────────
              _BookingIdBadge(bookingId: bookingId)
                  .animate()
                  .fadeIn(delay: 200.ms),

              const SizedBox(height: AppSpacing.xl),

              // ── Detail rows ─────────────────────────────────────────────
              _ConfirmRow(
                icon: Icons.calendar_today_rounded,
                label: "Date",
                value: DateFormat('EEEE d MMMM y', 'fr_FR').format(date),
                color: AppColors.primary,
                iconBg: AppColors.primarySurface,
              ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0),

              const SizedBox(height: AppSpacing.sm),

              _ConfirmRow(
                icon: Icons.access_time_rounded,
                label: "Horaire",
                value:
                    "${startTime.format(context)} → ${endTime.format(context)}",
                color: AppColors.gold,
                iconBg: AppColors.goldSurface,
              ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.2, end: 0),

              const SizedBox(height: AppSpacing.sm),

              _ConfirmRow(
                icon: Icons.location_on_rounded,
                label: "Adresse",
                value: address,
                color: AppColors.danger,
                iconBg: AppColors.dangerSurface,
              ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2, end: 0),

              const SizedBox(height: AppSpacing.sm),

              _ConfirmRow(
                icon: Icons.person_rounded,
                label: "Nounou",
                value: nanny.name,
                color: AppColors.accent,
                iconBg: AppColors.accentSurface,
              ).animate().fadeIn(delay: 900.ms).slideY(begin: 0.2, end: 0),

              const SizedBox(height: AppSpacing.xxl),

              // ── Action buttons ──────────────────────────────────────────
              Column(
                children: [
                  OutlinedButton(
                    onPressed: () => context.push('/chat/${nanny.id}'),
                    child: const Text("Contacter la nounou"),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ElevatedButton(
                    onPressed: () => context.go('/home'),
                    child: const Text("Retour à l'accueil"),
                  ),
                ],
              ).animate().fadeIn(delay: 1000.ms),

              const SizedBox(height: AppSpacing.xl),

              Text(
                "Vous recevrez une notification quand la nounou confirmera",
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 1100.ms),

              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusTimeline() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _TimelineStep(label: "Envoyée", isDone: true),
        _TimelineDivider(),
        _TimelineStep(label: "Traitée", isDone: true),
        _TimelineDivider(),
        _TimelineStep(label: "Confirmée", isDone: true),
      ],
    );
  }
}

// ── Booking ID badge ─────────────────────────────────────────────────────────

class _BookingIdBadge extends StatefulWidget {
  final String bookingId;
  const _BookingIdBadge({required this.bookingId});

  @override
  State<_BookingIdBadge> createState() => _BookingIdBadgeState();
}

class _BookingIdBadgeState extends State<_BookingIdBadge> {
  bool _copied = false;

  void _copy() {
    Clipboard.setData(ClipboardData(text: '#NE-${widget.bookingId}'));
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _copy,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primarySurface,
          borderRadius: AppSpacing.chipBorderRadius,
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
          ),
          boxShadow: AppColors.cardShadow,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.tag_rounded,
              size: 16,
              color: AppColors.primary,
            ),
            const SizedBox(width: 6),
            Text(
              "#NE-${widget.bookingId}",
              style: AppTypography.labelLg.copyWith(
                color: AppColors.primary,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(width: 8),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                _copied ? Icons.check_rounded : Icons.copy_rounded,
                key: ValueKey(_copied),
                size: 16,
                color: _copied ? AppColors.accent : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Confirm detail row ───────────────────────────────────────────────────────

class _ConfirmRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color iconBg;

  const _ConfirmRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.iconBg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.cardBorderRadius,
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.overline.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Status timeline widgets ──────────────────────────────────────────────────

class _TimelineStep extends StatelessWidget {
  final String label;
  final bool isDone;

  const _TimelineStep({required this.label, required this.isDone});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isDone ? AppColors.accent : AppColors.border,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_rounded,
            size: 16,
            color: isDone ? Colors.white : AppColors.textTertiary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.small.copyWith(
            color: isDone ? AppColors.accent : AppColors.textSecondary,
            fontWeight: isDone ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class _TimelineDivider extends StatelessWidget {
  const _TimelineDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 2,
      margin: const EdgeInsets.only(bottom: 22),
      decoration: BoxDecoration(
        gradient: AppColors.accentGradient,
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }
}
