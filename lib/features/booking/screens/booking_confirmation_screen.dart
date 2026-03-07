import 'package:flutter/material.dart';
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Success Animation
              const Icon(
                    Icons.check_circle_rounded,
                    size: 100,
                    color: Color(
                      0xFF4ECDC4,
                    ), // Turquoise color from user requirement
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

              const SizedBox(height: AppSpacing.md),

              Text(
                "${nanny.name} a été notifiée",
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 400.ms),

              const SizedBox(height: AppSpacing.xl * 2),

              _buildRecapCard(context, date, startTime, endTime, address),

              const SizedBox(height: AppSpacing.lg),

              Text(
                "Numéro de réservation : #$bookingId",
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),

              const Spacer(),

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
              ),

              const SizedBox(height: AppSpacing.xl),
              Text(
                "Vous recevrez une notification quand la nounou confirmera",
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecapCard(
    BuildContext context,
    DateTime date,
    TimeOfDay startTime,
    TimeOfDay endTime,
    String address,
  ) {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.lg),
        side: BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            _buildRecapItem(
              Icons.calendar_today,
              DateFormat('EEEE d MMMM y', 'fr_FR').format(date),
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildRecapItem(
              Icons.access_time,
              "${startTime.format(context)} → ${endTime.format(context)}",
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildRecapItem(Icons.location_on_outlined, address),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 600.ms).scale(duration: 400.ms);
  }

  Widget _buildRecapItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            text,
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
