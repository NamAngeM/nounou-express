import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/otp_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/role_selection_screen.dart';
import '../../features/booking/screens/booking_confirmation_screen.dart';
import '../../features/booking/screens/booking_detail_screen.dart';
import '../../features/booking/screens/booking_screen.dart';
import '../../features/booking/screens/bookings_list_screen.dart';
import '../../features/chat/screens/chat_screen.dart';
import '../../features/chat/screens/conversations_screen.dart';
import '../../features/chat/screens/video_call_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/home/screens/main_shell.dart';
import '../../features/legal/screens/privacy_policy_screen.dart';
import '../../features/legal/screens/terms_screen.dart';
import '../../features/missions/screens/available_missions_screen.dart';
import '../../features/missions/screens/candidatures_screen.dart';
import '../../features/missions/screens/delay_screen.dart';
import '../../features/missions/screens/mission_tracking_screen.dart';
import '../../features/missions/screens/my_applications_screen.dart';
import '../../features/missions/screens/publish_announcement_screen.dart';
import '../../features/nanny_profile/screens/nanny_profile_screen.dart';
import '../../features/notifications/screens/notifications_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/profile/screens/edit_profile_screen.dart';
import '../../features/profile/screens/favorites_screen.dart';
import '../../features/profile/screens/nanny_dashboard_screen.dart';
import '../../features/profile/screens/nanny_verification_screen.dart';
import '../../features/profile/screens/parent_profile_screen.dart';
import '../../features/profile/screens/wallet_screen.dart';
import '../../features/review/screens/leave_review_screen.dart';
import '../../features/search/screens/map_screen.dart';
import '../../features/search/screens/search_screen.dart';
import '../../features/sos/screens/sos_screen.dart';
import '../../features/splash/screens/splash_screen.dart';
import '../constants/app_constants.dart';
import 'app_router_observer.dart';

