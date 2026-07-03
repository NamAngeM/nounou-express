import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Uid de l'utilisateur connecté.
///
/// Lève [StateError] si aucun utilisateur n'est connecté : les repositories
/// Firestore ne doivent être interrogés qu'après authentification.
String currentUid() =>
    FirebaseAuth.instance.currentUser?.uid ??
    (throw StateError('Utilisateur non connecté'));

/// Normalise un document Firestore avant passage aux `fromJson` des modèles :
/// toute valeur [Timestamp] est convertie en chaîne ISO-8601, récursivement
/// (maps imbriquées et listes comprises).
///
/// Choix v1 documenté : les dates sont AUSSI écrites en chaînes ISO-8601
/// (les `toJson()` des modèles sérialisent via `toIso8601String()`), ce qui
/// les rend lexicographiquement ordonnables par `orderBy`. Migration vers
/// [Timestamp] prévue quand des range queries seront nécessaires.
Map<String, dynamic> normalizeDoc(Map<String, dynamic> data) =>
    _normalizeMap(data);

Map<String, dynamic> _normalizeMap(Map<dynamic, dynamic> map) =>
    map.map((key, value) => MapEntry(key.toString(), _normalizeValue(value)));

dynamic _normalizeValue(dynamic value) {
  if (value is Timestamp) return value.toDate().toIso8601String();
  if (value is Map) return _normalizeMap(value);
  if (value is List) return value.map(_normalizeValue).toList();
  return value;
}

/// Id déterministe du fil de discussion entre deux utilisateurs :
/// les deux ids triés puis joints par '_'. Les deux participants calculent
/// ainsi le même id quel que soit le sens de la conversation.
String chatThreadId(String a, String b) => ([a, b]..sort()).join('_');
