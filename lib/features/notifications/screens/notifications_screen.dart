import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_loader.dart';
import '../../../core/widgets/app_page_header.dart';
import '../../../data/models/notification_model.dart';
import '../../../data/providers/data_providers.dart';
import '../widgets/notification_tile.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  Future<void> _markAllAsRead() async {
    await ref.read(notificationRepositoryProvider).markAllAsRead();
    ref.invalidate(notificationsProvider);
  }

  Future<void> _deleteNotification(String id) async {
    await ref.read(notificationRepositoryProvider).deleteNotification(id);
    ref.invalidate(notificationsProvider);
  }

  Map<String, List<NotificationModel>> _groupNotifications(
    List<NotificationModel> notifications,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final thisWeek = today.subtract(const Duration(days: 7));

    final groups = <String, List<NotificationModel>>{
      "Aujourd'hui": [],
      "Hier": [],
      "Cette semaine": [],
      "Plus ancien": [],
    };

    for (final n in notifications) {
      final date = DateTime(
        n.createdAt.year,
        n.createdAt.month,
        n.createdAt.day,
      );
      if (date == today) {
        groups["Aujourd'hui"]!.add(n);
      } else if (date == yesterday) {
        groups["Hier"]!.add(n);
      } else if (date.isAfter(thisWeek)) {
        groups["Cette semaine"]!.add(n);
      } else {
        groups["Plus ancien"]!.add(n);
      }
    }
    groups.removeWhere((_, v) => v.isEmpty);
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final asyncNotifications = ref.watch(notificationsProvider);
    final notifications = asyncNotifications.valueOrNull ?? [];
    final unread = notifications.where((n) => !n.isRead).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Styled header ────────────────────────────────────────────────
          AppPageHeader(
            title: 'Notifications',
            subtitle: unread > 0
                ? '$unread nouvelle${unread > 1 ? 's' : ''}'
                : 'Tout est à jour',
            icon: Icons.notifications_rounded,
            gradientColors: const [AppColors.primaryDark, AppColors.primary],
            actions: [
              if (unread > 0)
                _HeaderTextAction(label: 'Tout lire', onTap: _markAllAsRead),
            ],
          ),

          // ── Content ──────────────────────────────────────────────────────
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.refresh(notificationsProvider.future),
              color: AppColors.primary,
              child: asyncNotifications.when(
                data: (_) => notifications.isEmpty
                    ? _buildScrollableEmptyState()
                    : _buildList(_groupNotifications(notifications)),
                loading: () => const AppLoader(),
                error: (e, _) => _buildScrollableEmptyState(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScrollableEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: _buildEmptyState(),
      ),
    );
  }

  Widget _buildList(Map<String, List<NotificationModel>> groups) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final title = groups.keys.elementAt(index);
        final items = groups[title]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: Text(
                title.toUpperCase(),
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            ...items.asMap().entries.map((e) => _buildTile(e.value, e.key)),
          ],
        );
      },
    );
  }

  Widget _buildTile(NotificationModel n, int index) {
    return Dismissible(
      key: Key(n.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: AppColors.danger,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => _deleteNotification(n.id),
      child: NotificationTile(notification: n, onTap: () => _handleTap(n))
          .animate()
          .fadeIn(delay: (index * 80).ms, duration: 350.ms)
          .slideX(begin: 0.08, end: 0),
    );
  }

  void _handleTap(NotificationModel n) {
    switch (n.type) {
      case 'booking_confirmed':
        context.go('/bookings');
      case 'new_message':
        context.go('/chat');
      case 'sos_alert':
        context.push('/sos');
      default:
        break;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: AppColors.primarySurface,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Aucune notification',
              style: AppTypography.h2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'C\'est ici que vous recevrez vos mises à jour importantes.',
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
}

class _HeaderTextAction extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _HeaderTextAction({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Text(
          'Tout lire',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
