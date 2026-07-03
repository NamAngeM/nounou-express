import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Session utilisateur.
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

/// Résultat d'une confirmation OTP.
class OtpResult {
  final AuthSession session;

  /// `true` si un profil existe déjà pour ce numéro (connexion) :
  /// l'écran OTP redirige alors vers /home au lieu de l'inscription.
  final bool hasProfile;

  const OtpResult({required this.session, required this.hasProfile});
}

/// Levée quand la confirmation OTP échoue (code invalide, expiré...).
class OtpException implements Exception {
  final String message;
  const OtpException(this.message);

  @override
  String toString() => message;
}

/// Contrat d'accès à l'authentification.
abstract class AuthRepository {
  Future<AuthSession> loadSession();

  /// Démarre la vérification du numéro (envoi du SMS OTP).
  /// [phone] : 9 chiffres gabonais sans indicatif (le +241 est ajouté).
  Future<void> startPhoneVerification(
    String phone, {
    required void Function() onCodeSent,
    required void Function(String message) onError,
  });

  /// Confirme le code OTP reçu par SMS.
  /// Lève [OtpException] si le code est invalide ou expiré.
  Future<OtpResult> confirmOtp(String smsCode, {required String role});

  /// Finalise l'inscription : persiste le rôle et, si fourni, le profil.
  ///
  /// [profile] ne doit contenir que des données non sensibles (minimisation
  /// RGPD/APDP : pas de CNI, pas de contacts d'urgence, pas de données
  /// médicales — le KYC passe par un bucket Storage à accès restreint).
  Future<AuthSession> signIn({
    required String role,
    Map<String, dynamic>? profile,
  });

  Future<void> signOut();

  /// Supprime toutes les données associées à l'utilisateur et son compte.
  Future<void> deleteAccount();
}

/// Implémentation mock : un booléen + un rôle en SharedPreferences.
/// N'importe quel code OTP passe (bandeau « mode démo » affiché par l'UI).
class MockAuthRepository implements AuthRepository {
  static const String _kAuthenticated = 'isAuthenticated';
  static const String _kRole = 'userRole';
  static const Duration _latency = Duration(milliseconds: 300);

  @override
  Future<AuthSession> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    return AuthSession(
      isAuthenticated: prefs.getBool(_kAuthenticated) ?? false,
      role: prefs.getString(_kRole) ?? 'parent',
    );
  }

  @override
  Future<void> startPhoneVerification(
    String phone, {
    required void Function() onCodeSent,
    required void Function(String message) onError,
  }) async {
    await Future<void>.delayed(_latency);
    onCodeSent();
  }

  @override
  Future<OtpResult> confirmOtp(String smsCode, {required String role}) async {
    await Future<void>.delayed(_latency);
    // Mode démo : tout code à 4 chiffres passe ; le profil n'existe jamais,
    // l'utilisateur poursuit vers l'inscription (comportement historique).
    return OtpResult(
      session: AuthSession(isAuthenticated: false, role: role),
      hasProfile: false,
    );
  }

  @override
  Future<AuthSession> signIn({
    required String role,
    Map<String, dynamic>? profile,
  }) async {
    // Mode démo : le profil n'est pas persisté.
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

  @override
  Future<void> deleteAccount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all mock data
  }
}

