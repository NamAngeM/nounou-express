import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/application_model.dart';
import '../../models/mission_model.dart';
import '../mission_repository.dart';
import 'firestore_helpers.dart';

/// Implémentation Firestore des missions et candidatures.
///
/// Schéma :
///  - `missions/{missionId}` : annonce (MissionModel.toJson, dates ISO-8601) ;
///  - `applications/{applicationId}` : candidature (ApplicationModel.toJson),
///    reliée à sa mission par le champ `missionId`.
class FirestoreMissionRepository implements MissionRepository {
  FirestoreMissionRepository({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _missions =>
      _db.collection('missions');

  @override
  Future<List<MissionModel>> getMissions() async {
    final snapshot = await _missions
        .orderBy('publishedAt', descending: true)
        .limit(50)
        .get();
    return List.unmodifiable(
      snapshot.docs.map((d) => MissionModel.fromJson(normalizeDoc(d.data()))),
    );
  }

  @override
  Future<MissionModel> getMissionById(String id) async {
    final snapshot = await _missions.doc(id).get();
    final data = snapshot.data();
    if (data == null) throw StateError('Mission introuvable : $id');
    return MissionModel.fromJson(normalizeDoc(data));
  }

  @override
  Future<List<ApplicationModel>> getApplicationsForMission(
    String missionId,
  ) async {
    final snapshot = await _db
        .collection('applications')
        .where('missionId', isEqualTo: missionId)
        .get();
    return List.unmodifiable(
      snapshot.docs.map(
        (d) => ApplicationModel.fromJson(normalizeDoc(d.data())),
      ),
    );
  }

  @override
  Future<MissionModel> publishMission(MissionModel mission) async {
    await _missions.doc(mission.id).set(mission.toJson());
    return mission;
  }

  @override
  Future<MissionModel> updateMission(MissionModel mission) async {
    // Même sémantique que le mock : mise à jour d'une mission existante
    // uniquement — un `set` seul créerait silencieusement le document.
    final snapshot = await _missions.doc(mission.id).get();
    if (!snapshot.exists) {
      throw StateError('Mission introuvable : ${mission.id}');
    }
    await _missions.doc(mission.id).set(mission.toJson());
    return mission;
  }

  @override
  Future<void> updateApplicationStatus(
    String applicationId,
    ApplicationStatus status,
  ) => _db.collection('applications').doc(applicationId).update({
    'status': status.name,
  });

  @override
  Future<List<ApplicationModel>> getApplicationsForNanny(
    String nannyId,
  ) async {
    final snapshot = await _db
        .collection('applications')
        .where('nannyId', isEqualTo: nannyId)
        .get();
    final applications = snapshot.docs
        .map((d) => ApplicationModel.fromJson(normalizeDoc(d.data())))
        .toList()
      ..sort((a, b) => b.appliedAt.compareTo(a.appliedAt));
    return List.unmodifiable(applications);
  }

  @override
  Future<void> applyToMission(ApplicationModel application) async {
    final batch = _db.batch()
      ..set(
        _db.collection('applications').doc(application.id),
        application.toJson(),
      )
      ..update(_missions.doc(application.missionId), {
        'applicantIds': FieldValue.arrayUnion([application.nannyId]),
      });
    await batch.commit();
  }
}
