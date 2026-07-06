import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/notification_model.dart';
import '../notification_repository.dart';
import 'firestore_helpers.dart';

/// Implémentation Firestore des notifications.
///
/// Schéma : `users/{uid}/notifications/{notificationId}`
/// (NotificationModel.toJson, dates ISO-8601).
class FirestoreNotificationRepository implements NotificationRepository {
  FirestoreNotificationRepository({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _notifications =>
      _db.collection('users').doc(currentUid()).collection('notifications');

  @override
  Future<List<NotificationModel>> getNotifications() async {
    final snapshot = await _notifications
        .orderBy('createdAt', descending: true)
        .limit(50)
        .get();
    return List.unmodifiable(
      snapshot.docs.map(
        (d) => NotificationModel.fromJson(normalizeDoc(d.data())),
      ),
    );
  }

  @override
  Future<void> markAsRead(String id) =>
      _notifications.doc(id).update({'isRead': true});

  @override
  Future<void> markAllAsRead() async {
    final unread = await _notifications.where('isRead', isEqualTo: false).get();
    if (unread.docs.isEmpty) return;
    final batch = _db.batch();
    for (final doc in unread.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  @override
  Future<void> deleteNotification(String id) => _notifications.doc(id).delete();

  @override
  Future<void> addNotification(NotificationModel notification) =>
      _notifications.doc(notification.id).set(notification.toJson());
}
