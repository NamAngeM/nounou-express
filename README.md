# Nounou Express

Application mobile (Flutter) de mise en relation entre **nounous** et **familles** au Gabon : recherche de nounous, réservations, missions/annonces, chat, notifications, wallet mobile money, bouton SOS.

> ℹ️ **État du projet : double backend derrière un feature flag.**
> Par défaut l'app tourne en **mode démo** (données mockées, OTP factice). Le backend **Firebase réel** (Auth téléphone + Firestore) est implémenté et s'active avec `--dart-define=USE_FIREBASE=true`, après configuration de la console (voir AUDIT.md §7). Historique complet : [AUDIT.md](AUDIT.md).

## Lancer

```bash
# Mode démo (mocks, par défaut)
flutter run

# Backend Firebase réel (prérequis console : Phone Auth, SHA, règles déployées)
flutter run --dart-define=USE_FIREBASE=true
```

## Stack

- **Flutter** (Dart ^3.10) — cible principale : mobile ; build web déployé en démo sur Firebase Hosting
- **go_router** — navigation (shell à 5 onglets + routes plein écran)
- **flutter_riverpod** — state management (adoption réelle prévue en Phase 2 de l'audit)
- **Firebase** — projet `nounou-express-2112b` (seul `firebase_core` est branché à ce jour)
- **google_fonts, flutter_animate, shimmer, cached_network_image** — UI

## Démarrage

```bash
flutter pub get
flutter run            # mobile (émulateur/appareil)
flutter run -d chrome  # web
```

> Le `pubspec.lock` peut nécessiter une régénération (`flutter pub get`) : les dépendances inutilisées ont été purgées lors de l'audit de juillet 2026.

## Structure

```
lib/
├── core/          # thème (design system), router, widgets partagés, utils, constantes
├── data/
│   ├── models/    # modèles métier (Nanny, Mission, Booking, ...)
│   └── mock/      # données mockées (source actuelle de TOUTES les données)
└── features/      # un dossier par fonctionnalité : screens/ + widgets/
    ├── auth/  booking/  chat/  home/  missions/  nanny_profile/
    ├── notifications/  onboarding/  profile/  review/  search/
    └── sos/  splash/  wallet/
```

## Qualité & CI

- **CI** (GitHub Actions) : format, analyze, tests + coverage, build web, APK debug — [.github/workflows/ci.yml](.github/workflows/ci.yml)
- **Deploy** : Firebase Hosting sur push `main`/`master` — [.github/workflows/deploy.yml](.github/workflows/deploy.yml)
- **Lint** : `flutter_lints` + règles additionnelles ([analysis_options.yaml](analysis_options.yaml))
- **Tests** : `flutter test` (couverture quasi nulle à ce jour — voir plan d'audit)

## Sécurité

Les règles Firestore/Storage versionnées ([firestore.rules](firestore.rules), [storage.rules](storage.rules)) sont **deny-all** tant que le backend n'est pas implémenté. Les actions console requises (restriction des clés API, App Check, déploiement des règles) sont listées dans [AUDIT.md §7](AUDIT.md).
