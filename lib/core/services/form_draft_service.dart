import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Brouillons de formulaires multi-étapes (publication d'annonce,
/// inscription...) : un JSON par clé dans SharedPreferences, pour que
/// quitter l'app ne fasse pas perdre la saisie.
abstract final class FormDraftService {
  static String _prefsKey(String key) => 'draft_$key';

  static Future<void> save(String key, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey(key), jsonEncode(data));
  }

  static Future<Map<String, dynamic>?> load(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey(key));
    if (raw == null) return null;
    try {
      return (jsonDecode(raw) as Map).cast<String, dynamic>();
    } catch (_) {
      // Brouillon corrompu : on repart de zéro plutôt que de planter.
      await prefs.remove(_prefsKey(key));
      return null;
    }
  }

  static Future<void> clear(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey(key));
  }
}