/// Implémentation Firebase : OTP réel via `verifyPhoneNumber`, rôle persisté
/// dans `users/{uid}` (à migrer vers des custom claims quand un backend
/// d'administration existera — voir AUDIT.md Phase 3).
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  String? _verificationId;
  int? _resendToken;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _db.collection('users').doc(uid);

  @override
  Future<AuthSession> loadSession() async {
    final user = _auth.currentUser;
    if (user == null) return AuthSession.unauthenticated;
    final snapshot = await _userDoc(user.uid).get();
    final role = snapshot.data()?['role'] as String? ?? 'parent';
    return AuthSession(isAuthenticated: true, role: role);
  }

  @override
  Future<void> startPhoneVerification(
    String phone, {
    required void Function() onCodeSent,
    required void Function(String message) onError,
  }) async {
    final number = '+241${phone.replaceAll(' ', '')}';
    await _auth.verifyPhoneNumber(
      phoneNumber: number,
      forceResendingToken: _resendToken,
      verificationCompleted: (credential) async {
        // Android uniquement : vérification automatique du SMS.
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (e) => onError(_frenchAuthMessage(e)),
      codeSent: (verificationId, resendToken) {
        _verificationId = verificationId;
        _resendToken = resendToken;
        onCodeSent();
      },
      codeAutoRetrievalTimeout: (verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  @override
  Future<OtpResult> confirmOtp(String smsCode, {required String role}) async {
    final verificationId = _verificationId;
    User? user = _auth.currentUser;

    if (user == null) {
      if (verificationId == null) {
        throw const OtpException(
          'Aucune vérification en cours. Renvoyez le code.',
        );
      }
      try {
        final credential = PhoneAuthProvider.credential(
          verificationId: verificationId,
          smsCode: smsCode,
        );
        user = (await _auth.signInWithCredential(credential)).user;
      } on FirebaseAuthException catch (e) {
        throw OtpException(_frenchAuthMessage(e));
      }
    }
    if (user == null) {
      throw const OtpException('Connexion impossible. Réessayez.');
    }

    final snapshot = await _userDoc(user.uid).get();
    final hasProfile = snapshot.exists;
    final storedRole = snapshot.data()?['role'] as String? ?? role;
    return OtpResult(
      session: AuthSession(isAuthenticated: true, role: storedRole),
      hasProfile: hasProfile,
    );
  }

  @override
  Future<AuthSession> signIn({
    required String role,
    Map<String, dynamic>? profile,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const OtpException('Vérifiez votre numéro avant de continuer.');
    }
    await _userDoc(user.uid).set({
      'role': role,
      'phone': user.phoneNumber,
      'createdAt': DateTime.now().toIso8601String(),
      ...?profile,
    }, SetOptions(merge: true));

    if (role == 'nanny') {
      // Profil public minimal de la nounou (lisible par les parents
      // connectés). Complété/mis à jour ensuite via l'édition de profil.
      await _db.collection('nannies').doc(user.uid).set({
        'id': user.uid,
        'role': 'nanny',
        'name': profile?['name'] ?? '',
        'phone': user.phoneNumber,
        'quartier': profile?['quartier'] ?? '',
        'bio': profile?['bio'] ?? '',
        'skills': profile?['skills'] ?? const <String>[],
        'hourlyRate': profile?['hourlyRate'] ?? 0,
        'rating': 0.0,
        'totalMissions': 0,
        'isVerified': false,
        'createdAt': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));
    }

    // Force refresh the token to retrieve custom claims right away.
    // However, the Cloud Function might take a second to write the claim,
    // so we fall back to the selected role during the initial session.
    try {
      await user.getIdTokenResult(true);
    } catch (_) {}

    return AuthSession(isAuthenticated: true, role: role);
  }

  @override
  Future<void> signOut() => _auth.signOut();

  @override
  Future<void> deleteAccount() async {
    // Appel de la Cloud Function de suppression (définie dans functions/src/index.ts)
    // qui supprimera Auth, Firestore (users, nannies, etc.) et Storage (KYC).
    try {
      final callable = FirebaseFunctions.instance.httpsCallable(
        'deleteUserData',
      );
      await callable();
      // AuthRepository state will be updated by signOut/session reload.
      await signOut();
    } catch (e) {
      throw Exception('Erreur lors de la suppression du compte: $e');
    }
  }

  static String _frenchAuthMessage(FirebaseAuthException e) {
    return switch (e.code) {
      'invalid-verification-code' => 'Code invalide. Vérifiez et réessayez.',
      'session-expired' => 'Code expiré. Renvoyez un nouveau code.',
      'invalid-phone-number' => 'Numéro de téléphone invalide.',
      'too-many-requests' => 'Trop de tentatives. Réessayez plus tard.',
      'quota-exceeded' => 'Service momentanément indisponible.',
      _ => 'Erreur d\'authentification (${e.code}).',
    };
  }
}
