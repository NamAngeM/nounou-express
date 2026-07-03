import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/conversation_model.dart';
import '../../models/message_model.dart';
import '../chat_repository.dart';
import 'firestore_helpers.dart';

/// Implémentation Firestore du chat.
///
/// Schéma :
///  - `users/{uid}/conversations/{otherUserId}` : résumé de conversation
///    (ConversationModel.toJson), tenu à jour en miroir des deux côtés
///    à chaque envoi de message ;
///  - `chats/{threadId}/messages/{messageId}` : messages du fil, où
///    `threadId` = [chatThreadId] des deux participants.
class FirestoreChatRepository implements ChatRepository {
  FirestoreChatRepository({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _conversationsOf(String uid) =>
      _db.collection('users').doc(uid).collection('conversations');

  CollectionReference<Map<String, dynamic>> _messagesOf(String threadId) =>
      _db.collection('chats').doc(threadId).collection('messages');

  @override
  Future<List<ConversationModel>> getConversations() async {
    final snapshot = await _conversationsOf(
      currentUid(),
    ).orderBy('lastMessageTime', descending: true).get();
    return List.unmodifiable(
      snapshot.docs.map(
        (d) => ConversationModel.fromJson(normalizeDoc(d.data())),
      ),
    );
  }

  @override
  Future<ConversationModel?> getConversationWith(String otherUserId) async {
    final snapshot = await _conversationsOf(
      currentUid(),
    ).doc(otherUserId).get();
    final data = snapshot.data();
    if (data == null) return null;
    return ConversationModel.fromJson(normalizeDoc(data));
  }

  @override
  Future<List<MessageModel>> getMessages(String otherUserId) async {
    final threadId = chatThreadId(currentUid(), otherUserId);
    final snapshot = await _messagesOf(
      threadId,
    ).orderBy('timestamp').limit(100).get();
    return List.unmodifiable(
      snapshot.docs.map((d) => MessageModel.fromJson(normalizeDoc(d.data()))),
    );
  }

  @override
  Stream<List<ConversationModel>> watchConversations() =>
      _conversationsOf(currentUid())
          .orderBy('lastMessageTime', descending: true)
          .snapshots()
          .map(
            (snapshot) => List.unmodifiable(
              snapshot.docs.map(
                (d) => ConversationModel.fromJson(normalizeDoc(d.data())),
              ),
            ),
          );

  @override
  Stream<List<MessageModel>> watchMessages(String otherUserId) {
    final threadId = chatThreadId(currentUid(), otherUserId);
    return _messagesOf(threadId)
        .orderBy('timestamp')
        .limit(100)
        .snapshots()
        .map(
          (snapshot) => List.unmodifiable(
            snapshot.docs.map(
              (d) => MessageModel.fromJson(normalizeDoc(d.data())),
            ),
          ),
        );
  }

  @override
  Future<MessageModel> sendMessage(MessageModel message) async {
    final uid = currentUid();
    final otherUserId = message.receiverId;
    final threadId = chatThreadId(uid, otherUserId);

    final messages = _messagesOf(threadId);
    final messageRef = message.id.isEmpty
        ? messages.doc()
        : messages.doc(message.id);

    final lastMessageFields = {
      'lastMessage': message.content,
      'lastMessageTime': message.timestamp.toIso8601String(),
    };

    // Écriture atomique : le message + le résumé de conversation en miroir
    // des deux côtés (chaque participant voit l'autre comme interlocuteur).
    final batch = _db.batch();
    batch.set(messageRef, message.toJson());
    batch.set(_conversationsOf(uid).doc(otherUserId), {
      'id': threadId,
      'otherUserId': otherUserId,
      ...lastMessageFields,
      'isLastMessageRead': true,
    }, SetOptions(merge: true));
    batch.set(_conversationsOf(otherUserId).doc(uid), {
      'id': threadId,
      'otherUserId': uid,
      ...lastMessageFields,
      'isLastMessageRead': false,
    }, SetOptions(merge: true));
    await batch.commit();

    return message;
  }
}
