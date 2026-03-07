import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/splash/screens/splash_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/auth/screens/role_selection_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/otp_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/home/screens/main_shell.dart';
import '../../features/search/screens/search_screen.dart';
import '../../features/chat/screens/conversations_screen.dart';
import '../../features/notifications/screens/notifications_screen.dart';
import '../../features/profile/screens/parent_profile_screen.dart';
import '../../features/nanny_profile/screens/nanny_profile_screen.dart';
import '../../features/booking/screens/booking_screen.dart';
import '../../features/booking/screens/bookings_list_screen.dart';
import '../../features/booking/screens/booking_detail_screen.dart';
import '../../features/booking/screens/booking_confirmation_screen.dart';
import '../../features/chat/screens/chat_screen.dart';
import '../../features/profile/screens/edit_profile_screen.dart';
import '../../features/profile/screens/nanny_dashboard_screen.dart';
import '../../features/search/screens/map_screen.dart';
import '../../features/sos/screens/sos_screen.dart';
import 'app_router_observer.dart';

// Mock Auth State (persisted via SharedPreferences)
bool _isAuthenticated = false;
String _userRole = 'parent'; // 'parent' | 'nanny'

/// Load auth state from SharedPreferences (call before runApp).
Future<void> loadAuthState() async {
  final prefs = await SharedPreferences.getInstance();
  _isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
  _userRole = prefs.getString('userRole') ?? 'parent';
}

/// Call this after a successful login/registration.
Future<void> setAuthenticated(bool value) async {
  _isAuthenticated = value;
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isAuthenticated', value);
}

/// Call this when the user's role is determined (during registration/login).
Future<void> setUserRole(String role) async {
  _userRole = role;
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('userRole', role);
}

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  observers: [AppRouterObserver()],
  redirect: (context, state) {
    final bool isAuthPath =
        state.uri.path.startsWith('/auth') ||
        state.uri.path == '/splash' ||
        state.uri.path == '/onboarding';

    if (!_isAuthenticated && !isAuthPath) {
      return '/onboarding';
    }
    return null;
  },
  routes: [
    // --- Public Routes ---
    GoRoute(path: '/', builder: (c, s) => const SplashScreen()),
    GoRoute(path: '/onboarding', builder: (c, s) => const OnboardingScreen()),

    // --- Auth Routes ---
    GoRoute(path: '/auth/role', builder: (c, s) => const RoleSelectionScreen()),
    GoRoute(path: '/auth/login', builder: (c, s) => const LoginScreen()),
    GoRoute(path: '/auth/otp', builder: (c, s) => const OtpScreen()),
    GoRoute(path: '/auth/register', builder: (c, s) => const RegisterScreen()),

    // --- Shell View (Bottom Navigation) ---
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          MainShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              pageBuilder: (c, s) => _fadeTransition(const HomeScreen()),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/search',
              pageBuilder: (c, s) => _fadeTransition(const SearchScreen()),
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
              pageBuilder: (c, s) {
                final bool isNanny = _userRole == 'nanny';
                return _fadeTransition(
                  isNanny
                      ? const NannyDashboardScreen()
                      : const ParentProfileScreen(),
                );
              },
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
      path: '/booking/confirmation/:id',
      builder: (c, s) =>
          BookingConfirmationScreen(bookingId: s.pathParameters['id']!),
    ),
    GoRoute(
      path: '/chat/:conversationId',
      builder: (c, s) =>
          ChatScreen(nannyId: s.pathParameters['conversationId']),
    ),
    GoRoute(
      path: '/profile/edit',
      builder: (c, s) => const EditProfileScreen(),
    ),
    GoRoute(
      path: '/notifications',
      builder: (c, s) => const NotificationsScreen(),
    ),
    GoRoute(path: '/sos', builder: (c, s) => const SosScreen()),
  ],
);

// Helpers for transitions
CustomTransitionPage _fadeTransition(Widget child) {
  return CustomTransitionPage(
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}
