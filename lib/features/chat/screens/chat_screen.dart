import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_loader.dart';
import '../../../data/models/conversation_model.dart';
import '../../../data/models/message_model.dart';
import '../../../data/providers/data_providers.dart';
import '../widgets/message_bubble.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String? nannyId;

  const ChatScreen({super.key, this.nannyId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  String get _otherUserId => widget.nannyId ?? 'n1';

  @override
  void initState() {
    super.initState();
    _messageController.addListener(() {
      setState(() {
        _isTyping = _messageController.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (!_isTyping) return;

    final newMessage = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: ref.read(currentUserIdProvider),
      receiverId: _otherUserId,
      content: _messageController.text.trim(),
      timestamp: DateTime.now(),
      isRead: false,
    );

    _messageController.clear();

    // Le stream de `messagesProvider` pousse la nouvelle liste tout seul ;
    // le scroll est déclenché par le `ref.listen` dans `build`.
    await ref.read(chatRepositoryProvider).sendMessage(newMessage);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Scroll en bas à l'arrivée de nouveaux messages (envoyés ou reçus).
    ref.listen(messagesProvider(_otherUserId), (previous, next) {
      final previousCount = previous?.valueOrNull?.length;
      final nextCount = next.valueOrNull?.length;
      if (previousCount != null &&
          nextCount != null &&
          nextCount > previousCount) {
        _scrollToBottom();
      }
    });

    // En-tête : conversation avec l'interlocuteur, sinon repli sur la
    // première conversation disponible (comportement historique du mock).
    final conversation =
        ref.watch(conversationWithProvider(_otherUserId)).valueOrNull ??
        ref.watch(conversationsProvider).valueOrNull?.firstOrNull;

    return Scaffold(
      appBar: _buildAppBar(conversation),
      body: Column(
        children: [
          Expanded(child: _buildMessagesList()),
          _buildInputBar(),
        ],
      ),
    );
  }

  void _startCall(ConversationModel? conversation) {
    final name = conversation?.otherUserName;
    context.push(
      '/video-call${name == null ? '' : '?name=${Uri.encodeQueryComponent(name)}'}',
    );
  }

  PreferredSizeWidget _buildAppBar(ConversationModel? conversation) {
    return AppBar(
      titleSpacing: 0,
      title: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundImage: conversation?.otherUserAvatar != null
                ? NetworkImage(conversation!.otherUserAvatar!)
                : null,
            child: conversation?.otherUserAvatar == null
                ? const Icon(Icons.person)
                : null,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  conversation?.otherUserName ?? '',
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (conversation != null)
                  Text(
                    conversation.isOnline
                        ? "En ligne"
                        : (conversation.lastSeen != null
                              ? "Vu il y a ${DateTime.now().difference(conversation.lastSeen!).inMinutes} min"
                              : "Hors ligne"),
                    style: AppTypography.caption.copyWith(
                      color: conversation.isOnline
                          ? AppColors.success
                          : AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.videocam_outlined),
          tooltip: 'Appel vidéo',
          onPressed: () => _startCall(conversation),
        ),
      ],
    );
  }

  Widget _buildMessagesList() {
    final currentUserId = ref.watch(currentUserIdProvider);
    return ref
        .watch(messagesProvider(_otherUserId))
        .when(
          loading: () => const AppLoader(),
          error: (e, _) => Center(
            child: Text(
              'Impossible de charger les messages.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          data: (messages) => ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index];
              final bool isMe = message.senderId == currentUserId;

              // Show date separator if the date changed
              bool showDateSeparator = false;
              if (index == 0) {
                showDateSeparator = true;
              } else {
                final prevDate = messages[index - 1].timestamp;
                if (prevDate.day != message.timestamp.day ||
                    prevDate.month != message.timestamp.month ||
                    prevDate.year != message.timestamp.year) {
                  showDateSeparator = true;
                }
              }

              return Column(
                children: [
                  if (showDateSeparator) _buildDateSeparator(message.timestamp),
                  MessageBubble(message: message, isMe: isMe),
                ],
              );
            },
          ),
        );
  }

  Widget _buildDateSeparator(DateTime date) {
    String dateStr;
    final now = DateTime.now();
    if (date.day == now.day &&
        date.month == now.month &&
        date.year == now.year) {
      dateStr = "Aujourd'hui";
    } else if (date.day == now.subtract(const Duration(days: 1)).day) {
      dateStr = "Hier";
    } else {
      dateStr = DateFormat('d MMMM yyyy', 'fr_FR').format(date);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: AppColors.border.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            dateStr,
            style: AppTypography.caption.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.sm,
        bottom: MediaQuery.of(context).padding.bottom + AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: "Écrivez votre message...",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
                maxLines: null,
                style: AppTypography.bodyMedium,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Semantics(
            button: true,
            label: 'Envoyer le message',
            child: GestureDetector(
              onTap: _sendMessage,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isTyping ? Icons.send : Icons.mic_none,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
