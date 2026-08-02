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
    emit(ContentLoading());
    try {
      final featured = await contentRepository.getFeaturedContent();
      final trending = await contentRepository.getTrendingContent();
      final continueWatching = await contentRepository
          .getContinueWatchingContent();
      final movies = await contentRepository.getMovies();
      final tvShows = await contentRepository.getTVShows();
      emit(
        HomeContentLoaded(
          featured: featured,
          trending: trending,
          continueWatching: continueWatching,
          movies: movies,
          tvShows: tvShows,
        ),
      );
    } catch (e) {
      emit(ContentError(e.toString()));
    }
  }
}
