# Changelog

## [Non publié] — 2026-07-03 (Phase 2 : fondations d'architecture)

### Architecture
- Couche repository réelle : interfaces `AuthRepository`, `NannyRepository`, `BookingRepository`, `ChatRepository`, `MissionRepository`, `NotificationRepository`, `ProfileRepository` + implémentations mock (latence simulée, mutations en mémoire) — `lib/data/repositories/`.
- Providers Riverpod centralisés (`lib/data/providers/data_providers.dart`) : un point de bascule unique vers Firestore en Phase 3.
- Adoption réelle de Riverpod : les 19 écrans/widgets consommant `MockData` directement passent désormais par des `FutureProvider`/`AsyncValue` (états loading/error/data systématiques) ; mutations via repositories + `ref.invalidate`.
- Auth : suppression des variables globales mutables du routeur ; `AuthNotifier` (session chargée avant `runApp`, injectée par override) ; GoRouter réactif via `refreshListenable`.
- Sérialisation JSON manuelle (toJson/fromJson robustes aux champs manquants) sur les 11 modèles + `DelayRequest` — prêts pour le mapping Firestore.
- `mockApplications` déplacé de `application_model.dart` vers `mock_data.dart`.

### Décisions
- Dark mode retiré (`darkTheme`/`ThemeMode.system`) : inopérant tant que le design system n'est pas branché sur `Theme.of(context)` (869 refs directes à `AppColors`).
- i18n différée : marché FR/Gabon uniquement — à réévaluer avant toute expansion.

### Qualité
- `pubspec.lock` régénéré (SDK Flutter 3.44.4 / Dart 3.12.2).
- `register_screen.dart` découpé (2 288 → 196 lignes + 10 widgets d'étapes) avec validation `Form` par étape (Validators existants enfin branchés) ; fuite de controllers corrigée à la suppression d'un enfant.
- API `Radio` dépréciée migrée vers `RadioGroup` (`price_summary.dart`).
- `dart fix` : 67 corrections de lint automatiques ; `flutter analyze` : **« No issues found! »** ; `dart format` ; `flutter test` : OK.

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
