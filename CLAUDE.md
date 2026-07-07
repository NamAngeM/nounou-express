# Nounou Express — Guide pour le développement

App Flutter de mise en relation nounous/familles (Libreville, Gabon).
Deux rôles : **parent** (cherche et réserve une nounou) et **nounou**
(candidate aux missions, gère son activité). Le rôle vient de la session
(`authProvider` → `AuthSession.isNanny`) — jamais d'un toggle UI.

## Commandes

```bash
flutter analyze          # doit rester à zéro issue
flutter test             # 100+ tests, tous verts avant tout commit
flutter run              # mode démo (backend mock) par défaut
flutter run --dart-define=USE_FIREBASE=true   # backend Firebase réel
```

## Architecture

- `lib/core/` — thème (tokens), widgets partagés, routeur, utilitaires.
- `lib/data/` — modèles, repositories (interface + implémentations
  Mock et Firestore), providers Riverpod (`data_providers.dart`).
- `lib/features/<feature>/screens|widgets/` — écrans par domaine.
- Bascule mock/Firebase : `BackendConfig.useFirebase` — les écrans ne
  connaissent que les interfaces de repository, jamais l'implémentation.

## Conventions UI (obligatoires)

Le test `test/core/design_system_guard_test.dart` fait échouer la CI si
ces règles sont violées. Les formulaires d'inscription
(`lib/features/auth/widgets/register/`) sont l'implémentation de
référence.

1. **Couleurs** : uniquement les tokens `AppColors`
   (`lib/core/theme/app_colors.dart`). Jamais de `Colors.red`,
   `Colors.green`, etc. (`Colors.white/black/transparent` tolérés).
   Sémantique : `success`/`warning`/`danger` + leurs `*Surface` pour
   les fonds ; `gold` pour les notes/étoiles.
2. **Radius** : cartes `cardBorderRadius` (20), inputs et boutons
   `buttonBorderRadius`/`inputBorderRadius` (14), pilules/badges
   `chipBorderRadius` (50), bottom sheets `sheetBorderRadius` (28).
   Pas de valeur littérale nouvelle.
3. **Espacements** : échelle `AppSpacing` uniquement ; padding d'écran
   = `AppSpacing.screenPadding`.
4. **Typographie** : styles `AppTypography` directs ; `copyWith`
   réservé à la couleur/graisse.
5. **Ombres** : `AppColors.cardShadow` / `primaryShadow` /
   `elevatedShadow`.
6. **Composants partagés** (`lib/core/widgets/`) — à réutiliser, ne pas
   réinventer : `AppButton`, `AppAvatar` (jamais d'URL pravatar),
   `AppLoader` (jamais de `CircularProgressIndicator` nu),
   `StatusBadge`, `EmptyState`, `ErrorState`, `RatingStars`,
   `NannyCard`, `DemoBanner`.
7. **Navigation** : GoRouter exclusivement (routes dans
   `lib/core/router/app_router.dart`). Jamais de `MaterialPageRoute`.
   Tout écran doit être atteignable par une route + un point d'entrée.
8. **Headers** : écrans de premier niveau (onglets) = `AppPageHeader`
   avec le gradient de son domaine ; écrans poussés = `AppBar` claire
   avec `leading: AppBackButton()` (variante `close: true` pour les
   formulaires). Gradients de domaine : Accueil/Dashboard et
   Notifications = `[primaryDark, primary]` ; Missions nounou =
   `[goldDark, gold]` ; Réservations/Gardes =
   `[secondary, secondaryLight]` ; Messages = `[accentDark, accent]` ;
   Profil = `[secondary, primary]`. Sémantique : primary = action et
   navigation, accent/success = confirmations, gold = travail/notes,
   warning/danger = urgences.
9. **Wording** : vouvoiement partout ; « Mes favoris » (jamais
   « Favorites ») ; « garde » côté nounou, « réservation » côté
   parent ; prix via `AppFormatters.formatFCFA` /
   `AppFormatters.pricePerHour` (jamais de « F » ou format local).

## Règles produit

- **Zéro bouton mort** : un élément cliquable fait quelque chose de
  réel ou n'existe pas. Pas de `onPressed: () {}`, pas de snackbar
  « bientôt disponible » sur une affordance qui semble fonctionnelle.
- **Prix** : tout calcul passe par `PricingService`
  (`lib/core/utils/pricing.dart`) ; les taux vivent dans
  `AppConstants`. Ne jamais recalculer localement.
- **Données honnêtes** : pas de données générées présentées comme
  réelles (avis, distances, plannings). En mode mock, la `DemoBanner`
  l'assume. Pas de géolocalisation simulée : afficher le quartier.
- **Identité** : `currentUserIdProvider` / `currentUserProfileProvider`
  pour l'utilisateur connecté — jamais d'id (`p1`) ni de prénom en dur.
- **Mutations** : via repository (mock = mémoire de session), jamais un
  simple état local d'écran qui se perd au refresh.

## Reste à faire (connu)

- Mode sombre : les tokens dark existent dans `AppColors` mais les
  écrans lisent les constantes claires directement (pas
  `Theme.of(context)`). Brancher un `darkTheme` superficiellement
  rendrait l'UI incohérente (widgets Material sombres, widgets custom
  clairs). Prérequis : refactor vers un `ColorScheme`/extension de
  thème consommé par les écrans — chantier dédié, ne pas brancher à
  moitié.
- Texte agrandi : la préférence système est respectée jusqu'à 130 %
  (clamp dans main.dart) ; auditer les layouts à hauteur fixe avant de
  relever le plafond.
- Garde récurrente : le flag `isRecurring` est porté par l'annonce et
  affiché aux candidates ; la génération de série de gardes viendra
  avec le backend.

- i18n : les strings sont en dur dans les écrans ; l'extraction doit se
  faire en un seul passage outillé (`flutter gen-l10n` + ARB), pas au
  fil de l'eau.
- Wallet (arbitré) : parent = recharge sur `/wallet`
  (`profile/screens/wallet_screen.dart`), nounou = revenus/retraits sur
  `/earnings` (`wallet/screens/nanny_wallet_screen.dart`). Reste côté
  backend : repository wallet (soldes réels) + paiement des
  réservations par solde parent.
- Unification visuelle des headers (14 AppBar vs 5 AppPageHeader, sans
  logique de domaine) + consolidation des empty states/badges locaux
  sur les composants centraux — voir audit chantier 7.
- Déploiement Firebase (tout est prêt localement — règles écrites,
  functions compilées, firebase.json configuré) ; il ne manque que
  l'authentification :
  1. `npx firebase-tools login`
  2. `npx firebase-tools deploy --only firestore:rules --project nounou-express-2112b`
  3. `npx firebase-tools deploy --only functions --project nounou-express-2112b`
  Prérequis console (voir backend_config.dart) : Phone Auth activée,
  empreintes SHA Android, App Check. Ensuite :
  `flutter run --dart-define=USE_FIREBASE=true`.
- Onglet « Mes Gardes » nounou : le titre est adapté au rôle mais la
  liste affiche encore les bookings du parent (indistinguable en mode
  démo mono-utilisateur) ; filtrer par `nannyId` à la phase Firebase.
