import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/notification_model.dart';

class NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;

  const NotificationTile({
    super.key,
    required this.notification,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: notification.isRead ? Colors.white : AppColors.primary.withValues(alpha: 0.05),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!notification.isRead)
              Container(
                margin: const EdgeInsets.only(top: 14, right: 8),
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            _buildIcon(),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.body,
                    style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatTime(notification.createdAt),
                    style: AppTypography.small.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    IconData iconData;
    Color iconColor;

    switch (notification.type) {
      case 'booking_confirmed':
        iconData = Icons.check_circle;
        iconColor = Colors.green;
        break;
      case 'new_message':
        iconData = Icons.chat_bubble;
        iconColor = Colors.blue;
        break;
      case 'reminder':
        iconData = Icons.notifications;
        iconColor = Colors.orange;
        break;
      case 'review_received':
        iconData = Icons.star;
        iconColor = Colors.amber;
        break;
      case 'sos_alert':
        iconData = Icons.warning;
        iconColor = AppColors.danger;
        break;
      case 'system_info':
        iconData = Icons.info;
        iconColor = Colors.blue;
        break;
      default:
        iconData = Icons.notifications;
        iconColor = AppColors.primary;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(iconData, color: iconColor, size: 20),
    );
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return "Il y a ${difference.inMinutes} min";
    } else if (difference.inHours < 24) {
      return "Il y a ${difference.inHours}h";
    } else if (difference.inDays == 1) {
      return "Hier à ${DateFormat('HH:mm').format(date)}";
    } else {
      return DateFormat('dd/MM à HH:mm').format(date);
    }
  }
}
