import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/conversation_model.dart';

class ConversationTile extends StatelessWidget {
  final ConversationModel conversation;
  final VoidCallback? onDelete;
  final VoidCallback? onArchive;

  const ConversationTile({
    super.key,
    required this.conversation,
    this.onDelete,
    this.onArchive,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(conversation.id),
      background: _buildSwipeBackground(
        color: AppColors.primary,
        icon: Icons.archive_outlined,
        alignment: Alignment.centerLeft,
      ),
      secondaryBackground: _buildSwipeBackground(
        color: AppColors.danger,
        icon: Icons.delete_outline,
        alignment: Alignment.centerRight,
      ),
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          onArchive?.call();
        } else {
          onDelete?.call();
        }
      },
      child: InkWell(
        onTap: () => context.push('/chat/${conversation.otherUserId}'),
        // Alternative non gestuelle au swipe (accessibilité).
        onLongPress: () => _showActions(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              _buildAvatar(),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          conversation.otherUserName,
                          style: AppTypography.bodyLarge.copyWith(
                            fontWeight: conversation.unreadCount > 0
                                ? FontWeight.bold
                                : FontWeight.w600,
                          ),
                        ),
                        Text(
                          AppFormatters.formatChatDate(
                            conversation.lastMessageTime,
                          ),
                          style: AppTypography.caption.copyWith(
                            color: conversation.unreadCount > 0
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            fontWeight: conversation.unreadCount > 0
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            conversation.lastMessage,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodyMedium.copyWith(
                              color: conversation.unreadCount > 0
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                              fontWeight: conversation.unreadCount > 0
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                        if (conversation.unreadCount > 0)
                          _buildUnreadBadge()
                        else if (conversation.isLastMessageRead)
                          const Icon(
                            Icons.done_all,
                            size: 16,
                            color: AppColors.primary,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showActions(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: AppSpacing.sheetBorderRadius,
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpacing.sm),
            ListTile(
              leading: const Icon(
                Icons.archive_outlined,
                color: AppColors.primary,
              ),
              title: Text('Archiver', style: AppTypography.bodyLarge),
              onTap: () {
                Navigator.of(ctx).pop();
                onArchive?.call();
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.delete_outline,
                color: AppColors.danger,
              ),
              title: Text(
                'Supprimer',
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.danger,
                ),
              ),
              onTap: () {
                Navigator.of(ctx).pop();
                onDelete?.call();
              },
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Stack(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundImage: conversation.otherUserAvatar != null
              ? NetworkImage(conversation.otherUserAvatar!)
              : null,
          child: conversation.otherUserAvatar == null
              ? const Icon(Icons.person)
              : null,
        ),
        if (conversation.isOnline)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildUnreadBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: const BoxDecoration(
        color: AppColors.danger,
        shape: BoxShape.circle,
      ),
      child: Text(
        "${conversation.unreadCount}",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSwipeBackground({
    required Color color,
    required IconData icon,
    required Alignment alignment,
  }) {
    return Container(
      color: color,
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Icon(icon, color: Colors.white),
    );
  }
}
