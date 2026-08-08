import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:media_kit/media_kit.dart';
import 'core/network/dio_client.dart';
import 'core/routing/app_router.dart';
import 'core/theme/theme_data.dart';
import 'data/models/content_model.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/content_repository.dart';
import 'data/repositories/watchlist_repository.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/home/bloc/content_bloc.dart';
import 'features/watchlist/bloc/watchlist_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize MediaKit for cross-platform video playback
  MediaKit.ensureInitialized();

  // Initialize Hive storage and register Type Adapters
  await Hive.initFlutter();
  Hive.registerAdapter(ContentModelAdapter());

  final dioClient = DioClient(baseUrl: 'http://10.0.2.2:8000');
  final authRepository = RealAuthRepository(dioClient: dioClient);
  final contentRepository = RealContentRepository(dioClient: dioClient);
  final watchlistRepository = RealWatchlistRepository(dioClient: dioClient);

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(value: authRepository),
        RepositoryProvider<ContentRepository>.value(value: contentRepository),
        RepositoryProvider<WatchlistRepository>.value(
          value: watchlistRepository,
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
