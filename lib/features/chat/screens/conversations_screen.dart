import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_page_header.dart';
import '../../../data/models/conversation_model.dart';
import '../../../data/providers/data_providers.dart';
import '../widgets/conversation_tile.dart';

class ConversationsScreen extends ConsumerStatefulWidget {
  const ConversationsScreen({super.key});

  @override
  ConsumerState<ConversationsScreen> createState() =>
      _ConversationsScreenState();
}

class _ConversationsScreenState extends ConsumerState<ConversationsScreen> {
  /// Suppressions/archivages locaux (mock assumé : pas encore persistés).
  final Set<String> _removedIds = {};

  void _removeConversation(String id) {
    setState(() {
      _removedIds.add(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final conversationsAsync = ref.watch(conversationsProvider);
    final conversations = (conversationsAsync.valueOrNull ??
            const <ConversationModel>[])
        .where((c) => !_removedIds.contains(c.id))
        .toList();
    final unread = conversations.where((c) => c.unreadCount > 0).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Styled header ────────────────────────────────────────────────
          AppPageHeader(
            title: 'Messages',
            subtitle: unread > 0
                ? '$unread non lu${unread > 1 ? 's' : ''}'
                : 'Toutes vos conversations',
            icon: Icons.chat_bubble_rounded,
            gradientColors: const [Color(0xFF006D62), AppColors.accent],
            actions: [_HeaderAction(icon: Icons.edit_rounded, onTap: () {})],
          ),

          // ── Content ──────────────────────────────────────────────────────
          Expanded(
            child: conversationsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text(
                  'Impossible de charger les conversations.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              data: (_) => RefreshIndicator(
                onRefresh: () => ref.refresh(conversationsProvider.future),
                color: AppColors.accent,
                child: conversations.isEmpty
                    ? SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.6,
                          child: _buildEmptyState(context),
                        ),
                      )
                    : _buildConversationsList(conversations),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationsList(List<ConversationModel> conversations) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      itemCount: conversations.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        indent: AppSpacing.lg + 56 + AppSpacing.md,
        endIndent: AppSpacing.lg,
        color: AppColors.border,
      ),
      itemBuilder: (context, index) {
        final conversation = conversations[index];
        return ConversationTile(
              conversation: conversation,
              onDelete: () => _removeConversation(conversation.id),
              onArchive: () => _removeConversation(conversation.id),
            )
            .animate()
            .fadeIn(delay: (index * 80).ms, duration: 350.ms)
            .slideX(begin: 0.08, end: 0);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.accentSurface,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                size: 48,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Aucune conversation',
              style: AppTypography.h2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Réservez une nounou pour commencer à discuter',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxxl),
            ElevatedButton(
              onPressed: () => context.go('/search'),
              child: const Text('Trouver une nounou'),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _HeaderAction({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 18, color: Colors.white),
      ),
    );
  }
}
