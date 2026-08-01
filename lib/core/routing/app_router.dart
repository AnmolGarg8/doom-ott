import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/auth/auth_landing_screen.dart';
import '../../features/auth/phone_entry_screen.dart';
import '../../features/auth/otp_verification_screen.dart';
import '../../features/auth/email_entry_screen.dart';
import '../../features/auth/profile_setup_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/browse/browse_screen.dart';
import '../../features/search/search_screen.dart';
import '../../features/watchlist/watchlist_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/legal/legal_screen.dart';
import '../../features/subscription/subscription_screen.dart';
import '../../features/payment/payment_screen.dart';
import '../../features/content_detail/content_detail_screen.dart';
import '../../features/player/player_screen.dart';
import '../../features/home/navigation_shell.dart';
import '../../features/style_guide/style_guide_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _homeNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _browseNavigatorKey =
    GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _searchNavigatorKey =
    GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _watchlistNavigatorKey =
    GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _profileNavigatorKey =
    GlobalKey<NavigatorState>();

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      // Splash
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      // Onboarding
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      // Auth
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthLandingScreen(),
        routes: [
          GoRoute(
            path: 'phone',
            builder: (context, state) => const PhoneEntryScreen(),
          ),
          GoRoute(
            path: 'otp',
            builder: (context, state) => const OtpVerificationScreen(),
          ),
          GoRoute(
            path: 'email',
            builder: (context, state) => const EmailEntryScreen(),
          ),
          GoRoute(
            path: 'profile-setup',
            builder: (context, state) => const ProfileSetupScreen(),
          ),
        ],
      ),
      // Main navigation tabs shell
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return NavigationShell(navigationShell: navigationShell);
        },
        branches: [
          // Home Tab
          StatefulShellBranch(
            navigatorKey: _homeNavigatorKey,
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          // Browse Tab
          StatefulShellBranch(
            navigatorKey: _browseNavigatorKey,
            routes: [
              GoRoute(
                path: '/browse',
                builder: (context, state) => const BrowseScreen(),
              ),
            ],
          ),
          // Search Tab
          StatefulShellBranch(
            navigatorKey: _searchNavigatorKey,
            routes: [
              GoRoute(
                path: '/search',
                builder: (context, state) => const SearchScreen(),
              ),
            ],
          ),
          // Watchlist Tab
          StatefulShellBranch(
            navigatorKey: _watchlistNavigatorKey,
            routes: [
              GoRoute(
                path: '/watchlist',
                builder: (context, state) => const WatchlistScreen(),
              ),
            ],
          ),
          // Profile Tab
          StatefulShellBranch(
            navigatorKey: _profileNavigatorKey,
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      // Full screen overlays pushed to root stack
      GoRoute(
        path: '/settings',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/legal',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const LegalScreen(),
      ),
      GoRoute(
        path: '/subscription',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SubscriptionScreen(),
      ),
      GoRoute(
        path: '/payment',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return PaymentScreen(planDetails: extra);
        },
      ),
      GoRoute(
        path: '/content-detail/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ContentDetailScreen(contentId: id);
        },
      ),
      GoRoute(
        path: '/player/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return PlayerScreen(contentId: id);
        },
      ),
      GoRoute(
        path: '/style-guide',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const StyleGuideScreen(),
      ),
    ],
  );
}
