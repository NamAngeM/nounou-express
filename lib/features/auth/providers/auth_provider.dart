import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/backend_config.dart';
import '../../../core/services/push_notifications_service.dart';
import '../../../data/repositories/auth_repository.dart';

/// Session chargée avant `runApp` (voir `main.dart`) et injectée via
/// `ProviderScope(overrides: ...)` pour que le redirect du routeur dispose
/// d'un état synchrone dès le premier frame.
final initialSessionProvider = Provider<AuthSession>(
  (ref) => AuthSession.unauthenticated,
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => BackendConfig.useFirebase
      ? FirebaseAuthRepository()
      : MockAuthRepository(),
);

class AuthNotifier extends Notifier<AuthSession> {
  @override
  AuthSession build() => ref.watch(initialSessionProvider);

  /// Envoi (ou renvoi) du SMS de vérification.
  Future<void> startPhoneVerification(
    String phone, {
    required void Function() onCodeSent,
    required void Function(String message) onError,
  }) {
    return ref
        .read(authRepositoryProvider)
        .startPhoneVerification(
          phone,
          onCodeSent: onCodeSent,
          onError: onError,
        );
  }

  /// Confirme le code OTP. Lève [OtpException] si le code est refusé.
  Future<OtpResult> confirmOtp(String smsCode, {required String role}) async {
    final result = await ref
        .read(authRepositoryProvider)
        .confirmOtp(smsCode, role: role);
    if (result.session.isAuthenticated) {
      state = result.session;
      // Synchronise le token FCM sans bloquer la navigation (no-op en mock).
      unawaited(PushNotificationsService.syncTokenForUser());
    }
    return result;
  }

  Future<void> signIn({
    required String role,
    Map<String, dynamic>? profile,
  }) async {
    state = await ref
        .read(authRepositoryProvider)
        .signIn(role: role, profile: profile);
    // Synchronise le token FCM sans bloquer la navigation (no-op en mock).
    unawaited(PushNotificationsService.syncTokenForUser());
  }

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    state = AuthSession.unauthenticated;
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthSession>(
  AuthNotifier.new,
);
