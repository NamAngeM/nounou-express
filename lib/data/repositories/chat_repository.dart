import 'dart:async';

import '../mock/mock_data.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';

/// Contrat d'accès aux conversations et messages.
abstract class ChatRepository {
  Future<List<ConversationModel>> getConversations();

  /// Conversation avec un utilisateur donné, ou `null` si aucune n'existe.
  Future<ConversationModel?> getConversationWith(String otherUserId);

  Future<List<MessageModel>> getMessages(String otherUserId);

  Future<MessageModel> sendMessage(MessageModel message);

  /// Flux temps réel des conversations de l'utilisateur courant.
  ///
  /// Émet immédiatement l'état courant à l'abonnement, puis chaque mise à
  /// jour.
  Stream<List<ConversationModel>> watchConversations();

  /// Flux temps réel des messages échangés avec [otherUserId].
  ///
  /// Émet immédiatement l'état courant à l'abonnement, puis chaque mise à
  /// jour.
  Stream<List<MessageModel>> watchMessages(String otherUserId);
}

/// Implémentation mock : messages en mémoire par interlocuteur,
/// initialisés depuis [MockData].
class MockChatRepository implements ChatRepository {
  static const Duration _latency = Duration(milliseconds: 300);

  final Map<String, List<MessageModel>> _messagesByUser = {};

  /// Controllers broadcast (un par fil + un pour les conversations) :
  /// [sendMessage] y pousse le nouvel état, les `watch*` émettent d'abord
  /// l'état courant puis relaient ces mises à jour. Pas de timers
  /// périodiques : rien ne bloque la fin des tests.
  final Map<String, StreamController<List<MessageModel>>> _threadControllers =
      {};
  final StreamController<List<ConversationModel>> _conversationsController =
      StreamController<List<ConversationModel>>.broadcast();

  List<MessageModel> _threadFor(String otherUserId) => _messagesByUser
      .putIfAbsent(otherUserId, () => List.of(MockData.messages));

  StreamController<List<MessageModel>> _threadControllerFor(
    String otherUserId,
  ) => _threadControllers.putIfAbsent(
    otherUserId,
    StreamController<List<MessageModel>>.broadcast,
  );

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
        final thread = _threadFor(message.receiverId)..add(message);
        _threadControllerFor(message.receiverId).add(List.unmodifiable(thread));
        return message;
      });

  @override
  Stream<List<ConversationModel>> watchConversations() async* {
    yield List.unmodifiable(MockData.conversations);
    yield* _conversationsController.stream;
  }

  @override
  Stream<List<MessageModel>> watchMessages(String otherUserId) async* {
    yield List.unmodifiable(_threadFor(otherUserId));
    yield* _threadControllerFor(otherUserId).stream;
  }
}
