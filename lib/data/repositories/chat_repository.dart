import '../mock/mock_data.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';

/// Contrat d'accès aux conversations et messages.
///
/// À terme (Phase 3) : streams Firestore temps réel.
abstract class ChatRepository {
  Future<List<ConversationModel>> getConversations();

  /// Conversation avec un utilisateur donné, ou `null` si aucune n'existe.
  Future<ConversationModel?> getConversationWith(String otherUserId);

  Future<List<MessageModel>> getMessages(String otherUserId);

  Future<MessageModel> sendMessage(MessageModel message);
}

/// Implémentation mock : messages en mémoire par interlocuteur,
/// initialisés depuis [MockData].
class MockChatRepository implements ChatRepository {
  static const Duration _latency = Duration(milliseconds: 300);

  final Map<String, List<MessageModel>> _messagesByUser = {};

  List<MessageModel> _threadFor(String otherUserId) => _messagesByUser
      .putIfAbsent(otherUserId, () => List.of(MockData.messages));

  @override
  Future<List<ConversationModel>> getConversations() =>
      Future.delayed(_latency, () => List.unmodifiable(MockData.conversations));

  @override
  Future<ConversationModel?> getConversationWith(String otherUserId) =>
      Future.delayed(_latency, () {
        for (final conversation in MockData.conversations) {
          if (conversation.otherUserId == otherUserId) return conversation;
        }
        return null;
      });

  @override
  Future<List<MessageModel>> getMessages(String otherUserId) => Future.delayed(
    _latency,
    () => List.unmodifiable(_threadFor(otherUserId)),
  );

  @override
  Future<MessageModel> sendMessage(MessageModel message) =>
      Future.delayed(_latency, () {
        _threadFor(message.receiverId).add(message);
        return message;
      });
}
