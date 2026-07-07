import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_loader.dart';
import '../../../core/widgets/app_page_header.dart';
import '../../../core/widgets/empty_state.dart';
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
    final conversations =
        (conversationsAsync.valueOrNull ?? const <ConversationModel>[])
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
            // Gradient clair : texte sombre pour le contraste AA.
            gradientColors: const [AppColors.accent, AppColors.accentLight],
            foregroundColor: AppColors.secondary,
          ),

          // ── Content ──────────────────────────────────────────────────────
          Expanded(
            child: conversationsAsync.when(
              loading: () => const AppLoader(),
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
                // Temps réel : le stream pousse les mises à jour tout seul,
                // le geste de rafraîchissement est conservé pour l'UX.
                onRefresh: () async {},
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
    return EmptyState(
      icon: Icons.chat_bubble_outline_rounded,
      title: 'Aucune conversation',
      description: 'Réservez une nounou pour commencer à discuter.',
      actionLabel: 'Trouver une nounou',
      onAction: () => context.go('/search'),
    );
  }
}
