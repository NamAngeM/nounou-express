# Audit approfondi — Nounou Express

**Date** : 2 juillet 2026
**Périmètre** : application Flutter de mise en relation nounous / familles (Gabon) — ~95 fichiers Dart, ~21 900 lignes.
**Axes audités** : architecture, clean code, sécurité, couche données / Firebase, qualité, tests, DevOps, conformité.

---

## 1. Verdict global

**Le projet est une maquette haute-fidélité, pas une application fonctionnelle.** Le décalage entre ce qu'annonçait le `pubspec.yaml` (stack Firebase complète) et la réalité du code était total :

- Les **5 repositories étaient des coquilles vides** (`class AuthRepository { // Implementation here }`).
- **Firebase n'est jamais utilisé** au-delà du `Firebase.initializeApp` de `main.dart` : aucun appel à FirebaseAuth, Firestore, Storage, Messaging ou Analytics dans tout le code.
- Toutes les données viennent de `lib/data/mock/mock_data.dart`, consommé directement par 16 écrans.
- **Riverpod était installé mais inutilisé** : 0 `ref.watch`/`ref.read`, providers stubs jamais consommés ; tout l'état passe par `setState` (117 occurrences) et des variables globales.
- **~25 dépendances déclarées n'étaient jamais importées** (purgées depuis, voir §6).

**Points forts réels** : structure feature-first propre, design system centralisé (`AppColors`/`AppSpacing`/`AppTypography`) réellement utilisé, hygiène de code correcte (0 `print()`, 0 TODO oublié), modèles immuables bien pensés (`MissionModel`), CI GitHub Actions existante, UI soignée (animations, empty states).

## 2. État réel des fonctionnalités

| Fonctionnalité | État | Preuve |
|---|---|---|
| Auth téléphone + OTP | ❌ Factice | `otp_screen.dart` : « Mock: any 4-digit code passes » |
| Recherche / booking / chat / missions / notifications | ❌ Mockés | Données en dur, rien n'est persisté |
| Carte / géolocalisation | ❌ Fausse carte | `map_screen.dart` = décor, pas de `GoogleMap` |
| Wallet | ❌ Mocké | Solde « 45 250 FCFA » codé en dur |
| Bouton SOS | ⚠️ Partiel | Corrigé : les boutons d'appel composent désormais le 17/15 (`url_launcher`). L'« alerte envoyée » reste factice. |
| Vérification CNI | ❌ Fausse | Les boutons « Photo CNI » basculent un booléen, aucun upload |

## 3. Sécurité — constats critiques

1. **Auth contournable** : n'importe quel code OTP connecte ; session = booléen `isAuthenticated` en SharedPreferences (clair) ; rôle parent/nounou en query param modifiable (`app_router.dart`).
2. **Règles Firestore/Storage absentes du repo** alors que le projet Firebase `nounou-express-2112b` est réel et déployé publiquement (Hosting via CI). → Des règles **deny-all** sont désormais versionnées (`firestore.rules`, `storage.rules`) ; **à vérifier/déployer côté console** (voir §7).
3. **Clés API Firebase commitées** (`firebase_options.dart`, `google-services.json`) sans restriction connue ni App Check. Acceptable uniquement avec des règles serveur strictes.
4. **Build release signé avec la clé de debug** (`android/app/build.gradle.kts:41`), pas de R8/obfuscation.
5. **Fausse promesse de vérification d'identité** : badges « Vérifiée » sans aucune vérification réelle — risque juridique pour une app de garde d'enfants. (Conservés pour la démo ; à retirer ou implémenter avant toute mise en service réelle.)
6. **Fuites mineures** : téléphone en query string (`/auth/otp?phone=...`) sur une app déployée web ; avatars chargés depuis `pravatar.cc` (tiers non maîtrisé) ; `debugPrint` des routes non gardé par `kDebugMode`.
7. **Manifests incohérents** : AndroidManifest release sans **aucune** permission (même INTERNET) ; Info.plist iOS sans usage descriptions.

## 4. Conformité RGPD / loi gabonaise n°001/2011 (APDP)

