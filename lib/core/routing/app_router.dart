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
import '../../features/browse/live_tv_screen.dart';
import '../../features/browse/browse_screen.dart';
import '../../features/search/search_screen.dart';
import '../../features/watchlist/watchlist_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/profile/profile_picker_screen.dart';
import '../../features/profile/edit_profile_screen.dart';
import '../../features/settings/notifications_screen.dart';
import '../../features/profile/parental_controls_screen.dart';
import '../../features/reviews/reviews_screen.dart';
import '../../features/legal/legal_screen.dart';
import '../../features/legal/faq_screen.dart';
import '../../features/legal/privacy_screen.dart';
import '../../features/legal/terms_screen.dart';
import '../../features/legal/about_screen.dart';
import '../../features/subscription/subscription_screen.dart';
import '../../features/payment/payment_screen.dart';
import '../../features/payment/payment_history_screen.dart';
import '../../features/content_detail/content_detail_screen.dart';
import '../../features/player/player_screen.dart';
import '../../features/home/navigation_shell.dart';
import '../../features/style_guide/style_guide_screen.dart';
import '../../features/shorts/shorts_reel_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/content_repository.dart';
import '../../features/content_detail/bloc/content_detail_bloc.dart';

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
          // Live TV Tab
          StatefulShellBranch(
            navigatorKey: _browseNavigatorKey,
            routes: [
              GoRoute(
                path: '/live-tv',
                builder: (context, state) => const LiveTvScreen(),
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
          // My List Tab
          StatefulShellBranch(
            navigatorKey: _watchlistNavigatorKey,
            routes: [
              GoRoute(
                path: '/my-list',
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
          final planName =
              extra['planName'] as String? ??
              state.uri.queryParameters['planName'] ??
              'Monthly Basic';
          final price =
              (extra['price'] as num?)?.toDouble() ??
              double.tryParse(state.uri.queryParameters['price'] ?? '199') ??
              199.0;
          return PaymentScreen(planName: planName, price: price);
        },
      ),
      GoRoute(
        path: '/content-detail/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          // Scope ContentDetailBloc locally so state is created fresh per content item details load
          return BlocProvider<ContentDetailBloc>(
            create: (context) => ContentDetailBloc(
              contentRepository: context.read<ContentRepository>(),
            ),
            child: ContentDetailScreen(contentId: id),
          );
        },
      ),
      GoRoute(
        path: '/player/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          // Scope ContentDetailBloc locally so state is created fresh per video playback load
          return BlocProvider<ContentDetailBloc>(
            create: (context) => ContentDetailBloc(
              contentRepository: context.read<ContentRepository>(),
            ),
            child: PlayerScreen(contentId: id),
          );
        },
      ),
      GoRoute(
        path: '/shorts/:startId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final startId = state.pathParameters['startId']!;
          return ShortsReelScreen(startId: startId);
        },
      ),
      GoRoute(
        path: '/browse',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final genre = state.uri.queryParameters['genre'];
          return BrowseScreen(initialGenre: genre);
        },
      ),
      GoRoute(
        path: '/style-guide',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const StyleGuideScreen(),
      ),
      GoRoute(
        path: '/payment-history',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PaymentHistoryScreen(),
      ),
      GoRoute(
        path: '/profile-picker',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final manage = state.uri.queryParameters['manage'] == 'true';
          return ProfilePickerScreen(manageMode: manage);
        },
      ),
      GoRoute(
        path: '/edit-profile',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.uri.queryParameters['id'];
          return EditProfileScreen(profileId: id);
        },
      ),
      GoRoute(
        path: '/notifications',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/parental-controls',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.uri.queryParameters['id'] ?? 'p_1';
          return ParentalControlsScreen(profileId: id);
        },
      ),
      GoRoute(
        path: '/reviews',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.uri.queryParameters['id'] ?? '1';
          final title = state.uri.queryParameters['title'] ?? 'Title';
          return ReviewsScreen(contentId: id, contentTitle: title);
        },
      ),
      GoRoute(
        path: '/help-faq',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const FaqScreen(),
      ),
      GoRoute(
        path: '/privacy-policy',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PrivacyScreen(),
      ),
      GoRoute(
        path: '/terms-conditions',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const TermsScreen(),
      ),
      GoRoute(
        path: '/about-us',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AboutScreen(),
      ),
    ],
  );
}
