import 'package:flutter_test/flutter_test.dart';
import 'package:nounou_express/data/repositories/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AuthSession', () {
    test('unauthenticated has correct defaults', () {
      expect(AuthSession.unauthenticated.isAuthenticated, false);
      expect(AuthSession.unauthenticated.role, 'parent');
    });

    test('isNanny returns true for nanny role', () {
      const session = AuthSession(isAuthenticated: true, role: 'nanny');
      expect(session.isNanny, true);
    });

    test('isNanny returns false for parent role', () {
      const session = AuthSession(isAuthenticated: true, role: 'parent');
      expect(session.isNanny, false);
    });
  });

  group('OtpException', () {
    test('toString returns message', () {
      const exception = OtpException('Code invalide');
      expect(exception.toString(), 'Code invalide');
      expect(exception.message, 'Code invalide');
    });
  });

  group('MockAuthRepository', () {
    late MockAuthRepository repo;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      repo = MockAuthRepository();
    });

    test('loadSession returns unauthenticated by default', () async {
      final session = await repo.loadSession();
      expect(session.isAuthenticated, false);
      expect(session.role, 'parent');
    });

    test('startPhoneVerification calls onCodeSent', () async {
      bool codeSent = false;
      await repo.startPhoneVerification(
        '066851818',
        onCodeSent: () => codeSent = true,
        onError: (_) {},
      );
      expect(codeSent, true);
    });

    test('confirmOtp returns unauthenticated session (demo mode)', () async {
      final result = await repo.confirmOtp('1234', role: 'parent');
      // In mock mode, confirmOtp returns unauthenticated (user needs to signIn)
      expect(result.session.isAuthenticated, false);
      expect(result.hasProfile, false);
    });

    test('confirmOtp returns correct role', () async {
      final result = await repo.confirmOtp('9999', role: 'nanny');
      expect(result.session.role, 'nanny');
    });

    test('signIn persists authenticated state', () async {
      final session = await repo.signIn(role: 'parent');
      expect(session.isAuthenticated, true);
      expect(session.role, 'parent');

      // Verify persistence
      final reloaded = await repo.loadSession();
      expect(reloaded.isAuthenticated, true);
      expect(reloaded.role, 'parent');
    });

    test('signIn with nanny role', () async {
      final session = await repo.signIn(role: 'nanny');
      expect(session.isAuthenticated, true);
      expect(session.role, 'nanny');

      final reloaded = await repo.loadSession();
      expect(reloaded.isNanny, true);
    });

    test('signOut clears authenticated state', () async {
      await repo.signIn(role: 'parent');
      await repo.signOut();

      final session = await repo.loadSession();
      expect(session.isAuthenticated, false);
    });

    test(
      'full auth flow: signIn → loadSession → signOut → loadSession',
      () async {
        // 1. Not authenticated
        var session = await repo.loadSession();
        expect(session.isAuthenticated, false);

        // 2. Sign in
        session = await repo.signIn(role: 'nanny');
        expect(session.isAuthenticated, true);
        expect(session.isNanny, true);

        // 3. Reload — still authenticated
        session = await repo.loadSession();
        expect(session.isAuthenticated, true);

        // 4. Sign out
        await repo.signOut();
        session = await repo.loadSession();
        expect(session.isAuthenticated, false);
      },
    );
  });
}