/// Routeur de l'application, réactif à l'état d'authentification :
/// tout changement de session (connexion, déconnexion) réévalue le redirect
/// via [GoRouter.refreshListenable].
final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = ValueNotifier<int>(0);
  ref.listen(authProvider, (_, _) => refreshNotifier.value++);
  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    initialLocation: '/',
    observers: [AppRouterObserver()],
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final session = ref.read(authProvider);
      final bool isAuthPath =
          state.uri.path.startsWith('/auth') ||
          state.uri.path.startsWith('/legal') ||
          state.uri.path == '/' || // splash
          state.uri.path == '/onboarding';

      if (!session.isAuthenticated && !isAuthPath) {
        return '/onboarding';
      }
      return null;
    },
    routes: [
      // --- Public Routes ---
      GoRoute(
        path: '/',
        pageBuilder: (c, s) => _fadeTransition(const SplashScreen()),
      ),
      GoRoute(
        path: '/onboarding',
        pageBuilder: (c, s) => _fadeTransition(const OnboardingScreen()),
      ),

      // --- Legal Routes ---
      GoRoute(
        path: '/legal/privacy',
        builder: (c, s) => const PrivacyPolicyScreen(),
      ),
      GoRoute(path: '/legal/terms', builder: (c, s) => const TermsScreen()),

      // --- Auth Routes ---
      GoRoute(
        path: '/auth/role',
        pageBuilder: (c, s) => _slideTransition(const RoleSelectionScreen()),
      ),
      GoRoute(
        path: '/auth/login',
        pageBuilder: (c, s) => _slideTransition(const LoginScreen()),
      ),
      GoRoute(
        path: '/auth/otp',
        pageBuilder: (c, s) => _slideTransition(const OtpScreen()),
      ),
      GoRoute(
        path: '/auth/register',
        pageBuilder: (c, s) => _slideTransition(const RegisterScreen()),
      ),

      // --- Shell View (Bottom Navigation) ---
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShell(navigationShell: navigationShell),
        branches: [
          // Chaque onglet s'adapte au rôle : le parent cherche une nounou,
          // la nounou gère son activité.
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                pageBuilder: (c, s) => _fadeTransition(
                  ref.read(authProvider).isNanny
                      ? const NannyDashboardScreen()
                      : const HomeScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/search',
                pageBuilder: (c, s) => _fadeTransition(
                  ref.read(authProvider).isNanny
                      ? const AvailableMissionsScreen()
                      : const SearchScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/bookings',
                pageBuilder: (c, s) =>
                    _fadeTransition(const BookingsListScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/chat',
                pageBuilder: (c, s) =>
                    _fadeTransition(const ConversationsScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                // Le dashboard nounou vit désormais dans l'onglet Accueil ;
                // l'onglet Profil donne à tous accès au compte (édition,
                // notifications, déconnexion...).
                pageBuilder: (c, s) =>
                    _fadeTransition(const ParentProfileScreen()),
              ),
            ],
          ),
        ],
      ),

      // --- Full Screen Routes (Push / Slide) ---
      GoRoute(path: '/search/map', builder: (c, s) => const MapScreen()),
      GoRoute(
        path: '/nanny/:id',
        builder: (c, s) => NannyProfileScreen(nannyId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/booking/new/:nannyId',
        builder: (c, s) => BookingScreen(nannyId: s.pathParameters['nannyId']!),
      ),
      GoRoute(
        path: '/booking/:id',
        builder: (c, s) =>
            BookingDetailScreen(bookingId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/booking/:id/review',
        builder: (c, s) =>
            LeaveReviewScreen(bookingId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/booking/confirmation/:id',
        builder: (c, s) =>
            BookingConfirmationScreen(bookingId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/chat/:nannyId',
        builder: (c, s) => ChatScreen(nannyId: s.pathParameters['nannyId']),
      ),
      GoRoute(
        path: '/profile/edit',
        builder: (c, s) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/favorites',
        builder: (c, s) => const FavoritesScreen(),
      ),
      GoRoute(
        path: '/profile/verification',
        builder: (c, s) => const NannyVerificationScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (c, s) => const NotificationsScreen(),
      ),
      GoRoute(path: '/sos', builder: (c, s) => const SosScreen()),

      // --- Missions routes ---
      GoRoute(
        path: '/missions/publish',
        builder: (c, s) => const PublishAnnouncementScreen(),
      ),
      GoRoute(
        path: '/missions/available',
        builder: (c, s) => const AvailableMissionsScreen(),
      ),
      GoRoute(
        path: '/missions/my-applications',
        builder: (c, s) => const MyApplicationsScreen(),
      ),
      GoRoute(
        path: '/missions/:missionId/candidatures',
        builder: (c, s) =>
            CandidaturesScreen(missionId: s.pathParameters['missionId']!),
      ),
      GoRoute(
        path: '/missions/:missionId/tracking',
        builder: (c, s) =>
            MissionTrackingScreen(missionId: s.pathParameters['missionId']!),
      ),
      GoRoute(
        path: '/missions/:missionId/delay',
        builder: (c, s) => DelayScreen(
          missionId: s.pathParameters['missionId']!,
          hourlyRate:
              double.tryParse(s.uri.queryParameters['rate'] ?? '') ??
              AppConstants.defaultHourlyRate,
        ),
      ),
      GoRoute(
        path: '/video-call',
        builder: (c, s) => VideoCallScreen(
          peerName: s.uri.queryParameters['name'] ?? 'Utilisateur',
        ),
      ),
      GoRoute(path: '/wallet', builder: (c, s) => const WalletScreen()),
    ],
  );
});

// Helpers for transitions
CustomTransitionPage _fadeTransition(Widget child) {
  return CustomTransitionPage(
    transitionDuration: const Duration(milliseconds: 600),
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
        child: child,
      );
    },
  );
}

CustomTransitionPage _slideTransition(Widget child) {
  return CustomTransitionPage(
    transitionDuration: const Duration(milliseconds: 350),
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final slide = Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
      return SlideTransition(position: slide, child: child);
    },
  );
}
