import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/mock/mock_data.dart';
import '../../../data/models/booking_model.dart';
import '../../../data/models/nanny_model.dart';

class BookingDetailScreen extends StatefulWidget {
  final String bookingId;

  const BookingDetailScreen({super.key, required this.bookingId});

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  late BookingModel _booking;
  late NannyModel _nanny;

  @override
  void initState() {
    super.initState();
    // For demonstration, we'll create a mock booking if not found
    _booking = BookingModel(
      id: widget.bookingId,
      parentId: "p1",
      nannyId: "n1",
      date: DateTime.now().add(const Duration(days: 1)),
      startTime: "09:00",
      endTime: "17:00",
      numberOfChildren: 2,
      childrenAges: [3, 6],
      totalPrice: 22425,
      commission: 2925,
      status: "En attente", // "En attente", "Confirmée", "En cours", "Terminée", "Annulée"
      address: "Quartier Glass, BAT G2",
      notes: "Allergies aux arachides.",
    );
    _nanny = MockData.nannies.firstWhere((n) => n.id == _booking.nannyId);
  }

  Color _getStatusColor() {
    switch (_booking.status) {
      case "En attente": return Colors.orange;
      case "Confirmée": return const Color(0xFF4ECDC4);
      case "En cours": return Colors.blue;
      case "Terminée": return Colors.green;
      case "Annulée": return Colors.red;
      default: return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final isEnCours = _booking.status == "En cours";

    return Scaffold(
      appBar: AppBar(
        title: Text("Détails de la réservation #${_booking.id}"),
        actions: [
          if (_booking.status == "En cours")
            IconButton(
              icon: const Icon(Icons.sos, color: AppColors.danger),
              onPressed: () => context.push('/sos'),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
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
                        .scale(duration: 1.seconds, begin: const Offset(0.8, 0.8), end: const Offset(1.2, 1.2))
                        .fadeOut(duration: 1.seconds),
                  if (isEnCours) const SizedBox(width: AppSpacing.sm),
                  Text(
                    _booking.status,
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
            _buildNannyCard(),
            const SizedBox(height: AppSpacing.xl),

            // Details
            _buildSectionTitle("Informations de la mission"),
            const SizedBox(height: AppSpacing.md),
            _buildDetailItem(Icons.calendar_today_outlined, "Date", DateFormat('EEEE d MMMM y', 'fr_FR').format(_booking.date)),
            _buildDetailItem(Icons.access_time, "Horaires", "${_booking.startTime} → ${_booking.endTime}"),
            _buildDetailItem(Icons.location_on_outlined, "Adresse", _booking.address),
            _buildDetailItem(Icons.child_care_outlined, "Enfants", "${_booking.numberOfChildren} enfant(s) (${_booking.childrenAges.join(', ')} ans)"),
            if (_booking.notes != null)
              _buildDetailItem(Icons.notes, "Notes", _booking.notes!),
            
            const SizedBox(height: AppSpacing.xl),
            _buildSectionTitle("Timeline de la mission"),
            const SizedBox(height: AppSpacing.lg),
            _buildTimeline(),

            const SizedBox(height: AppSpacing.xl * 2),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildNannyCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(_nanny.avatar ?? "https://i.pravatar.cc/150?u=${_nanny.id}"),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_nanny.name, style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                Text("${_nanny.experience} ans d'expérience", style: AppTypography.caption),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline, color: AppColors.primary),
            onPressed: () => context.push('/chat/${_nanny.id}'),
          ),
        ],
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
                      color: isDone ? AppColors.textPrimary : AppColors.textSecondary,
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

  Widget _buildActionButtons() {
    if (_booking.status == "En attente" || _booking.status == "Confirmée") {
      return OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger, side: const BorderSide(color: AppColors.danger)),
        child: const Text("Annuler la réservation"),
      );
    } else if (_booking.status == "Terminée") {
      return ElevatedButton(
        onPressed: () {},
        child: const Text("Noter la nounou"),
      );
    }
    return const SizedBox.shrink();
  }
}
