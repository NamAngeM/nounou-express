/// Bascule entre le backend mock (démo) et Firebase (réel).
///
/// Par défaut l'app tourne sur les mocks. Pour activer Firebase :
///   flutter run --dart-define=USE_FIREBASE=true
///   flutter build web --dart-define=USE_FIREBASE=true
///
/// Prérequis côté console Firebase avant d'activer (voir AUDIT.md §7) :
///  - Phone Auth activée + numéros de test configurés ;
///  - empreintes SHA-1/SHA-256 Android enregistrées ;
///  - règles Firestore déployées (firebase deploy --only firestore:rules) ;
///  - clés API restreintes + App Check.
abstract final class BackendConfig {
  static const bool useFirebase = bool.fromEnvironment('USE_FIREBASE');
}
