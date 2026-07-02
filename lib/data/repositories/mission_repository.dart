import '../mock/mock_data.dart';
import '../models/application_model.dart';
import '../models/mission_model.dart';

/// Contrat d'accès aux missions (annonces) et candidatures.
abstract class MissionRepository {
  Future<List<MissionModel>> getMissions();

  Future<MissionModel> getMissionById(String id);

  Future<List<ApplicationModel>> getApplicationsForMission(String missionId);

  Future<MissionModel> publishMission(MissionModel mission);

  /// Remplace la mission portant le même id (statut, retards, etc.).
  Future<MissionModel> updateMission(MissionModel mission);
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
  Future<MissionModel> publishMission(MissionModel mission) => Future.delayed(
    _latency,
    () {
      _missions.insert(0, mission);
      return mission;
    },
  );

  @override
  Future<MissionModel> updateMission(MissionModel mission) => Future.delayed(
    _latency,
    () {
      final index = _missions.indexWhere((m) => m.id == mission.id);
      if (index == -1) {
        throw StateError('Mission introuvable : ${mission.id}');
      }
      _missions[index] = mission;
      return mission;
    },
  );
}
