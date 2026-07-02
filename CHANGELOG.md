# Changelog

## [Non publié] — 2026-07-02 (audit)

### Sécurité
- Ajout de `firestore.rules` et `storage.rules` (deny-all par défaut), référencées dans `firebase.json`.

### Corrections
- `MissionModel.estimatedCost` : formule corrigée (retournait coût × taux horaire).
- Router : route `/chat/:conversationId` renommée `/chat/:nannyId` (cohérence avec les appelants) ; whitelist du redirect corrigée (`/` au lieu de `/splash` inexistant) ; splash redirige vers `/home` si authentifié.
- Écran SOS : boutons d'appel branchés sur de vrais appels téléphoniques (`url_launcher`).
- Taux horaire par défaut de `/missions/:id/delay` lu depuis `AppConstants.defaultHourlyRate`.

### Nettoyage
- Suppression du code mort : 6 providers stubs, 4 widgets core inutilisés, `helpers.dart`, 5 repositories vides.
- `mockMissions` déplacé vers `lib/data/mock/mock_data.dart`.
- Purge d'environ 24 dépendances déclarées mais jamais importées (`pubspec.yaml`).
- `analysis_options.yaml` : 10 règles de lint additionnelles.

### Documentation
- `AUDIT.md` : rapport d'audit complet + plan d'amélioration en 4 phases.
- `README.md` réécrit (remplace le template Flutter par défaut).
- Dépôt git initialisé avec commit de référence pré-audit.

## [1.0.0+1]
- Prototype UI initial (maquette navigable complète, données mockées).
