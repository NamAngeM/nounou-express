import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/constants/backend_config.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/auth_repository.dart';
import 'features/auth/providers/auth_provider.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Gestion d'erreurs globale — Crashlytics prendra le relais en Phase 4.
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('FlutterError: ${details.exceptionAsString()}');
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Erreur non interceptée: $error\n$stack');
    return true;
  };

  await initializeDateFormatting('fr_FR');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Session chargée avant le premier frame pour que le redirect du routeur
  // soit synchrone (pas d'écran de transition « auth inconnue »).
  final AuthRepository authRepository = BackendConfig.useFirebase
      ? FirebaseAuthRepository()
      : MockAuthRepository();
  final session = await authRepository.loadSession();

  runApp(
    ProviderScope(
      overrides: [initialSessionProvider.overrideWithValue(session)],
      child: const NounouExpressApp(),
    ),
  );
}

class NounouExpressApp extends ConsumerWidget {
  const NounouExpressApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Nounou Express',
      debugShowCheckedModeBanner: false,
      // Thème clair uniquement : le design system (AppColors) n'est pas encore
      // branché sur Theme.of(context), un darkTheme serait inopérant (audit M2).
      theme: AppTheme.light,
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
