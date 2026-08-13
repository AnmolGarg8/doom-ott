import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/content_repository.dart';
import 'content_event.dart';
import 'content_state.dart';

class ContentBloc extends Bloc<ContentEvent, ContentState> {
  final ContentRepository contentRepository;

  ContentBloc({required this.contentRepository}) : super(ContentInitial()) {
    on<LoadHomeContent>(_onLoadHomeContent);
  }

  Future<void> _onLoadHomeContent(
    LoadHomeContent event,
    Emitter<ContentState> emit,
  ) async {
    // 1. Instant First Paint: check cached entries
    final cachedFeatured = await contentRepository.getCachedFeaturedContent();
    final cachedTrending = await contentRepository.getCachedTrendingContent();
    final cachedContinue =
        await contentRepository.getContinueWatchingContent();
    final cachedMovies = await contentRepository.getCachedMovies();
    final cachedTvShows = await contentRepository.getCachedTVShows();
    final cachedShorts = await contentRepository.getCachedShorts();

    final hasCachedData = cachedFeatured.isNotEmpty ||
        cachedTrending.isNotEmpty ||
        cachedMovies.isNotEmpty ||
        cachedTvShows.isNotEmpty;

    if (hasCachedData) {
      emit(
        HomeContentLoaded(
          featured: cachedFeatured,
          trending: cachedTrending,
          continueWatching: cachedContinue,
          movies: cachedMovies,
          tvShows: cachedTvShows,
          shorts: cachedShorts,
        ),
      );
    } else {
      emit(ContentLoading());
    }

    // 2. Fresh API call always kicked off right after (Stale-While-Revalidate)
    try {
      final featured = await contentRepository.getFeaturedContent();
      final trending = await contentRepository.getTrendingContent();
      final continueWatching =
          await contentRepository.getContinueWatchingContent();
      final allMoviesAndShorts = await contentRepository.getMovies();
      final movies =
          allMoviesAndShorts.where((e) => e.type == 'movie').toList();
      final shorts =
          allMoviesAndShorts.where((e) => e.type == 'short').toList();
      final tvShows = await contentRepository.getTVShows();
      emit(
        HomeContentLoaded(
          featured: featured,
          trending: trending,
          continueWatching: continueWatching,
          movies: movies,
          tvShows: tvShows,
          shorts: shorts,
        ),
      );
    } catch (e) {
      if (!hasCachedData) {
        emit(ContentError(e.toString()));
      }
    }
  }
}
