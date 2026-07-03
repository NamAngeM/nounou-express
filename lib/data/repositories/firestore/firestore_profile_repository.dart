import 'package:cloud_firestore/cloud_firestore.dart';

import '../profile_repository.dart';
import 'firestore_helpers.dart';

/// Implémentation Firestore du profil/dashboard.
///
/// Schéma : document unique `users/{uid}/dashboard/stats` portant les champs
/// `parentStats` (`Map`), `nannyStats` (`Map`), `upcomingMissions`
/// (`List<Map>`) et `recentReviews` (`List<Map>`) — à terme dénormalisé
/// par Cloud Functions.
class FirestoreProfileRepository implements ProfileRepository {
  FirestoreProfileRepository({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  Future<Map<String, dynamic>> _statsDoc() async {
    final snapshot = await _db
        .collection('users')
        .doc(currentUid())
        .collection('dashboard')
        .doc('stats')
        .get();
    return normalizeDoc(snapshot.data() ?? const {});
  }

  Future<Map<String, dynamic>> _mapField(String field) async {
    final data = await _statsDoc();
    final value = (data[field] as Map?)?.cast<String, dynamic>();
    return Map.unmodifiable(value ?? const <String, dynamic>{});
  }

  Future<List<Map<String, dynamic>>> _listField(String field) async {
    final data = await _statsDoc();
    final value = (data[field] as List?)
        ?.map((e) => (e as Map).cast<String, dynamic>())
        .toList();
    return List.unmodifiable(value ?? const <Map<String, dynamic>>[]);
  }

  @override
  Future<Map<String, dynamic>> getParentStats() => _mapField('parentStats');

  @override
  Future<Map<String, dynamic>> getNannyStats() => _mapField('nannyStats');

  @override
  Future<List<Map<String, dynamic>>> getUpcomingMissions() =>
      _listField('upcomingMissions');

  @override
  Future<List<Map<String, dynamic>>> getRecentReviews() =>
      _listField('recentReviews');
}
