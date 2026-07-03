import 'package:cloud_firestore/cloud_firestore.dart';

import '../../mock/mock_data.dart';
import '../../models/nanny_model.dart';
import '../nanny_repository.dart';
import 'firestore_helpers.dart';

/// Implémentation Firestore des profils nounous.
///
/// Schéma :
///  - `nannies/{nannyId}` : profil (NannyModel.toJson, dates ISO-8601) ;
///  - `users/{uid}.favoriteNannyIds` : `List<String>` des favoris du parent ;
///  - `config/quartiers.values` : `List<String>` des quartiers proposés.
class FirestoreNannyRepository implements NannyRepository {
  FirestoreNannyRepository({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _nannies =>
      _db.collection('nannies');

  @override
  Future<List<NannyModel>> getNannies() async {
    final snapshot = await _nannies.limit(50).get();
    return List.unmodifiable(
      snapshot.docs.map((d) => NannyModel.fromJson(normalizeDoc(d.data()))),
    );
  }

  @override
  Future<NannyModel> getNannyById(String id) async {
    final snapshot = await _nannies.doc(id).get();
    final data = snapshot.data();
    if (data == null) throw StateError('Nounou introuvable : $id');
    return NannyModel.fromJson(normalizeDoc(data));
  }

  @override
  Future<List<NannyModel>> getFavorites() async {
    final userDoc = await _db.collection('users').doc(currentUid()).get();
    final ids =
        (userDoc.data()?['favoriteNannyIds'] as List?)?.cast<String>() ??
        const <String>[];
    if (ids.isEmpty) return List.unmodifiable(const <NannyModel>[]);

    // `whereIn` est limité à 10 valeurs : on interroge par paquets.
    final nannies = <NannyModel>[];
    for (var i = 0; i < ids.length; i += 10) {
      final batch = ids.sublist(i, (i + 10).clamp(0, ids.length));
      final snapshot = await _nannies
          .where(FieldPath.documentId, whereIn: batch)
          .get();
      nannies.addAll(
        snapshot.docs.map((d) => NannyModel.fromJson(normalizeDoc(d.data()))),
      );
    }
    return List.unmodifiable(nannies);
  }

  @override
  Future<List<String>> getQuartiers() async {
    final snapshot = await _db.collection('config').doc('quartiers').get();
    final values = (snapshot.data()?['values'] as List?)?.cast<String>();
    // Fallback : liste par défaut du mock tant que `config/quartiers`
    // n'est pas provisionné dans la console Firebase.
    return List.unmodifiable(values ?? MockData.quartiers);
  }
}
