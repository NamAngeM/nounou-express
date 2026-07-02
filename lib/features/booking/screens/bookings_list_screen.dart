import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_page_header.dart';
import '../../../data/mock/mock_data.dart';
import '../../../data/models/booking_model.dart';

class BookingsListScreen extends StatelessWidget {
  const BookingsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final total = MockData.bookings.length;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            // ── Styled header ──────────────────────────────────────────────
            AppPageHeader(
              title: 'Mes Réservations',
              subtitle: '$total réservation${total != 1 ? 's' : ''} au total',
              icon: Icons.calendar_month_rounded,
              gradientColors: const [
                AppColors.secondary,
                AppColors.secondaryLight,
              ],
            ),

            // ── Custom tab bar ─────────────────────────────────────────────
            Container(
              color: AppColors.surface,
              child: TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelStyle: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                unselectedLabelStyle: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.w400,
                ),
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primary,
                indicatorWeight: 2.5,
                dividerColor: AppColors.border,
                tabs: const [
                  Tab(text: 'À venir'),
                  Tab(text: 'En cours'),
                  Tab(text: 'Terminées'),
                  Tab(text: 'Annulées'),
                ],
              ),
            ),

            // ── Tab content ────────────────────────────────────────────────
            Expanded(
              child: TabBarView(
                children: [
                  _BookingsList(status: 'À venir'),
                  _BookingsList(status: 'En cours'),
                  _BookingsList(status: 'Terminée'),
                  _BookingsList(status: 'Annulée'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── List per tab ─────────────────────────────────────────────────────────────
class _BookingsList extends StatelessWidget {
  final String status;
  const _BookingsList({required this.status});

  @override
  Widget build(BuildContext context) {
    final bookings = MockData.bookings
        .where((b) => b.status == status)
        .toList();

    if (bookings.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.calendar_today_outlined,
                  size: 40,
                  color: AppColors.textSecondary.withValues(alpha: 0.4),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Aucune réservation',
                style: AppTypography.h3,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'dans la catégorie "$status"',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        100,
      ),
      itemCount: bookings.length,
      itemBuilder: (context, index) => _BookingCard(booking: bookings[index])
          .animate()
          .fadeIn(delay: (index * 70).ms, duration: 350.ms)
          .slideY(begin: 0.06, end: 0),
    );
  }
}

// ── Booking card ─────────────────────────────────────────────────────────────
class _BookingCard extends StatelessWidget {
  final BookingModel booking;
  const _BookingCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final nanny = MockData.nannies.firstWhere((n) => n.id == booking.nannyId);
    final statusInfo = _statusInfo(booking.status);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: InkWell(
        onTap: () => context.push('/booking/${booking.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            // Status accent bar
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: statusInfo.$1,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row: nanny info + badge
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColors.surfaceVariant,
                        backgroundImage: NetworkImage(
                          'https://i.pravatar.cc/150?u=${nanny.id}',
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nanny.name,
                              style: AppTypography.bodyLarge.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              booking.address,
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Status badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusInfo.$1.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: statusInfo.$1.withValues(alpha: 0.30),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(statusInfo.$3, size: 12, color: statusInfo.$1),
                            const SizedBox(width: 4),
                            Text(
                              booking.status,
                              style: AppTypography.small.copyWith(
                                color: statusInfo.$1,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  Divider(
                    height: AppSpacing.xl,
                    color: AppColors.border.withValues(alpha: 0.6),
                  ),

                  // Date/time + price
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _InfoRow(
                              icon: Icons.calendar_today_rounded,
                              text: DateFormat(
                                'dd MMMM yyyy',
                                'fr_FR',
                              ).format(booking.date),
                            ),
                            const SizedBox(height: 4),
                            _InfoRow(
                              icon: Icons.access_time_rounded,
                              text: '${booking.startTime} – ${booking.endTime}',
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradientH,
                          borderRadius: AppSpacing.chipBorderRadius,
                        ),
                        child: Text(
                          '${booking.totalPrice.toInt()} F',
                          style: AppTypography.labelMd.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Returns (color, label, icon) for the status
  (Color, String, IconData) _statusInfo(String status) {
    return switch (status) {
      'À venir' => (AppColors.accent, status, Icons.schedule_rounded),
      'En cours' => (AppColors.warning, status, Icons.play_circle_rounded),
      'Terminée' => (AppColors.success, status, Icons.check_circle_rounded),
      'Annulée' => (AppColors.danger, status, Icons.cancel_rounded),
      _ => (AppColors.textSecondary, status, Icons.help_rounded),
    };
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13, color: AppColors.primary),
        const SizedBox(width: 5),
        Text(
          text,
          style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
