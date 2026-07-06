import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../mock/mock_data.dart';

/// Contrat d'accès aux données de profil/dashboard.
///
/// Les types `Map<String, dynamic>` reflètent les données mockées actuelles ;
/// ils seront remplacés par des modèles typés lors du branchement Firestore.
abstract class ProfileRepository {
  /// Id de l'utilisateur connecté (uid Firebase, ou id fixe en mode démo).
  String currentUserId();

  /// Profil de l'utilisateur connecté tel que saisi à l'inscription
  /// (prénom, quartier...), ou `null` si aucun profil n'est enregistré.
  Future<Map<String, dynamic>?> getCurrentUserProfile();

  Future<Map<String, dynamic>> getParentStats();

  Future<Map<String, dynamic>> getNannyStats();

  Future<List<Map<String, dynamic>>> getUpcomingMissions();

  Future<List<Map<String, dynamic>>> getRecentReviews();
}

/// Implémentation mock : lit [MockData] avec une latence simulée.
class MockProfileRepository implements ProfileRepository {
  static const Duration _latency = Duration(milliseconds: 300);

  /// Clé partagée avec [MockAuthRepository] qui y persiste le profil
  /// saisi à l'inscription.
  static const String profilePrefsKey = 'userProfile';

  @override
  String currentUserId() => 'p1';

  @override
  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(profilePrefsKey);
    if (raw == null) return null;
    return (jsonDecode(raw) as Map).cast<String, dynamic>();
  }

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
