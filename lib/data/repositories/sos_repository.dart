import '../models/notification_model.dart';
import 'notification_repository.dart';

/// Alerte SOS émise par un utilisateur, éventuellement rattachée à la
/// mission en cours (ce qui permet d'identifier qui prévenir).
class SosAlert {
  final String id;
  final String fromUserId;
  final String? missionId;
  final DateTime createdAt;

  const SosAlert({
    required this.id,
    required this.fromUserId,
    this.missionId,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'fromUserId': fromUserId,
    'missionId': missionId,
    'createdAt': createdAt.toIso8601String(),
    // Renseigné par la Cloud Function une fois la contrepartie prévenue.
    'relayedTo': null,
  };
}

/// Contrat d'envoi d'une alerte SOS.
///
/// L'envoi produit deux effets : une trace horodatée côté émetteur
/// (notification dans son fil) et, quand une mission est rattachée,
/// le relais vers la contrepartie (parent ↔ nounou). En mode Firebase,
/// le relais est assuré par la Cloud Function `onSosAlertCreated`
/// (notification Firestore + push FCM).
abstract class SosRepository {
  Future<SosAlert> sendAlert({required String fromUserId, String? missionId});
}

String _alertBody(DateTime now, String? missionId) {
  final time =
      '${now.day}/${now.month}/${now.year} à '
      '${now.hour.toString().padLeft(2, '0')}:'
      '${now.minute.toString().padLeft(2, '0')}';
  return missionId == null
      ? 'Alerte enregistrée le $time (aucune mission en cours associée).'
      : 'Alerte enregistrée le $time pendant la mission $missionId. '
            'La personne concernée par la mission est prévenue.';
}

NotificationModel _traceNotification(SosAlert alert) => NotificationModel(
  id: 'notif-${alert.id}',
  userId: alert.fromUserId,
  title: 'Alerte SOS déclenchée',
  body: _alertBody(alert.createdAt, alert.missionId),
  type: 'sos_alert',
  isRead: false,
  createdAt: alert.createdAt,
);

/// Implémentation mock : alertes en mémoire de session, trace dans le
/// fil de notifications (le relais réel n'existe qu'en mode Firebase).
class MockSosRepository implements SosRepository {
  MockSosRepository(this._notifications);

  final NotificationRepository _notifications;
  final List<SosAlert> alerts = [];

  @override
  Future<SosAlert> sendAlert({
    required String fromUserId,
    String? missionId,
  }) async {
    final now = DateTime.now();
    final alert = SosAlert(
      id: 'sos-${now.millisecondsSinceEpoch}',
      fromUserId: fromUserId,
      missionId: missionId,
      createdAt: now,
    );
    alerts.add(alert);
    await _notifications.addNotification(_traceNotification(alert));
    return alert;
  }
}
