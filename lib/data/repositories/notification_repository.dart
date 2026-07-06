import '../mock/mock_data.dart';
import '../models/notification_model.dart';

/// Contrat d'accès aux notifications.
abstract class NotificationRepository {
  Future<List<NotificationModel>> getNotifications();

  Future<void> markAsRead(String id);

  Future<void> markAllAsRead();

  Future<void> deleteNotification(String id);

  /// Crée une notification (ex. trace d'une alerte SOS).
  Future<void> addNotification(NotificationModel notification);
}

/// Implémentation mock : liste en mémoire initialisée depuis [MockData].
class MockNotificationRepository implements NotificationRepository {
  static const Duration _latency = Duration(milliseconds: 300);

  final List<NotificationModel> _notifications = List.of(
    MockData.notifications,
  );

  NotificationModel _asRead(NotificationModel n) => NotificationModel(
    id: n.id,
    userId: n.userId,
    title: n.title,
    body: n.body,
    type: n.type,
    isRead: true,
    createdAt: n.createdAt,
  );

  @override
  Future<List<NotificationModel>> getNotifications() =>
      Future.delayed(_latency, () => List.unmodifiable(_notifications));

  @override
  Future<void> markAsRead(String id) => Future.delayed(_latency, () {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _asRead(_notifications[index]);
    }
  });

  @override
  Future<void> markAllAsRead() => Future.delayed(_latency, () {
    for (var i = 0; i < _notifications.length; i++) {
      _notifications[i] = _asRead(_notifications[i]);
    }
  });

  @override
  Future<void> deleteNotification(String id) => Future.delayed(_latency, () {
    _notifications.removeWhere((n) => n.id == id);
  });

  @override
  Future<void> addNotification(NotificationModel notification) =>
      Future.delayed(_latency, () {
        _notifications.insert(0, notification);
      });
}
