import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/auth_repository.dart';
import 'features/auth/providers/auth_provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Session chargée avant le premier frame pour que le redirect du routeur
  // soit synchrone (pas d'écran de transition « auth inconnue »).
  final session = await MockAuthRepository().loadSession();

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
