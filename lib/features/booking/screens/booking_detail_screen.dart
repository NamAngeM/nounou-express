import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/booking_model.dart';
import '../../../data/providers/data_providers.dart';

class BookingDetailScreen extends ConsumerWidget {
  final String bookingId;

  const BookingDetailScreen({super.key, required this.bookingId});

  Color _getStatusColor(String status) {
    switch (status) {
      case "En attente":
        return Colors.orange;
      case "À venir":
      case "Confirmée":
        return const Color(0xFF4ECDC4);
      case "En cours":
        return Colors.blue;
      case "Terminée":
        return Colors.green;
      case "Annulée":
        return Colors.red;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingAsync = ref.watch(bookingByIdProvider(bookingId));

    return Scaffold(
      appBar: AppBar(
        title: Text("Détails de la réservation #$bookingId"),
        actions: [
          if (bookingAsync.valueOrNull?.status == "En cours")
            IconButton(
              icon: const Icon(Icons.sos, color: AppColors.danger),
              onPressed: () => context.push('/sos'),
            ),
        ],
      ),
      body: bookingAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur : $e')),
        data: (booking) => _buildBody(context, ref, booking),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, BookingModel booking) {
    final statusColor = _getStatusColor(booking.status);
    final isEnCours = booking.status == "En cours";

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Banner
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.md),
              border: Border.all(color: statusColor),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isEnCours)
                  const Icon(Icons.circle, color: Colors.blue, size: 12)
                      .animate(onPlay: (controller) => controller.repeat())
                      .scale(
                        duration: 1.seconds,
                        begin: const Offset(0.8, 0.8),
                        end: const Offset(1.2, 1.2),
                      )
                      .fadeOut(duration: 1.seconds),
                if (isEnCours) const SizedBox(width: AppSpacing.sm),
                Text(
                  booking.status,
                  style: AppTypography.caption.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Nanny Info Card
          _buildNannyCard(context, ref, booking),
          const SizedBox(height: AppSpacing.xl),

          // Details
          _buildSectionTitle("Informations de la mission"),
          const SizedBox(height: AppSpacing.md),
          _buildDetailItem(
            Icons.calendar_today_outlined,
            "Date",
            DateFormat('EEEE d MMMM y', 'fr_FR').format(booking.date),
          ),
          _buildDetailItem(
            Icons.access_time,
            "Horaires",
            "${booking.startTime} → ${booking.endTime}",
          ),
          _buildDetailItem(
            Icons.location_on_outlined,
            "Adresse",
            booking.address,
          ),
          _buildDetailItem(
            Icons.child_care_outlined,
            "Enfants",
            "${booking.numberOfChildren} enfant(s) "
                "(${booking.childrenAges.join(', ')} ans)",
          ),
          if (booking.notes != null)
            _buildDetailItem(Icons.notes, "Notes", booking.notes!),

          const SizedBox(height: AppSpacing.xl),
          _buildSectionTitle("Timeline de la mission"),
          const SizedBox(height: AppSpacing.lg),
          _buildTimeline(),

          const SizedBox(height: AppSpacing.xl * 2),
          _buildActionButtons(context, booking, ref),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildNannyCard(
    BuildContext context,
    WidgetRef ref,
    BookingModel booking,
  ) {
    final nannyAsync = ref.watch(nannyByIdProvider(booking.nannyId));

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: nannyAsync.when(
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: CircularProgressIndicator(),
          ),
        ),
        error: (e, _) => Text('Erreur : $e'),
        data: (nanny) => Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(
                nanny.avatar ?? "https://i.pravatar.cc/150?u=${nanny.id}",
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
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "${nanny.experience} ans d'expérience",
                    style: AppTypography.caption,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.chat_bubble_outline,
                color: AppColors.primary,
              ),
              onPressed: () => context.push('/chat/${nanny.id}'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTypography.caption),
              Text(value, style: AppTypography.bodyMedium),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    final List<Map<String, String>> events = [
      {"title": "Réservation créée", "time": "Hier, 14:30", "done": "true"},
      {"title": "Nounou confirmée", "time": "Hier, 15:15", "done": "true"},
      {"title": "Mission démarrée", "time": "-", "done": "false"},
      {"title": "Mission terminée", "time": "-", "done": "false"},
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        final isDone = event['done'] == "true";
        final isLast = index == events.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDone ? Colors.green : AppColors.border,
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 40,
                    color: isDone ? Colors.green : AppColors.border,
                  ),
              ],
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event['title']!,
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
                      color: isDone
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                  if (isDone)
                    Text(event['time']!, style: AppTypography.caption),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    BookingModel booking,
    WidgetRef ref,
  ) {
    final buttons = <Widget>[];

    if (booking.status == "En attente" ||
        booking.status == "Confirmée" ||
        booking.status == "À venir") {
      buttons.add(
        ElevatedButton.icon(
          onPressed: () {
            final nannyAsync = ref.read(nannyByIdProvider(booking.nannyId));
            final name = nannyAsync.valueOrNull?.name ?? 'la Nounou';
            context.push('/video-call?name=$name');
          },
          icon: const Icon(Icons.videocam_rounded),
          label: const Text("Entretien Vidéo"),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
        ),
      );
      buttons.add(const SizedBox(height: AppSpacing.sm));
      buttons.add(
        OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.danger,
            side: const BorderSide(color: AppColors.danger),
          ),
          child: const Text("Annuler la réservation"),
        ),
      );
    } else if (booking.status == "Terminée") {
      buttons.add(
        ElevatedButton.icon(
          onPressed: () => context.push('/booking/new/${booking.nannyId}'),
          icon: const Icon(Icons.refresh_rounded),
          label: const Text("Re-réserver"),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
        ),
      );
      buttons.add(const SizedBox(height: AppSpacing.sm));
      buttons.add(
        OutlinedButton(onPressed: () {}, child: const Text("Noter la nounou")),
      );
    }

    if (buttons.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: buttons,
    );
  }
}
