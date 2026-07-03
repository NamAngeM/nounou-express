import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:nounou_express/data/repositories/auth_repository.dart';
import 'package:nounou_express/features/auth/providers/auth_provider.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  group('AuthNotifier', () {
    late ProviderContainer container;
    late MockAuthRepository mockRepository;

    setUp(() {
      mockRepository = MockAuthRepository();

      container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockRepository),
          initialSessionProvider.overrideWithValue(AuthSession.unauthenticated),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is unauthenticated', () {
      final state = container.read(authProvider);
      expect(state.isAuthenticated, isFalse);
    });

    test('signIn updates state to authenticated session', () async {
      const fakeSession = AuthSession(isAuthenticated: true, role: 'parent');

      when(
        () => mockRepository.signIn(
          role: 'parent',
          profile: any(named: 'profile'),
        ),
      ).thenAnswer((_) async => fakeSession);

      await container.read(authProvider.notifier).signIn(role: 'parent');

      final state = container.read(authProvider);
      expect(state.isAuthenticated, isTrue);
      expect(state.role, equals('parent'));
    });

    test('signOut updates state to unauthenticated', () async {
      when(() => mockRepository.signOut()).thenAnswer((_) async {});

      await container.read(authProvider.notifier).signOut();

      final state = container.read(authProvider);
      expect(state.isAuthenticated, isFalse);
      verify(() => mockRepository.signOut()).called(1);
    });
  });
}