L'app est conçue pour traiter : CNI recto/verso, photos, téléphone, **données d'enfants**, géolocalisation, mobile money. Avant toute collecte réelle :

- **AIPD/DPIA obligatoire** (croisement enfants + identité + localisation = risque élevé).
- CNI : bucket Storage dédié à accès restreint (jamais côté client), conservation courte, envisager un prestataire KYC.
- Données enfants : minimisation stricte, consentement parental, pas d'exposition publique.
- Politique de confidentialité, écrans de consentement, suppression de compte : **inexistants**.
- Firebase = transfert hors Gabon/UE : choisir la région (europe-west), encadrer contractuellement.
- Point positif : aucune donnée réelle n'est collectée aujourd'hui — intégrer « privacy by design » **avant** le branchement du backend.

## 5. Qualité du code — constats majeurs

- **`register_screen.dart` : 2 288 lignes**, ~60 champs, **aucun `Form`, aucune validation** (les `Validators` existants n'y sont jamais appelés). 10 fichiers > 600 lignes.
- **Dark mode cassé** : `ThemeMode.system` actif mais 869 références directes aux couleurs claires `AppColors.*` contre 3 `Theme.of(context)`.
- **Duplication** : `_formatDate` réimplémenté dans 5 fichiers, `"FCFA"` en dur 31 fois, quartiers dupliqués — alors que `AppFormatters`/`AppConstants` existent.
- **Aucune i18n** (chaînes FR en dur), **aucune sérialisation** des modèles (0 `fromJson`/`toJson`), **1 seul try/catch** dans toute l'app, **0 `Semantics`** (accessibilité).
- **Tests : 1 smoke test** (couverture < 2 %).
- CI : version Flutter non épinglée (`channel: stable`), `flutter analyze --no-fatal-infos`, APK debug seulement, `firebase deploy --token` déprécié (préférer un service account + `FirebaseExtended/action-hosting-deploy`).

## 6. Actions déjà réalisées (commit d'audit, 2026-07-02)

**Phase 0 — urgences :**
- ✅ `firestore.rules` + `storage.rules` **deny-all** créées et référencées dans `firebase.json` (le deploy CI utilise `--only hosting`, pas d'impact).
- ✅ Bug arithmétique `MissionModel.estimatedCost` corrigé (retournait coût × taux horaire, ex. 25 000 000 au lieu de 10 000).
- ✅ Route `/chat/:conversationId` renommée `/chat/:nannyId` (tous les appelants passent l'id de la nounou, pas un id de conversation).
- ✅ Redirect du router corrigé : la whitelist référençait `/splash` (inexistant) au lieu de `/` — le splash s'affiche désormais, et redirige vers `/home` si déjà authentifié (avant : toujours `/onboarding`).
- ✅ Écran SOS : les boutons « Appeler les secours (17) » et la carte « SAMU — 15 » composent réellement le numéro (`url_launcher`). ⚠️ Numéros 17/15 à confirmer pour le Gabon (Police 1730, SAMU 1300 ?).
- ✅ Taux horaire par défaut de la route delay lu depuis `AppConstants.defaultHourlyRate` (magic number supprimé).

**Phase 1 — assainissement :**
- ✅ Code mort supprimé : 6 providers stubs, 4 widgets core inutilisés (`app_card`, `app_input`, `loading_shimmer`, `auth_layout`), `helpers.dart` (vide), 5 repositories vides.
- ✅ `mockMissions` déplacé de `mission_model.dart` vers `lib/data/mock/mock_data.dart`.
- ✅ **~24 dépendances jamais importées purgées** du `pubspec.yaml` (firebase_auth, cloud_firestore, firebase_storage/messaging/analytics, dio, geolocator, geocoding, google_maps_flutter, image_picker, image_cropper, flutter_secure_storage, connectivity_plus, flutter_local_notifications, share_plus, package_info_plus, permission_handler, uuid, equatable, google_sign_in, lottie, pinput, flutter_rating_bar, flutter_svg, riverpod_annotation + build_runner/riverpod_generator/json_serializable/json_annotation en dev). Elles seront réintroduites au fil des implémentations réelles.
- ✅ `analysis_options.yaml` durci (10 règles additionnelles, sévérité info — sans casser la CI).
- ✅ README réel, CHANGELOG créé, dépôt git initialisé (commit de référence avant modifications).
- ⚠️ **`pubspec.lock` non régénéré** (SDK Flutter absent de la machine d'audit) : lancer `flutter pub get` au prochain poste de dev. La CI le fait automatiquement.

**Différé volontairement** (nécessite un environnement Flutter pour compiler/valider) :
- Découpage de `register_screen.dart` + branchement `Form`/`Validators`.
- Centralisation routes typées / formatters partout.
- Retrait des badges « Vérifiée » (conservés pour la démo — décision propriétaire requise).

## 7. Actions à faire par le propriétaire (console — non automatisables depuis le repo)

1. **Console Firebase (`nounou-express-2112b`)** : vérifier les règles Firestore/Storage actuelles ; si « mode test » → déployer les règles du repo : `firebase deploy --only firestore:rules,storage`.
2. **Google Cloud Console** : restreindre les 3 clés API (package Android `com.nounouexpress.nounou_express`, bundle iOS, domaine web) ; activer **App Check**.
3. Décider du sort du site Hosting public (démo assumée avec bandeau, ou dépublication).
4. Créer un keystore de release Android (`key.properties` hors git) le moment venu.

## 8. Plan d'amélioration (suite)

### Phase 2 — Fondations d'architecture ✅ RÉALISÉE (2026-07-03)
- ✅ Interfaces repository (7) + implémentations mock derrière l'interface ; plus aucun écran n'importe `MockData` directement (providers dans `lib/data/providers/data_providers.dart`).
- ✅ Adoption réelle de Riverpod : `AsyncValue` (loading/error/data) sur tous les écrans data, `refreshListenable` sur GoRouter, variables globales d'auth remplacées par `AuthNotifier` (`lib/features/auth/providers/auth_provider.dart`).
- ✅ Sérialisation manuelle toJson/fromJson robuste sur les 11 modèles (le mapping `Timestamp` Firestore restera à ajouter en Phase 3).
- ✅ Dark mode retiré (décision : design system non branché sur Theme) ; i18n différée (marché FR/Gabon).
- ✅ `register_screen.dart` découpé : 2 288 → 196 lignes + 10 widgets d'étapes (`lib/features/auth/widgets/register/`), avec validation `Form` par étape branchée sur les `Validators` existants (téléphone gabonais, email, CNI, champs requis, cases obligatoires).
- ✅ API `Radio` dépréciée migrée vers `RadioGroup` (price_summary).
- ✅ Validé : `flutter analyze` → **« No issues found! »** (0 erreur/warning/info), `dart format` propre, `flutter test` OK (SDK 3.44.4 local).

**Phase 2 : 100 % terminée (2026-07-03).**

### Phase 3 — Backend réel (4-8 semaines, ~60 % du travail restant)
- Auth Firebase réelle (`verifyPhoneNumber`), rôle en **custom claims**, session via `authStateChanges`, téléphone via `state.extra` (jamais en query string).
- Firestore par ordre de valeur : profils/recherche → booking → chat temps réel → notifications FCM → missions → wallet (paiements mobile money côté serveur uniquement — le param `rate` de l'URL ne doit jamais faire foi).
- Vraie carte (google_maps_flutter + geolocator + permissions manifest/Info.plist), vrai flux CNI (Storage restreint ou KYC).
- Failures typées, Crashlytics, `FlutterError.onError`, logger structuré.

### Phase 4 — Production-ready (en parallèle)
- Tests : unitaires (modèles, providers, redirects), widget tests par écran, 1-2 flux d'intégration ; viser > 60 % sur la logique.
- Release : keystore prod, R8/minify, permissions Android + usage descriptions iOS, build AAB signé en CI, service account Firebase (remplacer `--token`), épingler la version Flutter en CI.
- Conformité (§4), accessibilité (`Semantics`), incrément de version + CHANGELOG à chaque livraison.
