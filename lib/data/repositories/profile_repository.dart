import '../mock/mock_data.dart';

/// Contrat d'accès aux données de profil/dashboard.
///
/// Les types `Map<String, dynamic>` reflètent les données mockées actuelles ;
/// ils seront remplacés par des modèles typés lors du branchement Firestore.
abstract class ProfileRepository {
  Future<Map<String, dynamic>> getParentStats();

  Future<Map<String, dynamic>> getNannyStats();

  Future<List<Map<String, dynamic>>> getUpcomingMissions();

  Future<List<Map<String, dynamic>>> getRecentReviews();
}

/// Implémentation mock : lit [MockData] avec une latence simulée.
class MockProfileRepository implements ProfileRepository {
  static const Duration _latency = Duration(milliseconds: 300);

  @override
  Future<Map<String, dynamic>> getParentStats() =>
      Future.delayed(_latency, () => Map.unmodifiable(MockData.parentStats));

  @override
  Future<Map<String, dynamic>> getNannyStats() =>
      Future.delayed(_latency, () => Map.unmodifiable(MockData.nannyStats));

  @override
  Future<List<Map<String, dynamic>>> getUpcomingMissions() => Future.delayed(
    _latency,
    () => List.unmodifiable(MockData.upcomingMissions),
  );

  @override
  Future<List<Map<String, dynamic>>> getRecentReviews() =>
      Future.delayed(_latency, () => List.unmodifiable(MockData.recentReviews));
}
