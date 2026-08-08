import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:media_kit/media_kit.dart';
import 'core/network/dio_client.dart';
import 'core/routing/app_router.dart';
import 'core/theme/colors.dart';
import 'core/theme/theme_data.dart';
import 'data/models/content_model.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/content_repository.dart';
import 'data/repositories/subscription_repository.dart';
import 'data/repositories/watchlist_repository.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/home/bloc/content_bloc.dart';
import 'features/watchlist/bloc/watchlist_bloc.dart';

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Catch framework-level Flutter errors
      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.presentError(details);
        debugPrint('[FlutterError] ${details.exceptionAsString()}');
      };

      // Custom branded fallback for widget build errors
      ErrorWidget.builder = (FlutterErrorDetails details) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          home: Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      LucideIcons.alertTriangle,
                      color: AppColors.primary,
                      size: 64,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Something went wrong',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Please restart the app to continue watching.',
                      style: TextStyle(color: AppColors.muted, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      };

      // Initialize MediaKit for cross-platform video playback
      MediaKit.ensureInitialized();

      // Initialize Hive storage and register Type Adapters
      await Hive.initFlutter();
      Hive.registerAdapter(ContentModelAdapter());

      final dioClient = DioClient(baseUrl: 'http://10.0.2.2:8000');
      final authRepository = RealAuthRepository(dioClient: dioClient);
      final contentRepository = RealContentRepository(dioClient: dioClient);
      final watchlistRepository = RealWatchlistRepository(dioClient: dioClient);
      final subscriptionRepository = RealSubscriptionRepository(
        dioClient: dioClient,
      );

      runApp(
        MultiRepositoryProvider(
          providers: [
            RepositoryProvider<AuthRepository>.value(value: authRepository),
            RepositoryProvider<ContentRepository>.value(
              value: contentRepository,
            ),
            RepositoryProvider<WatchlistRepository>.value(
              value: watchlistRepository,
            ),
            RepositoryProvider<SubscriptionRepository>.value(
              value: subscriptionRepository,
            ),
          ],
          child: MultiBlocProvider(
            providers: [
              BlocProvider<AuthBloc>(
                create: (context) => AuthBloc(authRepository: authRepository),
              ),
              BlocProvider<ContentBloc>(
                create: (context) =>
                    ContentBloc(contentRepository: contentRepository),
              ),
              BlocProvider<WatchlistBloc>(
                create: (context) =>
                    WatchlistBloc(watchlistRepository: watchlistRepository),
              ),
            ],
            child: const DoomOttApp(),
          ),
        ),
      );
    },
    (error, stackTrace) {
      debugPrint('[AsyncZoneError] $error\n$stackTrace');
    },
  );
}

class DoomOttApp extends StatelessWidget {
  const DoomOttApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'DOOM OTT',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: AppRouter.router,
    );
  }
}
