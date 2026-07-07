import '../mock/mock_data.dart';
import '../models/application_model.dart';
import '../models/mission_model.dart';

/// Contrat d'accès aux missions (annonces) et candidatures.
abstract class MissionRepository {
  Future<List<MissionModel>> getMissions();

  Future<MissionModel> getMissionById(String id);

  Future<List<ApplicationModel>> getApplicationsForMission(String missionId);

  /// Candidatures déposées par une nounou, toutes missions confondues.
  Future<List<ApplicationModel>> getApplicationsForNanny(String nannyId);

  /// Dépose une candidature : crée l'[ApplicationModel] et référence la
  /// nounou dans `applicantIds` de la mission.
  Future<void> applyToMission(ApplicationModel application);

  Future<MissionModel> publishMission(MissionModel mission);

  /// Remplace la mission portant le même id (statut, retards, etc.).
  Future<MissionModel> updateMission(MissionModel mission);

  /// Change le statut d'une candidature (acceptée / refusée).
  Future<void> updateApplicationStatus(
    String applicationId,
    ApplicationStatus status,
  );
}

/// Implémentation mock : listes en mémoire initialisées depuis [MockData].
/// Les mutations persistent pendant la session (perdues au redémarrage).
class MockMissionRepository implements MissionRepository {
  static const Duration _latency = Duration(milliseconds: 300);

  final List<MissionModel> _missions = List.of(mockMissions);
  final List<ApplicationModel> _applications = List.of(mockApplications);

  @override
  Future<List<MissionModel>> getMissions() =>
      Future.delayed(_latency, () => List.unmodifiable(_missions));

  @override
  Future<MissionModel> getMissionById(String id) => Future.delayed(
    _latency,
    () => _missions.firstWhere(
      (m) => m.id == id,
      orElse: () => throw StateError('Mission introuvable : $id'),
    ),
  );

  @override
  Future<List<ApplicationModel>> getApplicationsForMission(String missionId) =>
      Future.delayed(
        _latency,
        () => List.unmodifiable(
          _applications.where((a) => a.missionId == missionId).toList(),
        ),
      );

  @override
  Future<List<ApplicationModel>> getApplicationsForNanny(String nannyId) =>
      Future.delayed(
        _latency,
        () => List.unmodifiable(
          _applications.where((a) => a.nannyId == nannyId).toList()
            ..sort((a, b) => b.appliedAt.compareTo(a.appliedAt)),
        ),
      );

  @override
  Future<void> applyToMission(ApplicationModel application) => Future.delayed(
    _latency,
    () {
      _applications.insert(0, application);
      final index = _missions.indexWhere((m) => m.id == application.missionId);
      if (index != -1 &&
          !_missions[index].applicantIds.contains(application.nannyId)) {
        _missions[index] = _missions[index].copyWith(
          applicantIds: [..._missions[index].applicantIds, application.nannyId],
        );
      }
    },
  );

  @override
  Future<MissionModel> publishMission(MissionModel mission) =>
      Future.delayed(_latency, () {
        _missions.insert(0, mission);
        return mission;
      });

  @override
  Future<MissionModel> updateMission(MissionModel mission) =>
      Future.delayed(_latency, () {
        final index = _missions.indexWhere((m) => m.id == mission.id);
        if (index == -1) {
          throw StateError('Mission introuvable : ${mission.id}');
        }
        _missions[index] = mission;
        return mission;
      });

  @override
  Future<void> updateApplicationStatus(
    String applicationId,
    ApplicationStatus status,
  ) => Future.delayed(_latency, () {
    final index = _applications.indexWhere((a) => a.id == applicationId);
    if (index == -1) {
      throw StateError('Candidature introuvable : $applicationId');
    }
    _applications[index] = _applications[index].copyWith(status: status);
  });
}
