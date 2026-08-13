import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/content_repository.dart';
import 'content_detail_event.dart';
import 'content_detail_state.dart';

class ContentDetailBloc extends Bloc<ContentDetailEvent, ContentDetailState> {
  final ContentRepository contentRepository;

  ContentDetailBloc({required this.contentRepository})
    : super(ContentDetailInitial()) {
    on<LoadContentDetail>(_onLoadContentDetail);
  }

  Future<void> _onLoadContentDetail(
    LoadContentDetail event,
    Emitter<ContentDetailState> emit,
  ) async {
    // 1. Instant First Paint: check cached content detail
    final cached = await contentRepository.getCachedContentById(event.id);
    if (cached != null) {
      emit(ContentDetailLoaded(cached, similar: const []));
    } else if (state is! ContentDetailLoaded) {
      emit(ContentDetailLoading());
    }

    // 2. Fresh API call always kicked off right after (Stale-While-Revalidate)
    try {
      final content = await contentRepository.getContentById(event.id);
      if (content != null) {
        final similar = await contentRepository.getSimilarContent(event.id);
        emit(ContentDetailLoaded(content, similar: similar));
      } else if (cached == null) {
        emit(ContentDetailError('Content not found'));
      }
    } catch (e) {
      if (cached == null) {
        emit(ContentDetailError(e.toString()));
      }
    }
  }
}
