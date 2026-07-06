import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/notification_model.dart';
import '../sos_repository.dart';

/// Implémentation Firestore des alertes SOS.
///
/// Schéma : `sos_alerts/{alertId}` (SosAlert.toJson). La Cloud Function
/// `onSosAlertCreated` (functions/src/index.ts) relaie l'alerte à la
/// contrepartie de la mission : notification Firestore + push FCM.
/// La trace côté émetteur est écrite ici, dans le même batch que l'alerte.
class FirestoreSosRepository implements SosRepository {
  FirestoreSosRepository({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

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

    final trace = NotificationModel(
      id: 'notif-${alert.id}',
      userId: fromUserId,
      title: 'Alerte SOS déclenchée',
      body:
          'Votre alerte a été enregistrée et transmise à Nounou Express '
          'le ${now.day}/${now.month}/${now.year}.',
      type: 'sos_alert',
      isRead: false,
      createdAt: now,
    );

    final batch = _db.batch()
      ..set(_db.collection('sos_alerts').doc(alert.id), alert.toJson())
      ..set(
        _db
            .collection('users')
            .doc(fromUserId)
            .collection('notifications')
            .doc(trace.id),
        trace.toJson(),
      );
    await batch.commit();
    return alert;
  }
}
