# Changelog

## [Non publié] — 2026-07-03 (Phase 3 : backend réel derrière feature flag)

### Architecture
- **Feature flag `USE_FIREBASE`** (`lib/core/constants/backend_config.dart`) : `flutter run --dart-define=USE_FIREBASE=true` bascule l'app des mocks vers Firebase — par défaut l'app reste en mode démo.
- **Auth téléphone réelle** : `FirebaseAuthRepository` (envoi SMS via `verifyPhoneNumber`, confirmation du code côté serveur, renvoi avec `forceResendingToken`, messages d'erreur en français). Rôle persisté dans `users/{uid}` (custom claims prévus en Phase 4). Écran OTP branché : le code est réellement vérifié, un profil existant connecte directement (`/home`), le bandeau « mode démo » n'apparaît que sur le backend mock.
- **Implémentations Firestore des 6 repositories** (`lib/data/repositories/firestore/`) : nannies, bookings (index composite parentId+date dans `firestore.indexes.json`), chat (messages `chats/{threadId}/messages` + index de conversations miroir chez les deux participants, envoi en WriteBatch atomique), missions/candidatures, notifications, dashboard. Dates stockées en ISO-8601 (v1), `normalizeDoc` tolère les `Timestamp`.
- **Règles Firestore réelles** (`firestore.rules`) : accès par propriétaire/participant, missions lisibles par les connectés, notifications/dashboard en écriture backend uniquement, catch-all deny. Storage reste deny-all (aucun upload implémenté).
- **Gestion d'erreurs globale** dans `main.dart` (`FlutterError.onError` + `PlatformDispatcher.onError`) — Crashlytics prévu en Phase 4.

### Fin de phase (même jour)
- **Chat temps réel** : streams mock + Firestore (`snapshots()`), `conversationsProvider`/`messagesProvider` en StreamProvider, scroll auto à la réception ; plus d'invalidation manuelle après envoi.
- **FCM** : `PushNotificationsService` (permission, handler background, onTokenRefresh), token dans `users/{uid}.fcmToken` synchronisé à la connexion ; manifest Android corrigé (INTERNET + POST_NOTIFICATIONS).
- **Upload CNI réel** : `DocumentUploadService` → Storage `kyc/{uid}/` (write propriétaire < 5 Mo images, read interdit — RGPD/APDP), spinner sur les tuiles KYC, usage descriptions iOS.
- **Profil écrit à l'inscription** : `users/{uid}` (minimisation RGPD) + profil public `nannies/{uid}` pour les nounous.
- Reporté (prérequis externes) : carte Google Maps (clé API), wallet mobile money (contrats Airtel/Moov, côté serveur).

### Qualité
- `flutter analyze` : « No issues found! » ; `dart format` ; `flutter test` OK.

### Prérequis console avant d'activer le flag (voir AUDIT.md §7)
- Activer Phone Auth (+ numéros de test), enregistrer les SHA-1/SHA-256 Android.
- `firebase deploy --only firestore:rules,firestore:indexes`.
- Restreindre les clés API, activer App Check, provisionner `config/quartiers`.

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
