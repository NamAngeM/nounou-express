import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_loader.dart';
import '../../../core/widgets/app_page_header.dart';
import '../../../core/widgets/avatar_widget.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../data/models/booking_model.dart';
import '../../../data/providers/data_providers.dart';
import '../../auth/providers/auth_provider.dart';

class BookingsListScreen extends ConsumerWidget {
  const BookingsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(bookingsProvider);
    final total = bookingsAsync.valueOrNull?.length ?? 0;
    // La nounou ne « réserve » pas : ce sont ses gardes confirmées.
    final isNanny = ref.watch(authProvider).isNanny;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            // ── Styled header ──────────────────────────────────────────────
            AppPageHeader(
              title: isNanny ? 'Mes Gardes' : 'Mes Réservations',
              subtitle: isNanny
                  ? '$total garde${total != 1 ? 's' : ''} au total'
                  : '$total réservation${total != 1 ? 's' : ''} au total',
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
            const Expanded(
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
class _BookingsList extends ConsumerWidget {
  final String status;
  const _BookingsList({required this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(bookingsProvider);

    return bookingsAsync.when(
      loading: () => const AppLoader(),
      error: (e, _) => Center(child: Text('Erreur : $e')),
      data: (allBookings) {
        final bookings = allBookings.where((b) => b.status == status).toList();

        if (bookings.isEmpty) {
          return EmptyState(
            icon: Icons.calendar_today_outlined,
            title: 'Aucune réservation',
            description: 'dans la catégorie « $status »',
          );
        }

        return RefreshIndicator(
          onRefresh: () => ref.refresh(bookingsProvider.future),
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              100,
            ),
            itemCount: bookings.length,
            itemBuilder: (context, index) =>
                _BookingCard(booking: bookings[index])
                    .animate()
                    .fadeIn(delay: (index * 70).ms, duration: 350.ms)
                    .slideY(begin: 0.06, end: 0),
          ),
        );
      },
    );
  }
}

// ── Booking card ─────────────────────────────────────────────────────────────
class _BookingCard extends ConsumerWidget {
  final BookingModel booking;
  const _BookingCard({required this.booking});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nanny = ref.watch(nannyByIdProvider(booking.nannyId)).valueOrNull;
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
                      AppAvatar(name: nanny?.name ?? '?', size: 44),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nanny?.name ?? '…',
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
                          AppFormatters.formatFCFA(booking.totalPrice),
                          style: AppTypography.labelMd.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Boucle d'avis : proposée au parent uniquement, quand
                  // la garde est terminée (l'avis porte sur la nounou).
                  if (booking.status == 'Terminée' &&
                      !ref.watch(authProvider).isNanny) ...[
                    const SizedBox(height: AppSpacing.md),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            context.push('/booking/${booking.id}/review'),
                        icon: const Icon(Icons.star_outline_rounded, size: 18),
                        label: const Text('Laisser un avis'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          shape: const RoundedRectangleBorder(
                            borderRadius: AppSpacing.buttonBorderRadius,
                          ),
                        ),
                      ),
                    ),
                  ],
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
