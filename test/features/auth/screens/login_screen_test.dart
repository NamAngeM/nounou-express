import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nounou_express/data/repositories/auth_repository.dart';
import 'package:nounou_express/features/auth/providers/auth_provider.dart';
import 'package:nounou_express/features/auth/screens/login_screen.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  group('LoginScreen Widget Tests', () {
    late MockAuthRepository mockRepository;

    setUp(() {
      mockRepository = MockAuthRepository();
    });

    late GoRouter router;

    // LoginScreen lit GoRouterState (query param role) et navigue vers
    // /auth/otp : il doit être monté sous un vrai GoRouter.
    Widget createWidgetUnderTest() {
      router = GoRouter(
        routes: [
          GoRoute(path: '/', builder: (c, s) => const LoginScreen()),
          GoRoute(
            path: '/auth/otp',
            builder: (c, s) =>
                const Scaffold(body: Text('OTP_SCREEN_PLACEHOLDER')),
          ),
          GoRoute(
            path: '/auth/role',
            builder: (c, s) =>
                const Scaffold(body: Text('ROLE_SCREEN_PLACEHOLDER')),
          ),
          GoRoute(
            path: '/auth/register',
            builder: (c, s) =>
                const Scaffold(body: Text('REGISTER_SCREEN_PLACEHOLDER')),
          ),
        ],
      );
      return ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockRepository),
          initialSessionProvider.overrideWithValue(AuthSession.unauthenticated),
        ],
        child: MaterialApp.router(routerConfig: router),
      );
    }

    testWidgets('renders login form elements', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Connexion'), findsOneWidget);
      expect(find.text('Recevoir le code'), findsOneWidget);
    });

    testWidgets('shows error when phone is empty', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.text('Recevoir le code'));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Veuillez entrer un numéro valide'), findsOneWidget);
    });

    testWidgets('navigates to OTP screen on valid phone', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(const Duration(seconds: 1));

      await tester.enterText(find.byType(TextField).first, '066851818');
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('Recevoir le code'));
      // Laisse la transition de route se jouer (plusieurs frames).
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // L'envoi réel du SMS est déclenché par l'écran OTP, pas par le login :
      // on vérifie la navigation.
      expect(
        router.routerDelegate.currentConfiguration.uri.path,
        equals('/auth/otp'),
      );
      expect(find.text('OTP_SCREEN_PLACEHOLDER'), findsOneWidget);
    });
  });
}
