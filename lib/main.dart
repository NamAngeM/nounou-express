import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/constants/backend_config.dart';
import 'core/router/app_router.dart';
import 'core/services/push_notifications_service.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/auth_repository.dart';
import 'features/auth/providers/auth_provider.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // ── Crashlytics ───────────────────────────────────────────────────────────
  // En debug, les erreurs restent dans la console ; en release, elles sont
  // envoyées à Crashlytics pour le monitoring en production.
  if (kReleaseMode) {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  } else {
    // Mode debug : garde le comportement console classique.
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      debugPrint('FlutterError: ${details.exceptionAsString()}');
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      debugPrint('Erreur non interceptée: $error\n$stack');
      return true;
    };
    // Désactive Crashlytics en debug pour ne pas polluer le dashboard.
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
  }
  await initializeDateFormatting('fr_FR');
  await PushNotificationsService.initialize();

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
      // Texte agrandi (accessibilité) : la préférence système est respectée
      // jusqu'à 130 % — au-delà, les hauteurs fixes de certains écrans
      // déborderaient. Plafond à relever après audit des layouts.
      builder: (context, child) {
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(
            textScaler: media.textScaler.clamp(
              minScaleFactor: 0.9,
              maxScaleFactor: 1.3,
            ),
          ),
          child: child!,
        );
      },
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
