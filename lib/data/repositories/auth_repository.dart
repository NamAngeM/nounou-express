import 'package:shared_preferences/shared_preferences.dart';

/// Session utilisateur.
///
/// Implémentation actuelle : mock persisté en SharedPreferences.
/// À terme (Phase 3 de l'audit) : session Firebase Auth (`authStateChanges`),
/// rôle porté par des custom claims côté serveur.
class AuthSession {
  final bool isAuthenticated;
  final String role; // 'parent' | 'nanny'

  const AuthSession({required this.isAuthenticated, required this.role});

  static const AuthSession unauthenticated = AuthSession(
    isAuthenticated: false,
    role: 'parent',
  );

  bool get isNanny => role == 'nanny';
}

/// Contrat d'accès à l'authentification.
abstract class AuthRepository {
  Future<AuthSession> loadSession();

  Future<AuthSession> signIn({required String role});

  Future<void> signOut();
}

/// Implémentation mock : un booléen + un rôle en SharedPreferences.
class MockAuthRepository implements AuthRepository {
  static const String _kAuthenticated = 'isAuthenticated';
  static const String _kRole = 'userRole';

  @override
  Future<AuthSession> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    return AuthSession(
      isAuthenticated: prefs.getBool(_kAuthenticated) ?? false,
      role: prefs.getString(_kRole) ?? 'parent',
    );
  }

  @override
  Future<AuthSession> signIn({required String role}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kAuthenticated, true);
    await prefs.setString(_kRole, role);
    return AuthSession(isAuthenticated: true, role: role);
  }

  @override
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kAuthenticated, false);
  }
}
