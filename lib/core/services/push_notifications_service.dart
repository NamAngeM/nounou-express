import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../constants/backend_config.dart';

/// Handler des messages reçus quand l'app est en background ou terminée.
///
/// Doit être une fonction top-level (pas une méthode) annotée
/// `@pragma('vm:entry-point')` pour survivre au tree-shaking AOT : le moteur
/// l'invoque dans un isolate dédié, hors de tout contexte Flutter.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint(
    'FCM (background) ${message.messageId}: '
    '${message.notification?.title} — ${message.notification?.body}',
  );
}

/// Notifications push FCM : permission, tokens et handlers de messages.
///
/// Entièrement no-op quand [BackendConfig.useFirebase] est désactivé (mode
/// mock) : l'app ne touche alors jamais à FirebaseMessaging.
///
/// NOTE iOS : la capability « Push Notifications » et la clé APNs doivent être
/// configurées via Xcode + console Apple/Firebase — impossible depuis ce poste
/// Windows. Sans cela, `getToken()` sur iOS restera null (Phase 4).
abstract final class PushNotificationsService {
  /// Initialise FCM : permission, handler background, écoute foreground et
  /// rafraîchissement de token. À appeler après `Firebase.initializeApp`.
  static Future<void> initialize() async {
    if (!BackendConfig.useFirebase) return;

    try {
      await FirebaseMessaging.instance.requestPermission();
    } catch (e) {
      // Permission refusée ou plateforme mal configurée : l'app doit
      // démarrer quand même, les pushes seront simplement inactifs.
      debugPrint('FCM: requestPermission a échoué: $e');
    }

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen((message) {
      // Message reçu app au premier plan : Android/iOS n'affichent rien
      // automatiquement dans ce cas. L'affichage d'une notification locale
      // viendra en Phase 4 avec flutter_local_notifications.
      debugPrint(
        'FCM (foreground): '
        '${message.notification?.title} — ${message.notification?.body}',
      );
    });

    FirebaseMessaging.instance.onTokenRefresh.listen((_) {
      syncTokenForUser();
    });
  }

  /// Écrit le token FCM courant dans `users/{uid}` (champs `fcmToken` et
  /// `fcmTokenUpdatedAt`). Silencieux si aucun utilisateur n'est connecté.
  ///
  /// À appeler après la connexion (et rappelée automatiquement à chaque
  /// rafraîchissement de token via [initialize]).
  static Future<void> syncTokenForUser() async {
    if (!BackendConfig.useFirebase) return;

    if (kIsWeb) {
      // TODO(phase4): getToken() sur le web exige une clé VAPID, à générer
      // dans la console Firebase (Cloud Messaging > Web Push certificates)
      // puis à passer ici : getToken(vapidKey: ...).
      return;
    }

    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final String? token = await FirebaseMessaging.instance.getToken();
      if (token == null) return;

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'fcmToken': token,
        'fcmTokenUpdatedAt': DateTime.now().toUtc().toIso8601String(),
      }, SetOptions(merge: true));
    } catch (e) {
      // Non bloquant : un token manquant ne doit pas casser le parcours.
      debugPrint('FCM: synchronisation du token impossible: $e');
    }
  }
}
