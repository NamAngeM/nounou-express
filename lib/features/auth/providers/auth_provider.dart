import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/auth_repository.dart';

/// Session chargée avant `runApp` (voir `main.dart`) et injectée via
/// `ProviderScope(overrides: ...)` pour que le redirect du routeur dispose
/// d'un état synchrone dès le premier frame.
final initialSessionProvider = Provider<AuthSession>(
  (ref) => AuthSession.unauthenticated,
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => MockAuthRepository(),
);

class AuthNotifier extends Notifier<AuthSession> {
  @override
  AuthSession build() => ref.watch(initialSessionProvider);

  Future<void> signIn({required String role}) async {
    state = await ref.read(authRepositoryProvider).signIn(role: role);
  }

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    state = AuthSession.unauthenticated;
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthSession>(
  AuthNotifier.new,
);
